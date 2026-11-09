/// A typed client of the Stripe REST API v1 for server side Dart.
///
/// Create a [StripeApi] with a secret key, call its endpoints with the `cv`
/// option models (`StripeApiPriceCreate`, `StripeApiCheckoutSessionCreate`...)
/// and read the answer models through `field.v`. A non 2xx answer throws an
/// `HttpClientException` (`package:tekartik_http/http_client.dart`).
/// Webhooks: [StripeWebhookSignature.verify] then [StripeApiEvent].
library;

export 'src/api_options.dart' show StripeApiMetadata;
export 'src/billing_portal.dart'
    show
        StripeApiBillingPortalConfiguration,
        StripeApiBillingPortalConfigurationCreate,
        StripeApiBillingPortalConfigurationList,
        StripeApiBillingPortalSession,
        StripeApiBillingPortalSessionCreate;
export 'src/checkout_session.dart';
export 'src/constant.dart';
export 'src/credentials_enc.dart'
    show
        stripeApiCredentialsEncType,
        stripeApiCredentialsToMapEnc,
        stripeApiCredentialsToJsonEnc,
        stripeApiCredentialsFromMapEnc,
        stripeApiKeyObfuscate;
export 'src/invoice.dart';
export 'src/payment_link_model.dart'
    show StripeApiPaymentLink, StripeApiPaymentLinkExt;
export 'src/payment_link_options.dart'
    show
        StripeApiPaymentLinkCreate,
        StripeApiPaymentLinkLineItem,
        StripeApiPaymentLinkSubscriptionData,
        StripeApiPaymentLinkUpdate;
export 'src/price_model.dart' show StripeApiPrice, StripeApiPriceList;
export 'src/price_options.dart'
    show
        StringApiPriceRecurring,
        StripeApiPriceCreate,
        StripeApiPriceListOptions,
        StripeApiPriceUpdate;
export 'src/product_model.dart'
    show StripeApiProduct, StripeApiProductListOptions, StripeApiProductList;
export 'src/product_options.dart'
    show StripeApiProductCreate, StripeApiProductUpdate;
export 'src/stripe_api.dart'
    show StripeApi, StripeApiCredentials, debugStripeApi;
export 'src/stripe_models.dart'
    show
        initStripeApiModels,
        CvModelStripeExt,
        StripeApiMetadataMixin,
        CvModelStripeMapExt;
export 'src/subscription.dart';
export 'src/webhook.dart';
