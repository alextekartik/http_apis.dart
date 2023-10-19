import 'dart:html';

extension UnsafeScriptElement on ScriptElement {
  // ignore: unsafe_html
  set safeSrc(String url) => src = url;
}
