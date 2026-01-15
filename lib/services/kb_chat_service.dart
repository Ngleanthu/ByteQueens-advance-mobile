import 'package:bytequeens_adm/services/kb_service.dart';
import 'package:bytequeens_adm/data/models/kb_chat_model.dart';
import 'package:bytequeens_adm/data/models/bot.dart';
import 'package:bytequeens_adm/config/app_constants.dart';

/// KB Chat Service
/// Handles chat interactions with bots using KB API
class KBChatService {
  static final KBChatService _instance = KBChatService._internal();
  factory KBChatService() => _instance;
  KBChatService._internal();

  final KBService _kbService = KBService();

  // Thread management for preview chat
  final Map<String, String> _botConversations = {}; // botId -> conversationId

  // Conversation history for each bot
  final Map<String, List<ConversationMessage>> _conversationHistory = {};

  // ========== PREVIEW CHAT (KB_Ask_Bot) ==========

  /// Chat with bot in preview mode
  /// Uses KB_Ask_Bot API with conversation management
  Future<String> previewChat({
    required String botId,
    required String message,
  }) async {
    try {
      // Send message via KB API (only message in body)
      final response = await _kbService.askBot(
        assistantId: botId,
        message: message,
      );

      // Store conversation ID if returned
      if (response.conversationId != null) {
        _botConversations[botId] = response.conversationId!;
      }

      return response.content;
    } catch (e) {
      print('Error in preview chat: $e');
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  /// Get conversation ID for a bot
  String? getConversationId(String botId) {
    return _botConversations[botId];
  }

  /// Clear conversation for a bot (start new conversation)
  void clearConversation(String botId) {
    _botConversations.remove(botId);
  }

  /// Clear all conversations
  void clearAllConversations() {
    _botConversations.clear();
  }

  // ========== PRODUCTION CHAT (Jarvis_Chat_With_Bot) ==========

  /// Chat with bot in production mode
  /// Uses Jarvis Chat API with full conversation history
  Future<JarvisChatResponse> productionChat({
    required Bot bot,
    required String message,
    List<dynamic>? files,
    bool includeHistory = true,
  }) async {
    try {
      // Create assistant info
      final assistant = JarvisAssistant(
        id: bot.openAiAssistantId ?? bot.id,
        model: AppConstants.knowledgeBaseModel,
        name: bot.name,
      );

      // Get conversation history if needed
      List<ConversationMessage> history = [];
      if (includeHistory) {
        history = _conversationHistory[bot.id] ?? [];
      }

      // Send message via Jarvis Chat API
      final response = await _kbService.chatWithBot(
        content: message,
        assistant: assistant,
        files: files,
        conversationHistory: history,
      );

      // Add user message to history
      _addToHistory(
        botId: bot.id,
        role: 'user',
        content: message,
        assistant: assistant,
        files: files,
      );

      // Add bot response to history
      _addToHistory(
        botId: bot.id,
        role: 'model',
        content: response.message,
        assistant: assistant,
      );

      return response;
    } catch (e) {
      print('Error in production chat: $e');
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  /// Add message to conversation history
  void _addToHistory({
    required String botId,
    required String role,
    required String content,
    required JarvisAssistant assistant,
    List<dynamic>? files,
  }) {
    if (!_conversationHistory.containsKey(botId)) {
      _conversationHistory[botId] = [];
    }

    final message = ConversationMessage(
      role: role,
      content: content,
      assistant: assistant,
      files: files,
    );

    _conversationHistory[botId]!.add(message);
  }

  /// Get conversation history for a bot
  List<ConversationMessage> getConversationHistory(String botId) {
    return _conversationHistory[botId] ?? [];
  }

  /// Clear conversation history for a bot
  void clearConversationHistory(String botId) {
    _conversationHistory.remove(botId);
  }

  /// Clear all conversation histories
  void clearAllConversationHistories() {
    _conversationHistory.clear();
  }

  // ========== HELPER METHODS ==========

  /// Build conversation messages for display
  List<Map<String, dynamic>> buildDisplayMessages(String botId) {
    final history = _conversationHistory[botId] ?? [];

    return history.map((msg) {
      return {
        'role': msg.role,
        'content': msg.content,
        'timestamp': DateTime.now().toIso8601String(),
        'isUser': msg.role == 'user',
      };
    }).toList();
  }

  /// Get last message from bot
  String? getLastBotMessage(String botId) {
    final history = _conversationHistory[botId];
    if (history == null || history.isEmpty) return null;

    // Find last model message
    for (int i = history.length - 1; i >= 0; i--) {
      if (history[i].role == 'model') {
        return history[i].content;
      }
    }

    return null;
  }

  /// Get conversation message count
  int getMessageCount(String botId) {
    return _conversationHistory[botId]?.length ?? 0;
  }

  /// Export conversation as JSON
  Map<String, dynamic> exportConversation(String botId) {
    final history = _conversationHistory[botId] ?? [];

    return {
      'botId': botId,
      'messageCount': history.length,
      'messages': history.map((msg) => msg.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import conversation from JSON
  void importConversation(String botId, Map<String, dynamic> data) {
    if (data['messages'] is List) {
      final messages = (data['messages'] as List)
          .map(
            (msg) => ConversationMessage.fromJson(msg as Map<String, dynamic>),
          )
          .toList();

      _conversationHistory[botId] = messages;
    }
  }

  /// Clear all data
  void clearAll() {
    _botConversations.clear();
    _conversationHistory.clear();
  }

  // ========== STREAM CHAT (FUTURE ENHANCEMENT) ==========

  /// Stream chat responses (for real-time streaming)
  /// This can be implemented later when KB API supports streaming
  Stream<String>? streamChat({required String botId, required String message}) {
    // TODO: Implement streaming when API supports it
    // For now, return null to indicate streaming not supported
    return null;
  }
}
