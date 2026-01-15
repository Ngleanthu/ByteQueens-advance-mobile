import 'package:dio/dio.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/data/models/kb_bot_model.dart';
import 'package:bytequeens_adm/data/models/kb_chat_model.dart';
import 'package:bytequeens_adm/data/models/api_exception.dart';
import 'package:bytequeens_adm/services/auth_service.dart';

/// Knowledge Base Service
/// Handles all KB API interactions for bot management, chat, and knowledge
class KBService {
  static final KBService _instance = KBService._internal();
  factory KBService() => _instance;
  KBService._internal();

  final Dio _dio = Dio();
  final Dio _jarvisChatDio = Dio();
  final AuthService _authService = AuthService();

  // Jarvis GUID - can be set from user info
  String? _jarvisGuid;

  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 1);

  // Retryable status codes
  static const List<int> _retryableStatusCodes = [408, 429, 500, 502, 503, 504];

  /// Set Jarvis GUID for API calls
  void setJarvisGuid(String? guid) {
    _jarvisGuid = guid;
  }

  /// Get current Jarvis GUID
  String? getJarvisGuid() => _jarvisGuid;

  /// Initialize Dio for KB API
  void _initializeKBDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.kbBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(
        minutes: 5,
      ), // Increased for AI chat responses
      sendTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null && status < 500,
      followRedirects: true,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'en-US,en;q=0.9',
      },
    );

    _dio.interceptors.clear();

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization token
          final token = _authService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add x-jarvis-guid header
          options.headers['x-jarvis-guid'] = _jarvisGuid ?? '';

          _logRequest('KB API', options);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse('KB API', response);
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logError('KB API', error);

          // Handle token expiration (401)
          if (error.response?.statusCode == 401) {
            try {
              // Try to refresh the token
              await _authService.refreshAccessToken();

              // Retry the request with new token
              final token = _authService.getAccessToken();
              if (token != null && token.isNotEmpty) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              }
            } catch (e) {
              print('Token refresh failed: $e');
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// Initialize Dio for Jarvis Chat API
  void _initializeJarvisChatDio() {
    _jarvisChatDio.options = BaseOptions(
      baseUrl: AppConstants.aiChatBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(
        minutes: 2,
      ), // Increased for AI chat responses
      sendTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null && status < 500,
      followRedirects: true,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'en-US,en;q=0.9',
      },
    );

    _jarvisChatDio.interceptors.clear();

    _jarvisChatDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization token
          final token = _authService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          _logRequest('Jarvis Chat API', options);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse('Jarvis Chat API', response);
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logError('Jarvis Chat API', error);

          // Handle token expiration (401)
          if (error.response?.statusCode == 401) {
            try {
              // Try to refresh the token
              await _authService.refreshAccessToken();

              // Retry the request with new token
              final token = _authService.getAccessToken();
              if (token != null && token.isNotEmpty) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await _jarvisChatDio.fetch(
                  error.requestOptions,
                );
                return handler.resolve(response);
              }
            } catch (e) {
              print('Token refresh failed: $e');
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  // ========== BOT MANAGEMENT APIS ==========

  /// Create a new AI Bot
  /// POST /ai-assistant
  Future<KBBot> createBot({
    required String assistantName,
    String? instructions,
    String? description,
  }) async {
    _initializeKBDio();

    return await _executeWithRetry<KBBot>(() async {
      final request = KBBotRequest(
        assistantName: assistantName,
        instructions: instructions,
        description: description,
      );

      final response = await _dio.post(
        AppConstants.kbAiAssistantEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return KBBot.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ApiException.fromStatusCode(
          statusCode: response.statusCode ?? 500,
          message: _getErrorMessage(response, AppConstants.botCreateError),
          endpoint: AppConstants.kbAiAssistantEndpoint,
        );
      }
    }, endpoint: AppConstants.kbAiAssistantEndpoint);
  }

  /// Get all bots with optional filters
  /// GET /ai-assistant
  Future<KBBotsListResponse> getBots({
    String? query,
    String? order,
    String? orderField,
    int? offset,
    int? limit,
    bool? isFavorite,
    bool? isPublished,
  }) async {
    _initializeKBDio();

    return await _executeWithRetry<KBBotsListResponse>(() async {
      final kbQuery = KBBotsQuery(
        q: query,
        order: order,
        orderField: orderField,
        offset: offset,
        limit: limit,
        isFavorite: isFavorite,
        isPublished: isPublished,
      );

      final response = await _dio.get(
        AppConstants.kbAiAssistantEndpoint,
        queryParameters: kbQuery.toQueryParameters(),
      );

      if (response.statusCode == 200) {
        return KBBotsListResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ApiException.fromStatusCode(
          statusCode: response.statusCode ?? 500,
          message: _getErrorMessage(response, AppConstants.botFetchError),
          endpoint: AppConstants.kbAiAssistantEndpoint,
        );
      }
    }, endpoint: AppConstants.kbAiAssistantEndpoint);
  }

  /// Get a single bot by ID
  /// GET /ai-assistant/{assistantId}
  Future<KBBot> getBotById(String assistantId) async {
    _initializeKBDio();

    final endpoint = AppConstants.kbAiAssistantByIdEndpoint.replaceAll(
      '{assistantId}',
      assistantId,
    );

    return await _executeWithRetry<KBBot>(() async {
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        return KBBot.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ApiException.fromStatusCode(
          statusCode: response.statusCode ?? 500,
          message: _getErrorMessage(response, AppConstants.botNotFoundError),
          endpoint: endpoint,
        );
      }
    }, endpoint: endpoint);
  }

  /// Update an existing bot
  /// PATCH /ai-assistant/{assistantId}
  Future<KBBot> updateBot({
    required String assistantId,
    String? assistantName,
    String? instructions,
    String? description,
  }) async {
    _initializeKBDio();

    final endpoint = AppConstants.kbAiAssistantByIdEndpoint.replaceAll(
      '{assistantId}',
      assistantId,
    );

    return await _executeWithRetry<KBBot>(() async {
      final request = KBBotRequest(
        assistantName: assistantName ?? '',
        instructions: instructions,
        description: description,
      );

      final response = await _dio.patch(endpoint, data: request.toJson());

      if (response.statusCode == 200) {
        return KBBot.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ApiException.fromStatusCode(
          statusCode: response.statusCode ?? 500,
          message: _getErrorMessage(response, AppConstants.botUpdateError),
          endpoint: endpoint,
        );
      }
    }, endpoint: endpoint);
  }

  /// Delete a bot
  /// DELETE /ai-assistant/{assistantId}
  Future<bool> deleteBot(String assistantId) async {
    _initializeKBDio();

    final endpoint = AppConstants.kbAiAssistantByIdEndpoint.replaceAll(
      '{assistantId}',
      assistantId,
    );

    return await _executeWithRetry<bool>(() async {
      final response = await _dio.delete(endpoint);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // API returns 200 OK or 204 No Content for success
        return true;
      } else {
        throw ApiException.fromStatusCode(
          statusCode: response.statusCode ?? 500,
          message: _getErrorMessage(response, AppConstants.botDeleteError),
          endpoint: endpoint,
        );
      }
    }, endpoint: endpoint);
  }

  // ========== CHAT APIS ==========

  /// Preview chat with bot (testing)
  /// POST /ai-assistant/{assistantId}/ask
  Future<KBChatResponse> askBot({
    required String assistantId,
    required String message,
  }) async {
    _initializeKBDio();

    final endpoint = AppConstants.kbAskBotEndpoint.replaceAll(
      '{assistantId}',
      assistantId,
    );

    return await _executeWithRetry<KBChatResponse>(() async {
      final request = KBChatRequest(message: message);

      final response = await _dio.post(endpoint, data: request.toJson());

      if (response.statusCode == 200) {
        // Response should contain content and conversationId
        if (response.data is String) {
          return KBChatResponse(
            content: response.data as String,
            conversationId: null,
          );
        } else if (response.data is Map<String, dynamic>) {
          return KBChatResponse.fromJson(response.data as Map<String, dynamic>);
        } else {
          throw ApiException.validation(
            message: 'Unexpected response format',
            endpoint: endpoint,
          );
        }
      } else {
        throw ApiException.fromStatusCode(
          statusCode: response.statusCode ?? 500,
          message: _getErrorMessage(response, AppConstants.chatError),
          endpoint: endpoint,
        );
      }
    }, endpoint: endpoint);
  }

  /// Production chat with bot
  /// POST /messages
  Future<JarvisChatResponse> chatWithBot({
    required String content,
    required JarvisAssistant assistant,
    List<dynamic>? files,
    List<ConversationMessage>? conversationHistory,
  }) async {
    _initializeJarvisChatDio();

    return await _executeWithRetry<JarvisChatResponse>(() async {
      final request = JarvisChatRequestBuilder()
          .setContent(content)
          .setAssistant(assistant)
          .setFiles(files ?? [])
          .setMessages(conversationHistory ?? [])
          .build();

      final response = await _jarvisChatDio.post(
        AppConstants.messagesEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return JarvisChatResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw ApiException.fromStatusCode(
          statusCode: response.statusCode ?? 500,
          message: _getErrorMessage(response, AppConstants.chatError),
          endpoint: AppConstants.messagesEndpoint,
        );
      }
    }, endpoint: AppConstants.messagesEndpoint);
  }

  // ========== KNOWLEDGE MANAGEMENT APIS ==========

  /// Add knowledge to bot
  /// POST /ai-assistant/{assistantId}/knowledges/{knowledgeId}
  Future<bool> addKnowledgeToBot({
    required String assistantId,
    required String knowledgeId,
  }) async {
    _initializeKBDio();

    final endpoint = AppConstants.kbImportKnowledgeEndpoint
        .replaceAll('{assistantId}', assistantId)
        .replaceAll('{knowledgeId}', knowledgeId);

    return await _executeWithRetry<bool>(() async {
      final response = await _dio.post(endpoint);

      if (response.statusCode == 200) {
        // API returns TRUE for success
        return true;
      } else {
        throw ApiException.fromStatusCode(
          statusCode: response.statusCode ?? 500,
          message: _getErrorMessage(response, AppConstants.knowledgeAddError),
          endpoint: endpoint,
        );
      }
    }, endpoint: endpoint);
  }

  /// Remove knowledge from bot
  /// DELETE /ai-assistant/{assistantId}/knowledges/{knowledgeId}
  Future<bool> removeKnowledgeFromBot({
    required String assistantId,
    required String knowledgeId,
  }) async {
    _initializeKBDio();

    final endpoint = AppConstants.kbImportKnowledgeEndpoint
        .replaceAll('{assistantId}', assistantId)
        .replaceAll('{knowledgeId}', knowledgeId);

    return await _executeWithRetry<bool>(() async {
      final response = await _dio.delete(endpoint);

      if (response.statusCode == 200) {
        // API returns TRUE for success
        return true;
      } else {
        throw ApiException.fromStatusCode(
          statusCode: response.statusCode ?? 500,
          message: _getErrorMessage(
            response,
            AppConstants.knowledgeRemoveError,
          ),
          endpoint: endpoint,
        );
      }
    }, endpoint: endpoint);
  }

  /// Publish bot to external platform (Slack, Telegram, Messenger)
  /// POST /ai-assistant/{assistantId}/publish
  Future<Map<String, dynamic>> publishBot({
    required String assistantId,
    required String platform,
    required Map<String, dynamic> config,
  }) async {
    _initializeKBDio();

    final endpoint = AppConstants.kbPublishBotEndpoint.replaceAll(
      '{assistantId}',
      assistantId,
    );

    return await _executeWithRetry<Map<String, dynamic>>(() async {
      final requestBody = {'platform': platform, ...config};

      final response = await _dio.post(endpoint, data: requestBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiException.fromStatusCode(
          statusCode: response.statusCode ?? 500,
          message: _getErrorMessage(response, AppConstants.botPublishError),
          endpoint: endpoint,
        );
      }
    }, endpoint: endpoint);
  }

  /// Unpublish bot from platform
  /// DELETE /ai-assistant/{assistantId}/publish/{platform}
  Future<bool> unpublishBot({
    required String assistantId,
    required String platform,
  }) async {
    _initializeKBDio();

    final endpoint =
        '${AppConstants.kbPublishBotEndpoint.replaceAll('{assistantId}', assistantId)}/$platform';

    return await _executeWithRetry<bool>(() async {
      final response = await _dio.delete(endpoint);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ApiException.fromStatusCode(
          statusCode: response.statusCode ?? 500,
          message: _getErrorMessage(response, AppConstants.botPublishError),
          endpoint: endpoint,
        );
      }
    }, endpoint: endpoint);
  }

  // ========== HELPER METHODS ==========

  /// Execute a request with retry logic for retryable errors
  Future<T> _executeWithRetry<T>(
    Future<T> Function() requestFn, {
    String? endpoint,
  }) async {
    int attempt = 0;
    Duration delay = _initialRetryDelay;

    while (true) {
      try {
        return await requestFn();
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        final isRetryable =
            statusCode != null && _retryableStatusCodes.contains(statusCode);

        attempt++;

        if (!isRetryable || attempt >= _maxRetries) {
          // Not retryable or max retries reached
          throw _handleDioException(e, endpoint);
        }

        // Wait before retry with exponential backoff
        print(
          '🔄 Retry attempt $attempt/$_maxRetries after ${delay.inMilliseconds}ms delay',
        );
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
  }

  /// Log request details
  void _logRequest(String apiName, RequestOptions options) {
    print('🔵 $apiName Request:');
    print('   URL: ${options.uri}');
    print('   Method: ${options.method}');
    print('   Headers: ${options.headers}');
    if (options.queryParameters.isNotEmpty) {
      print('   Query Params: ${options.queryParameters}');
    }
    if (options.data != null) {
      print('   Request Body: ${options.data}');
    }
  }

  /// Log response details
  void _logResponse(String apiName, Response response) {
    print('✅ $apiName Response:');
    print('   Status: ${response.statusCode}');
    print('   Data: ${response.data}');
  }

  /// Log error details
  void _logError(String apiName, DioException error) {
    print('❌ $apiName Error:');
    print('   Status: ${error.response?.statusCode}');
    print('   Message: ${error.message}');
    print('   Response: ${error.response?.data}');
  }

  /// Get error message from response
  String _getErrorMessage(Response response, String defaultMessage) {
    if (response.data != null && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      return data['message'] as String? ??
          data['error'] as String? ??
          defaultMessage;
    }
    return defaultMessage;
  }

  /// Handle Dio exceptions and convert to ApiException
  ApiException _handleDioException(DioException e, String? endpoint) {
    // Extract error message from response
    String? errorMessage;
    Map<String, dynamic>? errorDetails;

    if (e.response?.data != null && e.response!.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      errorMessage = data['message'] as String? ?? data['error'] as String?;
      errorDetails = data;
    }

    if (e.response != null) {
      final statusCode = e.response!.statusCode;

      switch (statusCode) {
        case 400:
          return ApiException.validation(
            message:
                errorMessage ?? 'Invalid request. Please check your input.',
            statusCode: statusCode,
            endpoint: endpoint,
            details: errorDetails,
          );
        case 401:
          return ApiException.authentication(
            message:
                errorMessage ?? 'Authentication failed. Please log in again.',
            statusCode: statusCode,
            endpoint: endpoint,
          );
        case 403:
          return ApiException.authentication(
            message:
                errorMessage ??
                'Access denied. You don\'t have permission for this action.',
            statusCode: statusCode,
            endpoint: endpoint,
          );
        case 404:
          return ApiException.notFound(
            message: errorMessage ?? 'Resource not found.',
            endpoint: endpoint,
          );
        case 408:
          return ApiException.timeout(
            message: errorMessage ?? 'Request timeout. Please try again.',
            endpoint: endpoint,
          );
        case 422:
          return ApiException.validation(
            message:
                errorMessage ?? 'Validation failed. Please check your input.',
            statusCode: statusCode,
            endpoint: endpoint,
            details: errorDetails,
          );
        case 429:
          return ApiException.rateLimited(
            message:
                errorMessage ??
                'Too many requests. Please wait a moment and try again.',
            endpoint: endpoint,
          );
        case 500:
        case 502:
        case 503:
        case 504:
          return ApiException.server(
            message: errorMessage ?? 'Server error. Please try again later.',
            statusCode: statusCode,
            endpoint: endpoint,
          );
        default:
          return ApiException.unknown(
            message: errorMessage ?? 'An unexpected error occurred.',
            statusCode: statusCode,
            endpoint: endpoint,
          );
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiException.timeout(
        message: 'Request timeout. Please check your connection and try again.',
        endpoint: endpoint,
      );
    } else if (e.type == DioExceptionType.connectionError) {
      return ApiException.network(
        message: 'Network error. Please check your internet connection.',
        endpoint: endpoint,
      );
    } else {
      return ApiException.unknown(
        message: errorMessage ?? e.message ?? 'An unexpected error occurred.',
        endpoint: endpoint,
      );
    }
  }

  /// Clear all caches and reset state
  void clearCache() {
    _jarvisGuid = null;
  }
}
