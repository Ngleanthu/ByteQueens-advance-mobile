import 'package:dio/dio.dart';
import '../api/prompt_api.dart';
import '../data/models/prompt.dart';

class PromptService {
  final PromptApi api;

  PromptService({PromptApi? api}) : api = api ?? PromptApi();

  Future<Prompt> createPrompt({
    required String title,
    required String content,
    required String description,
    required bool isPublic,
    String? token,
  }) async {
    final temp = Prompt(
      id: '',
      title: title,
      content: content,
      description: description,
      isPublic: isPublic,
    );

    final body = temp.toJsonForCreate();

    try {
      final resp = await api.createPrompt(body, token: token);
      if (resp.statusCode != null &&
          resp.statusCode! >= 200 &&
          resp.statusCode! < 300) {
        final data = resp.data;
        if (data is Map<String, dynamic>) {
          return Prompt.fromJson(data);
        } else {
          return Prompt.fromJson(Map<String, dynamic>.from(data));
        }
      } else {
        throw Exception('Create prompt failed: ${resp.statusCode}');
      }
    } on DioError catch (e) {
      String message = 'Network error';
      if (e.response != null && e.response?.data != null) {
        try {
          final d = e.response!.data;
          if (d is Map && d['message'] != null)
            message = d['message'].toString();
          else
            message = d.toString();
        } catch (_) {
          message = e.message ?? "";
        }
      } else {
        message = e.message ?? "";
      }
      throw Exception(message);
    }
  }

  Future<List<Prompt>> getPrompts({
    bool? isPublic,
    String? category,
    bool? isFavourite,
    int limit = 20,
    int offset = 0,
    String? token,
  }) async {
    print("🔧 [Service] getPrompts()");
    print("│ isPublic: $isPublic");
    print("│ category: $category");
    print("│ isFavourite: $isFavourite");
    print("│ limit: $limit, offset: $offset");

    try {
      final resp = await api.getPrompts(
        isPublic: isPublic,
        category: category,
        isFavourite: isFavourite,
        limit: limit,
        offset: offset,
        token: token,
      );

      print("🔍 [Service] Raw response: ${resp.data}");

      final data = resp.data;

      // Case list trực tiếp
      if (data is List) {
        print("📦 [Service] Received List<Prompt> (direct)");
        return data.map((e) => Prompt.fromJson(e)).toList();
      }

      // Case response dạng { items: [...] }
      if (data is Map && data['items'] is List) {
        print("📦 [Service] Received items[] inside map");
        return (data['items'] as List).map((e) => Prompt.fromJson(e)).toList();
      }

      print("❌ [Service] Invalid response format");
      throw Exception("Invalid response format");
    } catch (e) {
      print("❌ [Service] getPrompts error: $e");
      rethrow;
    }
  }
}
