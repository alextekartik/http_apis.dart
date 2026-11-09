import 'package:cv/cv_json.dart';
import 'package:path/path.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/basic_auth_client.dart';
import 'package:tekartik_http/http_client.dart';
import 'package:tekartik_stripe_api/src/billing_portal.dart';
import 'package:tekartik_stripe_api/src/checkout_session.dart';
import 'package:tekartik_stripe_api/src/payment_link_options.dart';
import 'package:tekartik_stripe_api/src/price_model.dart';
import 'package:tekartik_stripe_api/src/price_options.dart';
import 'package:tekartik_stripe_api/src/product_model.dart';
import 'package:tekartik_stripe_api/src/product_options.dart';

import 'credentials_enc.dart';
import 'invoice.dart';
import 'payment_link_model.dart';
import 'stripe_models.dart';
import 'subscription.dart';
import 'webhook.dart';

/// Prints every request and answer body (the signing secret of a new
/// webhook endpoint included): development only.
var debugStripeApi = false;
final stripeApiUrlBase = Uri.parse('https://api.stripe.com/v1');
void _log(Object? message) {
  // ignore: avoid_print
  print(message);
}

const httpContentTypeWwwFormUrlEncoded =
    'application/x-www-form-urlencoded'; //; charset=utf-8';

/// The Stripe keys: the secret key (`sk_...`, server side only) is the one
/// every endpoint here needs; a publishable key alone is for client side
/// uses. At least one of the two.
class StripeApiCredentials {
  final String? secretKey;
  final String? publishableKey;

  StripeApiCredentials({this.secretKey, this.publishableKey}) {
    assert(secretKey != null || publishableKey != null);
  }

  /// The credentials of their plain map ([toMap]).
  factory StripeApiCredentials.fromMap(Map<Object?, Object?> map) =>
      stripeApiCredentialsFromMap(map);

  /// The credentials of their obfuscated map ([toMapEnc]): the content of
  /// a json written by [toJsonEnc] pasted as it is, a dart map literal too;
  /// a plain map ([toMap]) is read too.
  ///
  /// ```dart
  /// final credentials = StripeApiCredentials.fromMapEnc({
  ///   "type": "stripe_credentials_enc",
  ///   ...
  /// });
  /// ```
  factory StripeApiCredentials.fromMapEnc(Map<Object?, Object?> map) =>
      stripeApiCredentialsFromMapEnc(map);

  /// The plain map: `publishableKey`, `secretKey`.
  Map<String, Object?> toMap() => stripeApiCredentialsToMap(this);

  /// The obfuscated map (see [stripeApiCredentialsToMapEnc]).
  Map<String, Object?> toMapEnc({String? password}) =>
      stripeApiCredentialsToMapEnc(this, password: password);

  /// The obfuscated map as an indented json, to keep in a git ignored file
  /// and paste in a [StripeApiCredentials.fromMapEnc] call.
  String toJsonEnc({String? password}) =>
      stripeApiCredentialsToJsonEnc(this, password: password);

  StripeApiCredentials withoutSecretKey() =>
      StripeApiCredentials(publishableKey: publishableKey);

  StripeApiCredentials withoutPublishableKey() =>
      StripeApiCredentials(secretKey: secretKey);
}

typedef StripeApiBodyFields = Map<String, String>;

// ignore: prefer_collection_literals
StripeApiBodyFields newStripeApiBodyFields() => StripeApiBodyFields();

/// Stripe API client: the key is sent as basic auth.
///
/// [baseClient] (a mock, a memory client) and [baseUri] are for tests.
/// Call [close] when done.
class StripeApi {
  final StripeApiCredentials credentials;

  /// Optional base client
  final Client? baseClient;
  final Uri? baseUri;

  StripeApi({required this.credentials, this.baseClient, this.baseUri}) {
    initStripeApiModels();
  }

  Client get _client => _clientOrNull ??= BasicAuthClient(
    credentials.secretKey ?? credentials.publishableKey!,
    '',
    inner: baseClient,
  );
  Client? _clientOrNull;

  Uri get _stripeApiUrlBase => baseUri ?? stripeApiUrlBase;

  Uri _uri(String path) =>
      _stripeApiUrlBase.replace(path: url.join(_stripeApiUrlBase.path, path));

  /// [id] as a single path segment.
  ///
  /// Throws an [ArgumentError] for an empty, `.` or `..` id: the uri would
  /// drop it and reach another endpoint (`subscriptions/../customers/x`).
  String _pathId(String id) {
    if (id.isEmpty || id == '.' || id == '..') {
      throw ArgumentError.value(id, 'id', 'Not a Stripe object id');
    }
    return Uri.encodeComponent(id);
  }

