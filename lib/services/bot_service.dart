import 'package:bytequeens_adm/data/models/bot.dart';
import 'package:bytequeens_adm/data/models/ai_model.dart';
import 'package:bytequeens_adm/data/models/knowledge_source.dart';
import 'package:bytequeens_adm/data/models/api_exception.dart';
import 'package:bytequeens_adm/services/kb_service.dart';
// import 'package:bytequeens_adm/services/bot_model_storage_service.dart'; // KB API doesn't support model info

class BotService {
  static final BotService _instance = BotService._internal();
  factory BotService() => _instance;
  BotService._internal();

  // Services
  final KBService _kbService = KBService();
  // final BotModelStorageService _modelStorage = BotModelStorageService(); // KB API doesn't support model info

  // Local cache for bots
  final List<Bot> _botsCache = [];
  DateTime? _lastCacheUpdate;
  static const _cacheValidDuration = Duration(minutes: 5);
  static const _maxCacheSize = 100; // Maximum number of bots to cache
  static const _apiMaxLimit = 50; // API maximum limit per request

  // Cache stats for monitoring
  int _cacheHits = 0;
  int _cacheMisses = 0;

  // Mock user info (will be replaced with real user from AuthService)
  String _currentUserId = 'user_001';
  String _currentUserName = 'Nguyễn Lê Anh Thư';
  String _currentUserEmail = 'ngleanth@gmail.com';

  // Use KB API flag (set to true to use real API, false for mock data)
  bool _useKBApi = true;

  // Validation constants
  static const int _maxNameLength = 100;
  static const int _maxDescriptionLength = 500;
  static const int _maxInstructionsLength = 2000;

  /// Enable/disable KB API usage
  void setUseKBApi(bool use) {
    _useKBApi = use;
    if (!use) {
      _botsCache.clear();
      _lastCacheUpdate = null;
    }
  }

  /// Check if cache is valid
  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidDuration;
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final totalRequests = _cacheHits + _cacheMisses;
    final hitRate = totalRequests > 0
        ? (_cacheHits / totalRequests * 100)
        : 0.0;

