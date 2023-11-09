import 'package:cv/cv.dart';
import 'package:tekartik_stripe_api/src/payment_link_model.dart';
import 'package:tekartik_stripe_api/src/price_model.dart';
import 'package:tekartik_stripe_api/src/product_model.dart';

var _priceModelInitialized = false;
void initStripeApiModels() {
  if (!_priceModelInitialized) {
    _priceModelInitialized = true;
    cvAddConstructor(StripeApiPrice.new);
    cvAddConstructor(StripeApiPaymentLink.new);
    cvAddConstructor(StripeApiProduct.new);
  }
}
