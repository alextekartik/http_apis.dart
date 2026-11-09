import 'dart:io';

import 'package:tekartik_http/http_client.dart';
import 'package:tekartik_mailjet/mailjet.dart';

/// Sends one email.
///
/// ```sh
/// MJ_APIKEY_PUBLIC=... MJ_APIKEY_PRIVATE=... MJ_FROM=me@example.com \
///   MJ_TO=you@example.com dart run example/main.dart
/// ```
Future<void> main() async {
  var env = Platform.environment;
  var apiKey = env['MJ_APIKEY_PUBLIC'];
  var apiSecret = env['MJ_APIKEY_PRIVATE'];
  var from = env['MJ_FROM'];
  var to = env['MJ_TO'];
  if ([apiKey, apiSecret, from, to].any((value) => value?.isEmpty ?? true)) {
    stderr.writeln(
      'Set MJ_APIKEY_PUBLIC, MJ_APIKEY_PRIVATE, MJ_FROM (a sender validated '
      'in Mailjet) and MJ_TO',
    );
    exitCode = 64;
    return;
  }
  var client = MailjetClient(apiKey: apiKey!, apiSecret: apiSecret!);
  try {
    var response = await client.sendEmail(
      CvMailjetSendEmailRequest()
        ..messages.v = [
          CvMailjetMessage()
            ..from.v = (CvMailjetRecipient()..email.v = from)
            ..to.v = [CvMailjetRecipient()..email.v = to]
            ..subject.v = 'Hello'
            ..textPart.v = 'Hello from tekartik_mailjet',
        ],
    );
    for (var message in response.messages.v ?? <CvMailjetMessageResponse>[]) {
      // ignore: avoid_print
      print('${message.status.v} ${message.to.v?.first.messageId.v}');
    }
  } on HttpClientException catch (e) {
    stderr.writeln('Mailjet error ${e.statusCode}: ${e.response.body}');
    exitCode = 1;
  } finally {
    client.close();
  }
}
