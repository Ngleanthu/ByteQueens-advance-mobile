import 'api_error.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final ApiError error;

  ApiException(this.error);

  /// Creates an ApiException from a network/connectivity issue
  factory ApiException.network({required String message, String? endpoint}) {
    return ApiException(ApiError.network(message: message, endpoint: endpoint));
  }

  /// Creates an ApiException from an authentication failure
  factory ApiException.authentication({
    required String message,
    int? statusCode,
    String? endpoint,
  }) {
    return ApiException(
      ApiError.authentication(
        message: message,
        statusCode: statusCode,
        endpoint: endpoint,
      ),
    );
  }

  /// Creates an ApiException from a validation failure
  factory ApiException.validation({
    required String message,
    int? statusCode,
    String? endpoint,
    Map<String, dynamic>? details,
  }) {
    return ApiException(
      ApiError.validation(
        message: message,
        statusCode: statusCode,
        endpoint: endpoint,
        details: details,
      ),
    );
  }

  /// Creates an ApiException from a server error
  factory ApiException.server({
    required String message,
    int? statusCode,
    String? endpoint,
  }) {
    return ApiException(
      ApiError.server(
        message: message,
        statusCode: statusCode,
        endpoint: endpoint,
      ),
    );
  }

  /// Creates an ApiException from a timeout
  factory ApiException.timeout({required String message, String? endpoint}) {
    return ApiException(ApiError.timeout(message: message, endpoint: endpoint));
  }

  /// Creates an ApiException from a not found error
  factory ApiException.notFound({required String message, String? endpoint}) {
    return ApiException(
      ApiError.notFound(message: message, endpoint: endpoint),
    );
  }

  /// Creates an ApiException from a rate limit error
  factory ApiException.rateLimited({
    required String message,
    String? endpoint,
  }) {
    return ApiException(
      ApiError.rateLimited(message: message, endpoint: endpoint),
    );
  }

  /// Creates an ApiException from an unknown error
  factory ApiException.unknown({
    required String message,
    int? statusCode,
    String? endpoint,
  }) {
    return ApiException(
      ApiError.unknown(
        message: message,
        statusCode: statusCode,
        endpoint: endpoint,
      ),
    );
  }

  /// Creates an ApiException from an HTTP status code
  factory ApiException.fromStatusCode({
    required int statusCode,
    String? message,
    String? endpoint,
    Map<String, dynamic>? details,
  }) {
    return ApiException(
      ApiError.fromStatusCode(
        statusCode: statusCode,
        message: message,
        endpoint: endpoint,
        details: details,
      ),
    );
  }

  @override
  String toString() => 'ApiException: ${error.toString()}';

  /// Gets the error type
  ApiErrorType get type => error.type;

  /// Gets the error message
  String get message => error.message;

  /// Gets the user-friendly error message
  String get userFriendlyMessage => error.userFriendlyMessage;

  /// Gets the status code
  int? get statusCode => error.statusCode;

  /// Gets the endpoint
  String? get endpoint => error.endpoint;

  /// Checks if this error is retryable
  bool get isRetryable => error.isRetryable;
}
