import 'package:tekartik_deezer_api/deezer_api.dart';
import 'package:tekartik_deezer_api/src/import.dart';

/// Returns [result] (decoded json), throws a [DeezerApiException] if it is a
/// Deezer error ({"error": {...}}).
Object deezerCheckJsonResult(Object result) {
  if (result is Map) {
    var errorInfo = asModel(result).cv<DeezerError>().error.v;
    if (errorInfo != null) {
      throw DeezerApiException(
        errorInfo: errorInfo,
        rawBody: jsonEncode(result),
      );
    }
  }
  return result;
}
