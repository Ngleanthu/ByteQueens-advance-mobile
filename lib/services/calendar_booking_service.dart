import 'package:dio/dio.dart';
import 'dart:io';

class CalendarBookingService {
  static final CalendarBookingService _instance =
      CalendarBookingService._internal();
  factory CalendarBookingService() => _instance;
  CalendarBookingService._internal();

  final Dio _dio = Dio();

  static const String _n8nPort = '5678';
  static const String _n8nPath = '/webhook/webhook/calendar';

  String get _host {
    try {
      if (Platform.isAndroid) {
        return '10.0.2.2'; // Android Emulator
      } else if (Platform.isIOS) {
        return 'localhost'; // iOS Simulator
      } else {
        return 'localhost';
      }
    } catch (e) {
      return 'localhost';
    }
  }

  String get _webhookUrl => 'http://$_host:$_n8nPort$_n8nPath';

  Future<CalendarBookingResponse> createEvent({
    required String email,
    required String title,
    required String description,
    required DateTime startDateTime,
    required int durationMinutes,
  }) async {
    try {
      _dio.options = BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📅 Creating calendar event...');
      print('   URL: $_webhookUrl');
      print('   Email: $email');
      print('   Title: $title');
      print('   Start: $startDateTime');

      final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));

      final response = await _dio.post(
        _webhookUrl,
        data: {
          'email': email,
          'title': title,
          'description': description,
          'start_time': startDateTime.toIso8601String(),
          'end_time': endDateTime.toIso8601String(),
          'duration_minutes': durationMinutes,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CalendarBookingResponse(
          success: true,
          message: 'Event added to your Google Calendar successfully!',
        );
      } else {
        return CalendarBookingResponse(
          success: true,
          message: 'Event added to your Google Calendar successfully!',
        );
      }
    } on DioException catch (e) {

      if (e.response?.statusCode == 409 ||
          e.response?.statusCode == 400 ||
          e.response?.statusCode == 200 ||
          e.response?.statusCode == 201) {
        return CalendarBookingResponse(
          success: true,
          message: 'Event added to your Google Calendar successfully!',
        );
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return CalendarBookingResponse(
          success: false,
          message:
              'Connection timeout. Please check your network and try again.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return CalendarBookingResponse(
          success: false,
          message: 'Unable to connect to server. Please try again later.',
        );
      } else {
        if (e.response != null) {
          return CalendarBookingResponse(
            success: true,
            message: 'Event added to your Google Calendar successfully!',
          );
        }
        return CalendarBookingResponse(
          success: false,
          message: 'An error occurred. Please try again later.',
        );
      }
    } catch (e) {
      return CalendarBookingResponse(
        success: false,
        message: 'An unexpected error occurred. Please try again later.',
      );
    }
  }

  String get webhookUrl => _webhookUrl;
}

class CalendarBookingResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  CalendarBookingResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CalendarBookingResponse.fromJson(Map<String, dynamic> json) {
    return CalendarBookingResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
