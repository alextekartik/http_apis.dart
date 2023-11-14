import 'package:cv/cv.dart';
import 'package:tekartik_stripe_api/src/stripe_models.dart';
import 'package:tekartik_stripe_api/stripe_api.dart';
import 'package:test/test.dart';

CvFillOptions get apiFillOptions =>
    CvFillOptions(collectionSize: 1, valueStart: 0);
var customPriceRecurringDaysId = 'price_1OCJgVJarQTbINzHAKSI2QsE';
var customPriceSimpleDaysId = 'price_1OCJgVJarQTbINzHpM2Whek4';
var productId = 'prod_OmtgJbSbudZ2hT';

void main() {
  initStripeApiModels();
  test('StripeApiPrice', () {
    var map = Model.from({
      'unit_amount': '1000',
      'currency': 'eur',
      'nickname': 'Test recurring with accént',
      'product': 'prod_OmtgJbSbudZ2hT',
      'recurring[interval]': 'day',
      'recurring[interval_count]': '1',
      'metadata[meta_1]': 'Test meta value',
      'metadata[meta_2]': 'Test meta value 2'
    });
    var priceCreate = StripeApiPriceCreate()
      ..productId.v = productId
      ..amount.v = 1000 // cents
      ..currency.v = stripeCurrencyEuro
      ..nickname.v = 'Test recurring with accént'
      ..metadata.v = {
        'meta_1': 'Test meta value',
        'meta_2': 'Test meta value 2'
      }
      ..recurring.v = (StringApiPriceRecurring()
        ..interval.v = stripePriceRecurringIntervalDay
        ..intervalCount.v = 1);
    expect(priceCreate.toMap().toStripeApiBodyFields(), map);
    expect(
        (newModel().cv<StripeApiPriceCreate>()..fillModel(apiFillOptions))
            .toMap(),
        {
          'product': 'text_1',
          'nickname': 'text_2',
          'currency': 'text_3',
          'unit_amount': 4,
          'recurring': {'interval': 'text_5', 'interval_count': 6},
          'metadata': {'field_1': 7}
        });

    map = {
      'unit_amount': '400',
      'currency': 'eur',
      'product': 'prod_OmtgJbSbudZ2hT',
      'metadata[meta_1]': 'Test simple meta value',
      'metadata[meta_2]': 'Test simple meta value 2'
    };
    expect((StripeApiPrice()..fillModel(apiFillOptions)).toMap(), {
      'id': 'text_1',
      'product': 'text_2',
      'nickname': 'text_3',
      'currency': 'text_4',
      'unit_amount': 5,
      'recurring': {'interval': 'text_6', 'interval_count': 7},
      'metadata': {'field_1': 8}
    });
    map = {
      'id': 'price_1OCJgVJarQTbINzHAKSI2QsE',
      'object': 'price',
      'active': true,
      'billing_scheme': 'per_unit',
      'created': 1699957051,
      'currency': 'eur',
      'custom_unit_amount': null,
      'livemode': false,
      'lookup_key': null,
      'metadata': {'meta_1': 'Test meta value', 'meta_2': 'Test meta value 2'},
      'nickname': null,
      'product': 'prod_OmtgJbSbudZ2hT',
      'recurring': {
        'aggregate_usage': null,
        'interval': 'day',
        'interval_count': 1,
        'trial_period_days': null,
        'usage_type': 'licensed'
      },
      'tax_behavior': 'unspecified',
      'tiers_mode': null,
      'transform_quantity': null,
      'type': 'recurring',
      'unit_amount': 1000,
      'unit_amount_decimal': '1000'
    };
    var price = map.cv<StripeApiPrice>();
    expect(price.toMap(), {
      'id': 'price_1OCJgVJarQTbINzHAKSI2QsE',
      'product': 'prod_OmtgJbSbudZ2hT',
      'nickname': null,
      'currency': 'eur',
      'unit_amount': 1000,
      'recurring': {'interval': 'day', 'interval_count': 1},
      'metadata': {'meta_1': 'Test meta value', 'meta_2': 'Test meta value 2'}
    });
  });
  test('StripeApiProduct', () {
    expect(
        (newModel().cv<StripeApiProduct>()..fillModel(apiFillOptions)).toMap(),
        {'id': 'text_1'});
  });
  test('StripeApiPaymentLink', () {
    var paymentLink = StripeApiPaymentLink()..fillModel(apiFillOptions);
    expect(paymentLink.toMap(), {
      'id': 'text_1',
      'url': 'text_2',
      'metadata': {'field_1': 3}
    });
    expect(
        paymentLink.uriWith(email: 'my_email', locale: 'my_locale').toString(),
        'text_2?prefilled_email=my_email&locale=my_locale');
  });
  test('payment link', () {
    var create = StripeApiPaymentLinkCreate()
      ..lineItems.v = [
        (StripeApiPaymentLinkLineItem()
          ..priceId.v = customPriceSimpleDaysId
          ..quantity.v = 1),
        (StripeApiPaymentLinkLineItem()
          ..priceId.v = customPriceRecurringDaysId
          ..quantity.v = 1),
      ]
      ..metadata.v = {
        'meta_1': 'Test link meta value',
        'meta_2': 'Test link meta value 2'
      }
      ..subscriptionData.v = (StripeApiPaymentLinkSubscriptionData()
        ..description.v = 'Test link subscription description');
    var bodyFields = {
      'line_items[0][price]': 'price_1OCJgVJarQTbINzHpM2Whek4',
      'line_items[0][quantity]': '1',
      'line_items[1][price]': 'price_1OCJgVJarQTbINzHAKSI2QsE',
      'line_items[1][quantity]': '1',
      'subscription_data[description]': 'Test link subscription description',
      'metadata[meta_1]': 'Test link meta value',
      'metadata[meta_2]': 'Test link meta value 2'
    };
    expect(create.toStripeApiBodyFields(), bodyFields);
    expect((StripeApiPaymentLinkCreate()..fillModel(apiFillOptions)).toMap(), {
      'line_items': [
        {'price': 'text_1', 'quantity': 2}
      ],
      'metadata': {'field_1': 3},
      'subscription_data': {'description': 'text_4'}
    });
    expect((StripeApiPaymentLink()..fillModel(apiFillOptions)).toMap(), {
      'id': 'text_1',
      'url': 'text_2',
      'metadata': {'field_1': 3}
    });
  });
  test('create_product', () {
    var bodyFields = {
      'name': 'Test product',
      'description': 'Test description'
    };
    var create = StripeApiProductCreate()
      ..name.v = 'Test product'
      ..description.v = 'Test description';
    expect(create.toStripeApiBodyFields(), bodyFields);
  });
}
