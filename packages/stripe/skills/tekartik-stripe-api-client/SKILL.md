---
name: tekartik-stripe-api-client
description: >-
  Use when calling the Stripe REST API v1 from server side Dart with
  tekartik_stripe_api: StripeApi, StripeApiCredentials, createProduct,
  getProduct, listProducts, createPrice, updatePrice, getPrice,
  createPaymentLink, updatePaymentLink, getPaymentLink, and the cv models
  StripeApiProduct, StripeApiProductCreate, StripeApiProductList,
  StripeApiProductListOptions, StripeApiPrice, StripeApiPriceCreate,
  StripeApiPriceUpdate, StringApiPriceRecurring, StripeApiPaymentLink,
  StripeApiPaymentLinkCreate, StripeApiPaymentLinkUpdate,
  StripeApiPaymentLinkLineItem, StripeApiPaymentLinkSubscriptionData,
  uriWith, metadata, stripeCurrencyEuro, stripePriceRecurringInterval*,
  toStripeApiBodyFields, initStripeApiModels, debugStripeApi, and testing
  against a memory http server; subscriptions: listPrices
  (StripeApiPriceListOptions, lookup keys), createCheckoutSession
  (StripeApiCheckoutSessionCreate, mode subscription), the customer portal
  (createBillingPortalSession, createBillingPortalConfiguration),
  getSubscription / updateSubscription / cancelSubscription
  (StripeApiSubscription, cancel_at_period_end, currentPeriodEndSeconds),
  webhook endpoints (createWebhookEndpoint, listWebhookEndpoints), webhook
  events (StripeApiEvent, stripeEvent* constants) and their signature
  (StripeWebhookSignature.verify).
---

# Stripe products, prices and payment links (tekartik_stripe_api)

`tekartik_stripe_api` is a small subset of the Stripe REST API v1
(`https://api.stripe.com/v1`) covering products, prices and payment links.
Requests are `cv` models flattened into `application/x-www-form-urlencoded`
body fields; responses are parsed back into `cv` models, so every field is
read and written through `.v`.

## Guidelines

* Dependency (git, not on pub.dev); add `cv` too, you build the models:
  ```yaml
  dependencies:
    tekartik_stripe_api:
      git:
        url: https://github.com/alextekartik/http_apis.dart
        path: packages/stripe
      version: '>=0.1.0'
    cv: '>=1.1.0+4'
  ```
* Single import: `package:tekartik_stripe_api/stripe_api.dart`. Never import
  `package:tekartik_stripe_api/src/...` from application code (`formatAmount`
  and the `stripePriceType*` constants live there and are not exported).
* `StripeApi(credentials: StripeApiCredentials(secretKey: '<stripe-secret-key>'))`.
  The key is sent as HTTP basic auth (key as user, empty password), exactly
  like Stripe's `-u sk_test_xxx:`. `StripeApiCredentials` also takes a
  `publishableKey` and asserts at least one of the two is set; the secret key
  wins when both are given, and all the endpoints here need it, so the
  publishable key alone is only useful for a client-side instance built with
  `credentials.withoutSecretKey()`.
* **Server side only**: never embed a secret key in a Flutter app, a web app
  or a repo. Read it from an environment variable or a secret manager, use
  `sk_test_...` while developing, and call `await stripeApi.close()` when done.
* `credentials.toMapEnc()` gives an obfuscated map (`type`
  `stripe_credentials_enc`, the publishable key slightly obfuscated and the
  secret key kind in clear, the whole aes encrypted in `enc`, a random
  `password` next to it) that `StripeApiCredentials.fromMapEnc(map)` reads
  back; `toJsonEnc()` is that map as an indented json, a dart map literal to
  paste as it is in a `fromMapEnc({...})` call. It only hides the keys from a
  glance, a grep or a secret scanner: keep it in a git ignored file or a
  private repo.
* Optional constructor parameters: `baseUri` (point at a fake server in
  tests) and `baseClient` (a `package:http` `Client` wrapped by the basic
  auth client - a mock or a memory client).
* Endpoints, all `Future`s of a single model: `createProduct`, `getProduct`,
  `listProducts`; `createPrice`, `updatePrice(priceId, options)`, `getPrice`;
  `createPaymentLink`, `updatePaymentLink(paymentLinkId, options)`,
  `getPaymentLink`; `listPrices`; `createCheckoutSession`,
  `getCheckoutSession`; `createBillingPortalSession`,
  `createBillingPortalConfiguration`, `listBillingPortalConfigurations`;
  `getSubscription`, `updateSubscription`, `cancelSubscription` (DELETE);
  `createWebhookEndpoint`, `listWebhookEndpoints`, `deleteWebhookEndpoint`.
  Anything else (customers, refunds, invoices) is not wrapped: call the
  Stripe API yourself.
