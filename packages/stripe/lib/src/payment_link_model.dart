import 'package:cv/cv.dart';
import 'package:tekartik_stripe_api/src/price_options.dart';

import 'line_item.dart';
import 'payment_link_options.dart';

//
//   "id": "plink_1O9kTkJarQTbINzHWrS3TPl7",
//   "object": "payment_link",
//   "active": true,
//   "after_completion": {
//     "hosted_confirmation": {
//       "custom_message": null
//     },
//     "type": "hosted_confirmation"
//   },
//   "allow_promotion_codes": false,
//   "application": null,
//   "application_fee_amount": null,
//   "application_fee_percent": null,
//   "automatic_tax": {
//     "enabled": false
//   },
//   "billing_address_collection": "auto",
//   "consent_collection": null,
//   "currency": "eur",
//   "custom_fields": [],
//   "custom_text": {
//     "shipping_address": null,
//     "submit": null,
//     "terms_of_service_acceptance": null
//   },
//   "customer_creation": "if_required",
//   "invoice_creation": {
//     "enabled": false,
//     "invoice_data": {
//       "account_tax_ids": null,
//       "custom_fields": null,
//       "description": null,
//       "footer": null,
//       "metadata": {},
//       "rendering_options": null
//     }
//   },
//   "livemode": false,
//   "metadata": {},
//   "on_behalf_of": null,
//   "payment_intent_data": null,
//   "payment_method_collection": "always",
//   "payment_method_types": null,
//   "phone_number_collection": {
//     "enabled": false
//   },
//   "shipping_address_collection": null,
//   "shipping_options": [],
//   "submit_type": "auto",
//   "subscription_data": {
//     "description": null,
//     "metadata": {},
//     "trial_period_days": null
//   },
//   "tax_id_collection": {
//     "enabled": false
//   },
//   "transfer_data": null,
//   "url": "https://buy.stripe.com/test_5kA3f43TRfsT8qA6ou"
// }
class StripeApiPaymentLink extends CvModelBase
    with StripeApiPaymentLinkCreateUpdateMixin {
  final id = CvField<String>('id');
  final url = CvField<String>('url');

  final recurring = CvModelField<StringApiPriceRecurring>('recurring');

  /// Livemode.
  final livemode = CvField<bool>('livemode');

  /// The line items as read, when expanded (`expand: ['data.line_items']`
  /// in a list): their price gives the only date of a link (a Payment Link
  /// has no `created`). [lineItems] is the creation form, never read.
  final lineItemList = CvModelField<StripeApiLineItemList>('line_items');

  @override
  List<CvField<Object?>> get fields => [
    id,
    url,
    livemode,
    metadata,
    subscriptionData,
    active,
    restrictions,
    lineItemList,
  ];
}

/// A page of Payment Links.
class StripeApiPaymentLinkList extends CvModelBase {
  /// More after.
  final hasMore = CvField<bool>('has_more');

  /// The links, newest first.
  final data = CvModelListField<StripeApiPaymentLink>('data');

  @override
  List<CvField<Object?>> get fields => [data, hasMore];
}

/// https://stripe.com/docs/payment-links/customer-info
extension StripeApiPaymentLinkExt on StripeApiPaymentLink {
  Uri uriWith({String? email, String? locale}) {
    var uri = Uri.parse(url.v!);
    uri = uri.replace(
      queryParameters: {'prefilled_email': ?email, 'locale': ?locale},
    );
    return uri;
  }
}
