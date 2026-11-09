# tekartik_stripe_api

A small typed client of the [Stripe REST API v1](https://docs.stripe.com/api)
for server side Dart: products, prices, payment links, Checkout Sessions,
the customer portal, subscriptions, invoices, webhook endpoints and the
webhook signature check. Requests and answers are `cv` models (`field.v`).

## Getting started

Git package, not on pub.dev:

```yaml
dependencies:
  tekartik_stripe_api:
    git:
      url: https://github.com/alextekartik/http_apis.dart
      path: packages/stripe
```

A subscription checkout, then its webhook:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:tekartik_stripe_api/stripe_api.dart';

Future<void> main() async {
  // A secret key (sk_test_... while developing), never in the source.
  var stripeApi = StripeApi(
    credentials: StripeApiCredentials(
      secretKey: Platform.environment['STRIPE_SECRET_KEY']!,
    ),
  );
  try {
    var prices = await stripeApi.listPrices(
      StripeApiPriceListOptions()..lookupKeys.v = ['pro_yearly'],
    );
    var session = await stripeApi.createCheckoutSession(
      StripeApiCheckoutSessionCreate()
        ..mode.v = stripeCheckoutModeSubscription
        ..lineItems.v = [
          StripeApiCheckoutLineItem()
            ..priceId.v = prices.data.v!.first.id.v
            ..quantity.v = 1,
        ]
        ..clientReferenceId.v = 'my_user_id'
        ..successUrl.v = 'https://example.com/ok?session={CHECKOUT_SESSION_ID}'
        ..cancelUrl.v = 'https://example.com/cancel',
    );
    print(session.url.v); // open it in the browser
  } finally {
    await stripeApi.close();
  }
}

/// Your webhook handler: [body] is the raw request body, [signature] the
/// `Stripe-Signature` header, [secret] the `whsec_...` of the endpoint.
StripeApiEvent? readEvent(String body, String? signature, String secret) {
  if (!StripeWebhookSignature.verify(
    payload: body,
    header: signature,
    secret: secret,
  )) {
    return null; // answer 400
  }
  return StripeApiEvent()..fromMap(jsonDecode(body) as Map);
}
```

Platforms: any Dart that runs `package:http` (VM, node, Flutter), but a
secret key belongs to a server only: never ship it in an app or a web page.
[example/main.dart](example/main.dart) lists your prices.

## What to use

| Need | API |
|---|---|
| Client | `StripeApi(credentials:, baseClient:, baseUri:)`, `close()` |
| Catalog | `createProduct`/`updateProduct`/`getProduct`/`listProducts`, `createPrice`/`updatePrice`/`getPrice`/`listPrices` (by lookup keys) |
| One time payment page | `createPaymentLink`/`updatePaymentLink`, `link.uriWith(email:, locale:)` |
| Subscription | `createCheckoutSession` (`stripeCheckoutModeSubscription`), `getSubscription`, `updateSubscription` (`cancelAtPeriodEnd`), `cancelSubscription`, `createBillingPortalSession` |
| Invoices | `listInvoices`, `getInvoice` |
| Webhooks | `createWebhookEndpoint`/`listWebhookEndpoints`/`deleteWebhookEndpoint`, `StripeWebhookSignature.verify`, `StripeApiEvent` and the `stripeEvent*` constants |
| Keys in a git ignored file | `credentials.toJsonEnc()`, `StripeApiCredentials.fromMapEnc(map)` |

Anything else (customers, refunds...) is not wrapped.

## Common pitfalls

* Amounts are integers in the smallest unit (`amount.v = 4900` is 49.00
  EUR); a price amount cannot change: create a new price, deactivate the old
  one (`StripeApiPriceUpdate()..active.v = false`).
* A non 2xx answer throws an `HttpClientException`
  (`package:tekartik_http/http_client.dart`): `statusCode`, and
  `response.body` holds Stripe's `error` json.
* No `Idempotency-Key` is sent: retrying a `create...` call after a timeout
  can create the object twice.
* An object id is sent as one path segment; an empty, `.` or `..` id throws
  an `ArgumentError`.
* Webhooks: verify the raw body exactly as received (not a re-encoded json);
  an empty secret never verifies; a timestamp older than 5 minutes is
  refused; Stripe may send an event twice, so dedupe on `event.id.v`.
* Some fields moved in the API version 2025-03-31 (the subscription period
  end, the invoice subscription and tax): `currentPeriodEndSeconds`,
  `subscriptionId`, `subscriptionMetadata` and `taxAmount` read either.
* `debugStripeApi = true` prints every body sent and received, the signing
  secret of a new webhook endpoint included: never in production.
* `toMapEnc` only hides the keys from a glance or a secret scanner (the
  password is in the map): keep the result private.

More: the [tekartik-stripe-api-client skill](skills/tekartik-stripe-api-client/SKILL.md).

## Versioning

Follow [Tekartik git versioning system](https://github.com/tekartik/common.dart/blob/main/doc/tekartik_versioning.md)
