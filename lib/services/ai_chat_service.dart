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

    // Clear existing interceptors to avoid duplicates
    _dio.interceptors.clear();

    // Add interceptor for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization token từ AuthService
          final token = _authService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add x-jarvis-guid header (luôn gửi, có thể rỗng)
          options.headers['x-jarvis-guid'] = _jarvisGuid ?? '';

          // Debug logging
          print('🔵 AI Chat API Request:');
          print('   URL: ${options.uri}');
          print('   Method: ${options.method}');
          print('   Headers: ${options.headers}');
          if (options.queryParameters.isNotEmpty) {
            print('   Query Params: ${options.queryParameters}');
          }
          if (options.data != null) {
            print('   Request Body: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ AI Chat API Response:');
          print('   Status: ${response.statusCode}');
          print('   Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ AI Chat API Error:');
          print('   Status: ${error.response?.statusCode}');
          print('   Message: ${error.message}');
          print('   Response: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  /// Get conversation history/messages
  ///
  /// [conversationId] - ID of the conversation
  /// [assistantId] - ID of the assistant (optional)
  /// [assistantModel] - Model of the assistant (optional, default: "dify")
  /// [cursor] - Cursor for pagination (optional)
  /// [limit] - Number of messages to fetch (default: 20)
  Future<ConversationHistoryResponse> getConversationHistory({
    required String conversationId,
    String? assistantId,
    String? assistantModel,
    String? cursor,
    int limit = 20,
  }) async {
    // Validation
    if (conversationId.trim().isEmpty) {
      throw Exception('Conversation ID cannot be empty');
    }

    try {
      _initializeDio();

      final queryParams = <String, dynamic>{'limit': limit};

      // Add optional params only if provided
      if (assistantId != null && assistantId.trim().isNotEmpty) {
        queryParams['assistantId'] = assistantId;
      }
      if (assistantModel != null && assistantModel.trim().isNotEmpty) {
        queryParams['assistantModel'] = assistantModel;
      }

      // Add cursor only if provided
      if (cursor != null && cursor.isNotEmpty) {
        queryParams['cursor'] = cursor;
      }

      print('📜 Fetching conversation history...');
      print('   ConversationId: $conversationId');
      if (assistantId != null) print('   AssistantId: $assistantId');
      if (assistantModel != null) print('   Model: $assistantModel');
      print('   Limit: $limit');

      final response = await _dio.get(
        '/conversations/$conversationId/messages',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        // Validate response data
        if (response.data == null) {
          throw Exception('Empty response from server');
        }
        final history = ConversationHistoryResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        print('✅ Fetched ${history.items.length} messages from history');
        print('   Has more: ${history.hasMore}');
        if (history.cursor != null) print('   Next cursor: ${history.cursor}');
        return history;
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

      print('📤 Sending message...');
      print('   Content: ${content.trim()}');
      print('   Assistant: ${assistant.id} (${assistant.name})');
      print('   History length: ${metadata.conversation.messages.length}');

      final response = await _dio.post('/messages', data: requestBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Validate response data
        if (response.data == null) {
          throw Exception('Empty response from server');
        }
        final messageResponse = MessageResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        print('✅ Message sent successfully!');
        print('   ConversationId: ${messageResponse.conversationId}');
        print('   Remaining Usage: ${messageResponse.remainingUsage}');
        print('   Response length: ${messageResponse.message.length} chars');
        return messageResponse;
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
  /// [assistantId] - ID of the assistant (optional, e.g., "gpt-4o-mini")
  /// [assistantModel] - Model of the assistant (optional, default: "dify")
  /// [cursor] - Cursor for pagination (optional)
  /// [limit] - Number of conversations to fetch (default: 20)
  Future<ConversationListResponse> getConversations({
    String? assistantId,
    String? assistantModel,
    String? cursor,
    int limit = 20,
  }) async {
    // Validation
    if (limit <= 0 || limit > 100) {
      throw Exception('Limit must be between 1 and 100');
    }

    try {
      _initializeDio();

      final queryParams = <String, dynamic>{'limit': limit};

      // Add optional params only if provided
      if (assistantId != null && assistantId.trim().isNotEmpty) {
        queryParams['assistantId'] = assistantId;
      }
      if (assistantModel != null && assistantModel.trim().isNotEmpty) {
        queryParams['assistantModel'] = assistantModel;
      }

      // Add cursor only if provided
      if (cursor != null && cursor.isNotEmpty) {
        queryParams['cursor'] = cursor;
      }

      print('📊 Fetching conversations...');
      if (assistantId != null) print('   AssistantId: $assistantId');
      if (assistantModel != null) print('   Model: $assistantModel');
      print('   Limit: $limit');
      if (cursor != null) print('   Cursor: $cursor');

      final response = await _dio.get(
        '/conversations',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        // Validate response data
        if (response.data == null) {
          throw Exception('Empty response from server');
        }
        final conversationList = ConversationListResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        print('✅ Fetched ${conversationList.items.length} conversations');
        print('   Has more: ${conversationList.hasMore}');
        return conversationList;
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
