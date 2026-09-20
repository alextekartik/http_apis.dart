---
name: tekartik-mailjet-send-email
description: >-
  Use when sending transactional email through the Mailjet Send API v3.1 from
  Dart with tekartik_mailjet: MailjetClient, MailjetClient.widthCredentials,
  MailjetCredentials, sendEmail, close, and the cv models
  CvMailjetSendEmailRequest, CvMailjetMessage, CvMailjetRecipient,
  CvMailjetAttachment, CvMailjetSendEmailResponse, CvMailjetMessageResponse,
  CvMailjetRecipientResponse, plus initMailjetCvBuilders, debugMailjet,
  injecting a mock http Client in tests and handling HttpClientException.
---

# Sending email with Mailjet (tekartik_mailjet)

`tekartik_mailjet` is a minimal client for the Mailjet Send API v3.1
(`POST https://api.mailjet.com/v3.1/send`, basic auth). Request and response
are `cv` models (`package:cv`), so every field is a `CvField` written and read
through `.v`.

## Guidelines

* Dependency (git, not on pub.dev); add `cv` too, since you build the models:
  ```yaml
  dependencies:
    tekartik_mailjet:
      git:
        url: https://github.com/alextekartik/http_apis.dart
        path: packages/mailjet
      version: '>=0.1.0'
    cv: '>=1.1.0+4'
  ```
* Single import: `package:tekartik_mailjet/mailjet.dart` (exports the client
  and all the models). Never import `package:tekartik_mailjet/src/...`.
* Create the client with `MailjetClient(apiKey: ..., apiSecret: ...)`, or with
  `MailjetClient.widthCredentials(MailjetCredentials(apiKey, apiSecret))`
  (the typo in `widthCredentials` is the real name). Both accept an optional
  `client:` (`package:http` `Client`) used for every call. The constructor
  registers the cv builders for you.
* The api key pair is the Mailjet *API Key* and *Secret Key*. Read them from
  the environment or an untracked config file; never commit them and never put
  them in an example.
* Reuse one `MailjetClient` for the life of the process and `close()` it when
  done (it closes the underlying http client, including one you injected).
