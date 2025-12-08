import 'package:dio/dio.dart';
import 'package:bytequeens_adm/data/models/ai_chat_models.dart';
import 'package:bytequeens_adm/services/auth_service.dart';

class AiChatService {
  static final AiChatService _instance = AiChatService._internal();
  factory AiChatService() => _instance;
  AiChatService._internal();

  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  static const String baseUrl = 'https://api.jarvis.cx/api/v1/ai-chat';

  // Jarvis GUID - có thể set từ bên ngoài hoặc lấy từ user info
  String? _jarvisGuid;

  /// Initialize Dio with base configuration
  void _initializeDio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptor for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization token từ AuthService
          final token = _authService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add x-jarvis-guid header nếu có
          if (_jarvisGuid != null && _jarvisGuid!.isNotEmpty) {
            options.headers['x-jarvis-guid'] = _jarvisGuid;
          }

          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors
          return handler.next(error);
        },
      ),
    );
  }

  /// Get conversation history/messages
  ///
  /// [conversationId] - ID of the conversation
  /// [assistantId] - ID of the assistant
  /// [assistantModel] - Model of the assistant (default: "dify")
  /// [cursor] - Cursor for pagination (optional)
  /// [limit] - Number of messages to fetch (default: 20)
  Future<ConversationHistoryResponse> getConversationHistory({
    required String conversationId,
    required String assistantId,
    String assistantModel = 'dify',
    String? cursor,
    int limit = 20,
  }) async {
    // Validation
    if (conversationId.trim().isEmpty) {
      throw Exception('Conversation ID cannot be empty');
    }
    if (assistantId.trim().isEmpty) {
      throw Exception('Assistant ID cannot be empty');
    }

    try {
      _initializeDio();

      final queryParams = {
        'assistantId': assistantId,
        'assistantModel': assistantModel,
        'limit': limit.toString(),
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      };

      final response = await _dio.get(
        '/conversations/$conversationId/messages',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        // Validate response data
        if (response.data == null) {
          throw Exception('Empty response from server');
        }
        return ConversationHistoryResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Failed to load conversation history: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
  }

  /// Send message to AI Chat Bot
  ///
  /// [content] - Message content
  /// [files] - List of file URLs (optional)
  /// [metadata] - Conversation metadata with message history
  /// [assistant] - Assistant configuration (id, model, name)
  Future<MessageResponse> sendMessage({
    required String content,
    List<String>? files,
    required AiChatMetadata metadata,
    required AssistantDto assistant,
  }) async {
    // Validation
    if (content.trim().isEmpty) {
      throw Exception('Message content cannot be empty');
    }
    if (assistant.id.trim().isEmpty) {
      throw Exception('Assistant ID cannot be empty');
    }

    try {
      _initializeDio();

      final requestBody = AiSendMessageRequest(
        content: content.trim(),
        files: files ?? [],
        metadata: metadata,
        assistant: assistant,
      ).toJson();

      final response = await _dio.post('/messages', data: requestBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Validate response data
        if (response.data == null) {
          throw Exception('Empty response from server');
        }
        return MessageResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
  }

  /// Create new thread/conversation
  /// This is essentially sending a message with empty conversation history
  ///
  /// [content] - First message content
  /// [files] - List of file URLs (optional)
  /// [assistant] - Assistant configuration (id, model, name)
  Future<MessageResponse> createNewThread({
    required String content,
    List<String>? files,
    required AssistantDto assistant,
  }) async {
    // Create metadata with empty message history for new thread
    final metadata = AiChatMetadata(
      conversation: ConversationMetadata(messages: []),
    );

    return await sendMessage(
      content: content,
      files: files,
      metadata: metadata,
      assistant: assistant,
    );
  }

  /// Get list of conversations/threads
  ///
  /// [cursor] - Cursor for pagination (optional)
  /// [limit] - Number of conversations to fetch (default: 20)
  Future<ConversationListResponse> getConversations({
    String? cursor,
    int limit = 20,
  }) async {
    // Validation
    if (limit <= 0 || limit > 100) {
      throw Exception('Limit must be between 1 and 100');
    }

    try {
      _initializeDio();

      final queryParams = {
        'limit': limit.toString(),
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      };

      final response = await _dio.get(
        '/conversations',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        // Validate response data
        if (response.data == null) {
          throw Exception('Empty response from server');
        }
        return ConversationListResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw Exception('Failed to load conversations: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected error: $e');
    }
  }

  /// Handle Dio errors and convert to meaningful exceptions
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.sendTimeout:
        return Exception(
          'Request timeout. The server is taking too long to respond.',
        );

      case DioExceptionType.receiveTimeout:
        return Exception('Response timeout. Please try again.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;

        // Try to extract error message from response
        String errorMessage = 'Unknown error';
        try {
          if (error.response?.data != null) {
            if (error.response?.data is Map) {
              errorMessage =
                  error.response?.data['message'] ??
                  error.response?.data['error'] ??
                  error.response?.data['detail'] ??
                  'Unknown error';
            } else if (error.response?.data is String) {
              errorMessage = error.response?.data as String;
            }
          }
        } catch (e) {
          // Ignore parsing errors
        }

        // Map status codes to user-friendly messages
        if (statusCode == 400) {
          return Exception('Bad request. $errorMessage');
        } else if (statusCode == 401) {
          return Exception('Unauthorized. Please login again.');
        } else if (statusCode == 403) {
          return Exception('Access forbidden. You do not have permission.');
        } else if (statusCode == 404) {
          return Exception('Resource not found.');
        } else if (statusCode == 429) {
          return Exception('Too many requests. Please try again later.');
        } else if (statusCode == 500) {
          return Exception('Server error. Please try again later.');
        } else if (statusCode == 502) {
          return Exception('Bad gateway. Server is temporarily unavailable.');
        } else if (statusCode == 503) {
          return Exception('Service unavailable. Please try again later.');
        } else if (statusCode != null && statusCode >= 500) {
          return Exception(
            'Server error ($statusCode). Please try again later.',
          );
        }
        return Exception('Error ($statusCode): $errorMessage');

      case DioExceptionType.cancel:
        return Exception('Request cancelled.');

      case DioExceptionType.unknown:
        final errorStr = error.error.toString().toLowerCase();
        if (errorStr.contains('socketexception') ||
            errorStr.contains('network is unreachable')) {
          return Exception('No internet connection.');
        } else if (errorStr.contains('connection refused')) {
          return Exception('Connection refused. Server is not available.');
        } else if (errorStr.contains('host lookup failed')) {
          return Exception(
            'Cannot reach server. Please check your connection.',
          );
        } else if (errorStr.contains('handshake')) {
          return Exception('SSL/TLS error. Please check your connection.');
        }
        return Exception('Network error: ${error.message ?? "Unknown"}');

      case DioExceptionType.badCertificate:
        return Exception('SSL certificate error. Connection is not secure.');

      default:
        return Exception('Unexpected error: ${error.message ?? "Unknown"}');
    }
  }

  /// Set Jarvis GUID (call after getting user info)
  /// Token sẽ tự động được lấy từ AuthService
  void setJarvisGuid(String guid) {
    _jarvisGuid = guid;
  }

  /// Get current Jarvis GUID
  String? getJarvisGuid() {
    return _jarvisGuid;
  }

  /// Clear Jarvis GUID (call on logout)
  void clearJarvisGuid() {
    _jarvisGuid = null;
  }
}
