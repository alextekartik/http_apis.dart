// The pasted json keeps its double quotes.
// ignore_for_file: prefer_single_quotes

import 'dart:convert';

import 'package:tekartik_stripe_api/stripe_api.dart';
import 'package:test/test.dart';

// Fake keys, in the shape of Stripe's.
const _publishableKey = 'pk_test_51AbcdEFghIJklMNopQRstUVwxYZ0123456789wxyz';
const _secretKey = 'sk_test_51AbcdEFghIJklMNopQRstUVwxYZ9876543210abcd';

void main() {
  var credentials = StripeApiCredentials(
    publishableKey: _publishableKey,
    secretKey: _secretKey,
  );

  void expectSame(StripeApiCredentials read, StripeApiCredentials expected) {
    expect(read.publishableKey, expected.publishableKey);
    expect(read.secretKey, expected.secretKey);
  }

  test('obfuscate', () {
    expect(stripeApiKeyObfuscate(_publishableKey), 'pk_test_51Ab...wxyz');
    expect(stripeApiKeyObfuscate(_secretKey, showEnds: false), 'sk_test_...');
    expect(stripeApiKeyObfuscate('rk_live_short'), 'rk_live_...');
    expect(stripeApiKeyObfuscate('unknown_key_value_long'), 'unkn...long');
  });

  test('map', () {
    expect(credentials.toMap(), {
      'publishableKey': _publishableKey,
      'secretKey': _secretKey,
    });
    expectSame(StripeApiCredentials.fromMap(credentials.toMap()), credentials);
    expect(
      () => StripeApiCredentials.fromMap({'secretKey': ''}),
      throwsFormatException,
    );
  });

  test('map enc', () {
    var map = credentials.toMapEnc();
    // No key in clear.
    var text = jsonEncode(map);
    expect(text, isNot(contains(_publishableKey)));
    expect(text, isNot(contains(_secretKey.substring(8))));
    expect(map['type'], stripeApiCredentialsEncType);
    expect(map['publishableKey'], 'pk_test_51Ab...wxyz');
    expect(map['secretKey'], 'sk_test_...');
    expect(map['password'], hasLength(32));
    expectSame(StripeApiCredentials.fromMapEnc(map), credentials);
    // A random password: never the same map twice.
    expect(jsonEncode(credentials.toMapEnc()), isNot(text));

    // One key only.
    var secretOnly = credentials.withoutPublishableKey();
    map = secretOnly.toMapEnc(password: 'aaaabbbbccccdddd');
    expect(map.containsKey('publishableKey'), isFalse);
    expect(map['password'], 'aaaabbbbccccdddd');
    expectSame(StripeApiCredentials.fromMapEnc(map), secretOnly);
  });

  test('json enc', () {
    var text = credentials.toJsonEnc();
    expect(text, startsWith('{\n  "type": "stripe_credentials_enc",\n'));
    expectSame(
      StripeApiCredentials.fromMapEnc(jsonDecode(text) as Map),
      credentials,
    );
  });

  test('map enc pasted', () {
    // The json written by toJsonEnc, pasted as a dart map literal.
    var pasted = StripeApiCredentials.fromMapEnc({
      "type": "stripe_credentials_enc",
      "publishableKey": "pk_test_51Ab...wxyz",
      "secretKey": "sk_test_...",
      "password": "JYmDsEVwXqcn97GKHuEdC6kxhrjcbZIR",
      "enc":
          "OX6gePl0RbZHzGEq5xqEVA==hkCCJpF23fNiT9YHyogLjv764PR/RPODuZZyQ5nQ8kAxurUjdOJDyDrVHfVmcAaMUq01ab38JxrzgfKrNczgjfKl0OU52q2169ME0SeT/Apcs6UUXXZRdrBWqWlfBxFm1kWYwhDYJs3Q9EKEbtpl1iFYEGu5tLe1EmnxPa3Vr7K3bys2ZGOC+s/AlenQgF8j",
    });
    expectSame(pasted, credentials);
  });

  test('map plain', () {
    expectSame(
      StripeApiCredentials.fromMapEnc(credentials.toMap()),
      credentials,
    );
  });

  test('map enc errors', () {
    expect(() => credentials.toMapEnc(password: 'short'), throwsArgumentError);
    var map = credentials.toMapEnc();
    for (var bad in <Map<String, Object?>>[
      {},
      // A wrong password.
      {...map, 'password': 'aaaabbbbccccddddaaaabbbbccccdddd'},
      // Not the keys shown in clear.
      {...map, 'publishableKey': 'pk_test_51Ab...0000'},
      {...map, 'secretKey': 'sk_live_...'},
    ]) {
      expect(
        () => StripeApiCredentials.fromMapEnc(bad),
        throwsFormatException,
        reason: '$bad',
      );
    }
  });
}
