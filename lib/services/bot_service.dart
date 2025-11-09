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
}
