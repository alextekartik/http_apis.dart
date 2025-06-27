import 'deezer_error.dart';

class DeezerApiException implements Exception {
  final int? httpStatusCode;
  final DeezerErrorInfo? errorInfo;
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
