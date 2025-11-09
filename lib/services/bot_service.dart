import 'package:bytequeens_adm/data/models/bot.dart';
import 'package:bytequeens_adm/data/models/ai_model.dart';
import 'package:bytequeens_adm/data/models/knowledge_source.dart';


class BotService {
  static final BotService _instance = BotService._internal();
  factory BotService() => _instance;
  BotService._internal();

  
  final List<Bot> _bots = [];
  
  String _currentUserId = 'user_001';
  String _currentUserName = 'Nguyễn Lê Anh Thư';
  String _currentUserEmail = 'ngleanth@gmail.com';

  
  Future<List<Bot>> getAllBots() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_bots);
  }

  
  Future<Bot?> getBotById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _bots.firstWhere((bot) => bot.id == id);
    } catch (e) {
      return null;
    }
  }

  
  Future<Bot> createBot({
    required String name,
    String? description,
    String? instructions,
    required AIModel model,
    List<KnowledgeSource>? knowledgeSources,
  }) async {
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

    _bots.add(bot);
    return bot;
  }

  
  Future<Bot> updateBot(Bot bot) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _bots.indexWhere((b) => b.id == bot.id);
    if (index != -1) {
      _bots[index] = bot;
      return bot;
    }

    throw Exception('Bot not found');
  }

  
  Future<void> deleteBot(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _bots.removeWhere((bot) => bot.id == id);
  }

  
  Future<Bot> toggleFavorite(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final bot = await getBotById(id);
    if (bot != null) {
      final updated = bot.copyWith(isFavorite: !bot.isFavorite);
      return await updateBot(updated);
    }

    throw Exception('Bot not found');
  }

  
  Future<Bot> addKnowledgeSource(String botId, KnowledgeSource source) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final bot = await getBotById(botId);
    if (bot != null) {
      final sources = List<KnowledgeSource>.from(bot.knowledgeSources);
      sources.add(source);
      final updated = bot.copyWith(knowledgeSources: sources);
      return await updateBot(updated);
    }

    throw Exception('Bot not found');
  }

  
  Future<Bot> removeKnowledgeSource(String botId, String sourceId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final bot = await getBotById(botId);
    if (bot != null) {
      final sources = bot.knowledgeSources
          .where((s) => s.id != sourceId)
          .toList();
      final updated = bot.copyWith(knowledgeSources: sources);
      return await updateBot(updated);
    }

    throw Exception('Bot not found');
  }

  
  Future<List<Bot>> searchBots(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (query.isEmpty) {
      return getAllBots();
    }

    final lowerQuery = query.toLowerCase();
    return _bots.where((bot) {
      return bot.name.toLowerCase().contains(lowerQuery) ||
          (bot.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  
  Future<List<Bot>> getFavoriteBots() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _bots.where((bot) => bot.isFavorite).toList();
  }

  
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

  
  Future<String> sendMessage(String botId, String message) async {
    await Future.delayed(const Duration(seconds: 2));

    final bot = await getBotById(botId);
    if (bot == null) {
      return 'Bot not found';
    }

    
    return 'This is a mock response from ${bot.name}. '
        'In production, this would use the ${bot.model.displayName} model '
        'and knowledge from ${bot.knowledgeSources.length} sources.';
  }

  
  Map<String, String> getCurrentUser() {
    return {
      'id': _currentUserId,
      'name': _currentUserName,
      'email': _currentUserEmail,
    };
  }
}
