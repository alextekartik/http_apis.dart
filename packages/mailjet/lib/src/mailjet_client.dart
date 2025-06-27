import 'dart:convert';

import 'package:cv/cv.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
// ignore: depend_on_referenced_packages
import 'package:tekartik_http/http_client.dart';

import 'mailjet_models.dart';

/// To set before creating the client.
var debugMailjet = false;

class MailjetCredentials {
  final String apiKey;
  final String apiSecret;
  MailjetCredentials(this.apiKey, this.apiSecret);
}

/// The main client
class MailjetClient {
  final _debug = debugMailjet;
  late final MailjetCredentials credentials;
  String get apiKey => credentials.apiKey;
  String get apiSecret => credentials.apiSecret;
  late final http.Client _client;

  static String _getAuthString(String username, String password) {
    final token = base64.encode(latin1.encode('$username:$password'));

    final authString = 'Basic ${token.trim()}';

    return authString;
  }

  MailjetClient.widthCredentials(this.credentials, {http.Client? client}) {
    _client = client ?? http.Client();
    initMailjetCvBuilders();
  }

  MailjetClient({
    required String apiKey,
    required String apiSecret,
    http.Client? client,
  }) : this.widthCredentials(
         MailjetCredentials(apiKey, apiSecret),
         client: client,
       );

  /// The main way to send an email
  Future<CvMailjetSendEmailResponse> sendEmail(
    CvMailjetSendEmailRequest request,
  ) async {
    var result = await _send(request.toMap());
    return result.cv<CvMailjetSendEmailResponse>();
  }

  Future<Map> _send(Map request) async {
    var body = jsonEncode(request);
    if (_debug) {
      print('send: $body');
    }
    var resultText = await httpClientRead(
      _client,
      httpMethodPost,
      Uri.parse('https://api.mailjet.com/v3.1/send'),
      headers: {
        httpHeaderContentType: httpContentTypeJson,
        httpHeaderAuthorization: _getAuthString(apiKey, apiSecret),
      },
      body: body,
    );
    if (_debug) {
      print('recv: $resultText');
    }
    return jsonDecode(resultText) as Map;
  }

  /// Dispose the client
  void close() {
    _client.close();
  }
}
