/// API Exception classes for handling errors
class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (code: $code, status: $statusCode)';

  factory ApiException.fromResponse(Map<String, dynamic> response, int? statusCode) {
    return ApiException(
      message: response['message'] ?? 'An error occurred',
      code: response['code'],
      statusCode: statusCode,
      data: response['errors'],
    );
  }
}

class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}

class TimeoutException implements Exception {
  final String message;

  TimeoutException([this.message = 'Request timed out']);

  @override
  String toString() => 'TimeoutException: $message';
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException([this.message = 'Unauthorized access']);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;

  ValidationException({
    this.message = 'Validation failed',
    this.errors,
  });

  @override
  String toString() => 'ValidationException: $message';
}
