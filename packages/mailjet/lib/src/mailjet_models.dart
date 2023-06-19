import 'package:cv/cv.dart';

void initMailjetCvBuilders() {
  cvAddConstructor(CvMailjetSendEmailResponse.new);
  cvAddConstructor(CvMailjetRecipientResponse.new);
  cvAddConstructor(CvMailjetMessageResponse.new);
  cvAddConstructor(CvMailjetSendEmailRequest.new);
  cvAddConstructor(CvMailjetMessage.new);
  cvAddConstructor(CvMailjetRecipient.new);
  cvAddConstructor(CvMailjetAttachment.new);
}

class CvMailjetCredentials extends CvModelBase {
  late final apiKey = CvField<String>('apiKey');
  late final apiSecretKey = CvField<String>('apiSecretKey');
  @override
  List<CvField<Object?>> get fields => [apiKey, apiSecretKey];
}

// {
//   "Messages": [
//     {
//       "Status": "success",
//       "To": [
//         {
//           "Email": "passenger@mailjet.com",
//           "MessageID": "1234567890987654321",
//           "MessageHref": "https://api.mailjet.com/v3/message/1234567890987654321"
//         }
//       ]
//     }
//   ]
// }
class CvMailjetSendEmailResponse extends CvModelBase {
  final messages = CvModelListField<CvMailjetMessageResponse>('Messages');
  @override
  List<CvField<Object?>> get fields => [messages];
}

// {
// //       "Status": "success",
// //       "To": [
// //         {
// //           "Email": "passenger@mailjet.com",
// //           "MessageID": "1234567890987654321",
// //           "MessageHref": "https://api.mailjet.com/v3/message/1234567890987654321"
// //         }
// //       ]
// //     }
class CvMailjetMessageResponse extends CvModelBase {
  late final status = CvField<String>('Status');
  late final to = CvModelListField<CvMailjetRecipientResponse>('To');
  @override
  List<CvField<Object?>> get fields => [status, to];
}

// {
// // //           "Email": "passenger@mailjet.com",
// // //           "MessageID": "1234567890987654321",
// // //           "MessageHref": "https://api.mailjet.com/v3/message/1234567890987654321"
// // //         }
class CvMailjetRecipientResponse extends CvModelBase {
  late final email = CvField<String>('Email');
  late final messageId = CvField<String>('MessageID');
  late final messageHref = CvField<String>('MessageHref');
  @override
  List<CvField<Object?>> get fields => [email, messageId, messageHref];
}

//curl -s \
// 	-X POST \
// 	--user "$MJ_APIKEY_PUBLIC:$MJ_APIKEY_PRIVATE" \
// 	https://api.mailjet.com/v3.1/send \
// 	-H 'Content-Type: application/json' \
// 	-d '{
// 		"Messages":[
// 				{
// 						"From": {
// 								"Email": "$SENDER_EMAIL",
// 								"Name": "Me"
// 						},
// 						"To": [
// 								{
// 										"Email": "$RECIPIENT_EMAIL",
// 										"Name": "You"
// 								}
// 						],
// 						"Subject": "My first Mailjet Email!",
// 						"TextPart": "Greetings from Mailjet!",
// 						"HTMLPart": "<h3>Dear passenger 1, welcome to <a href=\"https://www.mailjet.com/\">Mailjet</a>!</h3><br />May the delivery force be with you!"
// 				}
// 		]
// 	}'
class CvMailjetSendEmailRequest extends CvModelBase {
  late final messages = CvModelListField<CvMailjetMessage>('Messages');

  @override
  List<CvField<Object?>> get fields => [messages];
}

// {
// // 						"From": {
// // 								"Email": "$SENDER_EMAIL",
// // 								"Name": "Me"
// // 						},
// // 						"To": [
// // 								{
// // 										"Email": "$RECIPIENT_EMAIL",
// // 										"Name": "You"
// // 								}
// // 						],
// // 						"Subject": "My first Mailjet Email!",
// // 						"TextPart": "Greetings from Mailjet!",
// // 						"HTMLPart": "<h3>Dear passenger 1, welcome to <a href=\"https://www.mailjet.com/\">Mailjet</a>!</h3><br />May the delivery force be with you!"
// // "TextPart": "Dear passenger 1, welcome to Mailjet! May the delivery force be with you!",
// 						"HTMLPart": "<h3>Dear passenger 1, welcome to <a href=\"https://www.mailjet.com/\">Mailjet</a>!</h3><br />May the delivery force be with you!",
// 						"Attachments": [
// 								{
// 										"ContentType": "text/plain",
// 										"Filename": "test.txt",
// 										"Base64Content": "VGhpcyBpcyB5b3VyIGF0dGFjaGVkIGZpbGUhISEK"
// 								}
// 						]
// // 				}
class CvMailjetMessage extends CvModelBase {
  late final from = CvModelField<CvMailjetRecipient>('From');
  late final to = CvModelListField<CvMailjetRecipient>('To');
  late final cc = CvModelListField<CvMailjetRecipient>('Cc');
  late final bcc = CvModelListField<CvMailjetRecipient>('Bcc');
  late final subject = CvField<String>('Subject');
  late final textPart = CvField<String>('TextPart');
  late final htmlPart = CvField<String>('HTMLPart');
  late final attachments = CvModelListField<CvMailjetAttachment>('Attachments');
  @override
  late final fields = [
    from,
    to,
    cc,
    bcc,
    subject,
    textPart,
    htmlPart,
    attachments
  ];
}

/// "Attachments": [
// 								{
// 										"ContentType": "text/plain",
// 										"Filename": "test.txt",
// 										"Base64Content": "VGhpcyBpcyB5b3VyIGF0dGFjaGVkIGZpbGUhISEK"
// 								}
// 						]
class CvMailjetAttachment extends CvModelBase {
  late final contentType = CvField<String>('ContentType');
  late final filename = CvField<String>('Filename');
  late final base64Content = CvField<String>('Base64Content');
  @override
  late final fields = [contentType, filename, base64Content];
}

// {
// // // 										"Email": "$RECIPIENT_EMAIL",
// // // 										"Name": "You"
// // // 								}
class CvMailjetRecipient extends CvModelBase {
  late final email = CvField<String>('Email');
  late final name = CvField<String>('Name');
  @override
  late final fields = [email, name];
}
