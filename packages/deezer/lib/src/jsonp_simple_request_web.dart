library;

import 'dart:js_interop' as js;

// ignore: depend_on_referenced_packages
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:web/web.dart' as web;

import 'http_simple_request.dart';

var debugJsonp = false; // devWarning(true);

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
  web.HTMLScriptElement? _callbackScript;
  web.HTMLScriptElement? _jsonpScript;
  final String callbackParam;

  /// Request timeout.
  final Duration timeout;
  StreamSubscription<web.MessageEvent>? _callbackSubscription;
  StreamSubscription<web.Event>? _errorSubscription;
  Timer? _timeoutTimer;
  Completer<Object>? _completer;

  JsonpRequest({
    this.callbackParam = 'callback',
    this.timeout = const Duration(milliseconds: 30000),
  });

  void _listenForCallback() {
    _callbackSubscription = web.EventStreamProviders.messageEvent
        .forTarget(web.window)
        .listen((web.MessageEvent event) {
          if (debugJsonp) {
            print('event: ${event.data}');
          }
          var rawData = event.data;
          if (rawData.isA<js.JSString>()) {
            var data = (rawData as js.JSString).toDart;
            if (data.startsWith('{')) {
              var result = parseJsonObject(data)!;
              // devPrint(result);
              if (result['callbackName'] == _callbackName) {
                var data = result['data'];
                if (data == null) {
                  _fail(Exception('jsonp null result'));
                } else {
                  _succeed(data);
                }
              }
            }
          }
        });
  }

  void _cleanUp() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _callbackSubscription?.cancel();
    _callbackSubscription = null;
    _errorSubscription?.cancel();
    _errorSubscription = null;
    _callbackScript?.remove();
    _callbackScript = null;
    _jsonpScript?.remove();
    _jsonpScript = null;
  }

  void _succeed(Object data) {
    var completer = _completer!;
    _cleanUp();
    if (!completer.isCompleted) {
      completer.complete(data);
    }
  }

  /// Completes the request with [error] (timeout or script load error).
  void _fail(Object error) {
    var completer = _completer!;
    _cleanUp();
    if (!completer.isCompleted) {
      completer.completeError(error);
    }
  }

  void _addCallbackScript() {
    _callbackScript = web.HTMLScriptElement()
      ..text =
          """function $_callbackName(value) {
      window.postMessage('{"callbackName":"$_callbackName","data":' + JSON.stringify(value) + '}', '*');
    }""";
    if (debugJsonp) {
      print('adding _callback: ${_callbackScript!.text}');
    }
    web.document.body!.appendChild(_callbackScript!);
  }

  void _doRequest(Uri uri) {
    if (debugJsonp) {
      print('jsonpRequest: $uri');
    }
    var script = _jsonpScript = web.HTMLScriptElement()..src = uri.toString();
    // Network error, 404...
    _errorSubscription = web.EventStreamProviders.errorEvent
        .forTarget(script)
        .listen((_) => _fail(Exception('jsonp request failed $uri')));
    web.document.body!.appendChild(script);
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
        ..[callbackParam] = _callbackName,
    );

    _listenForCallback();
    _addCallbackScript();
    _doRequest(uri);

    _timeoutTimer = Timer(
      timeout,
      () => _fail(TimeoutException('jsonp request timeout $uri', timeout)),
    );

    return completer.future;
  }
}
