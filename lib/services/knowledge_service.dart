import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:bytequeens_adm/services/auth_service.dart';

class KnowledgeService {
  final Dio _dio;
  final AuthService _authService = AuthService();

  static const String _fallbackToken = "";
  static const String _jarvisGuid = "a153d8df-ee7d-4ac3-943e-882726700f9b";

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

  String _getToken(String? token) {
    final actualToken =
        token ?? _authService.getAccessToken() ?? _fallbackToken;
    return actualToken;
  }

  Map<String, String> _headers(String token, {String? jarvisGuid}) {
    final guid = jarvisGuid ?? _jarvisGuid;
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'x-jarvis-guid': guid,
    };
  }

  /// CREATE Knowledge Base
  Future<Response> createKnowledge({
    required String knowledgeName,
    required String description,
    String? token,
    String? jarvisGuid,
  }) async {
    final actualToken = _getToken(token);

    try {
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

  /// GET All Knowledge Bases
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
      final queryParams = <String, dynamic>{
        'q': query ?? '',
        'order': order,
        'order_field': orderField,
        'offset': offset,
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

  /// UPDATE Knowledge Base
  Future<Response> updateKnowledge(
    String knowledgeId, {
    required String knowledgeName,
    required String description,
    String? token,
    String? jarvisGuid,
  }) async {
    final actualToken = _getToken(token);

    try {
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

  /// DELETE Knowledge Base
  Future<void> deleteKnowledge(
    String knowledgeId, {
    String? token,
    String? jarvisGuid,
  }) async {
    final actualToken = _getToken(token);

    try {
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

  /// GET Knowledge Units
  Future<Response> getKnowledgeUnits(
    String knowledgeId, {
    String? query,
    String order = 'DESC',
    String orderField = 'createdAt',
    int offset = 0,
    int limit = 10,
    String? token,
    String? jarvisGuid,
  }) async {
    final actualToken = _getToken(token);

    try {
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

  /// GET Single Knowledge Base (optional helper method)
  Future<Response> getKnowledge(
    String knowledgeId, {
    String? token,
    String? jarvisGuid,
  }) async {
    final actualToken = _getToken(token);

    try {
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

  /// UPLOAD Files
  Future<Response> uploadFiles({
    required List<File> files,
    String? token,
    String? jarvisGuid,
  }) async {
    final actualToken = _getToken(token);

    try {
      FormData formData = FormData();

      for (var file in files) {
        String fileName = file.path.split('/').last;
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(file.path, filename: fileName),
          ),
        );
      }

      return await _dio.post(
        '/knowledge/files',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $actualToken',
            'x-jarvis-guid': jarvisGuid ?? _jarvisGuid,
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Response> addDatasources(
    String knowledgeId, {
    required List<Map<String, dynamic>> datasources,
    String? token,
    String? jarvisGuid,
  }) async {
    final actualToken = _getToken(token);
    final guid = jarvisGuid ?? _jarvisGuid;

    final requestBody = {'datasources': datasources};

    final path = '/knowledge/$knowledgeId/datasources';
    try {
      final response = await _dio.post(
        path,
        data: requestBody,
        options: Options(
          headers: _headers(actualToken, jarvisGuid: jarvisGuid),
        ),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Response> addLocalFilesDatasource(
    String knowledgeId, {
    required String name,
    required List<String> fileIds,
    String? token,
    String? jarvisGuid,
  }) async {
    final datasources = [
      {
        'name': name,
        'type': 'local_file',
        'credentials': {
          'files': fileIds
              .map(
                (id) => {
                  'fileId': id,
                  'fileType': 'pdf', // You can make this dynamic if needed
                },
              )
              .toList(),
        },
      },
    ];

    return addDatasources(
      knowledgeId,
      datasources: datasources,
      token: token,
      jarvisGuid: jarvisGuid,
    );
  }

  /// ADD Confluence Datasource
  Future<Response> addConfluenceDatasource(
    String knowledgeId, {
    required String name,
    required String url,
    required String username,
    required String confluenceToken,
    bool sync = false,
    int pageLimit = 128,
    String? token,
    String? jarvisGuid,
  }) async {
    final datasources = [
      {
        'name': name,
        'type': 'confluence',
        'credentials': {
          'url': url,
          'username': username,
          'token': confluenceToken,
        },
        'options': {'sync': sync, 'pageLimit': pageLimit},
      },
    ];

    return addDatasources(
      knowledgeId,
      datasources: datasources,
      token: token,
      jarvisGuid: jarvisGuid,
    );
  }

  /// ADD Google Drive Datasource
  Future<Response> addGoogleDriveDatasource(
    String knowledgeId, {
    required String name,
    required String oauthToken,
    required List<Map<String, String>> items, // [{id, type}]
    bool autoSync = true,
    String syncInterval = '12h',
    String? token,
    String? jarvisGuid,
  }) async {
    final datasources = [
      {
        'name': name,
        'type': 'google_drive',
        'credentials': {'oauthToken': oauthToken, 'items': items},
        'options': {'autoSync': autoSync, 'syncInterval': syncInterval},
      },
    ];

    return addDatasources(
      knowledgeId,
      datasources: datasources,
      token: token,
      jarvisGuid: jarvisGuid,
    );
  }

  /// ADD Web Datasource
  Future<Response> addWebDatasource(
    String knowledgeId, {
    required String name,
    required String url,
    String crawlType = 'single_page', // 'single_page' or 'whole_site'
    int pageLimit = 64,
    bool autoSync = true,
    String syncInterval = '12h',
    String? token,
    String? jarvisGuid,
  }) async {
    final datasources = [
      {
        'name': name,
        'type': 'web',
        'credentials': {'url': url},
        'options': {
          'crawlType': crawlType,
          'pageLimit': pageLimit,
          'autoSync': autoSync,
          'syncInterval': syncInterval,
        },
      },
    ];

    return addDatasources(
      knowledgeId,
      datasources: datasources,
      token: token,
      jarvisGuid: jarvisGuid,
    );
  }

  Future<Response> addSlackDatasource(
    String knowledgeId, {
    required String name,
    required String token,
    bool autoUpdate = false,
    String? authToken,
    String? jarvisGuid,
  }) {
    return addDatasources(
      knowledgeId,
      datasources: [
        {
          'name': name,
          'type': 'slack',
          'credentials': {'token': token, 'autoUpdate': autoUpdate},
        },
      ],
      token: authToken,
      jarvisGuid: jarvisGuid,
    );
  }

  Future<Response> getDatasources(
    String knowledgeId, {
    String? query,
    String order = 'DESC',
    String orderField = 'createdAt',
    int offset = 0,
    int limit = 20,
    bool? isFavorite,
    bool? isPublished,
    String? token,
    String? jarvisGuid,
  }) async {
    final actualToken = _getToken(token);
    final guid = jarvisGuid ?? _jarvisGuid;

    try {
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

      if (isFavorite != null) {
        queryParams['is_favorite'] = isFavorite;
      }

      if (isPublished != null) {
        queryParams['is_published'] = isPublished;
      }

      final path = '/knowledge/$knowledgeId/datasources';
      // Generate cURL command
      final response = await _dio.get(
        path,
        queryParameters: queryParams,
        options: Options(
          headers: _headers(actualToken, jarvisGuid: jarvisGuid),
        ),
      );
      return response;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// UPDATE Datasource
  Future<Response> updateDatasource(
    String knowledgeId,
    String datasourceId, {
    String? name,
    Map<String, dynamic>? credentials,
    Map<String, dynamic>? options,
    String? token,
    String? jarvisGuid,
  }) async {
    final actualToken = _getToken(token);

    try {
      final data = <String, dynamic>{};

      if (name != null) {
        data['name'] = name;
      }

      if (credentials != null) {
        data['credentials'] = credentials;
      }

      if (options != null) {
        data['options'] = options;
      }

      return await _dio.patch(
        '/knowledge/$knowledgeId/datasources/$datasourceId',
        data: data,
        options: Options(
          headers: _headers(actualToken, jarvisGuid: jarvisGuid),
        ),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// DELETE Datasource
  Future<void> deleteDatasource(
    String knowledgeId,
    String datasourceId, {
    String? token,
    String? jarvisGuid,
  }) async {
    final actualToken = _getToken(token);

    try {
      await _dio.delete(
        '/knowledge/$knowledgeId/datasources/$datasourceId',
        options: Options(
          headers: _headers(actualToken, jarvisGuid: jarvisGuid),
        ),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Error Handler
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

  /// Test Connection (optional helper method)
  Future<bool> testConnection() async {
    try {
      final response = await getKnowledges(limit: 1);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
