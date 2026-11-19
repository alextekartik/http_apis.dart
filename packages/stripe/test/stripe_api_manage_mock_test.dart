import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tekartik_stripe_api/stripe_api.dart';
import 'package:test/test.dart';

/// The list, balance, account, refund and product calls against a mock
/// client: the request sent and the answer read.
void main() {
  late List<http.Request> requests;
  late StripeApi api;
  late Object? Function(http.Request request) answer;

  setUp(() {
    requests = [];
    answer = (_) => <String, Object?>{};
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

  test('listCheckoutSessions query and expanded line items', () async {
    answer = (_) => {
      'has_more': true,
      'data': [
        {
          'id': 'cs_1',
          'status': 'complete',
          'payment_status': 'paid',
          'amount_total': 2500,
          'currency': 'eur',
          'created': 1700000000,
          'payment_link': 'plink_1',
          'customer_details': {'email': 'a@example.com', 'name': 'A B'},
          'metadata': {'orderId': 'o1'},
          'line_items': {
            'has_more': false,
            'data': [
              {
                'id': 'li_1',
                'description': 'Book',
                'quantity': 2,
                'amount_total': 2000,
                'currency': 'eur',
                'price': {
                  'id': 'price_1',
                  'product': 'prod_1',
                  'unit_amount': 1000,
                  'type': 'one_time',
                },
              },
            ],
          },
        },
      ],
    };
    var list = await api.listCheckoutSessions(
      StripeApiCheckoutSessionListOptions()
        ..paymentLink.v = 'plink_1'
        ..status.v = stripeCheckoutSessionStatusComplete
        ..limit.v = 100
        ..createdGte.v = 1600000000
        ..createdLt.v = 1800000000
        ..startingAfter.v = 'cs_0'
        ..expand.v = ['data.line_items'],
    );
    var url = requests.single.url;
    expect(requests.single.method, 'GET');
    expect(url.path, '/v1/checkout/sessions');
    expect(url.queryParametersAll, {
      'limit': ['100'],
      'starting_after': ['cs_0'],
      'created[gte]': ['1600000000'],
      'created[lt]': ['1800000000'],
      'expand[]': ['data.line_items'],
      'payment_link': ['plink_1'],
      'status': ['complete'],
    });
    expect(list.hasMore.v, isTrue);
    var session = list.data.v!.single;
    expect(session.amountTotal.v, 2500);
    expect(session.paymentStatus.v, stripeCheckoutSessionPaymentStatusPaid);
    expect(session.customerDetails.v!.email.v, 'a@example.com');
    expect(session.metadata.v, {'orderId': 'o1'});
    expect(stripeApiDateTime(session.created.v)!.year, 2023);
    var item = session.lineItems.v!.data.v!.single;
    expect(item.quantity.v, 2);
    expect(item.price.v!.productId.v, 'prod_1');
    expect(item.price.v!.amount.v, 1000);
  });

  test('payment link with a completed sessions limit', () async {
    answer = (_) => {
      'id': 'plink_1',
      'url': 'https://buy.stripe.com/test',
      'restrictions': {
        'completed_sessions': {'count': 0, 'limit': 1},
      },
    };
    var link = await api.createPaymentLink(
      StripeApiPaymentLinkCreate()
        ..lineItems.v = [
          StripeApiPaymentLinkLineItem()
            ..priceId.v = 'price_1'
            ..quantity.v = 3,
        ]
        ..restrictions.v = (StripeApiPaymentLinkRestrictions()
          ..completedSessions.v = (StripeApiPaymentLinkCompletedSessions()
            ..limit.v = 1))
        ..metadata.v = {'orderId': 'o1'},
    );
    expect(requests.single.bodyFields, {
      'line_items[0][price]': 'price_1',
      'line_items[0][quantity]': '3',
      'metadata[orderId]': 'o1',
      'restrictions[completed_sessions][limit]': '1',
    });
    expect(link.restrictions.v!.completedSessions.v!.limit.v, 1);

    answer = (_) => {
      'has_more': false,
      'data': [
        {'id': 'plink_1', 'active': false, 'livemode': false},
      ],
    };
    var links = await api.listPaymentLinks(
      StripeApiPaymentLinkListOptions()..active.v = false,
    );
    expect(requests.last.url.queryParameters, {'active': 'false'});
    expect(links.data.v!.single.active.v, isFalse);

    // Expanded line items: the price date (a link has no created date),
    // the paid count of a link paid once.
    answer = (_) => {
      'has_more': true,
      'data': [
        {
          'id': 'plink_2',
          'restrictions': {
            'completed_sessions': {'count': 1, 'limit': 1},
          },
          'line_items': {
            'object': 'list',
            'has_more': false,
            'data': [
              {
                'id': 'li_1',
                'description': 'Book',
                'quantity': 2,
                'amount_total': 2000,
                'price': {
                  'id': 'price_1',
                  'created': 1700000000,
                  'nickname': 'Book Doe',
                  'product': 'prod_1',
                },
              },
            ],
          },
        },
      ],
    };
    links = await api.listPaymentLinks(
      StripeApiPaymentLinkListOptions()
        ..limit.v = 50
        ..expand.v = ['data.line_items'],
    );
    expect(requests.last.url.queryParametersAll, {
      'limit': ['50'],
      'expand[]': ['data.line_items'],
    });
    var expanded = links.data.v!.single;
    expect(expanded.restrictions.v!.completedSessions.v!.count.v, 1);
    var item = expanded.lineItemList.v!.data.v!.single;
    expect(item.quantity.v, 2);
    expect(item.price.v!.created.v, 1700000000);
    expect(item.price.v!.nickname.v, 'Book Doe');
  });

  test('products: create with a default price, archive, delete', () async {
    answer = (_) => {
      'id': 'prod_1',
      'name': 'Book',
      'active': true,
      'default_price': 'price_1',
      'created': 1700000000,
    };
    var product = await api.createProduct(
      StripeApiProductCreate()
        ..name.v = 'Book'
        ..defaultPriceData.v = (StripeApiProductDefaultPriceData()
          ..currency.v = stripeCurrencyEuro
          ..amount.v = 1000)
        ..metadata.v = {'itemId': 'book'},
    );
    expect(requests.last.bodyFields, {
      'name': 'Book',
      'default_price_data[currency]': 'eur',
      'default_price_data[unit_amount]': '1000',
      'metadata[itemId]': 'book',
    });
    expect(product.defaultPrice.v, 'price_1');
    expect(product.active.v, isTrue);

    await api.updateProduct(
      'prod_1',
      StripeApiProductUpdate()..active.v = false,
    );
    expect(requests.last.url.path, '/v1/products/prod_1');
    expect(requests.last.bodyFields, {'active': 'false'});

    answer = (_) => {'id': 'prod_1', 'deleted': true};
    var deleted = await api.deleteProduct('prod_1');
    expect(requests.last.method, 'DELETE');
    expect(deleted.deleted.v, isTrue);

    await api.listProducts(
      StripeApiProductListOptions()
        ..active.v = false
        ..limit.v = 100,
    );
    expect(requests.last.url.queryParameters, {
      'limit': '100',
      'active': 'false',
    });
    await api.listPrices(
      StripeApiPriceListOptions()
        ..productId.v = 'prod_1'
        ..startingAfter.v = 'price_0',
    );
    expect(requests.last.url.queryParameters, {
      'product': 'prod_1',
      'starting_after': 'price_0',
    });
  });

  test('balance, account, transactions, payouts, charges, refund', () async {
    answer = (_) => {
      'available': [
        {'amount': 1200, 'currency': 'eur'},
      ],
      'pending': [
        {'amount': 300, 'currency': 'eur'},
      ],
      'livemode': false,
    };
    var balance = await api.getBalance();
    expect(requests.last.url.path, '/v1/balance');
    expect(balance.available.v!.single.amount.v, 1200);
    expect(balance.pending.v!.single.currency.v, 'eur');

    answer = (_) => {
      'id': 'acct_1',
      'country': 'FR',
      'settings': {
        'payouts': {
          'schedule': {'interval': 'manual', 'delay_days': 7},
        },
      },
    };
    var account = await api.getAccount();
    expect(requests.last.url.path, '/v1/account');
    expect(account.settings.v!.payouts.v!.schedule.v!.interval.v, 'manual');

    answer = (_) => {
      'has_more': false,
      'data': [
        {
          'id': 'txn_1',
          'amount': 1000,
          'fee': 40,
          'net': 960,
          'type': 'charge',
        },
      ],
    };
    var transactions = await api.listBalanceTransactions(
      StripeApiBalanceTransactionListOptions()..payout.v = 'po_1',
    );
    expect(requests.last.url.queryParameters, {'payout': 'po_1'});
    expect(transactions.data.v!.single.net.v, 960);

    answer = (_) => {
      'has_more': false,
      'data': [
        {'id': 'po_1', 'amount': 960, 'status': 'paid', 'automatic': false},
      ],
    };
    var payouts = await api.listPayouts(
      StripeApiPayoutListOptions()..status.v = 'paid',
    );
    expect(requests.last.url.queryParameters, {'status': 'paid'});
    expect(payouts.data.v!.single.automatic.v, isFalse);

    answer = (_) => {
      'has_more': false,
      'data': [
        {
          'id': 'ch_1',
          'amount': 1000,
          'amount_refunded': 0,
          'paid': true,
          'billing_details': {'email': 'a@example.com'},
        },
      ],
    };
    var charges = await api.listCharges(
      StripeApiChargeListOptions()..limit.v = 10,
    );
    expect(requests.last.url.path, '/v1/charges');
    expect(charges.data.v!.single.billingDetails.v!.email.v, 'a@example.com');

    answer = (_) => {'id': 're_1', 'amount': 1000, 'status': 'succeeded'};
    var refund = await api.createRefund(
      StripeApiRefundCreate()
        ..charge.v = 'ch_1'
        ..reason.v = 'requested_by_customer',
    );
    expect(requests.last.url.path, '/v1/refunds');
    expect(requests.last.bodyFields, {
      'charge': 'ch_1',
      'reason': 'requested_by_customer',
    });
    expect(refund.status.v, 'succeeded');

    answer = (_) => {
      'has_more': false,
      'data': [
        {'id': 'sub_1', 'status': 'active'},
      ],
    };
    var subscriptions = await api.listSubscriptions(
      StripeApiSubscriptionListOptions()..status.v = 'all',
    );
    expect(requests.last.url.queryParameters, {'status': 'all'});
    expect(subscriptions.data.v!.single.status.v, 'active');
  });

  test('stripeApiSeconds', () {
    var dateTime = DateTime.utc(2026, 11, 19);
    expect(stripeApiDateTime(stripeApiSeconds(dateTime)), dateTime);
    expect(stripeApiDateTime(null), isNull);
  });
}
