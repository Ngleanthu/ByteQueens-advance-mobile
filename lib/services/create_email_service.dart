import 'dart:io';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:bytequeens_adm/services/auth_service.dart';
import '../data/models/email_model.dart';

class EmailService {
  final Dio _dio;
  final AuthService _authService = AuthService();

  static const String _fallbackToken = "";

  EmailService({Dio? dio})
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
      print('Setting up SSL bypass for Email Service...');

      if (_dio.httpClientAdapter is IOHttpClientAdapter) {
        (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) {
                print(' Bypassing SSL for $host:$port');
                return true;
              };
          return client;
        };
      } else {
        print(' Running on web platform - SSL bypass not needed');
      }
    } catch (e) {
      print('Error setting up SSL bypass: $e');
    }
  }

  /// Setup interceptors for logging
  void _setupInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          log('📤 Request: ${options.method} ${options.uri}');
          log('📤 Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log('Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          log('Error: ${error.response?.statusCode} - ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  /// Generate email từ AI
  Future<EmailResponse> generateEmail({
    required String model,
    required String email,
    required String action,
    required String mainIdea,
    required EmailMetadata metadata,
    String? token,
  }) async {
    final actualToken =
        token ?? _authService.getAccessToken() ?? _fallbackToken;

    final body = {
      "email": email,
      "action": action,
      "mainIdea": mainIdea,
      "metadata": metadata.toJson(),
    };

    try {
      log('Generating email with model: $model');

      final response = await _dio.post(
        '/ai-email',
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $actualToken',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('Email generated successfully');
        return EmailResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to generate email: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('Dio error: ${e.response?.data}');

      String errorMessage = "Network error";

      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          errorMessage = data['message'];
        } else if (data is String) {
          errorMessage = data;
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = "Connection timeout";
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Receive timeout";
      }

      throw ApiException(
        statusCode: e.response?.statusCode ?? 0,
        message: errorMessage,
      );
    } catch (e) {
      log(' Unexpected error: $e');
      throw ApiException(statusCode: 0, message: 'Unexpected error: $e');
    }
  }
}
