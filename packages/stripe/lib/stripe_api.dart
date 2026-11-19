/// A typed client of the Stripe REST API v1 for server side Dart.
///
/// Create a [StripeApi] with a secret key, call its endpoints with the `cv`
/// option models (`StripeApiPriceCreate`, `StripeApiCheckoutSessionCreate`...)
/// and read the answer models through `field.v`. A non 2xx answer throws an
/// `HttpClientException` (`package:tekartik_http/http_client.dart`).
/// Webhooks: [StripeWebhookSignature.verify] then [StripeApiEvent].
library;

export 'src/account.dart';
export 'src/api_options.dart' show StripeApiMetadata;
export 'src/balance.dart';
export 'src/billing_portal.dart'
    show
        StripeApiBillingPortalConfiguration,
        StripeApiBillingPortalConfigurationCreate,
        StripeApiBillingPortalConfigurationList,
        StripeApiBillingPortalSession,
        StripeApiBillingPortalSessionCreate;
export 'src/charge.dart';
export 'src/checkout_session.dart';
export 'src/constant.dart';
export 'src/credentials_enc.dart'
    show
        stripeApiCredentialsEncType,
        stripeApiCredentialsToMapEnc,
        stripeApiCredentialsToJsonEnc,
        stripeApiCredentialsFromMapEnc,
        stripeApiKeyObfuscate;
export 'src/error.dart' show stripeApiErrorMessage;
export 'src/invoice.dart';
export 'src/line_item.dart';
export 'src/list_options.dart';
export 'src/payment_link_model.dart'
    show
        StripeApiPaymentLink,
        StripeApiPaymentLinkExt,
        StripeApiPaymentLinkList;
export 'src/payment_link_options.dart'
    show
        StripeApiPaymentLinkCreate,
        StripeApiPaymentLinkCompletedSessions,
        StripeApiPaymentLinkLineItem,
        StripeApiPaymentLinkListOptions,
        StripeApiPaymentLinkRestrictions,
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
    show
        StripeApiProductCreate,
        StripeApiProductDefaultPriceData,
        StripeApiProductUpdate;
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