* Subscriptions: recurring prices with a `lookupKey` (find them back with
  `listPrices(StripeApiPriceListOptions()..lookupKeys.v = [...])`), a
  Checkout Session in `stripeCheckoutModeSubscription` mode
  (`clientReferenceId` = your user id, `subscriptionData.metadata`,
  `successUrl` / `cancelUrl`), then a webhook: verify the raw body with
  `StripeWebhookSignature.verify(payload:, header: <Stripe-Signature>,
  secret: <whsec_...>)`, parse `StripeApiEvent` and its `object`
  (`StripeApiCheckoutSession`, `StripeApiSubscription`). The period end of a
  subscription moved to its items in the API version 2025-03-31:
  `currentPeriodEndSeconds` reads either. `StripeApiSubscriptionUpdate
  ..cancelAtPeriodEnd.v = true` ends it at the end of the period.
* Typical flow: create a product (`StripeApiProductCreate` with `name`,
  `description`), create a price for it (`StripeApiPriceCreate` with
  `productId` = the product id, `amount` in **cents** as an int, `currency`
  such as `stripeCurrencyEuro`, optional `nickname`, `active`, `metadata`,
  and `recurring` for a subscription), then create a payment link
  (`StripeApiPaymentLinkCreate` with `lineItems`).
* `StringApiPriceRecurring` (yes, `String…`, not `Stripe…`) holds `interval`
  (`stripePriceRecurringIntervalDay` / `…Week` / `…Month` / `…Year`) and
  `intervalCount`. Leave `recurring` unset for a one-time price.
* `StripeApiPaymentLinkCreate.lineItems` is a list of
  `StripeApiPaymentLinkLineItem` (`priceId`, `quantity`, default 1);
  `subscriptionData` (`StripeApiPaymentLinkSubscriptionData.description`) is
  only valid when a line item is recurring; `active` and `metadata` are shared
  with `StripeApiPaymentLinkUpdate`. The response
  `StripeApiPaymentLink` exposes `id`, `url` (the `https://buy.stripe.com/...`
  page) plus the create/update fields; `link.uriWith(email: ..., locale: ...)`
  returns that url with `prefilled_email` and `locale` (`stripeLocaleFr`)
  query parameters.
* Prices are immutable in Stripe: `StripeApiPriceUpdate` only carries
  `nickname`, `active` and `metadata`. To change an amount, create a new price
  and a new payment link, then deactivate the old ones with `active.v = false`.
* `metadata` is a `StripeApiMetadata` (a cv `Model`, i.e.
  `Map<String, Object?>`): `..metadata.v = {'orderId': '123'}` is flattened to
  `metadata[orderId]=123`. Use it to correlate Stripe objects with your own
  ids; it is echoed back on read.
* **There is no error handling in this client.** A 4xx from Stripe is parsed
  like a success, so you get a model whose fields are all null instead of an
  exception. After every call assert on what you need
  (`price.id.v`, `link.url.v`) and treat null as a failure; set the top-level
  `debugStripeApi = true` to print the request uri, the body fields and the
  raw response (never in production, it prints the request payload).
* Only the declared fields survive a round trip: `StripeApiProduct` is
  `id`/`name`/`description`, `StripeApiPrice` is `id`, `nickname`, `active`,
  `productId`, `currency`, `amount`, `recurring`, `metadata`. Everything else
  Stripe returns (`livemode`, `created`, `object`, ...) is dropped silently.
* `listProducts(StripeApiProductListOptions()..limit.v = 100)` returns a
  `StripeApiProductList` with `data` and `hasMore`; paginate by setting
  `startingAfter` to the last id of the previous page.
* Conversion helpers if you build a call by hand: `model.toStripeApiBodyFields()`
  (`CvModelStripeExt`) and `map.toStripeApiBodyFields()` /
  `map.toStripeApiParam()` (`CvModelStripeMapExt`) flatten nested maps and
  lists to `key[sub]` / `key[0]` form fields.
* Tests: the `StripeApi` constructor calls `initStripeApiModels()`; call it
  yourself in a model-only test before any `.cv<StripeApiPrice>()`. To test a
  call, serve the json from an in-memory server (`httpFactoryMemory` from
  `package:tekartik_http/http_memory.dart`) and pass its uri as `baseUri` with
  its client as `baseClient`. Never run a test against a live key.

## Examples

### Product, price and payment link

