import 'dart:io';

import 'package:tekartik_http/http_client.dart';
import 'package:tekartik_stripe_api/stripe_api.dart';

/// Lists the active prices of a Stripe account.
///
/// ```sh
/// STRIPE_SECRET_KEY=sk_test_... dart run example/main.dart
/// ```
Future<void> main() async {
  var secretKey = Platform.environment['STRIPE_SECRET_KEY'];
  if (secretKey == null || secretKey.isEmpty) {
    stderr.writeln('Set STRIPE_SECRET_KEY (a test key, sk_test_...)');
    exitCode = 64;
    return;
  }
  var stripeApi = StripeApi(
    credentials: StripeApiCredentials(secretKey: secretKey),
  );
  try {
    var prices = await stripeApi.listPrices(
      StripeApiPriceListOptions()
        ..active.v = true
        ..limit.v = 10,
    );
    for (var price in prices.data.v ?? <StripeApiPrice>[]) {
      // Amounts are in cents.
      // ignore: avoid_print
      print(
        '${price.id.v} ${price.amount.v} ${price.currency.v} '
        '${price.lookupKey.v ?? ''}',
      );
    }
  } on HttpClientException catch (e) {
    // Stripe explains the error in the body.
    stderr.writeln('Stripe error ${e.statusCode}: ${e.response.body}');
    exitCode = 1;
  } finally {
    await stripeApi.close();
  }
}
