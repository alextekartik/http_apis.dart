import 'package:cv/cv.dart';

/// https://docs.stripe.com/api/customer_portal/sessions/create
class StripeApiBillingPortalSessionCreate extends CvModelBase {
  /// The customer id.
  final customer = CvField<String>('customer');

  /// Where the portal goes back to.
  final returnUrl = CvField<String>('return_url');

  /// `auto`, `fr`, `en`...
  final locale = CvField<String>('locale');

  /// A configuration id, the default one when null.
  final configuration = CvField<String>('configuration');

  @override
  CvFields get fields => [customer, returnUrl, locale, configuration];
}

/// A customer portal session: its url.
class StripeApiBillingPortalSession extends CvModelBase {
  /// `bps_...`.
  final id = CvField<String>('id');

  /// The page to open.
  final url = CvField<String>('url');

  @override
  CvFields get fields => [id, url];
}

/// https://docs.stripe.com/api/customer_portal/configurations/create, its
/// fields as Stripe names them (nested maps), for instance:
///
/// ```dart
/// StripeApiBillingPortalConfigurationCreate()
///   ..features.v = {
///     'subscription_cancel': {'enabled': true, 'mode': 'at_period_end'},
///     'invoice_history': {'enabled': true},
///   }
/// ```
class StripeApiBillingPortalConfigurationCreate extends CvModelBase {
  /// `headline`, `privacy_policy_url`, `terms_of_service_url`.
  final businessProfile = CvField<Model>('business_profile');

  /// The features (see the Stripe documentation).
  final features = CvField<Model>('features');

  /// The return url when a session has none.
  final defaultReturnUrl = CvField<String>('default_return_url');

  /// Metadata.
  final metadata = CvField<Model>('metadata');

  @override
  CvFields get fields => [
    businessProfile,
    features,
    defaultReturnUrl,
    metadata,
  ];
}

/// A customer portal configuration.
class StripeApiBillingPortalConfiguration extends CvModelBase {
  /// `bpc_...`.
  final id = CvField<String>('id');

  /// Active.
  final active = CvField<bool>('active');

  /// The default one.
  final isDefault = CvField<bool>('is_default');

  /// Metadata.
  final metadata = CvField<Model>('metadata');

  @override
  CvFields get fields => [id, active, isDefault, metadata];
}

/// A list of customer portal configurations.
class StripeApiBillingPortalConfigurationList extends CvModelBase {
  /// More after.
  final hasMore = CvField<bool>('has_more');

  /// The configurations.
  final data = CvModelListField<StripeApiBillingPortalConfiguration>('data');

  @override
  CvFields get fields => [data, hasMore];
}
