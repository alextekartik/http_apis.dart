import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tekartik_stripe_api/stripe_api.dart';
import 'package:test/test.dart';

void main() {
  group('review regression', () {
    late List<http.Request> requests;
    late StripeApi api;

    setUp(() {
      requests = [];
      api = StripeApi(
        credentials: StripeApiCredentials(secretKey: 'sk_test_fake'),
        baseClient: MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode({'id': 'x'}),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }),
        baseUri: Uri.parse('http://localhost:1/v1'),
      );
    });
    tearDown(() async {
      await api.close();
    });

    test('an id cannot reach another endpoint', () async {
      for (var id in ['', '.', '..']) {
        await expectLater(
          api.cancelSubscription(id),
          throwsArgumentError,
          reason: id,
        );
      }
      // Dot segments inside an id stay in one encoded segment.
      await api.cancelSubscription('../customers/cus_victim');
      await api.getCheckoutSession('cs_1/../../../v1/customers/cus_victim');
      await api.getPrice('%2E%2E');
      var sessionSegment = 'cs_1%2F..%2F..%2F..%2Fv1%2Fcustomers%2Fcus_victim';
      expect(requests.map((request) => '${request.method} ${request.url}'), [
        'DELETE http://localhost:1/v1/subscriptions/..%2Fcustomers%2Fcus_victim',
        'GET http://localhost:1/v1/checkout/sessions/$sessionSegment',
        'GET http://localhost:1/v1/prices/%252E%252E',
      ]);
      // A regular id is unchanged.
      await api.getSubscription('sub_1AbC');
      expect(
        requests.last.url.toString(),
        'http://localhost:1/v1/subscriptions/sub_1AbC',
      );
    });
  });

  test('an empty webhook secret never verifies', () {
    var payload = '{"type":"checkout.session.completed"}';
    var now = DateTime.now();
    var timestamp = now.millisecondsSinceEpoch ~/ 1000;
    var forged = StripeWebhookSignature.header(
      payload: payload,
      timestamp: timestamp,
      secret: '',
    );
    expect(
      StripeWebhookSignature.verify(
        payload: payload,
        header: forged,
        secret: '',
        now: now,
      ),
      isFalse,
    );
    // A real secret still verifies.
    var header = StripeWebhookSignature.header(
      payload: payload,
      timestamp: timestamp,
      secret: 'whsec_fake',
    );
    expect(
      StripeWebhookSignature.verify(
        payload: payload,
        header: header,
        secret: 'whsec_fake',
        now: now,
      ),
      isTrue,
    );
  });

  test('a plain key next to enc is not quoted in the error', () {
    var secretKey = 'sk_live_0123456789abcdefghij_SECRET';
    var map = StripeApiCredentials(secretKey: secretKey).toMapEnc();
    var plainKey = 'sk_live_0123456789abcdefghij_OTHER_SECRET';
    expect(
      () => StripeApiCredentials.fromMapEnc({...map, 'secretKey': plainKey}),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(isNot(contains('0123456789')), contains('sk_live_...')),
        ),
      ),
    );
  });
}