* Sending: `sendEmail(CvMailjetSendEmailRequest)` returns a
  `CvMailjetSendEmailResponse`. One request carries a list of
  `CvMailjetMessage` in `messages` (up to Mailjet's per-call limit), so batch
  instead of calling `sendEmail` in a loop.
* `CvMailjetMessage` fields: `from` and `to`/`cc`/`bcc` (`CvMailjetRecipient`
  with `email` and `name`), `subject`, `textPart`, `htmlPart`, `templateId` +
  `templateLanguage` for a Mailjet template, `attachments`
  (`CvMailjetAttachment` with `contentType`, `filename`, `base64Content`).
  `from` and a non-empty `to` are required by Mailjet; fields you leave unset
  are simply absent from the json, so do not set `cc`/`bcc` to empty lists.
  Use a template (`templateId` + `templateLanguage.v = true`) or
  `textPart`/`htmlPart`, not both.
* Attachments are inline base64 in the json: keep them small
  (`base64Encode(bytes)` for `base64Content`, plus a mime `contentType`).
* Response: `response.messages.v` is a list of `CvMailjetMessageResponse`
  aligned with the request messages, each with `status` (`'success'` or
  `'error'`) and `to`, a list of `CvMailjetRecipientResponse`
  (`email`, `messageId`, `messageHref`). Mailjet answers `200` with a
  per-message `status`, so always check `status.v`, not just the absence of an
  exception.
* Transport failures (401 on wrong credentials, 4xx/5xx) throw
  `HttpClientException` from `package:tekartik_http/http_client.dart`
  (also a `package:http` `ClientException`): read `e.statusCode` and
  `e.response.body`. There is no Mailjet-specific exception type.
* Set the top-level `debugMailjet = true` *before* creating the client (the
  flag is captured at construction) to print the sent and received json.
  Turn it off in production: the dump contains recipient addresses.
* Tests: pass a `MockClient` from `package:http/testing.dart` as `client:` and
  assert on the posted body - nothing else is injectable, the url is
  hardcoded. For model-only tests with no client, call
  `initMailjetCvBuilders()` first, otherwise `.cv<CvMailjetSendEmailResponse>()`
  and the nested model fields have no builder. `CvMailjetCredentials`
  (`apiKey`, `apiSecretKey`) is a model for storing credentials in your own
  config; it is not registered by `initMailjetCvBuilders()`, so build it
  directly rather than with `.cv<CvMailjetCredentials>()`.

## Examples

### Send one email

```dart
import 'dart:io';

import 'package:tekartik_mailjet/mailjet.dart';

Future<void> main() async {
  var env = Platform.environment;
  var client = MailjetClient(
    apiKey: env['MJ_APIKEY_PUBLIC']!,
    apiSecret: env['MJ_APIKEY_PRIVATE']!,
  );
  try {
    var response = await client.sendEmail(
      CvMailjetSendEmailRequest()
        ..messages.v = [
          CvMailjetMessage()
            ..from.v = (CvMailjetRecipient()
              ..email.v = 'no-reply@example.com'
              ..name.v = 'Example')
            ..to.v = [CvMailjetRecipient()..email.v = 'user@example.com']
            ..subject.v = 'Hello'
            ..textPart.v = 'Greetings from Mailjet!'
            ..htmlPart.v = '<h3>Greetings from Mailjet!</h3>',
        ],
    );
    for (var message in response.messages.v ?? <CvMailjetMessageResponse>[]) {
      print('${message.status.v} ${message.to.v?.first.messageId.v}');
    }
  } finally {
    client.close();
  }
}
```

### Batch, template, attachment, and error handling

```dart
import 'dart:convert';
import 'dart:io';

import 'package:tekartik_http/http_client.dart';
import 'package:tekartik_mailjet/mailjet.dart';

Future<void> sendInvoices(
  MailjetClient client,
  Map<String, File> invoiceByEmail,
) async {
  var messages = <CvMailjetMessage>[];
  for (var entry in invoiceByEmail.entries) {
    messages.add(
      CvMailjetMessage()
        ..from.v = (CvMailjetRecipient()..email.v = 'billing@example.com')
        ..to.v = [CvMailjetRecipient()..email.v = entry.key]
        ..bcc.v = [CvMailjetRecipient()..email.v = 'archive@example.com']
        // Mailjet template, variables come from the template itself.
        ..templateId.v = 1234567
        ..templateLanguage.v = true
        ..subject.v = 'Your invoice'
        ..attachments.v = [
          CvMailjetAttachment()
            ..contentType.v = 'application/pdf'
            ..filename.v = 'invoice.pdf'
            ..base64Content.v = base64Encode(await entry.value.readAsBytes()),
        ],
    );
  }

  try {
    var response = await client.sendEmail(
      CvMailjetSendEmailRequest()..messages.v = messages,
    );
    // 200 does not mean delivered: check every message status.
    var failed = (response.messages.v ?? <CvMailjetMessageResponse>[])
        .where((m) => m.status.v != 'success')
        .toList();
    if (failed.isNotEmpty) {
      print('${failed.length} message(s) rejected');
    }
  } on HttpClientException catch (e) {
    // 401: wrong api key/secret. 400: invalid payload.
    print('mailjet failed ${e.statusCode}: ${e.response.body}');
    rethrow;
  }
}
```

### Unit test with a mock http client

```dart
import 'dart:convert';

import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:tekartik_mailjet/mailjet.dart';
import 'package:test/test.dart';

void main() {
  test('sendEmail posts the expected json', () async {
    Object? sent;
    var mock = MockClient((request) async {
      sent = jsonDecode(request.body);
      expect(request.url.toString(), 'https://api.mailjet.com/v3.1/send');
      expect(request.headers['authorization'], startsWith('Basic '));
      return http.Response(
        jsonEncode({
          'Messages': [
            {
              'Status': 'success',
              'To': [
                {'Email': 'user@example.com', 'MessageID': '1234567890'},
              ],
            },
          ],
        }),
        200,
      );
    });
    var client = MailjetClient(
      apiKey: 'test-api-key',
      apiSecret: 'test-api-secret',
      client: mock,
    );
    var response = await client.sendEmail(
      CvMailjetSendEmailRequest()
        ..messages.v = [
          CvMailjetMessage()
            ..from.v = (CvMailjetRecipient()..email.v = 'no-reply@example.com')
            ..to.v = [CvMailjetRecipient()..email.v = 'user@example.com']
            ..subject.v = 'Hello'
            ..textPart.v = 'Hi',
        ],
    );
    expect(response.messages.v!.first.status.v, 'success');
    expect(response.messages.v!.first.to.v!.first.messageId.v, '1234567890');
    expect(sent, {
      'Messages': [
        {
          'From': {'Email': 'no-reply@example.com'},
          'To': [
            {'Email': 'user@example.com'},
          ],
          'Subject': 'Hello',
          'TextPart': 'Hi',
        },
      ],
    });
    client.close();
  });
}
```

### Building a request from a json map

```dart
import 'package:cv/cv_json.dart';
import 'package:tekartik_mailjet/mailjet.dart';

Future<void> sendFromMap(MailjetClient client) async {
  initMailjetCvBuilders(); // no-op once a MailjetClient exists
  var request = {
    'Messages': [
      {
        'From': {'Email': 'no-reply@example.com', 'Name': 'Example'},
        'To': [
          {'Email': 'user@example.com', 'Name': 'User'},
        ],
        'Subject': 'Hello',
        'HTMLPart': '<h3>Hello</h3>',
      },
    ],
  }.cv<CvMailjetSendEmailRequest>();
  var response = await client.sendEmail(request);
  print(response.toMap());
}
```
