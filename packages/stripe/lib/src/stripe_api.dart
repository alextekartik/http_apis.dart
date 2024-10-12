import 'package:cv/cv_json.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/basic_auth_client.dart';
import 'package:tekartik_http/http_client.dart';
import 'package:tekartik_stripe_api/src/api_options.dart';
import 'package:tekartik_stripe_api/src/payment_link_options.dart';
import 'package:tekartik_stripe_api/src/price_model.dart';
import 'package:tekartik_stripe_api/src/price_options.dart';
import 'package:tekartik_stripe_api/src/product_model.dart';
import 'package:tekartik_stripe_api/src/product_options.dart';

import 'payment_link_model.dart';
import 'stripe_models.dart';

var debugStripeApi = false;
final stripeApiUrlBase = Uri.parse('https://api.stripe.com/v1');

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

extension StripeApiBodyFieldsExt on StripeApiBodyFields {
  void addMetadata(StripeApiMetadata? metadata) {
    if (metadata != null) {
      for (var entry in metadata.entries) {
        this['metadata[${entry.key}]'] = '${entry.value}';
      }
    }
  }
}

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
      credentials.secretKey ?? credentials.publishableKey!, '',
      inner: baseClient);
  Client? _clientOrNull;

  Uri get _stripeApiUrlBase => baseUri ?? stripeApiUrlBase;

  Uri _uri(String path) =>
      _stripeApiUrlBase.replace(path: url.join(_stripeApiUrlBase.path, path));

  Future<T> _send<T extends CvModel>(
      Uri uri, Map<String, String> bodyFields) async {
    var headers = {
      httpHeaderContentType: httpContentTypeWwwFormUrlEncoded,
    };
    var request = Request(httpMethodPost, uri);
    request.headers.clear();
    request.headers.addAll(headers);

    request.bodyFields = bodyFields;
    if (debugStripeApi) {
      print('send: $uri');
      print('      ${request.bodyFields}');
    }

    request.encoding = Encoding.getByName('utf-8')!;

    var response = await _client.send(request);
    var data = await response.stream.bytesToString();
    if (debugStripeApi) {
      print('recv: $data');
    }
    var object = data.cv<T>();
    return object;
  }

  Future<T> _get<T extends CvModel>(Uri uri) async {
    if (debugStripeApi) {
      print('get: $uri');
    }
    var request = Request(httpMethodGet, uri);
    var response = await _client.send(request);
    var data = await response.stream.bytesToString();
    if (debugStripeApi) {
      print('recv: $data');
    }
    var object = data.cv<T>();
    return object;
  }

  /// Create a payment link from a give price.
  /// https://stripe.com/docs/api/payment_links/payment_links/create
  Future<StripeApiPaymentLink> createPaymentLink(
      StripeApiPaymentLinkCreate options) async {
    var uri = _uri('payment_links');
    var bodyFields = options.toStripeApiBodyFields();
    return _send<StripeApiPaymentLink>(uri, bodyFields);
  }

  /// https://stripe.com/docs/api/payment_links/payment_links/update
  Future<StripeApiPaymentLink> updatePaymentLink(
      String paymentLinkId, StripeApiPaymentLinkUpdate options) async {
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
      String priceId, StripeApiPriceUpdate options) async {
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
      StripeApiProductListOptions options) async {
    var uri = _uri('products');

    return _get<StripeApiProductList>(
        uri.replace(queryParameters: options.toStripeApiParam()));
  }

  Future<void> close() async {
    _clientOrNull?.close();
  }
}