  /// POST [bodyFields] (form url encoded).
  Future<T> _send<T extends CvModel>(Uri uri, StripeApiBodyFields bodyFields) =>
      _read<T>(httpMethodPost, uri, bodyFields: bodyFields);

  Future<T> _get<T extends CvModel>(Uri uri) => _read<T>(httpMethodGet, uri);

  Future<T> _delete<T extends CvModel>(Uri uri) =>
      _read<T>(httpMethodDelete, uri);

  /// Throws an [HttpClientException] on a non 2xx status (the Stripe error is
  /// in its response body).
  Future<T> _read<T extends CvModel>(
    String method,
    Uri uri, {
    StripeApiBodyFields? bodyFields,
  }) async {
    if (debugStripeApi) {
      _log('$method: $uri');
      if (bodyFields != null) {
        _log('      $bodyFields');
      }
    }
    HttpClientResponse response;
    try {
      response = await httpClientSend(
        _client,
        method,
        uri,
        headers: bodyFields == null
            ? null
            : {httpHeaderContentType: httpContentTypeWwwFormUrlEncoded},
        body: bodyFields,
        encoding: bodyFields == null ? null : utf8,
        throwOnFailure: true,
      );
    } on HttpClientException catch (e) {
      if (debugStripeApi) {
        _log('error: ${e.statusCode} ${utf8.decode(e.response.bodyBytes)}');
      }
      rethrow;
    }
    var data = utf8.decode(response.bodyBytes);
    if (debugStripeApi) {
      _log('recv: $data');
    }
    return data.cv<T>();
  }

  /// Create a payment link from a give price.
  /// https://stripe.com/docs/api/payment_links/payment_links/create
  Future<StripeApiPaymentLink> createPaymentLink(
    StripeApiPaymentLinkCreate options,
  ) async {
    var uri = _uri('payment_links');
    var bodyFields = options.toStripeApiBodyFields();
    return _send<StripeApiPaymentLink>(uri, bodyFields);
  }

  /// https://stripe.com/docs/api/payment_links/payment_links/update
  Future<StripeApiPaymentLink> updatePaymentLink(
    String paymentLinkId,
    StripeApiPaymentLinkUpdate options,
  ) async {
    var uri = _uri('payment_links/${_pathId(paymentLinkId)}');
    var bodyFields = options.toStripeApiBodyFields();
    return _send<StripeApiPaymentLink>(uri, bodyFields);
  }

  /// Get a payment link.
  Future<StripeApiPaymentLink> getPaymentLink(String paymentLinkId) async {
    var uri = _uri('payment_links/${_pathId(paymentLinkId)}');
    return _get<StripeApiPaymentLink>(uri);
  }

  /// Create a payment link from a give price.
  /// https://stripe.com/docs/api/prices/create
  Future<StripeApiPrice> createPrice(StripeApiPriceCreate options) async {
    var uri = _uri('prices');
    var bodyFields = options.toStripeApiBodyFields();
    return _send<StripeApiPrice>(uri, bodyFields);
  }

  /// Create a payment link from a give price.
  /// https://stripe.com/docs/api/prices/create
  Future<StripeApiPrice> updatePrice(
    String priceId,
    StripeApiPriceUpdate options,
  ) async {
    var uri = _uri('prices/${_pathId(priceId)}');
    var bodyFields = options.toStripeApiBodyFields();
    return _send<StripeApiPrice>(uri, bodyFields);
  }

  /// Get a price.
  Future<StripeApiPrice> getPrice(String priceId) async {
    var uri = _uri('prices/${_pathId(priceId)}');

    return _get<StripeApiPrice>(uri);
  }

  /// Create a product with optional options.
  Future<StripeApiProduct> createProduct(StripeApiProductCreate options) async {
    var uri = _uri('products');
    var bodyFields = options.toStripeApiBodyFields();
    return _send<StripeApiProduct>(uri, bodyFields);
  }

  /// Update a product (its tax code...).
  /// https://docs.stripe.com/api/products/update
  Future<StripeApiProduct> updateProduct(
    String productId,
    StripeApiProductUpdate options,
  ) async => _send<StripeApiProduct>(
    _uri('products/${_pathId(productId)}'),
    options.toStripeApiBodyFields(),
  );

  /// Get a product.
  Future<StripeApiProduct> getProduct(String productId) async {
    var uri = _uri('products/${_pathId(productId)}');

    return _get<StripeApiProduct>(uri);
  }

  /// List products
  Future<StripeApiProductList> listProducts(
    StripeApiProductListOptions options,
  ) async {
    var uri = _uri('products');

    return _get<StripeApiProductList>(
      uri.replace(queryParameters: options.toStripeApiParam()),
    );
  }

