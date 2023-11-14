import 'package:cv/cv.dart';
import 'package:tekartik_stripe_api/src/payment_link_options.dart';
import 'package:tekartik_stripe_api/stripe_api.dart';
import 'package:test/test.dart';

CvFillOptions get apiFillOptions =>
    CvFillOptions(collectionSize: 1, valueStart: 0);
var customPriceRecurringDaysId = 'price_1OCJgVJarQTbINzHAKSI2QsE';
var customPriceSimpleDaysId = 'price_1OCJgVJarQTbINzHpM2Whek4';
void main() {
  initStripeApiModels();
  test('StripeApiPrice', () {
    expect((StripeApiPrice()..fillModel(apiFillOptions)).toMap(),
        {'id': 'text_1'});
  });
  test('StripeApiProduct', () {
    expect(
        (newModel().cv<StripeApiProduct>()..fillModel(apiFillOptions)).toMap(),
        {'id': 'text_1'});
  });
  test('StripeApiPaymentLink', () {
    var paymentLink = StripeApiPaymentLink()..fillModel(apiFillOptions);
    expect(paymentLink.toMap(), {'id': 'text_1', 'url': 'text_2'});
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
