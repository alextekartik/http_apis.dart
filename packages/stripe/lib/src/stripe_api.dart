// TODO: Put public facing types in this file.

import 'package:cv/cv_json.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_http/basic_auth_client.dart';
import 'package:tekartik_http/http_client.dart';
import 'package:tekartik_stripe_api/src/format.dart';
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
}

/// Stripe API client
class StripeApi {
  final StripeApiCredentials credentials;

  StripeApi({required this.credentials}) {
    initStripeApiModels();
  }

  Client get _client => _clientOrNull ??=
      BasicAuthClient(credentials.secretKey ?? credentials.publishableKey!, '');
  Client? _clientOrNull;

  Uri _uri(String path) =>
      stripeApiUrlBase.replace(path: url.join(stripeApiUrlBase.path, path));

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
  Future<StripeApiPaymentLink> createPaymentLink(
      {required String priceId}) async {
    var uri = _uri('payment_links');
    var bodyFields = {
      'line_items[0][price]': priceId,
      'line_items[0][quantity]': '1'
    };
    return _send<StripeApiPaymentLink>(uri, bodyFields);
  }

  /// Get a payment link.
  Future<StripeApiPaymentLink> getPaymentLink(String paymentLinkId) async {
    var uri = _uri('payment_links/$paymentLinkId');
    return _get<StripeApiPaymentLink>(uri);
  }

  /// Create a price with optional options.
  Future<StripeApiPrice> createPrice(StripeApiPriceOptions options) async {
    var uri = _uri('prices');

    var bodyFields = <String, String>{
      'unit_amount': formatAmount(options.amount),
      'currency': options.currency,
      'product': options.productId,
    };
    var recurring = options.recurring;
    if (recurring != null) {
      bodyFields.addAll({
        'recurring[interval]': recurring.interval,
        'recurring[interval_count]': recurring.intervalCount.toString(),
      });
    }
    return _send<StripeApiPrice>(uri, bodyFields);
  }

  /// Get a price.
  Future<StripeApiPrice> getPrice(String priceId) async {
    var uri = _uri('prices/$priceId');

    return _get<StripeApiPrice>(uri);
  }

  /// Create a product with optional options.
  Future<StripeApiProduct> createProduct(
      StripeApiProductOptions options) async {
    var uri = _uri('products');

    var bodyFields = <String, String>{
      'name': options.name,
      if (options.description != null) 'description': options.description!,
    };

    return _send<StripeApiProduct>(uri, bodyFields);
  }

  /// Get a product.
  Future<StripeApiProduct> getProduct(String productId) async {
    var uri = _uri('products/$productId');

    return _get<StripeApiProduct>(uri);
  }

  Future<void> close() async {
    _clientOrNull?.close();
  }
}
