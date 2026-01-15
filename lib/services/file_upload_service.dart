import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:crypto/crypto.dart';

/// Service for uploading files to Cloudinary via REST API
class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() => _instance;
  FileUploadService._internal();

  final Dio _dio = Dio();

  // Cloudinary configuration
  static const String _cloudName = 'dszu0fyxg';
  static const String _apiKey = '726877353115713';
  static const String _apiSecret = 'tShQVqXpvBXoxunLZzo_v9EG-Fw';
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Generate Cloudinary signature for signed upload
  String _generateSignature(Map<String, dynamic> params) {
    // Sort parameters alphabetically
    final sortedKeys = params.keys.toList()..sort();

    // Create signature string: param1=value1&param2=value2...
    final signatureString = sortedKeys
        .map((key) => '$key=${params[key]}')
        .join('&');

    // Create SHA256 hash with API secret
    final bytes = utf8.encode(signatureString + _apiSecret);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  /// Upload an image file to Cloudinary and return the file URL
  /// [filePath] - Path to the local file
  /// [xFile] - XFile object (for web support)
  /// Returns the uploaded file secure URL
  Future<String> uploadImage(String filePath, {dynamic xFile}) async {
    try {
      print('🚀 Starting signed image upload to Cloudinary');

      // Generate timestamp for signature
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Parameters for signature
      final params = {
        'folder': 'chat_images',
        'timestamp': timestamp.toString(),
      };

      // Generate signature
      final signature = _generateSignature(params);
      print('🔐 Signature generated for timestamp: $timestamp');

      FormData formData;

      if (kIsWeb && xFile != null) {
        // On web, use XFile to read bytes
        print('📤 Web upload: Reading bytes from XFile');
        final bytes = await xFile.readAsBytes();
        final fileName = xFile.name;

        formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            bytes,
            filename: fileName,
            contentType: MediaType('image', 'jpeg'),
          ),
          'folder': 'chat_images',
          'timestamp': timestamp.toString(),
          'api_key': _apiKey,
          'signature': signature,
        });
        print('✅ Web FormData created with ${bytes.length} bytes');
      } else {
        // On mobile, use file path
        print('📤 Mobile upload: Using file path');
        final file = File(filePath);
        if (!await file.exists()) {
          throw Exception('File does not exist: $filePath');
        }

        final fileName = file.path.split('/').last;
        print('   File: $fileName (${await file.length()} bytes)');

        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: MediaType('image', 'jpeg'),
          ),
          'folder': 'chat_images',
          'timestamp': timestamp.toString(),
          'api_key': _apiKey,
          'signature': signature,
        });
        print('✅ Mobile FormData created');
      }

      // Upload to Cloudinary
      print('📡 Sending POST request to Cloudinary...');
      final response = await _dio.post(
        _uploadUrl,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('📥 Cloudinary response: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.data['secure_url'] != null) {
          final url = response.data['secure_url'] as String;
          print('✅ Upload successful: $url');
          return url;
        } else {
          print('❌ Response missing secure_url: ${response.data}');
          throw Exception('Upload failed: No secure_url in response');
        }
      } else {
        print('❌ Upload failed with status ${response.statusCode}');
        print('   Response: ${response.data}');
        throw Exception('Upload failed: ${response.data}');
      }
    } on DioException catch (e) {
      print('❌ DioException during upload:');
      print('   Status: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
      print('   Message: ${e.message}');
      throw Exception(
        'Failed to upload image: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      print('❌ Unexpected error during upload: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload an image with progress callback
  /// [filePath] - Path to the local file
  /// [onProgress] - Callback for upload progress (0.0 to 1.0)
  /// Returns the uploaded file secure URL
  Future<String> uploadImageWithProgress(
    String filePath,
    Function(double)? onProgress,
  ) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      // Generate timestamp and signature
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final params = {
        'folder': 'chat_images',
        'timestamp': timestamp.toString(),
      };
      final signature = _generateSignature(params);

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'folder': 'chat_images',
        'timestamp': timestamp.toString(),
        'api_key': _apiKey,
        'signature': signature,
      });

      // Upload with progress tracking
      final response = await _dio.post(
        _uploadUrl,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200 && response.data['secure_url'] != null) {
        return response.data['secure_url'] as String;
      } else {
        throw Exception('Upload failed: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload multiple files
  /// [filePaths] - List of file paths
  /// Returns list of uploaded file URLs
  Future<List<String>> uploadMultipleFiles(List<String> filePaths) async {
    final urls = <String>[];

    for (final path in filePaths) {
      try {
        final url = await uploadImage(path);
        urls.add(url);
      } catch (e) {
        // Continue with other files
      }
    }

    return urls;
  }
}
