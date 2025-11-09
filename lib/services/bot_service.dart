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


}
