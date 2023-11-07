import 'package:cv/cv.dart';
import 'package:tekartik_stripe_api/stripe_api.dart';
import 'package:test/test.dart';

CvFillOptions get apiFillOptions =>
    CvFillOptions(collectionSize: 1, valueStart: 0);

void main() {
  initStripeApiModels();
  test('StripeApiPrice', () {
    expect((StripeApiPrice()..fillModel(apiFillOptions)).toMap(),
        {'id': 'text_1'});
  });
  test('StripeApiPaymentLink', () {
    var paymentLink = StripeApiPaymentLink()..fillModel(apiFillOptions);
    expect(paymentLink.toMap(), {'id': 'text_1', 'url': 'text_2'});
    expect(
        paymentLink.uriWith(email: 'my_email', locale: 'my_locale').toString(),
        'text_2?prefilled_email=my_email&locale=my_locale');
  });
}
