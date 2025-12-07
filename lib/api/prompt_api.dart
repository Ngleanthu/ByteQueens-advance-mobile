import 'package:dio/dio.dart';

class PromptApi {
  final Dio _dio;
  static const String _defaultToken =
      'eyJhbGciOiJFUzI1NiIsImtpZCI6IjNjbFlkbURkLVFrbSJ9.eyJzdWIiOiI1OThiYmYwYi0wNjgyLTQ2MzEtYjNkYy1mM2Q1NjZhMjg5YzUiLCJicmFuY2hJZCI6Im1haW4iLCJpc3MiOiJodHRwczovL2FjY2Vzcy10b2tlbi5qd3Qtc2lnbmF0dXJlLnN0YWNrLWF1dGguY29tIiwiaWF0IjoxNzY1MTI2MDI2LCJhdWQiOiJhOTE0ZjA2Yi01ZTQ2LTQ5NjYtODY5My04MGU0YjlmNGY0MDkiLCJleHAiOjE3NjUxMjY2MjZ9.SaU5GHdyNVnU6paLOuhf09_45SaNfyREZr7bYGgiViY84Osv_IRFO6he4Ut3lCZ0YWw4Nx2WfpvZsHh8POJz5g';
  PromptApi({Dio? dio})
    : _dio =
          dio ?? Dio(BaseOptions(baseUrl: 'https://api.dev.jarvis.cx/api/v1'));
  // -------------------------- CREATE PROMPTS --------------------------
  Future<Response> createPrompt(
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final actualToken = token ?? _defaultToken;
    final options = Options(
      headers: {
        'Content-Type': 'application/json',
        if (actualToken != null) 'Authorization': 'Bearer $actualToken',
      },
    );

    try {
      final resp = await _dio.post('/prompts', data: body, options: options);
      return resp;
    } on DioError catch (e) {
      rethrow;
    }
  }

  // -------------------------- GET PROMPTS --------------------------
  Future<Response> getPrompts({
    String? category,
    bool? isPublic,
    bool? isFavorite,
    int limit = 20,
    int offset = 0,
    String? token,
  }) async {
    final actualToken = token ?? _defaultToken;
    final query = {
      if (category != null) 'category': category,
      if (isPublic != null) 'isPublic': isPublic.toString(),
      if (isFavorite != null) 'isFavorite': isFavorite.toString(),
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    final options = Options(
      headers: {
        if (actualToken.isNotEmpty) 'Authorization': 'Bearer $actualToken',
      },
    );
    try {
      final resp = await _dio.get(
        '/prompts',
        queryParameters: query,
        options: options,
      );

      return resp;
    } on DioError catch (e) {
      if (e.response != null) {}
      rethrow;
    }
  }

}
