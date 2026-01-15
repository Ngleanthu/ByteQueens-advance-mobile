// NOTE: This service is currently not in use because the KB API does not support
// storing or retrieving AI model information for bots. The API only stores:
// - Bot name (assistantName)
// - Instructions
// - Description
// - OpenAI Assistant ID
// - Thread ID
//
// The model selection is not persisted on the backend, so all bots will default
// to using AIModel.gpt4oMini when retrieved from the API.
//
// To use this service, the backend would need to add a "model" field to the bot entity
// and include it in the create/update/get bot endpoints.

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bytequeens_adm/data/models/ai_model.dart';

/// Service to store and retrieve bot model mappings
/// Since KB API doesn't store model information, we need to store it locally
class BotModelStorageService {
  static final BotModelStorageService _instance =
      BotModelStorageService._internal();
  factory BotModelStorageService() => _instance;
  BotModelStorageService._internal();

  final _storage = const FlutterSecureStorage();
  static const _key = 'bot_models_mapping';

  // In-memory cache for quick access
  Map<String, AIModel>? _cache;

  /// Load all bot model mappings from storage
  Future<Map<String, AIModel>> _loadMapping() async {
    if (_cache != null) {
      return _cache!;
    }

    try {
      final jsonString = await _storage.read(key: _key);
      if (jsonString == null || jsonString.isEmpty) {
        _cache = {};
        return _cache!;
      }

      final Map<String, dynamic> json = jsonDecode(jsonString);
      _cache = json.map(
        (key, value) => MapEntry(key, AIModel.values[value as int]),
      );

      return _cache!;
    } catch (e) {
      print('Error loading bot models mapping: $e');
      _cache = {};
      return _cache!;
    }
  }

  /// Save all bot model mappings to storage
  Future<void> _saveMapping(Map<String, AIModel> mapping) async {
    try {
      final json = mapping.map((key, value) => MapEntry(key, value.index));
      final jsonString = jsonEncode(json);
      await _storage.write(key: _key, value: jsonString);
      _cache = mapping;
    } catch (e) {
      print('Error saving bot models mapping: $e');
    }
  }

  /// Store model for a specific bot
  Future<void> saveBotModel(String botId, AIModel model) async {
    final mapping = await _loadMapping();
    mapping[botId] = model;
    await _saveMapping(mapping);
    print('💾 Saved model ${model.displayName} for bot $botId');
  }

  /// Get model for a specific bot
  /// Returns null if not found, caller should use default
  Future<AIModel?> getBotModel(String botId) async {
    final mapping = await _loadMapping();
    final model = mapping[botId];
    if (model != null) {
      print('📖 Retrieved model ${model.displayName} for bot $botId');
    } else {
      print('⚠️ No model found for bot $botId, will use default');
    }
    return model;
  }

  /// Delete model mapping for a specific bot
  Future<void> deleteBotModel(String botId) async {
    final mapping = await _loadMapping();
    mapping.remove(botId);
    await _saveMapping(mapping);
    print('🗑️ Deleted model mapping for bot $botId');
  }

  /// Get models for multiple bots
  Future<Map<String, AIModel>> getBotModels(List<String> botIds) async {
    final mapping = await _loadMapping();
    final result = <String, AIModel>{};

    for (final botId in botIds) {
      if (mapping.containsKey(botId)) {
        result[botId] = mapping[botId]!;
      }
    }

    return result;
  }

  /// Clear all model mappings
  Future<void> clearAll() async {
    await _storage.delete(key: _key);
    _cache = null;
    print('🧹 Cleared all bot model mappings');
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStats() async {
    final mapping = await _loadMapping();
    return {
      'totalBots': mapping.length,
      'modelCounts': _getModelCounts(mapping),
    };
  }

  Map<String, int> _getModelCounts(Map<String, AIModel> mapping) {
    final counts = <String, int>{};
    for (final model in mapping.values) {
      final name = model.displayName;
      counts[name] = (counts[name] ?? 0) + 1;
    }
    return counts;
  }
}
