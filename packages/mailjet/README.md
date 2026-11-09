# tekartik_mailjet

A minimal Dart client of the [Mailjet Send API v3.1](https://dev.mailjet.com/email/guides/send-api-v31/)
(`POST https://api.mailjet.com/v3.1/send`): transactional email, with
templates and attachments. Requests and answers are `cv` models
(`field.v`).

## Getting started

Git package, not on pub.dev:

```yaml
dependencies:
  tekartik_mailjet:
    git:
      url: https://github.com/alextekartik/http_apis.dart
      path: packages/mailjet
```

```dart
import 'dart:io';

import 'package:tekartik_mailjet/mailjet.dart';

Future<void> main() async {
  var env = Platform.environment;
  // The API key and secret key of your Mailjet account, never in the source.
  var client = MailjetClient(
    apiKey: env['MJ_APIKEY_PUBLIC']!,
    apiSecret: env['MJ_APIKEY_PRIVATE']!,
  );
  try {
    var response = await client.sendEmail(
      CvMailjetSendEmailRequest()
        ..messages.v = [
          CvMailjetMessage()
            ..from.v = (CvMailjetRecipient()..email.v = 'no-reply@example.com')
            ..to.v = [CvMailjetRecipient()..email.v = 'user@example.com']
            ..subject.v = 'Hello'
            ..textPart.v = 'Hello from Mailjet',
        ],
    );
    for (var message in response.messages.v ?? <CvMailjetMessageResponse>[]) {
      print(message.status.v); // success
    }
  } finally {
    client.close();
  }
}
```

Platforms: any Dart with `package:http` (VM, node, Flutter); the secret key
belongs to a server, never to an app or a web page.
[example/main.dart](example/main.dart) sends one email.

## Common pitfalls

* An error answer (wrong keys: 401, an invalid message: 400) throws an
  `HttpClientException` (`package:tekartik_http/http_client.dart`):
  `statusCode`, and `response.body` holds Mailjet's errors. On success,
  still check the `status` of each message.
* `close()` also closes the `client:` you passed to the constructor.
* `debugMailjet = true` (set before creating the client) prints the sent
  and received json: recipient addresses and content, not the keys.
* The other constructor is spelled `MailjetClient.widthCredentials`.

More: the [tekartik-mailjet-send-email skill](skills/tekartik-mailjet-send-email/SKILL.md).

## Versioning

Follow [Tekartik git versioning system](https://github.com/tekartik/common.dart/blob/main/doc/tekartik_versioning.md)
