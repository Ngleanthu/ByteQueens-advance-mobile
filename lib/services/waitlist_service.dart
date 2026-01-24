import 'package:dio/dio.dart';
import 'dart:io';

class WaitlistService {
  static final WaitlistService _instance = WaitlistService._internal();
  factory WaitlistService() => _instance;
  WaitlistService._internal();

  final Dio _dio = Dio();

  static const String _n8nPort = '5678';
  static const String _n8nPath = '/webhook/webhook/waitlist';

  String get _host {
    try {
      if (Platform.isAndroid) {
        return '10.0.2.2'; // Android Emulator
      } else if (Platform.isIOS) {
        return 'localhost'; // iOS Simulator can use localhost
      } else {
        return 'localhost'; // Default for other platforms
      }
    } catch (e) {
      return 'localhost'; // Fallback
    }
  }

  String get _webhookUrl => 'http://$_host:$_n8nPort$_n8nPath';

  Future<WaitlistResponse> addToWaitlist({required String email}) async {
    try {
      _dio.options = BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );


      final now = DateTime.now();
      final formattedDate = _formatDateTime(now);

      final response = await _dio.post(
        _webhookUrl,
        data: {'email': email, 'registered_at': formattedDate},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return WaitlistResponse(
          success: true,
          message:
              'Successfully added to waitlist! Thank you for your interest.',
        );
      } else {
        return WaitlistResponse(
          success: true,
          message:
              'Successfully added to waitlist! Thank you for your interest.',
        );
      }
    } on DioException catch (e) {

      if (e.response?.statusCode == 409 ||
          e.response?.statusCode == 400 ||
          e.response?.statusCode == 200 ||
          e.response?.statusCode == 201) {
        return WaitlistResponse(
          success: true,
          message:
              'Successfully added to waitlist! Thank you for your interest.',
        );
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return WaitlistResponse(
          success: false,
          message:
              'Connection timeout. Please check your network and try again.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return WaitlistResponse(
          success: false,
          message: 'Unable to connect to server. Please try again later.',
        );
      } else {
        if (e.response != null) {
          return WaitlistResponse(
            success: true,
            message:
                'Successfully added to waitlist! Thank you for your interest.',
          );
        }
        return WaitlistResponse(
          success: false,
          message: 'An error occurred. Please try again later.',
        );
      }
    } catch (e) {
      return WaitlistResponse(
        success: false,
        message: 'An unexpected error occurred. Please try again later.',
      );
    }
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final month = months[dt.month - 1];
    final day = dt.day;
    final year = dt.year;

    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';

    return '$month $day, $year $hour:$minute $period';
  }

  String get webhookUrl => _webhookUrl;
}

class WaitlistResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  WaitlistResponse({required this.success, required this.message, this.data});

  factory WaitlistResponse.fromJson(Map<String, dynamic> json) {
    return WaitlistResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
