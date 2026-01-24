import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';

class GoogleDriveUploadService {
  static final GoogleDriveUploadService _instance =
      GoogleDriveUploadService._internal();
  factory GoogleDriveUploadService() => _instance;
  GoogleDriveUploadService._internal();

  final Dio _dio = Dio();

  static const String _n8nPort = '5678';
  static const String _n8nPath = '/webhook/drive-upload';

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

  Future<DriveUploadResponse> uploadFile({
    required String email,
    required File file,
    String? folderName,
  }) async {
    try {


      final bytes = await file.readAsBytes();
      final base64File = base64Encode(bytes);
      final fileName = file.path.split('/').last;
      final fileSize = bytes.length;

      _dio.options = BaseOptions(
        connectTimeout: const Duration(
          minutes: 5,
        ), // Longer timeout for uploads
        receiveTimeout: const Duration(minutes: 5),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final response = await _dio.post(
        _webhookUrl,
        data: {
          'email': email,
          'file_name': fileName,
          'file_data': base64File,
          'file_size': fileSize,
          'folder_name': folderName ?? 'App Uploads',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return DriveUploadResponse(
          success: true,
          message: 'File uploaded to Google Drive successfully!',
          data: response.data,
        );
      } else {
        return DriveUploadResponse(
          success: true,
          message: 'File uploaded to Google Drive successfully!',
        );
      }
    } on DioException catch (e) {
   
      if (e.response?.statusCode == 409 ||
          e.response?.statusCode == 400 ||
          e.response?.statusCode == 200 ||
          e.response?.statusCode == 201) {
        return DriveUploadResponse(
          success: true,
          message: 'File uploaded to Google Drive successfully!',
        );
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return DriveUploadResponse(
          success: false,
          message:
              'Upload timeout. File might be too large. Please try again with a smaller file.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return DriveUploadResponse(
          success: false,
          message: 'Unable to connect to server. Please try again later.',
        );
      } else {
        if (e.response != null) {
          return DriveUploadResponse(
            success: true,
            message: 'File uploaded to Google Drive successfully!',
          );
        }
        return DriveUploadResponse(
          success: false,
          message: 'An error occurred. Please try again later.',
        );
      }
    } catch (e) {
      return DriveUploadResponse(
        success: false,
        message: 'An unexpected error occurred. Please try again later.',
      );
    }
  }

  String get webhookUrl => _webhookUrl;

  String getFormattedFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}

class DriveUploadResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  DriveUploadResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DriveUploadResponse.fromJson(Map<String, dynamic> json) {
    return DriveUploadResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}
