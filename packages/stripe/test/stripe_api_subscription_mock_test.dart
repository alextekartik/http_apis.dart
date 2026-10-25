import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tekartik_stripe_api/stripe_api.dart';
import 'package:test/test.dart';

void main() {
  group('subscriptions, mock client', () {
    late List<http.Request> requests;
    late StripeApi api;
    late Object? Function(http.Request request) answer;

    setUp(() {
      requests = [];
      api = StripeApi(
        credentials: StripeApiCredentials(secretKey: 'sk_test_fake'),
        baseClient: MockClient((request) async {
          requests.add(request);
          return http.Response.bytes(
            utf8.encode(jsonEncode(answer(request))),
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

    test('checkout session', () async {
      answer = (_) => {
        'id': 'cs_test_1',
        'url': 'https://checkout.stripe.com/c/pay/cs_test_1',
        'mode': 'subscription',
        'status': 'open',
      };
      var session = await api.createCheckoutSession(
        StripeApiCheckoutSessionCreate()
          ..mode.v = stripeCheckoutModeSubscription
          ..successUrl.v = 'https://app.example.com/me?plan=done'
          ..cancelUrl.v = 'https://app.example.com/me?plan=cancelled'
          ..clientReferenceId.v = 'uid1'
          ..customerEmail.v = 'ana@example.com'
          ..locale.v = 'fr'
          ..lineItems.v = [
            StripeApiCheckoutLineItem()
              ..priceId.v = 'price_month'
              ..quantity.v = 1,
          ]
          ..subscriptionData.v = (StripeApiCheckoutSubscriptionData()
            ..metadata.v = {'app': 'contaktly_dev', 'uid': 'uid1'})
          ..consentCollection.v = (StripeApiCheckoutConsentCollection()
            ..termsOfService.v = 'required'),
      );
      expect(session.url.v, 'https://checkout.stripe.com/c/pay/cs_test_1');
      var request = requests.single;
      expect(request.method, 'POST');
      expect(request.url.path, '/v1/checkout/sessions');
      expect(request.bodyFields, {
        'mode': 'subscription',
        'success_url': 'https://app.example.com/me?plan=done',
        'cancel_url': 'https://app.example.com/me?plan=cancelled',
        'client_reference_id': 'uid1',
        'customer_email': 'ana@example.com',
        'locale': 'fr',
        'line_items[0][price]': 'price_month',
        'line_items[0][quantity]': '1',
        'subscription_data[metadata][app]': 'contaktly_dev',
        'subscription_data[metadata][uid]': 'uid1',
        'consent_collection[terms_of_service]': 'required',
      });
    });

    test('prices by lookup keys', () async {
      answer = (_) => {
        'object': 'list',
        'has_more': false,
        'data': [
          {
            'id': 'price_1',
            'lookup_key': 'plan_month_eur',
            'unit_amount': 200,
            'currency': 'eur',
            'recurring': {'interval': 'month', 'interval_count': 1},
          },
        ],
      };
      var prices = await api.listPrices(
        StripeApiPriceListOptions()
          ..lookupKeys.v = ['plan_month_eur', 'plan_year_eur']
          ..active.v = true,
      );
      var price = prices.data.v!.single;
      expect(price.lookupKey.v, 'plan_month_eur');
      expect(price.recurring.v!.interval.v, 'month');
      var url = requests.single.url;
      expect(url.path, '/v1/prices');
      expect(url.queryParametersAll['lookup_keys[]'], [
        'plan_month_eur',
        'plan_year_eur',
      ]);
      expect(url.queryParameters['active'], 'true');
      expect(requests.single.method, 'GET');
    });

    test('portal, subscription', () async {
      answer = (_) => {
        'id': 'bps_1',
        'url': 'https://billing.stripe.com/p/session/x',
      };
      var portal = await api.createBillingPortalSession(
        StripeApiBillingPortalSessionCreate()
          ..customer.v = 'cus_1'
          ..returnUrl.v = 'https://app.example.com/me',
      );
      expect(portal.url.v, 'https://billing.stripe.com/p/session/x');
      expect(requests.last.url.path, '/v1/billing_portal/sessions');
      expect(requests.last.bodyFields, {
        'customer': 'cus_1',
        'return_url': 'https://app.example.com/me',
      });

      // The period end on the item (API 2025-03-31 and later).
      Map<String, Object?> subscription({bool onItem = true}) => {
        'id': 'sub_1',
        'customer': 'cus_1',
        'status': 'active',
        'cancel_at_period_end': true,
        if (!onItem) 'current_period_end': 1790000000,
        'metadata': {'uid': 'uid1'},
        'items': {
          'data': [
            {
              if (onItem) 'current_period_end': 1790000000,
              'price': {
                'id': 'price_year',
                'lookup_key': 'plan_year_usd',
                'currency': 'usd',
                'recurring': {'interval': 'year'},
              },
            },
          ],
        },
      };
      for (var onItem in [true, false]) {
        answer = (_) => subscription(onItem: onItem);
        var sub = await api.getSubscription('sub_1');
        expect(sub.currentPeriodEndSeconds, 1790000000);
        expect(sub.priceLookupKey, 'plan_year_usd');
        expect(sub.priceInterval, 'year');
        expect(sub.priceCurrency, 'usd');
        expect(sub.metadata.v, {'uid': 'uid1'});
      }
      await api.updateSubscription(
        'sub_1',
        StripeApiSubscriptionUpdate()..cancelAtPeriodEnd.v = false,
      );
      expect(requests.last.url.path, '/v1/subscriptions/sub_1');
      expect(requests.last.bodyFields, {'cancel_at_period_end': 'false'});
      await api.cancelSubscription('sub_1');
      expect(requests.last.method, 'DELETE');
    });

    test('webhook endpoint', () async {
      answer = (_) => {
        'id': 'we_1',
        'url': 'https://example.com/hook',
        'secret': 'whsec_x',
        'status': 'enabled',
        'enabled_events': ['invoice.paid'],
      };
      var endpoint = await api.createWebhookEndpoint(
        StripeApiWebhookEndpointCreate()
          ..url.v = 'https://example.com/hook'
          ..enabledEvents.v = [
            stripeEventCheckoutSessionCompleted,
            stripeEventInvoicePaid,
          ],
      );
      expect(endpoint.secret.v, 'whsec_x');
      expect(requests.last.bodyFields, {
        'url': 'https://example.com/hook',
        'enabled_events[0]': 'checkout.session.completed',
        'enabled_events[1]': 'invoice.paid',
      });
    });
  });

  group('webhook', () {
    test('signature', () {
      const payload = '{"id":"evt_1"}';
      var now = DateTime.utc(2026, 10, 25, 12);
      var timestamp = now.millisecondsSinceEpoch ~/ 1000;
      var header = StripeWebhookSignature.header(
        payload: payload,
        timestamp: timestamp,
        secret: 'whsec_test',
      );
      expect(
        StripeWebhookSignature.verify(
          payload: payload,
          header: header,
          secret: 'whsec_test',
          now: now,
        ),
        isTrue,
      );
      for (var (body, secret, at) in [
        ('{"id":"evt_2"}', 'whsec_test', now),
        (payload, 'whsec_other', now),
        (payload, 'whsec_test', now.add(const Duration(minutes: 6))),
      ]) {
        expect(
          StripeWebhookSignature.verify(
            payload: body,
            header: header,
            secret: secret,
            now: at,
          ),
          isFalse,
        );
      }
      expect(StripeWebhookSignature.parse('nonsense'), isNull);
    });
    test('event', () {
      initStripeApiModels();
      var event = StripeApiEvent()
        ..fromMap({
          'id': 'evt_1',
          'type': stripeEventCustomerSubscriptionUpdated,
          'created': 1790000000,
          'livemode': false,
          'data': {
            'object': {'id': 'sub_1', 'status': 'past_due'},
          },
        });
      expect(event.type.v, 'customer.subscription.updated');
      var subscription = StripeApiSubscription()..fromMap(event.object);
      expect(subscription.status.v, stripeSubscriptionStatusPastDue);
    });
  });
}
