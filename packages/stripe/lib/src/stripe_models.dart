import 'package:cv/cv.dart';
import 'package:tekartik_stripe_api/src/payment_link_model.dart';
import 'package:tekartik_stripe_api/src/payment_link_options.dart';
import 'package:tekartik_stripe_api/src/price_model.dart';
import 'package:tekartik_stripe_api/src/product_model.dart';
import 'package:tekartik_stripe_api/src/stripe_api.dart';

var _priceModelInitialized = false;
void initStripeApiModels() {
  if (!_priceModelInitialized) {
    _priceModelInitialized = true;
    cvAddConstructor(StripeApiPrice.new);
    cvAddConstructor(StripeApiPaymentLink.new);
    cvAddConstructor(StripeApiProduct.new);
    cvAddConstructor(StripeApiPaymentLinkCreate.new);
    cvAddConstructor(StripeApiPaymentLinkLineItem.new);
    cvAddConstructor(StripeApiPaymentLinkSubscriptionData.new);
  }
}

void bodyFieldsAddValue(
    StripeApiBodyFields bodyFields, String key, Object? value) {
  if (value is Iterable) {
    for (var (index, value) in value.indexed) {
      bodyFieldsAddValue(bodyFields, '$key[$index]', value);
    }
  } else if (value is Map) {
    for (var entry in value.entries) {
      bodyFieldsAddValue(bodyFields, '$key[${entry.key}]', entry.value);
    }
  } else {
    bodyFields[key] = value.toString();
  }
}

extension CvModelStripeListExt on Iterable {
  StripeApiBodyFields toStripeApiBodyFields() {
    var bodyFields = newStripeApiBodyFields();
    for (var (index, value) in indexed) {
      bodyFieldsAddValue(bodyFields, '$index', value);
    }
    return bodyFields;
  }
}

extension CvModelStripeMapExt on Map {
  StripeApiBodyFields toStripeApiBodyFields() {
    var bodyFields = newStripeApiBodyFields();
    for (var entry in entries) {
      var fieldKey = entry.key;
      var value = entry.value;
      bodyFieldsAddValue(bodyFields, '$fieldKey', value);
    }
    return bodyFields;
  }
}

extension CvModelStripeExt on CvModel {
  StripeApiBodyFields toStripeApiBodyFields() {
    return toMap().toStripeApiBodyFields();
  }
}
