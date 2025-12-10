import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../data/models/prompt.dart';
import 'package:bytequeens_adm/services/auth_service.dart';

class PromptService {
  final Dio _dio;
  final AuthService _authService = AuthService();

  static const String _fallbackToken = "";

  PromptService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://api.jarvis.cx/api/v1',
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          ) {
    _setupSslBypass();
    _setupInterceptors();
  }

  /// Setup SSL bypass để fix lỗi certificate expired
  void _setupSslBypass() {
    try {
      // ⚠️ WARNING: Chỉ dùng cho development/testing
      print('🔧 Setting up SSL bypass...');

      // Chỉ setup SSL bypass khi không phải web platform
      if (_dio.httpClientAdapter is IOHttpClientAdapter) {
        (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) {
                print('⚠️ Bypassing SSL for $host:$port');
                return true;
              };
          return client;
        };
      } else {
        // Web platform - không cần SSL bypass
        print('🌐 Running on web platform - SSL bypass not needed');
      }
    } catch (e) {
      print('⚠️ SSL bypass setup failed: $e');
      // Không throw error, để app vẫn chạy được
    }
  }

  /// Setup interceptors for logging
  void _setupInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> _createPromptApi(
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final actualToken =
        token ?? _authService.getAccessToken() ?? _fallbackToken;

    return _dio.post(
      '/prompts',
      data: body,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $actualToken',
        },
      ),
    );
  }

  Future<Response> _getPromptsApi({
    String? category,
    bool? isPublic,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
    String? token,
  }) async {
    final actualToken =
        token ?? _authService.getAccessToken() ?? _fallbackToken;

    final query = {
      if (category != null) 'category': category,
      if (isPublic != null) 'isPublic': isPublic.toString(),
      if (isFavorite != null) 'isFavorite': isFavorite.toString(),
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    return _dio.get(
      '/prompts',
      queryParameters: query,
      options: Options(headers: {'Authorization': 'Bearer $actualToken'}),
    );
  }

  /// CREATE PROMPT
  Future<Prompt> createPrompt({
    required String title,
    required String content,
    required String description,
    required bool isPublic,
    String? token,
  }) async {
    final body = {
      "title": title,
      "content": content,
      "description": description,
      "isPublic": isPublic,
    };

    try {
      final resp = await _createPromptApi(body, token: token);

      return Prompt.fromJson(
        resp.data is Map<String, dynamic>
            ? resp.data
            : Map<String, dynamic>.from(resp.data),
      );
    } on DioException catch (e) {
      String msg = "Network error";

      if (e.response != null) {
        final d = e.response!.data;
        msg = (d is Map && d['message'] != null) ? d['message'] : d.toString();
      }
      throw Exception(msg);
    }
  }

  /// GET PROMPTS
  Future<List<Prompt>> getPrompts({
    bool? isPublic,
    String? category,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
    String? token,
  }) async {
    try {
      final resp = await _getPromptsApi(
        isPublic: isPublic,
        category: category,
        isFavorite: isFavorite,
        limit: limit,
        offset: offset,
        token: token,
      );

      final data = resp.data;

      if (data is List) {
        return data.map((e) => Prompt.fromJson(e)).toList();
      }

      if (data is Map && data['items'] is List) {
        return (data['items'] as List).map((e) => Prompt.fromJson(e)).toList();
      }

      throw Exception("Invalid response format");
    } catch (e) {
      rethrow;
    }
  }

  //ADD Favorite
  Future<void> addFavorite(String promptId, {String? token}) async {
    final actualToken =
        token ?? _authService.getAccessToken() ?? _fallbackToken;

    try {
      await _dio.post(
        '/prompts/$promptId/favorite',
        options: Options(headers: {'Authorization': 'Bearer $actualToken'}),
      );
    } on DioException catch (e) {
      String msg = "Network error";

      if (e.response != null) {
        final d = e.response!.data;
        msg = (d is Map && d['message'] != null) ? d['message'] : d.toString();
      }

      throw Exception(msg);
    }
  }

  Future<void> removeFavorite(String promptId, {String? token}) async {
    final actualToken =
        token ?? _authService.getAccessToken() ?? _fallbackToken;

    try {
      await _dio.delete(
        '/prompts/$promptId/favorite',
        options: Options(headers: {'Authorization': 'Bearer $actualToken'}),
      );
    } on DioException catch (e) {
      String msg = "Network error";
      if (e.response != null) {
        final d = e.response!.data;
        msg = (d is Map && d['message'] != null) ? d['message'] : d.toString();
      }
      throw Exception(msg);
    }
  }

  Future<void> toggleFavorite(bool isFav, String promptId) async {
    if (isFav) {
      await removeFavorite(promptId);
    } else {
      await addFavorite(promptId);
    }
  }
}
