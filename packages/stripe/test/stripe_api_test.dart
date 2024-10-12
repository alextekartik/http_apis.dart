import 'package:cv/cv_json.dart';
import 'package:tekartik_http/http_memory.dart';
import 'package:tekartik_stripe_api/src/import.dart';
import 'package:tekartik_stripe_api/stripe_api.dart';
import 'package:test/test.dart';

void main() {
  // debugStripeApi = devWarning(true);
  group('memory', () {
    group('server', () {
      var httpFactory = httpFactoryMemory;
      late HttpServer server;
      late Uri uri;
      late StripeApi stripeApi;
      late Client client;

      setUp(() async {
        server = await httpFactory.server.bind(InternetAddress.anyIPv4, 1);
        expect(server.address, InternetAddress.anyIPv4);
        uri = httpServerGetUri(server);
        server.listen((request) {
          var path = request.uri.path;
          if (path.startsWith('/')) {
            path = path.substring(1);
          }
          void sendResponse(Object? object) {
            request.response
              ..write(jsonPretty(object))
              ..close();
          }

          if (path == 'prices') {
            sendResponse((StripeApiPrice()..id.v = 'price_1').toJson());
          } else {
            print('request: $path');
            request.response
              ..write('test')
              ..close();
          }
        });
        client = httpFactory.client.newClient();
        stripeApi = StripeApi(
            credentials: StripeApiCredentials(
                secretKey: 'secret', publishableKey: 'publishable'),
            baseUri: uri,
            baseClient: client);
      });
      tearDown(() async {
        await server.close();
        client.close();
      });
      test('createPrice', () async {
        var result = await stripeApi.createPrice(StripeApiPriceCreate()
          ..productId.v = 'product'
          ..amount.v = 1000
          ..currency.v = stripeCurrencyEuro
          ..nickname.v = 'Test recurring with accént'
          ..metadata.v = {
            'meta_1': 'Test meta value',
            'meta_2': 'Test meta value 2'
          }
          ..recurring.v = (StringApiPriceRecurring()
            ..interval.v = stripePriceRecurringIntervalDay
            ..intervalCount.v = 1));
        expect(result.id.v, 'price_1');
      });
    });
  });
}
