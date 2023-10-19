abstract class HttpSimpleRequest {
  /// Returns a JSON object (map or list)
  Future<Object> fetch(Uri uri);
}
