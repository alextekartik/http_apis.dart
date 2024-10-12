import 'package:tekartik_app_http/app_http.dart';
// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/common_utils_import.dart';

import 'http_simple_request.dart';

Client? _client;

var debugDeezerApi = false; // devWarning(true);

void disposeJsonRequests() {
  _client?.close();
}

/// Json fetch
Future<Object> jsonFetch(Uri uri) => JsonRequest().fetch(uri);

class JsonRequest implements HttpSimpleRequest {
  @override
  Future<Object> fetch(Uri uri) async {
    var client = _client ??= httpClientFactory.newClient();

    var result = await httpClientRead(client, httpMethodGet, uri);
    if (debugDeezerApi) {
      print(uri);
      print(result);
    }
    return jsonDecode(result) as Object;
  }
}
