// Local JSONP endpoint for jsonp_web_test.dart: calls the function named by
// its own ?callback= parameter with the ?json= value ({"ok": true} by
// default), never calls it with ?silent=1.
(function () {
  var params = new URL(document.currentScript.src).searchParams;
  if (params.get('silent')) {
    return;
  }
  var json = params.get('json');
  window[params.get('callback')](json ? JSON.parse(json) : { ok: true });
})();