```dart
import 'dart:io';

import 'package:tekartik_stripe_api/stripe_api.dart';

Future<void> main() async {
  var stripeApi = StripeApi(
    credentials: StripeApiCredentials(
      // sk_test_... while developing, never committed.
      secretKey: Platform.environment['STRIPE_SECRET_KEY']!,
    ),
  );
  try {
    var product = await stripeApi.createProduct(
      StripeApiProductCreate()
        ..name.v = 'Pro plan'
        ..description.v = 'One year of pro features',
    );
    var productId = product.id.v;
    if (productId == null) {
      throw StateError('product creation failed (enable debugStripeApi)');
    }

    var price = await stripeApi.createPrice(
      StripeApiPriceCreate()
        ..productId.v = productId
        ..amount.v = 4900 // 49.00, always in cents
        ..currency.v = stripeCurrencyEuro
        ..nickname.v = 'Pro yearly'
        ..metadata.v = {'planId': 'pro'}
        ..recurring.v = (StringApiPriceRecurring()
          ..interval.v = stripePriceRecurringIntervalYear
          ..intervalCount.v = 1),
    );

    var link = await stripeApi.createPaymentLink(
      StripeApiPaymentLinkCreate()
        ..lineItems.v = [
          StripeApiPaymentLinkLineItem()
            ..priceId.v = price.id.v!
            ..quantity.v = 1,
        ]
        ..metadata.v = {'planId': 'pro'}
        ..subscriptionData.v =
            (StripeApiPaymentLinkSubscriptionData()
              ..description.v = 'Pro plan, billed yearly'),
    );
    print(link.url.v); // https://buy.stripe.com/...
    // Prefilled, localized checkout url for one user.
    print(link.uriWith(email: 'user@example.com', locale: stripeLocaleFr));
  } finally {
    await stripeApi.close();
  }
}
```

### Retiring a price and its payment link

```dart
import 'package:tekartik_stripe_api/stripe_api.dart';

/// A price amount cannot be changed: create the new one, then deactivate.
Future<StripeApiPaymentLink> replacePrice(
  StripeApi stripeApi, {
  required String productId,
  required String oldPriceId,
  required String oldPaymentLinkId,
  required int newAmountCents,
}) async {
  var newPrice = await stripeApi.createPrice(
    StripeApiPriceCreate()
      ..productId.v = productId
      ..amount.v = newAmountCents
      ..currency.v = stripeCurrencyEuro,
  );
  if (newPrice.id.v == null) {
    throw StateError('price creation failed');
  }
  var newLink = await stripeApi.createPaymentLink(
    StripeApiPaymentLinkCreate()
      ..lineItems.v = [StripeApiPaymentLinkLineItem()..priceId.v = newPrice.id.v!],
  );

  // Deactivate the old link first, then the old price.
  await stripeApi.updatePaymentLink(
    oldPaymentLinkId,
    StripeApiPaymentLinkUpdate()..active.v = false,
  );
  await stripeApi.updatePrice(
    oldPriceId,
    StripeApiPriceUpdate()
      ..active.v = false
      ..nickname.v = 'replaced by ${newPrice.id.v}',
  );
  return newLink;
}
```

### Listing products page by page

```dart
import 'package:tekartik_stripe_api/stripe_api.dart';

Future<List<StripeApiProduct>> allProducts(StripeApi stripeApi) async {
  var products = <StripeApiProduct>[];
  String? startingAfter;
  while (true) {
    var page = await stripeApi.listProducts(
      StripeApiProductListOptions()
        ..limit.v = 100
        ..startingAfter.v = startingAfter,
    );
    var data = page.data.v ?? <StripeApiProduct>[];
    products.addAll(data);
    if (page.hasMore.v != true || data.isEmpty) {
      return products;
    }
    startingAfter = data.last.id.v;
  }
}
```

### Test against an in-memory stripe server

```dart
import 'package:cv/cv_json.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_stripe_api/stripe_api.dart';
import 'package:test/test.dart';

void main() {
  test('createPrice', () async {
    var httpFactory = httpFactoryMemory;
    var server = await httpFactory.server.bind(InternetAddress.anyIPv4, 1);
    var client = httpFactory.client.newClient();
    var stripeApi = StripeApi(
      credentials: StripeApiCredentials(secretKey: 'test-secret-key'),
      baseUri: httpServerGetUri(server),
      baseClient: client,
    );
    server.listen((request) {
      var path = request.uri.path;
      if (path == '/prices') {
        request.response
          ..write(
            (StripeApiPrice()
                  ..id.v = 'price_1'
                  ..amount.v = 1000
                  ..currency.v = stripeCurrencyEuro)
                .toJson(),
          )
          ..close();
      } else {
        request.response.close();
      }
    });

    var price = await stripeApi.createPrice(
      StripeApiPriceCreate()
        ..productId.v = 'prod_1'
        ..amount.v = 1000
        ..currency.v = stripeCurrencyEuro,
    );
    expect(price.id.v, 'price_1');

    await stripeApi.close();
    client.close();
    await server.close();
  });
}
```

### Flattened body fields, when you need to see the wire format

```dart
import 'package:tekartik_stripe_api/stripe_api.dart';

void main() {
  initStripeApiModels(); // not needed once a StripeApi was created
  var create = StripeApiPriceCreate()
    ..productId.v = 'prod_1'
    ..amount.v = 1000
    ..currency.v = stripeCurrencyEuro
    ..metadata.v = {'meta_1': 'value 1'}
    ..recurring.v = (StringApiPriceRecurring()
      ..interval.v = stripePriceRecurringIntervalDay
      ..intervalCount.v = 1);
  print(create.toStripeApiBodyFields());
  // {product: prod_1, unit_amount: 1000, currency: eur,
  //  recurring[interval]: day, recurring[interval_count]: 1,
  //  metadata[meta_1]: value 1}
}
```
