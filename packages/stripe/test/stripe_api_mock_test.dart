import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tekartik_http/http_client.dart';
import 'package:tekartik_stripe_api/stripe_api.dart';
import 'package:test/test.dart';

void main() {
  group('mock client', () {
    late List<http.Request> requests;
    late StripeApi api;
    late http.Response Function(http.Request request) handler;

    setUp(() {
      requests = [];
      api = StripeApi(
        credentials: StripeApiCredentials(secretKey: 'sk_test_fake'),
        baseClient: MockClient((request) async {
          requests.add(request);
          return handler(request);
        }),
        baseUri: Uri.parse('http://localhost:1/v1'),
      );
    });
    tearDown(() async {
      await api.close();
    });

    test('success', () async {
      handler = (request) => http.Response.bytes(
        utf8.encode(
          jsonEncode({'id': 'price_1', 'nickname': 'accént', 'active': true}),
        ),
        200,
        headers: {'content-type': 'application/json'},
        request: request,
      );
      var price = await api.updatePrice(
        'price_1',
        StripeApiPriceUpdate()..active.v = false,
      );
      expect(price.id.v, 'price_1');
      expect(price.nickname.v, 'accént');
      var request = requests.single;
      expect(request.method, 'POST');
      expect(request.url.toString(), 'http://localhost:1/v1/prices/price_1');
      expect(
        request.headers['content-type'],
        'application/x-www-form-urlencoded',
      );
      expect(request.headers['authorization'], startsWith('Basic '));
      expect(request.bodyFields, {'active': 'false'});

      price = await api.getPrice('price_1');
      expect(price.id.v, 'price_1');
      expect(requests.last.method, 'GET');
      expect(requests.last.body, isEmpty);
    });

    test('error', () async {
      var errorBody = jsonEncode({
        'error': {
          'type': 'invalid_request_error',
          'message': 'No such price: price_x',
        },
      });
      handler = (request) => http.Response(
        errorBody,
        404,
        headers: {'content-type': 'application/json'},
        request: request,
      );
      Future<void> expectHttp404(Future<Object?> future) async {
        try {
          await future;
          fail('should fail');
        } on HttpClientException catch (e) {
          expect(e.statusCode, 404);
          expect(e.response.body, errorBody);
        }
      }

      // Used to return an empty model.
      await expectHttp404(
        api.updatePrice('price_x', StripeApiPriceUpdate()..active.v = false),
      );
      await expectHttp404(api.getPrice('price_x'));
      await expectHttp404(
        api.updatePaymentLink(
          'plink_x',
          StripeApiPaymentLinkUpdate()..active.v = false,
        ),
      );
      expect(requests, hasLength(3));
    });
  });
}
