import 'deezer_error.dart';

/// A failed Deezer request.
class DeezerApiException implements Exception {
  /// The http status, when the request failed at the http level (or the code
  /// exchange answered no token).
  final int? httpStatusCode;

  /// The Deezer error (`type`, `code`, `message`), when Deezer answered one.
  final DeezerErrorInfo? errorInfo;

  /// The body as received, if any.
  final String? rawBody;

  DeezerApiException({
    this.errorInfo,
    this.httpStatusCode,
    required this.rawBody,
  });

  @override
  String toString() => errorInfo != null
      ? '${errorInfo!.type.v}: ${errorInfo!.message.v}'
      : 'statusCode: $httpStatusCode';
}