    return {
      'cacheSize': _botsCache.length,
      'maxCacheSize': _maxCacheSize,
      'cacheHits': _cacheHits,
      'cacheMisses': _cacheMisses,
      'hitRate': hitRate.toStringAsFixed(2),
      'lastUpdate': _lastCacheUpdate?.toIso8601String(),
      'isValid': _isCacheValid(),
    };
  }

  /// Clear cache
  void clearCache() {
    _botsCache.clear();
    _lastCacheUpdate = null;
    _cacheHits = 0;
    _cacheMisses = 0;
    // Note: We don't clear model storage here as it should persist across app restarts
  }

  /// Invalidate specific bot in cache
  void invalidateBotCache(String botId) {
    _botsCache.removeWhere((bot) => bot.id == botId);
  }

  /// Update bot in cache
  void _updateBotInCache(Bot bot) {
    final index = _botsCache.indexWhere((b) => b.id == bot.id);
    if (index != -1) {
      _botsCache[index] = bot;
    } else {
      // Add to cache if not exists, but check size limit
      if (_botsCache.length >= _maxCacheSize) {
        // Remove oldest bot (first item)
        _botsCache.removeAt(0);
      }
      _botsCache.add(bot);
    }
  }

  /// Validate bot name
  void _validateBotName(String name) {
    if (name.trim().isEmpty) {
      throw ApiException.validation(message: 'Bot name cannot be empty.');
    }
    if (name.length > _maxNameLength) {
      throw ApiException.validation(
        message: 'Bot name cannot exceed $_maxNameLength characters.',
      );
    }
  }

  /// Validate bot description
  void _validateDescription(String? description) {
    if (description != null && description.length > _maxDescriptionLength) {
      throw ApiException.validation(
        message: 'Description cannot exceed $_maxDescriptionLength characters.',
      );
    }
  }

  /// Validate bot instructions
  void _validateInstructions(String? instructions) {
    if (instructions != null && instructions.length > _maxInstructionsLength) {
      throw ApiException.validation(
        message:
            'Instructions cannot exceed $_maxInstructionsLength characters.',
      );
    }
  }

  /// Validate bot ID
  void _validateBotId(String id) {
    if (id.trim().isEmpty) {
      throw ApiException.validation(message: 'Bot ID cannot be empty.');
    }
  }

  /// Validate knowledge source ID
  void _validateKnowledgeId(String id) {
    if (id.trim().isEmpty) {
      throw ApiException.validation(
        message: 'Knowledge source ID cannot be empty.',
      );
    }
  }

  /// Get all bots with caching
  Future<List<Bot>> getAllBots({
    bool forceRefresh = false,
    String? searchQuery,
  }) async {
    if (!_useKBApi) {
      // Mock data fallback
      await Future.delayed(const Duration(milliseconds: 500));
      return List.from(_botsCache);
    }

    // If searching, always fetch from API (don't use cache)
    final useCache = searchQuery == null || searchQuery.trim().isEmpty;

    // Return cache if valid and not forcing refresh and not searching
    if (useCache && !forceRefresh && _isCacheValid() && _botsCache.isNotEmpty) {
      _cacheHits++;
      print('📊 Cache hit! Stats: ${getCacheStats()}');
      return List.from(_botsCache);
    }

    _cacheMisses++;
    print('📊 Cache miss! Stats: ${getCacheStats()}');

    // Fetch from KB API (using API limit, not cache size)
    final response = await _kbService.getBots(
      query: searchQuery,
      limit: _apiMaxLimit,
      order: 'DESC',
      orderField: 'createdAt',
    );

    // Convert KB bots to app bots
    final bots = response.data.map((kbBot) {
      return Bot.fromKBBot(
        kbBot,
        model: AIModel
            .gpt4oMini, // Default model since KB API doesn't support model info
        ownerId: _currentUserId,
        ownerName: _currentUserName,
        ownerEmail: _currentUserEmail,
      );
    }).toList();

    // Only update cache if not searching (cache should only contain all bots)
    if (useCache) {
      _botsCache.clear();
      _botsCache.addAll(bots);
      _lastCacheUpdate = DateTime.now();
      print('✅ Loaded and cached ${bots.length} bots');
    } else {
      print('🔍 Search returned ${bots.length} bots (not cached)');
    }

    return bots;
  }

  /// Get bots with pagination
  Future<List<Bot>> getBotsWithPagination({
    int page = 1,
    int limit = 20,
    String? orderField,
    String? order,
    bool? isFavorite,
  }) async {
    if (!_useKBApi) {
      // Mock data fallback
      await Future.delayed(const Duration(milliseconds: 500));
      return List.from(_botsCache);
    }

    try {
      final response = await _kbService.getBots(
        offset: (page - 1) * limit,
        limit: limit,
        orderField: orderField,
        order: order,
        isFavorite: isFavorite,
      );

      // Convert KB bots to app bots
      // Note: KB API doesn't store model info, so we default to gpt4oMini
      return response.data.map((kbBot) {
        return Bot.fromKBBot(
          kbBot,
          model: AIModel
              .gpt4oMini, // Default model since KB API doesn't support model info
          isFavorite: isFavorite ?? false,
          ownerId: _currentUserId,
          ownerName: _currentUserName,
          ownerEmail: _currentUserEmail,
        );
      }).toList();
    } catch (e) {
      print('Error fetching bots with pagination: $e');
      return [];
    }
  }

  /// Get bot by ID
  Future<Bot?> getBotById(String id) async {
    if (!_useKBApi) {
      // Mock data fallback
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        return _botsCache.firstWhere((bot) => bot.id == id);
      } catch (e) {
        return null;
      }
    }

    // Try cache first
    final cached = _botsCache.firstWhere(
      (bot) => bot.id == id,
      orElse: () => Bot(
        id: '',
        name: '',
        model: AIModel.gpt4o,
        knowledgeSources: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ownerId: '',
        ownerName: '',
        ownerEmail: '',
      ),
    );

    if (cached.id.isNotEmpty) {
      _cacheHits++;
      print('📊 Bot cache hit for ID: $id');
      return cached;
    }

    _cacheMisses++;
    print('📊 Bot cache miss for ID: $id');

    // Fetch from KB API
    final kbBot = await _kbService.getBotById(id);

    // Note: KB API doesn't store model info, so we default to gpt4oMini
    final bot = Bot.fromKBBot(
      kbBot,
      model: AIModel
          .gpt4oMini, // Default model since KB API doesn't support model info
      ownerId: _currentUserId,
      ownerName: _currentUserName,
      ownerEmail: _currentUserEmail,
    );

    // Update cache using helper method
    _updateBotInCache(bot);

    // Update cache using helper method
    _updateBotInCache(bot);

    return bot;
  }

  /// Create a new bot
  Future<Bot> createBot({
    required String name,
    String? description,
    String? instructions,
    required AIModel model,
    List<KnowledgeSource>? knowledgeSources,
  }) async {
    // Validate inputs
    _validateBotName(name);
    _validateDescription(description);
    _validateInstructions(instructions);

    if (!_useKBApi) {
      // Mock data fallback
      await Future.delayed(const Duration(seconds: 1));

      final bot = Bot(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        instructions: instructions,
        model: model,
        knowledgeSources: knowledgeSources ?? [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ownerId: _currentUserId,
        ownerName: _currentUserName,
        ownerEmail: _currentUserEmail,
      );

      _botsCache.add(bot);
      return bot;
    }

    // Create via KB API
    final kbBot = await _kbService.createBot(
      assistantName: name,
      instructions: instructions,
      description: description,
    );

    final bot = Bot.fromKBBot(
      kbBot,
      model: model,
      knowledgeSources: knowledgeSources ?? [],
      ownerId: _currentUserId,
      ownerName: _currentUserName,
      ownerEmail: _currentUserEmail,
    );

    // Note: KB API doesn't support model info, so we can't save it
    // await _modelStorage.saveBotModel(bot.id, model);

    // Add to cache using helper method
    _updateBotInCache(bot);
    _lastCacheUpdate = DateTime.now();
    print('✅ Bot created and cached: ${bot.name}');

    return bot;
  }

  /// Update an existing bot
  Future<Bot> updateBot(Bot bot) async {
    // Validate inputs
    _validateBotId(bot.id);
    _validateBotName(bot.name);
    _validateDescription(bot.description);
    _validateInstructions(bot.instructions);

    if (!_useKBApi) {
      // Mock data fallback
      await Future.delayed(const Duration(milliseconds: 800));

      final index = _botsCache.indexWhere((b) => b.id == bot.id);
      if (index != -1) {
        _botsCache[index] = bot;
        return bot;
      }

      throw ApiException.notFound(message: 'Bot not found');
    }

    // Update via KB API
    final kbBot = await _kbService.updateBot(
      assistantId: bot.id,
      assistantName: bot.name,
      instructions: bot.instructions,
      description: bot.description,
    );

    final updatedBot = Bot.fromKBBot(
      kbBot,
      model: bot.model,
      knowledgeSources: bot.knowledgeSources,
      isFavorite: bot.isFavorite,
      ownerId: bot.ownerId,
      ownerName: bot.ownerName,
      ownerEmail: bot.ownerEmail,
    );

    // Note: KB API doesn't support model info, so we can't save it
    // await _modelStorage.saveBotModel(bot.id, bot.model);

    // Update cache using helper method
    _updateBotInCache(updatedBot);
    print('✅ Bot updated and cached: ${updatedBot.name}');

    return updatedBot;
  }

  /// Delete a bot
  Future<void> deleteBot(String id) async {
    // Validate input
    _validateBotId(id);

    if (!_useKBApi) {
      // Mock data fallback
      await Future.delayed(const Duration(milliseconds: 500));
      _botsCache.removeWhere((bot) => bot.id == id);
      return;
    }

    // Delete via KB API
    await _kbService.deleteBot(id);

    // Note: KB API doesn't support model info, so no need to delete it
    // await _modelStorage.deleteBotModel(id);

    // Remove from cache
    invalidateBotCache(id);
    print('✅ Bot deleted and removed from cache: $id');
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String botId) async {
    final bot = await getBotById(botId);
    if (bot != null) {
      final updated = bot.copyWith(isFavorite: !bot.isFavorite);
      await updateBot(updated);
    }
  }

  /// Add knowledge source to bot
  Future<Bot> addKnowledgeSource(String botId, KnowledgeSource source) async {
    // Validate inputs
    _validateBotId(botId);
    _validateKnowledgeId(source.id);

    if (!_useKBApi) {
      // Mock data fallback
      await Future.delayed(const Duration(milliseconds: 500));

      final bot = await getBotById(botId);
      if (bot != null) {
        final sources = List<KnowledgeSource>.from(bot.knowledgeSources);
        sources.add(source);
        final updated = bot.copyWith(knowledgeSources: sources);
        return await updateBot(updated);
      }

      throw ApiException.notFound(message: 'Bot not found');
    }

    // Add via KB API
    await _kbService.addKnowledgeToBot(
      assistantId: botId,
      knowledgeId: source.id,
    );

    // Update local bot
    final bot = await getBotById(botId);
    if (bot != null) {
      final sources = List<KnowledgeSource>.from(bot.knowledgeSources);
      sources.add(source);
      final updated = bot.copyWith(knowledgeSources: sources);

      // Update cache
      final index = _botsCache.indexWhere((b) => b.id == botId);
      if (index != -1) {
        _botsCache[index] = updated;
      }

      return updated;
    }

    throw ApiException.notFound(message: 'Bot not found');
  }

  /// Remove knowledge source from bot
  Future<Bot> removeKnowledgeSource(String botId, String sourceId) async {
    // Validate inputs
    _validateBotId(botId);
    _validateKnowledgeId(sourceId);

    if (!_useKBApi) {
      // Mock data fallback
      await Future.delayed(const Duration(milliseconds: 500));

      final bot = await getBotById(botId);
      if (bot != null) {
        final sources = bot.knowledgeSources
            .where((s) => s.id != sourceId)
            .toList();
        final updated = bot.copyWith(knowledgeSources: sources);
        return await updateBot(updated);
      }

      throw ApiException.notFound(message: 'Bot not found');
    }

    // Remove via KB API
    await _kbService.removeKnowledgeFromBot(
      assistantId: botId,
      knowledgeId: sourceId,
    );

    // Update local bot
    final bot = await getBotById(botId);
    if (bot != null) {
      final sources = bot.knowledgeSources
          .where((s) => s.id != sourceId)
          .toList();
      final updated = bot.copyWith(knowledgeSources: sources);

      // Update cache
      final index = _botsCache.indexWhere((b) => b.id == botId);
      if (index != -1) {
        _botsCache[index] = updated;
      }

      return updated;
    }

    throw ApiException.notFound(message: 'Bot not found');
  }

  /// Search bots by query
  Future<List<Bot>> searchBots(String query) async {
    if (!_useKBApi) {
      // Mock data fallback
      await Future.delayed(const Duration(milliseconds: 400));

      if (query.isEmpty) {
        return getAllBots();
      }

      final lowerQuery = query.toLowerCase();
      return _botsCache.where((bot) {
        return bot.name.toLowerCase().contains(lowerQuery) ||
            (bot.description?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    try {
      // Search via KB API
      final response = await _kbService.getBots(query: query, limit: 100);

      // Convert to app bots
      return response.data.map((kbBot) {
        return Bot.fromKBBot(
          kbBot,
          model: AIModel.gpt4o,
          ownerId: _currentUserId,
          ownerName: _currentUserName,
          ownerEmail: _currentUserEmail,
        );
      }).toList();
    } catch (e) {
      print('Error searching bots: $e');
      // Fallback to local search
      final lowerQuery = query.toLowerCase();
      return _botsCache.where((bot) {
        return bot.name.toLowerCase().contains(lowerQuery) ||
            (bot.description?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }
  }

  /// Get favorite bots
  Future<List<Bot>> getFavoriteBots() async {
    if (!_useKBApi) {
      // Mock data fallback
      await Future.delayed(const Duration(milliseconds: 300));
      return _botsCache.where((bot) => bot.isFavorite).toList();
    }

    try {
      // Fetch favorites via KB API
      final response = await _kbService.getBots(
        isFavorite: true,
        limit: 100,
        order: 'DESC',
        orderField: 'createdAt',
      );

      // Convert to app bots
      return response.data.map((kbBot) {
        return Bot.fromKBBot(
          kbBot,
          model: AIModel.gpt4o,
          isFavorite: true,
          ownerId: _currentUserId,
          ownerName: _currentUserName,
          ownerEmail: _currentUserEmail,
        );
      }).toList();
    } catch (e) {
      print('Error fetching favorite bots: $e');
      // Fallback to cached favorites
      return _botsCache.where((bot) => bot.isFavorite).toList();
    }
  }

  /// Sort bots locally
  List<Bot> sortBots(List<Bot> bots, String sortBy) {
    final sorted = List<Bot>.from(bots);

    switch (sortBy) {
      case 'name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'date':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return sorted;
  }

  /// Send message to bot (mock for now, will be replaced with KB chat)
  Future<String> sendMessage(String botId, String message) async {
    await Future.delayed(const Duration(seconds: 2));

    final bot = await getBotById(botId);
    if (bot == null) {
      return 'Bot not found';
    }

    // This will be replaced with KB chat integration in Phase 4
    return 'This is a mock response from ${bot.name}. '
        'In production, this would use the ${bot.model.displayName} model '
        'and knowledge from ${bot.knowledgeSources.length} sources.';
  }

  /// Get current user info
  Map<String, String> getCurrentUser() {
    return {
      'id': _currentUserId,
      'name': _currentUserName,
      'email': _currentUserEmail,
    };
  }

  /// Set current user info
  void setCurrentUser({
    required String userId,
    required String userName,
    required String userEmail,
  }) {
    _currentUserId = userId;
    _currentUserName = userName;
    _currentUserEmail = userEmail;
  }

  /// Get KB Service instance
  KBService get kbService => _kbService;
}
