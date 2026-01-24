import 'package:bytequeens_adm/data/models/ai_chat_models.dart';
import 'package:bytequeens_adm/services/ai_chat_service.dart';

/// Repository layer for AI Chat
/// Wraps the service layer and provides additional business logic if needed
class AiChatRepository {
  static final AiChatRepository _instance = AiChatRepository._internal();
  factory AiChatRepository() => _instance;
  AiChatRepository._internal();

  final AiChatService _service = AiChatService();

  /// Get conversation history with messages
  ///
  /// Returns a list of messages from a specific conversation
  /// [conversationId] - ID of the conversation to fetch
  /// [assistantId] - ID of the assistant used in conversation
  /// [assistantModel] - Model type (default: "dify")
  /// [cursor] - For pagination, get next page
  /// [limit] - Number of messages per page
  Future<ConversationHistoryResponse> getConversationHistory({
    required String conversationId,
    required String assistantId,
    String assistantModel = 'dify',
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _service.getConversationHistory(
        conversationId: conversationId,
        assistantId: assistantId,
        assistantModel: assistantModel,
        cursor: cursor,
        limit: limit,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Send a message to the AI assistant
  ///
  /// [content] - The message text to send
  /// [assistant] - Assistant configuration (id, model, name)
  /// [conversationHistory] - Previous messages in the conversation
  /// [conversationId] - ID of the conversation (if continuing existing conversation)
  /// [files] - Optional list of file URLs
  ///
  /// Returns the AI's response along with conversation ID
  Future<MessageResponse> sendMessage({
    required String content,
    required AssistantDto assistant,
    List<Map<String, dynamic>>? conversationHistory,
    String? conversationId,
    List<String>? files,
  }) async {
    try {
      // Build metadata with conversation history and ID
      final metadata = AiChatMetadata(
        conversation: ConversationMetadata(
          messages: conversationHistory ?? [],
          id: conversationId,
        ),
      );

      final response = await _service.sendMessage(
        content: content,
        files: files,
        metadata: metadata,
        assistant: assistant,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new conversation thread
  ///
  /// This starts a new conversation with the first message
  /// [content] - First message content
  /// [assistant] - Assistant configuration
  /// [files] - Optional list of file URLs
  ///
  /// Returns the AI's response and new conversation ID
  Future<MessageResponse> createNewThread({
    required String content,
    required AssistantDto assistant,
    List<String>? files,
  }) async {
    try {
      final response = await _service.createNewThread(
        content: content,
        files: files,
        assistant: assistant,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Get list of all conversations/threads
  ///
  /// [assistantId] - ID of the assistant (e.g., "gpt-4o-mini")
  /// [assistantModel] - Model of the assistant (default: "dify")
  /// [cursor] - For pagination
  /// [limit] - Number of conversations per page
  ///
  /// Returns list of conversation threads with metadata
  Future<ConversationListResponse> getConversationList({
    required String assistantId,
    String assistantModel = 'dify',
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final response = await _service.getConversations(
        assistantId: assistantId,
        assistantModel: assistantModel,
        cursor: cursor,
        limit: limit,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Helper: Get all messages from a conversation (auto-pagination)
  ///
  /// This will automatically fetch all pages if there are more messages
  /// [conversationId] - ID of the conversation
  /// [assistantId] - Assistant ID
  /// [assistantModel] - Assistant model type
  Future<List<ApiChatMessage>> getAllMessagesInConversation({
    required String conversationId,
    required String assistantId,
    String assistantModel = 'dify',
  }) async {
    final List<ApiChatMessage> allMessages = [];
    String? cursor;
    bool hasMore = true;

    try {
      while (hasMore) {
        final response = await getConversationHistory(
          conversationId: conversationId,
          assistantId: assistantId,
          assistantModel: assistantModel,
          cursor: cursor,
        );

        allMessages.addAll(response.items);
        cursor = response.cursor;
        hasMore = response.hasMore;
      }

      return allMessages;
    } catch (e) {
      rethrow;
    }
  }

  /// Helper: Get all conversations (auto-pagination)
  ///
  /// [assistantId] - ID of the assistant (e.g., "gpt-4o-mini")
  /// [assistantModel] - Model of the assistant (default: "dify")
  /// Fetches all conversation threads across multiple pages
  Future<List<ThreadItemModel>> getAllConversations({
    required String assistantId,
    String assistantModel = 'dify',
  }) async {
    final List<ThreadItemModel> allConversations = [];
    String? cursor;
    bool hasMore = true;

    try {
      while (hasMore) {
        final response = await getConversationList(
          assistantId: assistantId,
          assistantModel: assistantModel,
          cursor: cursor,
        );
        allConversations.addAll(response.items);
        cursor = response.cursor;
        hasMore = response.hasMore;
      }

      return allConversations;
    } catch (e) {
      rethrow;
    }
  }

  /// Helper: Create a default assistant for Gemini 1.5 Flash
  AssistantDto getDefaultAssistant() {
    return AssistantDto(
      id: AssistantId.gemini15FlashLatest.value,
      model: AssistantModel.dify.value,
      name: 'Gemini 1.5 Flash',
    );
  }

  /// Helper: Create assistant from enum values
  AssistantDto createAssistant({
    required AssistantId assistantId,
    required AssistantModel assistantModel,
    String? name,
  }) {
    return AssistantDto(
      id: assistantId.value,
      model: assistantModel.value,
      name: name ?? assistantId.displayName,
    );
  }

  /// Helper: Get all available assistants
  List<AssistantDto> getAllAssistants() {
    return [
      // Claude Models
      AssistantDto(
        id: AssistantId.claude35Sonnet20240620.value,
        model: AssistantModel.dify.value,
        name: AssistantId.claude35Sonnet20240620.displayName,
      ),
      AssistantDto(
        id: AssistantId.claude3Haiku20240307.value,
        model: AssistantModel.dify.value,
        name: AssistantId.claude3Haiku20240307.displayName,
      ),
      // Gemini Models
      AssistantDto(
        id: AssistantId.gemini15FlashLatest.value,
        model: AssistantModel.dify.value,
        name: AssistantId.gemini15FlashLatest.displayName,
      ),
      AssistantDto(
        id: AssistantId.gemini15ProLatest.value,
        model: AssistantModel.dify.value,
        name: AssistantId.gemini15ProLatest.displayName,
      ),
      // GPT Models
      AssistantDto(
        id: AssistantId.gpt4O.value,
        model: AssistantModel.dify.value,
        name: AssistantId.gpt4O.displayName,
      ),
      AssistantDto(
        id: AssistantId.gpt4OMini.value,
        model: AssistantModel.dify.value,
        name: AssistantId.gpt4OMini.displayName,
      ),
    ];
  }

  /// Set Jarvis GUID (call after getting user info)
  /// Access token sẽ tự động được lấy từ AuthService
  void setJarvisGuid(String guid) {
    _service.setJarvisGuid(guid);
  }

  /// Get current Jarvis GUID
  String? getJarvisGuid() {
    return _service.getJarvisGuid();
  }

  /// Clear Jarvis GUID (call on logout)
  void clearJarvisGuid() {
    _service.clearJarvisGuid();
  }
}
