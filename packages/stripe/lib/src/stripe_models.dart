import 'package:cv/cv.dart';
import 'package:tekartik_stripe_api/src/payment_link_model.dart';
import 'package:tekartik_stripe_api/src/payment_link_options.dart';
import 'package:tekartik_stripe_api/src/price_model.dart';
import 'package:tekartik_stripe_api/src/product_model.dart';
import 'package:tekartik_stripe_api/src/stripe_api.dart';

import 'price_options.dart';
import 'product_options.dart';

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
    cvAddConstructor(StripeApiPriceCreate.new);
    cvAddConstructor(StringApiPriceRecurring.new);
    cvAddConstructor(StripeApiProductCreate.new);
    cvAddConstructor(StripeApiProductList.new);
    cvAddConstructor(StripeApiProductListOptions.new);
    cvAddConstructors(
        [StripeApiPaymentLinkUpdate.new, StripeApiPriceUpdate.new]);
  }
}

mixin StripeApiMetadataMixin implements CvModel {
  final metadata = CvField<Model>('metadata');
  List<CvField<Object?>> get metadataMixinFields => [metadata];
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

  Map<String, String> toStripeApiParam() {
    var param = <String, String>{};
    for (var entry in entries) {
      var fieldKey = entry.key;
      var value = entry.value;
      if (fieldKey is String && value != null) {
        param[fieldKey] = value.toString();
      }
    }
    return param;
  }
}

extension CvModelStripeExt on CvModel {
  StripeApiBodyFields toStripeApiBodyFields() {
    return toMap().toStripeApiBodyFields();
  }

  Map<String, String> toStripeApiParam() {
    return toMap().toStripeApiParam();
  }
}
