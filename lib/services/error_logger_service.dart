import 'dart:async';
import 'package:bytequeens_adm/data/models/api_exception.dart';
import 'package:bytequeens_adm/data/models/api_error.dart';

/// Error severity levels
enum ErrorSeverity {
  low, // Minor UI issues
  medium, // Non-critical errors
  high, // Important errors affecting functionality
  critical, // Critical errors requiring immediate attention
}

/// Error entry for logging
class ErrorEntry {
  final String id;
  final DateTime timestamp;
  final String message;
  final String? stackTrace;
  final ErrorSeverity severity;
  final String? endpoint;
  final Map<String, dynamic>? context;
  final ApiErrorType? errorType;

  ErrorEntry({
    required this.id,
    required this.timestamp,
    required this.message,
    this.stackTrace,
    required this.severity,
    this.endpoint,
    this.context,
    this.errorType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'message': message,
      'stackTrace': stackTrace,
      'severity': severity.toString(),
      'endpoint': endpoint,
      'context': context,
      'errorType': errorType?.toString(),
    };
  }

  String toFormattedString() {
    final buffer = StringBuffer();
    buffer.writeln('Error ID: $id');
    buffer.writeln('Time: ${timestamp.toLocal()}');
    buffer.writeln('Severity: ${severity.name.toUpperCase()}');
    buffer.writeln('Message: $message');
    if (endpoint != null) buffer.writeln('Endpoint: $endpoint');
    if (errorType != null) buffer.writeln('Type: ${errorType?.name}');
    if (stackTrace != null) buffer.writeln('Stack Trace:\n$stackTrace');
    if (context != null) buffer.writeln('Context: $context');
    return buffer.toString();
  }
}

/// Service for logging and tracking errors
class ErrorLoggerService {
  static final ErrorLoggerService _instance = ErrorLoggerService._internal();
  factory ErrorLoggerService() => _instance;
  ErrorLoggerService._internal();

  final List<ErrorEntry> _errorLog = [];
  final int _maxLogSize = 100; // Keep last 100 errors

  // Stream for real-time error monitoring
  final _errorStreamController = StreamController<ErrorEntry>.broadcast();
  Stream<ErrorEntry> get errorStream => _errorStreamController.stream;

  // Error counters
  int _totalErrors = 0;
  int _apiErrors = 0;
  int _validationErrors = 0;
  int _networkErrors = 0;

