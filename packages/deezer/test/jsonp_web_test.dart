@TestOn('browser')
library;

import 'dart:async';

import 'package:tekartik_deezer_api/src/jsonp_simple_request_web.dart';
import 'package:test/test.dart';

/// Local endpoint (test/jsonp_echo.js), no network.
final echoUri = Uri.parse('jsonp_echo.js');

void main() {
  test('jsonp result', () async {
    expect(await jsonpRequest(echoUri), {'ok': true});
    expect(
      await jsonpRequest(echoUri.replace(queryParameters: {'json': '[1,2]'})),
      [1, 2],
    );
  });

  test('jsonp load error', () async {
    // Used to have no error listener: hang then uncaught timeout error.
    await expectLater(
      jsonpRequest(
        Uri.parse('jsonp_missing.js'),
      ).timeout(const Duration(seconds: 10)),
      throwsA(allOf(isA<Exception>(), isNot(isA<TimeoutException>()))),
    );
  });

  test('jsonp timeout', () async {
    // Used to throw in a zone and leave the request pending forever.
    await expectLater(
      JsonpRequest(
        timeout: const Duration(milliseconds: 500),
      ).fetch(echoUri.replace(queryParameters: {'silent': '1'})),
      throwsA(isA<TimeoutException>()),
    );
  });
}
