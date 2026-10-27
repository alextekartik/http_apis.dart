import 'dart:convert';

import 'package:tekartik_app_crypto/encrypt.dart';
import 'package:tekartik_app_crypto/password_generator.dart';

import 'stripe_api.dart';

/// The `type` of the obfuscated json of Stripe credentials
/// ([StripeApiCredentials.toJsonEnc]).
const stripeApiCredentialsEncType = 'stripe_credentials_enc';

/// The key lengths aes takes as a password, in bytes.
const _encPasswordLengths = [16, 24, 32];

/// The mode and kind prefix of a Stripe key (`pk_test_`, `sk_live_`,
/// `rk_test_`...).
final _keyPrefixRegExp = RegExp(r'^[a-z]+_(test|live)_');

/// [key] slightly obfuscated: its prefix (`pk_test_`, `sk_live_`...), then
/// the first and last 4 characters of the rest when [showEnds] is true.
///
/// `pk_test_51Abcd...wxyz`, `sk_live_...`
String stripeApiKeyObfuscate(String key, {bool showEnds = true}) {
  var prefix = _keyPrefixRegExp.firstMatch(key)?.group(0) ?? '';
  var rest = key.substring(prefix.length);
  if (!showEnds || rest.length < 16) {
    return '$prefix...';
  }
  return '$prefix${rest.substring(0, 4)}...${rest.substring(rest.length - 4)}';
}

/// The plain map of [credentials]: `publishableKey`, `secretKey`.
Map<String, Object?> stripeApiCredentialsToMap(
  StripeApiCredentials credentials,
) => {
  'publishableKey': ?credentials.publishableKey,
  'secretKey': ?credentials.secretKey,
};

/// The credentials of their plain [map] ([stripeApiCredentialsToMap]).
///
/// Throws a [FormatException] when it has no key; the message never quotes
/// a value.
StripeApiCredentials stripeApiCredentialsFromMap(Map<Object?, Object?> map) {
  String? key(String name) => switch (map[name]) {
    String value when value.isNotEmpty => value,
    _ => null,
  };
  var publishableKey = key('publishableKey');
  var secretKey = key('secretKey');
  if (publishableKey == null && secretKey == null) {
    throw const FormatException(
      'The Stripe credentials have no publishableKey nor secretKey',
    );
  }
  return StripeApiCredentials(
    publishableKey: publishableKey,
    secretKey: secretKey,
  );
}

/// The obfuscated map of [credentials]: the publishable key slightly
/// obfuscated and the kind of the secret key in clear, the whole credentials
/// aes encrypted with [password] (`enc`), the password next to it.
///
/// ```json
/// {
///   "type": "stripe_credentials_enc",
///   "publishableKey": "pk_test_51Ab...wxyz",
///   "secretKey": "sk_test_...",
///   "password": "<16, 24 or 32 characters>",
///   "enc": "<aes, base 64>"
/// }
/// ```
///
/// The password is in the map: this hides the keys from a glance, a grep or
/// a secret scanner, nothing more. Its json
/// ([stripeApiCredentialsToJsonEnc]) is a dart map literal too, read back by
/// [StripeApiCredentials.fromMapEnc] pasted as it is. [password] is 16, 24
/// or 32 ascii characters, a random one by default, so the same credentials
/// never obfuscate the same way twice.
Map<String, Object?> stripeApiCredentialsToMapEnc(
  StripeApiCredentials credentials, {
  String? password,
}) {
  password ??= generatePassword();
  if (!_encPasswordLengths.contains(utf8.encode(password).length)) {
    throw ArgumentError('The password must be 16, 24 or 32 ascii characters');
  }
  return {
    'type': stripeApiCredentialsEncType,
    if (credentials.publishableKey case var publishableKey?)
      'publishableKey': stripeApiKeyObfuscate(publishableKey),
    if (credentials.secretKey case var secretKey?)
      'secretKey': stripeApiKeyObfuscate(secretKey, showEnds: false),
    'password': password,
    'enc': aesEncrypt(
      jsonEncode(stripeApiCredentialsToMap(credentials)),
      password,
    ),
  };
}

/// The obfuscated map of [credentials] ([stripeApiCredentialsToMapEnc]) as
/// an indented json, to write in a git ignored file and paste in a
/// [StripeApiCredentials.fromMapEnc] call.
String stripeApiCredentialsToJsonEnc(
  StripeApiCredentials credentials, {
  String? password,
}) => const JsonEncoder.withIndent(
  '  ',
).convert(stripeApiCredentialsToMapEnc(credentials, password: password));

/// The credentials of their obfuscated [map]
/// ([stripeApiCredentialsToMapEnc]); a plain map
/// ([stripeApiCredentialsToMap]) is read too.
///
/// Throws a [FormatException] when [map] does not decrypt (a wrong password,
/// a damaged text), holds other keys than the ones it shows in clear, or has
/// no key; the message never quotes a secret.
StripeApiCredentials stripeApiCredentialsFromMapEnc(Map<Object?, Object?> map) {
  var enc = map['enc'];
  var password = map['password'];
  if (enc is! String || password is! String) {
    return stripeApiCredentialsFromMap(map);
  }
  Object? plain;
  try {
    plain = jsonDecode(aesDecrypt(enc, password));
  } catch (_) {
    // Not decrypted: said below.
  }
  if (plain is! Map) {
    throw const FormatException(
      'The obfuscated Stripe credentials do not decrypt (enc or password)',
    );
  }
  var credentials = stripeApiCredentialsFromMap(plain);
  void check(String name, String? key, {bool showEnds = true}) {
    var shown = map[name];
    if (shown is String &&
        (key == null ||
            stripeApiKeyObfuscate(key, showEnds: showEnds) != shown)) {
      throw FormatException(
        'The obfuscated Stripe credentials do not hold the $name $shown',
      );
    }
  }

  check('publishableKey', credentials.publishableKey);
  check('secretKey', credentials.secretKey, showEnds: false);
  return credentials;
}
