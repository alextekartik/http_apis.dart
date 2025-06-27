import 'package:cv/cv.dart';
import 'package:tekartik_mailjet/mailjet.dart';
import 'package:test/test.dart';

CvFillOptions get apiFillOptions =>
    CvFillOptions(collectionSize: 1, valueStart: 1);

//a request contains a header field in the form of Authorization: Basic <credentials>, where credentials is the Base64 encoding of ID and password joined by a single colon :.

void main() {
  initMailjetCvBuilders();
  test('model', () {
    expect((CvMailjetSendEmailRequest()..fillModel(apiFillOptions)).toMap(), {
      'Messages': [
        {
          'From': {'Email': 'text_2', 'Name': 'text_3'},
          'To': [
            {'Email': 'text_4', 'Name': 'text_5'},
          ],
          'Cc': [
            {'Email': 'text_6', 'Name': 'text_7'},
          ],
          'Bcc': [
            {'Email': 'text_8', 'Name': 'text_9'},
          ],
          'Subject': 'text_10',
          'TextPart': 'text_11',
          'HTMLPart': 'text_12',
          'Attachments': [
            {
              'ContentType': 'text_13',
              'Filename': 'text_14',
              'Base64Content': 'text_15',
            },
          ],
          'TemplateID': 16,
          'TemplateLanguage': false,
        },
      ],
    });
    expect((CvMailjetSendEmailResponse()..fillModel(apiFillOptions)).toMap(), {
      'Messages': [
        {
          'Status': 'text_2',
          'To': [
            {'Email': 'text_3', 'MessageID': 'text_4', 'MessageHref': 'text_5'},
          ],
        },
      ],
    });
  });
}