  /// Log a general error
  void logError(
    String message, {
    ErrorSeverity severity = ErrorSeverity.medium,
    String? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final entry = ErrorEntry(
      id: _generateErrorId(),
      timestamp: DateTime.now(),
      message: message,
      stackTrace: stackTrace,
      severity: severity,
      context: context,
    );

    _addToLog(entry);
    _totalErrors++;

    // Print to console for debugging
    print('🔴 Error logged: ${entry.message}');
    if (severity == ErrorSeverity.critical) {
      print('⚠️ CRITICAL ERROR: ${entry.toFormattedString()}');
    }
  }

  /// Log an ApiException
  void logApiException(
    ApiException exception, {
    Map<String, dynamic>? additionalContext,
  }) {
    final context = <String, dynamic>{
      'errorType': exception.type.toString(),
      'statusCode': exception.statusCode,
      'endpoint': exception.endpoint,
      'isRetryable': exception.isRetryable,
    };

    if (additionalContext != null) {
      context.addAll(additionalContext);
    }

    final severity = _getSeverityFromErrorType(exception.type);

    final entry = ErrorEntry(
      id: _generateErrorId(),
      timestamp: DateTime.now(),
      message: exception.message,
      stackTrace: StackTrace.current.toString(),
      severity: severity,
      endpoint: exception.endpoint,
      context: context,
      errorType: exception.type,
    );

    _addToLog(entry);
    _totalErrors++;
    _apiErrors++;

    // Increment specific counters
    if (exception.type == ApiErrorType.network) {
      _networkErrors++;
    } else if (exception.type == ApiErrorType.validation) {
      _validationErrors++;
    }

    print('🔴 API Error logged: ${exception.type.name} - ${exception.message}');
  }

  /// Log a validation error
  void logValidationError(
    String field,
    String message, {
    Map<String, dynamic>? context,
  }) {
    final entry = ErrorEntry(
      id: _generateErrorId(),
      timestamp: DateTime.now(),
      message: 'Validation Error: $field - $message',
      severity: ErrorSeverity.low,
      context: {'field': field, ...?context},
      errorType: ApiErrorType.validation,
    );

    _addToLog(entry);
    _totalErrors++;
    _validationErrors++;

    print('⚠️ Validation error: $field - $message');
  }

  /// Log a network error
  void logNetworkError(
    String message, {
    String? endpoint,
    Map<String, dynamic>? context,
  }) {
    final entry = ErrorEntry(
      id: _generateErrorId(),
      timestamp: DateTime.now(),
      message: 'Network Error: $message',
      severity: ErrorSeverity.high,
      endpoint: endpoint,
      context: context,
      errorType: ApiErrorType.network,
    );

    _addToLog(entry);
    _totalErrors++;
    _networkErrors++;

    print('🌐 Network error: $message');
  }

  /// Add error to log and manage size
  void _addToLog(ErrorEntry entry) {
    _errorLog.add(entry);
    _errorStreamController.add(entry);

    // Maintain max log size
    if (_errorLog.length > _maxLogSize) {
      _errorLog.removeAt(0);
    }
  }

  /// Generate unique error ID
  String _generateErrorId() {
    return 'ERR_${DateTime.now().millisecondsSinceEpoch}_${_totalErrors + 1}';
  }

  /// Get severity from ApiErrorType
  ErrorSeverity _getSeverityFromErrorType(ApiErrorType type) {
    switch (type) {
      case ApiErrorType.network:
      case ApiErrorType.timeout:
        return ErrorSeverity.high;
      case ApiErrorType.authentication:
      case ApiErrorType.server:
        return ErrorSeverity.critical;
      case ApiErrorType.validation:
        return ErrorSeverity.low;
      case ApiErrorType.notFound:
      case ApiErrorType.rateLimited:
      case ApiErrorType.unknown:
        return ErrorSeverity.medium;
    }
  }

  /// Get all errors
  List<ErrorEntry> getAllErrors() => List.from(_errorLog);

  /// Get errors by severity
  List<ErrorEntry> getErrorsBySeverity(ErrorSeverity severity) {
    return _errorLog.where((e) => e.severity == severity).toList();
  }

  /// Get errors by error type
  List<ErrorEntry> getErrorsByType(ApiErrorType type) {
    return _errorLog.where((e) => e.errorType == type).toList();
  }

  /// Get recent errors (last n errors)
  List<ErrorEntry> getRecentErrors(int count) {
    if (_errorLog.length <= count) {
      return List.from(_errorLog);
    }
    return _errorLog.sublist(_errorLog.length - count);
  }

  /// Get error statistics
  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    final last24Hours = _errorLog
        .where((e) => now.difference(e.timestamp).inHours < 24)
        .length;
    final lastHour = _errorLog
        .where((e) => now.difference(e.timestamp).inMinutes < 60)
        .length;

    return {
      'totalErrors': _totalErrors,
      'apiErrors': _apiErrors,
      'validationErrors': _validationErrors,
      'networkErrors': _networkErrors,
      'logSize': _errorLog.length,
      'last24Hours': last24Hours,
      'lastHour': lastHour,
      'criticalErrors': getErrorsBySeverity(ErrorSeverity.critical).length,
      'highErrors': getErrorsBySeverity(ErrorSeverity.high).length,
      'mediumErrors': getErrorsBySeverity(ErrorSeverity.medium).length,
      'lowErrors': getErrorsBySeverity(ErrorSeverity.low).length,
    };
  }

  /// Export errors as formatted string
  String exportErrors() {
    final buffer = StringBuffer();
    buffer.writeln('=== Error Log Export ===');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total Errors: $_totalErrors');
    buffer.writeln('Statistics: ${getStatistics()}');
    buffer.writeln('\n=== Error Entries ===\n');

    for (var error in _errorLog) {
      buffer.writeln(error.toFormattedString());
      buffer.writeln('---');
    }

    return buffer.toString();
  }

  /// Clear all errors
  void clearErrors() {
    _errorLog.clear();
    _totalErrors = 0;
    _apiErrors = 0;
    _validationErrors = 0;
    _networkErrors = 0;
    print('🗑️ Error log cleared');
  }

  /// Clear errors older than specified duration
  void clearOldErrors(Duration duration) {
    final cutoffTime = DateTime.now().subtract(duration);
    _errorLog.removeWhere((e) => e.timestamp.isBefore(cutoffTime));
    print('🗑️ Cleared errors older than $duration');
  }

  /// Dispose resources
  void dispose() {
    _errorStreamController.close();
  }

  /// Print statistics to console
  void printStatistics() {
    print('📊 Error Statistics:');
    final stats = getStatistics();
    stats.forEach((key, value) {
      print('   $key: $value');
    });
  }
}
