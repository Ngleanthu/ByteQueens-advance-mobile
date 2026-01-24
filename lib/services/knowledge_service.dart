import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:bytequeens_adm/services/auth_service.dart';

class KnowledgeService {
  final Dio _dio;
  final AuthService _authService = AuthService();

  static const String _fallbackToken = "";
  static const String _jarvisGuid =
      "a153d8df-ee7d-4ac3-943e-882726700f9b"; // ✅ Your GUID

  KnowledgeService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://knowledge-api.jarvis.cx/kb-core/v1',
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          ) {
    _setupSslBypass();
    _setupInterceptors();
  }

  /// SSL bypass (dev only)
  void _setupSslBypass() {
    try {
      if (_dio.httpClientAdapter is IOHttpClientAdapter) {
        (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          client.connectionTimeout = const Duration(seconds: 30);
          return client;
        };
      }
    } catch (e) {
      print('⚠️ SSL bypass setup failed: $e');
    }
  }

  void _setupInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 🔵 LOG REQUEST
          print('┌─────────────────────────────────────────────');
          print('│ 📤 REQUEST');
          print('├─────────────────────────────────────────────');
          print('│ Method: ${options.method}');
          print('│ URL: ${options.baseUrl}${options.path}');
          print('│ Query: ${options.queryParameters}');
          print('│ Headers: ${options.headers}');
          print('│ Body: ${options.data}');
          print('└─────────────────────────────────────────────');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // ✅ LOG RESPONSE
          print('┌─────────────────────────────────────────────');
          print('│ 📥 RESPONSE');
          print('├─────────────────────────────────────────────');
          print('│ Status: ${response.statusCode}');
          print('│ URL: ${response.requestOptions.path}');
          print('│ Data: ${response.data}');
          print('└─────────────────────────────────────────────');
          return handler.next(response);
        },
        onError: (error, handler) {
          // ❌ LOG ERROR
          print('┌─────────────────────────────────────────────');
          print('│ ❌ ERROR');
          print('├─────────────────────────────────────────────');
          print('│ Type: ${error.type}');
          print('│ Message: ${error.message}');
          print('│ Error: ${error.error}');
          print('│ Status: ${error.response?.statusCode}');
          print('│ URL: ${error.requestOptions.path}');
          print('│ Response Data: ${error.response?.data}');
          print('│ Stack Trace: ${error.stackTrace}');
          print('└─────────────────────────────────────────────');
          return handler.next(error);
        },
      ),
    );
  }

  String _getToken(String? token) {
    final actualToken =
        token ?? _authService.getAccessToken() ?? _fallbackToken;
    print(
      '🔑 Token: ${actualToken.isEmpty ? "EMPTY!" : "${actualToken.substring(0, actualToken.length > 20 ? 20 : actualToken.length)}..."}',
    );
    return actualToken;
  }

  Map<String, String> _headers(String token, {String? jarvisGuid}) {
    final guid = jarvisGuid ?? _jarvisGuid;
    print(
      '🆔 Jarvis GUID: ${guid.isEmpty ? "EMPTY!" : "${guid.substring(0, guid.length > 20 ? 20 : guid.length)}..."}',
    );

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'x-jarvis-guid': guid,
    };
  }

  /// 🆕 CREATE Knowledge Base
  Future<Response> createKnowledge({
    required String knowledgeName,
    required String description,
    String? token,
    String? jarvisGuid,
  }) async {
    final actualToken = _getToken(token);

    try {
      print('🆕 Creating knowledge: $knowledgeName');
      return await _dio.post(
        '/knowledge',
        data: {'knowledgeName': knowledgeName, 'description': description},
        options: Options(
          headers: _headers(actualToken, jarvisGuid: jarvisGuid),
        ),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 📋 GET All Knowledge Bases
  Future<Response> getKnowledges({
    String? query,
    String order = 'DESC',
    String orderField = 'createdAt',
    int offset = 0,
    int limit = 20,
    String? token,
    String? jarvisGuid,
  }) async {
    final actualToken = _getToken(token);

    try {
      print('📋 Getting knowledges with query: ${query ?? "(empty)"}');

      // 🔥 ALWAYS send all parameters (API requirement)
      final queryParams = <String, dynamic>{
        'q': query ?? '', // Required - always send even if empty
        'order': order,
        'order_field': orderField,
        'offset': offset, // Send even when 0
        'limit': limit,
      };

      return await _dio.get(
        '/knowledge',
        queryParameters: queryParams,
        options: Options(
          headers: _headers(actualToken, jarvisGuid: jarvisGuid),
        ),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// ✏️ UPDATE Knowledge Base
  Future<Response> updateKnowledge(
    String knowledgeId, {
    required String knowledgeName,
    required String description,
    String? token,
    String? jarvisGuid,
  }) async {
    final actualToken = _getToken(token);

    try {
      print('✏️ Updating knowledge: $knowledgeId');
      return await _dio.patch(
        '/knowledge/$knowledgeId',
        data: {'knowledgeName': knowledgeName, 'description': description},
        options: Options(
          headers: _headers(actualToken, jarvisGuid: jarvisGuid),
        ),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 🗑️ DELETE Knowledge Base
  Future<void> deleteKnowledge(
    String knowledgeId, {
    String? token,
    String? jarvisGuid,
  }) async {
    final actualToken = _getToken(token);

    try {
      print('🗑️ Deleting knowledge: $knowledgeId');
      await _dio.delete(
        '/knowledge/$knowledgeId',
        options: Options(
          headers: _headers(actualToken, jarvisGuid: jarvisGuid),
        ),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 📦 GET Knowledge Units
  Future<Response> getKnowledgeUnits(
    String knowledgeId, {
    String? query,
    String order = 'DESC',
    String orderField = 'createdAt',
    int offset = 0,
    int limit = 100,
    String? token,
    String? jarvisGuid,
  }) async {
    final actualToken = _getToken(token);

    try {
      print('📦 Getting units for knowledge: $knowledgeId');

      // Build query parameters
      final queryParams = <String, dynamic>{
        'order': order,
        'order_field': orderField,
        'limit': limit,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      if (offset > 0) {
        queryParams['offset'] = offset;
      }

      return await _dio.get(
        '/knowledge/$knowledgeId/units',
        queryParameters: queryParams,
        options: Options(
          headers: _headers(actualToken, jarvisGuid: jarvisGuid),
        ),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// 🔍 GET Single Knowledge Base (optional helper method)
  Future<Response> getKnowledge(
    String knowledgeId, {
    String? token,
    String? jarvisGuid,
  }) async {
    final actualToken = _getToken(token);

    try {
      print('🔍 Getting knowledge: $knowledgeId');
      return await _dio.get(
        '/knowledge/$knowledgeId',
        options: Options(
          headers: _headers(actualToken, jarvisGuid: jarvisGuid),
        ),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// ⚠️ Error Handler
  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;

      // Try to extract error message from response
      if (data is Map) {
        if (data['message'] != null) {
          return data['message'].toString();
        }
        if (data['error'] != null) {
          return data['error'].toString();
        }
      }

      return data.toString();
    }

    // Handle different error types
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout - please check your internet connection';
      case DioExceptionType.sendTimeout:
        return 'Send timeout - request took too long';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout - server response took too long';
      case DioExceptionType.badCertificate:
        return 'Bad certificate - SSL/TLS error';
      case DioExceptionType.badResponse:
        return 'Bad response from server (${e.response?.statusCode})';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error - check your internet connection';
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return 'Network error - no internet connection';
        }
        return 'Unknown error: ${e.message ?? e.error?.toString() ?? "No details"}';
      default:
        return 'Network error occurred';
    }
  }

  /// 🧪 Test Connection (optional helper method)
  Future<bool> testConnection() async {
    try {
      final response = await getKnowledges(limit: 1);
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }
}
