import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tekartik_stripe_api/stripe_api.dart';
import 'package:test/test.dart';

void main() {
  test('stripeApiErrorMessage', () async {
    var api = StripeApi(
      credentials: StripeApiCredentials(secretKey: 'sk_test_fake'),
      baseClient: MockClient(
        (request) async => http.Response(
          jsonEncode({
            'error': {
              'message': 'No such product: prod_x',
              'type': 'invalid_request_error',
            },
          }),
          404,
          request: request,
        ),
      ),
      baseUri: Uri.parse('http://localhost:1/v1'),
    );
    try {
      await api.getProduct('prod_x');
      fail('should fail');
    } catch (e) {
      expect(stripeApiErrorMessage(e), '404: No such product: prod_x');
    } finally {
      await api.close();
    }
    expect(stripeApiErrorMessage(StateError('x')), 'Bad state: x');
  });
}
