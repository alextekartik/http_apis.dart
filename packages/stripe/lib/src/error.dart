import 'dart:convert';

import 'package:tekartik_http/http_client.dart';

/// The text of an [error] of a call: for a Stripe answer
/// ([HttpClientException]) its status and `error.message` (Stripe masks the
/// keys it quotes), the error text otherwise.
String stripeApiErrorMessage(Object error) {
  if (error is HttpClientException) {
    String? message;
    try {
      var body = jsonDecode(utf8.decode(error.response.bodyBytes));
      if (body is Map && body['error'] is Map) {
        var stripeError = body['error'] as Map;
        message = (stripeError['message'] ?? stripeError['code'])?.toString();
      }
    } catch (_) {
      // Not a Stripe json answer.
    }
    return message == null
        ? 'HTTP ${error.statusCode}'
        : '${error.statusCode}: $message';
  }
  return error.toString();
}