  /// The prices of [options] (by lookup keys...).
  /// https://docs.stripe.com/api/prices/list
  Future<StripeApiPriceList> listPrices(
    StripeApiPriceListOptions options,
  ) async {
    var uri = _uri('prices');
    return _get<StripeApiPriceList>(
      uri.replace(queryParameters: options.toQueryParameters()),
    );
  }

  /// A page of invoices, newest first (every status unless
  /// [StripeApiInvoiceListOptions.status]).
  /// https://docs.stripe.com/api/invoices/list
  Future<StripeApiInvoiceList> listInvoices(
    StripeApiInvoiceListOptions options,
  ) => _get<StripeApiInvoiceList>(
    _uri('invoices').replace(queryParameters: options.toQueryParameters()),
  );

  /// Get an invoice.
  Future<StripeApiInvoice> getInvoice(String invoiceId) async =>
      _get<StripeApiInvoice>(_uri('invoices/${_pathId(invoiceId)}'));

  /// A Checkout Session, its url to open.
  /// https://docs.stripe.com/api/checkout/sessions/create
  Future<StripeApiCheckoutSession> createCheckoutSession(
    StripeApiCheckoutSessionCreate options,
  ) => _send<StripeApiCheckoutSession>(
    _uri('checkout/sessions'),
    options.toStripeApiBodyFields(),
  );

  /// Get a Checkout Session.
  Future<StripeApiCheckoutSession> getCheckoutSession(String sessionId) async =>
      _get<StripeApiCheckoutSession>(
        _uri('checkout/sessions/${_pathId(sessionId)}'),
      );

  /// A customer portal session, its url to open.
  /// https://docs.stripe.com/api/customer_portal/sessions/create
  Future<StripeApiBillingPortalSession> createBillingPortalSession(
    StripeApiBillingPortalSessionCreate options,
  ) => _send<StripeApiBillingPortalSession>(
    _uri('billing_portal/sessions'),
    options.toStripeApiBodyFields(),
  );

  /// A customer portal configuration.
  /// https://docs.stripe.com/api/customer_portal/configurations/create
  Future<StripeApiBillingPortalConfiguration> createBillingPortalConfiguration(
    StripeApiBillingPortalConfigurationCreate options,
  ) => _send<StripeApiBillingPortalConfiguration>(
    _uri('billing_portal/configurations'),
    options.toStripeApiBodyFields(),
  );

  /// The customer portal configurations (the first 100).
  Future<StripeApiBillingPortalConfigurationList>
  listBillingPortalConfigurations() =>
      _get<StripeApiBillingPortalConfigurationList>(
        _uri(
          'billing_portal/configurations',
        ).replace(queryParameters: {'limit': '100'}),
      );

  /// Get a subscription.
  /// https://docs.stripe.com/api/subscriptions/retrieve
  Future<StripeApiSubscription> getSubscription(String subscriptionId) async =>
      _get<StripeApiSubscription>(
        _uri('subscriptions/${_pathId(subscriptionId)}'),
      );

  /// Update a subscription (cancel at the end of the period, or not).
  /// https://docs.stripe.com/api/subscriptions/update
  Future<StripeApiSubscription> updateSubscription(
    String subscriptionId,
    StripeApiSubscriptionUpdate options,
  ) async => _send<StripeApiSubscription>(
    _uri('subscriptions/${_pathId(subscriptionId)}'),
    options.toStripeApiBodyFields(),
  );

  /// Cancel a subscription now.
  /// https://docs.stripe.com/api/subscriptions/cancel
  Future<StripeApiSubscription> cancelSubscription(
    String subscriptionId,
  ) async => _delete<StripeApiSubscription>(
    _uri('subscriptions/${_pathId(subscriptionId)}'),
  );

  /// A webhook endpoint, its signing secret in the answer only.
  /// https://docs.stripe.com/api/webhook_endpoints/create
  Future<StripeApiWebhookEndpoint> createWebhookEndpoint(
    StripeApiWebhookEndpointCreate options,
  ) => _send<StripeApiWebhookEndpoint>(
    _uri('webhook_endpoints'),
    options.toStripeApiBodyFields(),
  );

  /// The webhook endpoints (the first 100).
  Future<StripeApiWebhookEndpointList> listWebhookEndpoints() =>
      _get<StripeApiWebhookEndpointList>(
        _uri('webhook_endpoints').replace(queryParameters: {'limit': '100'}),
      );

  /// Delete a webhook endpoint.
  Future<void> deleteWebhookEndpoint(String webhookEndpointId) async {
    await _delete<StripeApiWebhookEndpoint>(
      _uri('webhook_endpoints/${_pathId(webhookEndpointId)}'),
    );
  }

  Future<void> close() async {
    _clientOrNull?.close();
  }
}
