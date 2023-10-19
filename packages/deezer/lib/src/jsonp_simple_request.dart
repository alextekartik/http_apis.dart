import 'dart:html';

// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/common_utils_import.dart';

import 'http_simple_request.dart';
import 'unsafe_api.dart';

/// Executes a JSONP request.
///
/// Returns a [Future] with the result of the request.
///
/// The callback attribute is automatically added. By default, the name
/// of the callback attribute is "callback". Another name can be specified via
/// the [callbackParam] parameter.
Future<Object> jsonpRequest(Uri uri, {String callbackParam = 'callback'}) =>
    JsonpRequest(callbackParam: callbackParam).fetch(uri);

/// Executes a JSONP request.
///
/// Returns a [Future] with the result of the request.
///
/// The callback attribute is automatically added. By default, the name
/// of the callback attribute is "callback". Another name can be specified via
/// the [callbackParam] parameter.
class JsonpRequest implements HttpSimpleRequest {
  static int _requestCounter = 0;
  String? _callbackName;
  ScriptElement? _callbackScript;
  ScriptElement? _jsonpScript;
  final String callbackParam;
  StreamSubscription? _callbackSubscription;
  Completer? _completer;

  JsonpRequest({this.callbackParam = 'callback'});

  void _listenForCallback() {
    _callbackSubscription = window.onMessage.listen((MessageEvent event) {
      var data = event.data;
      if (data is String) {
        if (data.startsWith('{')) {
          var result = parseJsonObject(data)!;
          // devPrint(result);
          if (result['callbackName'] == _callbackName) {
            _completer!.complete(result['data']);
            _cancel();
          }
        }
      }
    });
  }

  void _cancel([Exception? e]) {
    _callbackSubscription?.cancel();
    _callbackSubscription = null;
    _callbackScript?.remove();
    _callbackScript = null;
    _jsonpScript?.remove();
    _jsonpScript = null;
    if (!(_completer?.isCompleted ?? false)) {
      throw e ?? Exception('jsonp request cancelled');
    }
  }

  void _addCallbackScript() {
    _callbackScript = ScriptElement()
      ..text = """function $_callbackName(value) {
      window.postMessage('{"callbackName":"$_callbackName","data":' + JSON.stringify(value) + '}', '*');
    }""";
    document.body!.children.add(_callbackScript!);
  }

  void _doRequest(Uri uri) {
    var script = _jsonpScript = ScriptElement()..safeSrc = uri.toString();
    document.body!.children.add(script);
    //script.remove();
    // devPrint(document.body!.innerHtml);
  }

  @override
  Future<Object> fetch(Uri uri) {
    assert(_completer == null);
    var completer = _completer = Completer<Object>();
    _callbackName = 'jsonpCallback_${_requestCounter++}';
    uri = uri.replace(
        queryParameters: Map<String, Object?>.from(uri.queryParameters)
          ..[callbackParam] = _callbackName);

    _listenForCallback();
    _addCallbackScript();
    _doRequest(uri);

    Future<void>.delayed(Duration(milliseconds: 30000))
        .then((_) => _cancel(TimeoutException('jsonp request timeout $uri')));

    return completer.future;
  }
}
