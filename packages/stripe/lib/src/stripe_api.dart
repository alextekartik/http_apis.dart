import 'package:cv/cv_json.dart';
import 'package:path/path.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/basic_auth_client.dart';
import 'package:tekartik_http/http_client.dart';
import 'package:tekartik_stripe_api/src/payment_link_options.dart';
import 'package:tekartik_stripe_api/src/price_model.dart';
import 'package:tekartik_stripe_api/src/price_options.dart';
import 'package:tekartik_stripe_api/src/product_model.dart';
import 'package:tekartik_stripe_api/src/product_options.dart';

import 'payment_link_model.dart';
import 'stripe_models.dart';

var debugStripeApi = false;
final stripeApiUrlBase = Uri.parse('https://api.stripe.com/v1');
void _log(Object? message) {
  // ignore: avoid_print
  print(message);
}

const httpContentTypeWwwFormUrlEncoded =
    'application/x-www-form-urlencoded'; //; charset=utf-8';

/// One (secret or publishable) is needed only
class StripeApiCredentials {
  final String? secretKey;
  final String? publishableKey;

  StripeApiCredentials({this.secretKey, this.publishableKey}) {
    assert(secretKey != null || publishableKey != null);
  }

  StripeApiCredentials withoutSecretKey() =>
      StripeApiCredentials(publishableKey: publishableKey);

  StripeApiCredentials withoutPublishableKey() =>
      StripeApiCredentials(secretKey: secretKey);
}

typedef StripeApiBodyFields = Map<String, String>;

// ignore: prefer_collection_literals
StripeApiBodyFields newStripeApiBodyFields() => StripeApiBodyFields();

/// Stripe API client
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

  /// POST [bodyFields] (form url encoded).
  Future<T> _send<T extends CvModel>(Uri uri, StripeApiBodyFields bodyFields) =>
      _read<T>(httpMethodPost, uri, bodyFields: bodyFields);

  Future<T> _get<T extends CvModel>(Uri uri) => _read<T>(httpMethodGet, uri);

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
    var uri = _uri('payment_links/$paymentLinkId');
    var bodyFields = options.toStripeApiBodyFields();
    return _send<StripeApiPaymentLink>(uri, bodyFields);
  }

  /// Get a payment link.
  Future<StripeApiPaymentLink> getPaymentLink(String paymentLinkId) async {
    var uri = _uri('payment_links/$paymentLinkId');
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
    var uri = _uri('prices/$priceId');
    var bodyFields = options.toStripeApiBodyFields();
    return _send<StripeApiPrice>(uri, bodyFields);
  }

  /// Get a price.
  Future<StripeApiPrice> getPrice(String priceId) async {
    var uri = _uri('prices/$priceId');

    return _get<StripeApiPrice>(uri);
  }

  /// Create a product with optional options.
  Future<StripeApiProduct> createProduct(StripeApiProductCreate options) async {
    var uri = _uri('products');
    var bodyFields = options.toStripeApiBodyFields();
    return _send<StripeApiProduct>(uri, bodyFields);
  }

  /// Get a product.
  Future<StripeApiProduct> getProduct(String productId) async {
    var uri = _uri('products/$productId');

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

  Future<void> close() async {
    _clientOrNull?.close();
  }
}
