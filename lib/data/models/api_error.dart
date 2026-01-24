/// Represents different types of API errors that can occur
enum ApiErrorType {
  /// Network connectivity issues (no internet, timeout, etc.)
  network,

  /// Authentication/authorization errors (401, 403)
  authentication,

  /// Client-side validation errors (400, 422)
  validation,

  /// Server-side errors (500, 502, 503, 504)
  server,

  /// Request timeout errors (408)
  timeout,

  /// Resource not found (404)
  notFound,

  /// Rate limiting (429)
  rateLimited,

  /// Unknown or unhandled errors
  unknown,
}

/// Represents an API error with detailed information
class ApiError {
  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final String? endpoint;
  final Map<String, dynamic>? details;
  final DateTime timestamp;

  ApiError({
    required this.type,
    required this.message,
    this.statusCode,
    this.endpoint,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates an ApiError from a network/connectivity issue
  factory ApiError.network({required String message, String? endpoint}) {
    return ApiError(
      type: ApiErrorType.network,
      message: message,
      endpoint: endpoint,
    );
  }

  /// Creates an ApiError from an authentication failure
  factory ApiError.authentication({
    required String message,
    int? statusCode,
    String? endpoint,
  }) {
    return ApiError(
      type: ApiErrorType.authentication,
      message: message,
      statusCode: statusCode,
      endpoint: endpoint,
    );
  }

  /// Creates an ApiError from a validation failure
  factory ApiError.validation({
    required String message,
    int? statusCode,
    String? endpoint,
    Map<String, dynamic>? details,
  }) {
    return ApiError(
      type: ApiErrorType.validation,
      message: message,
      statusCode: statusCode,
      endpoint: endpoint,
      details: details,
    );
  }

  /// Creates an ApiError from a server error
  factory ApiError.server({
    required String message,
    int? statusCode,
    String? endpoint,
  }) {
    return ApiError(
      type: ApiErrorType.server,
      message: message,
      statusCode: statusCode,
      endpoint: endpoint,
    );
  }

  /// Creates an ApiError from a timeout
  factory ApiError.timeout({required String message, String? endpoint}) {
    return ApiError(
      type: ApiErrorType.timeout,
      message: message,
      statusCode: 408,
      endpoint: endpoint,
    );
  }

  /// Creates an ApiError from a not found error
  factory ApiError.notFound({required String message, String? endpoint}) {
    return ApiError(
      type: ApiErrorType.notFound,
      message: message,
      statusCode: 404,
      endpoint: endpoint,
    );
  }

  /// Creates an ApiError from a rate limit error
  factory ApiError.rateLimited({required String message, String? endpoint}) {
    return ApiError(
      type: ApiErrorType.rateLimited,
      message: message,
      statusCode: 429,
      endpoint: endpoint,
    );
  }

  /// Creates an ApiError from an unknown error
  factory ApiError.unknown({
    required String message,
    int? statusCode,
    String? endpoint,
  }) {
    return ApiError(
      type: ApiErrorType.unknown,
      message: message,
      statusCode: statusCode,
      endpoint: endpoint,
    );
  }

  /// Creates an ApiError from an HTTP status code
  factory ApiError.fromStatusCode({
    required int statusCode,
    String? message,
    String? endpoint,
    Map<String, dynamic>? details,
  }) {
    ApiErrorType type;
    String defaultMessage;

    switch (statusCode) {
      case 400:
        type = ApiErrorType.validation;
        defaultMessage = 'Invalid request. Please check your input.';
        break;
      case 401:
        type = ApiErrorType.authentication;
        defaultMessage = 'Authentication failed. Please log in again.';
        break;
      case 403:
        type = ApiErrorType.authentication;
        defaultMessage =
            'Access denied. You don\'t have permission for this action.';
        break;
      case 404:
        type = ApiErrorType.notFound;
        defaultMessage = 'Resource not found.';
        break;
      case 408:
        type = ApiErrorType.timeout;
        defaultMessage = 'Request timeout. Please try again.';
        break;
      case 422:
        type = ApiErrorType.validation;
        defaultMessage = 'Validation failed. Please check your input.';
        break;
      case 429:
        type = ApiErrorType.rateLimited;
        defaultMessage =
            'Too many requests. Please wait a moment and try again.';
        break;
      case 500:
      case 502:
      case 503:
      case 504:
        type = ApiErrorType.server;
        defaultMessage = 'Server error. Please try again later.';
        break;
      default:
        type = ApiErrorType.unknown;
        defaultMessage = 'An unexpected error occurred.';
    }

    return ApiError(
      type: type,
      message: message ?? defaultMessage,
      statusCode: statusCode,
      endpoint: endpoint,
      details: details,
    );
  }

  /// Gets a user-friendly error message
  String get userFriendlyMessage {
    switch (type) {
      case ApiErrorType.network:
        return 'Network error. Please check your internet connection.';
      case ApiErrorType.authentication:
        return 'Authentication error. Please log in again.';
      case ApiErrorType.validation:
        return message.isNotEmpty
            ? message
            : 'Invalid input. Please check your data.';
      case ApiErrorType.server:
        return 'Server error. Please try again later.';
      case ApiErrorType.timeout:
        return 'Request timeout. Please try again.';
      case ApiErrorType.notFound:
        return message.isNotEmpty ? message : 'Resource not found.';
      case ApiErrorType.rateLimited:
        return 'Too many requests. Please wait a moment.';
      case ApiErrorType.unknown:
        return message.isNotEmpty
            ? message
            : 'An error occurred. Please try again.';
    }
  }

  /// Checks if this error is retryable
  bool get isRetryable {
    return type == ApiErrorType.network ||
        type == ApiErrorType.timeout ||
        type == ApiErrorType.server ||
        type == ApiErrorType.rateLimited;
  }

  @override
  String toString() {
    final buffer = StringBuffer('ApiError(');
    buffer.write('type: $type');
    if (statusCode != null) buffer.write(', statusCode: $statusCode');
    buffer.write(', message: $message');
    if (endpoint != null) buffer.write(', endpoint: $endpoint');
    buffer.write(')');
    return buffer.toString();
  }

  /// Converts the ApiError to a map
  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'message': message,
      'statusCode': statusCode,
      'endpoint': endpoint,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
