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

}
