/// Enums for AI Chat
enum AssistantId {
  // Claude Models
  claude35Sonnet20240620('claude-3-5-sonnet-20240620'),
  claude3Haiku20240307('claude-3-haiku-20240307'),

  // Gemini Models
  gemini15FlashLatest('gemini-1.5-flash-latest'),
  gemini15ProLatest('gemini-1.5-pro-latest'),

  // GPT Models
  gpt4O('gpt-4o'),
  gpt4OMini('gpt-4o-mini');

  final String value;
  const AssistantId(this.value);

  static AssistantId fromString(String value) {
    return AssistantId.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AssistantId.gemini15FlashLatest,
    );
  }

  /// Helper: Get display name for UI
  String get displayName {
    switch (this) {
      case AssistantId.claude35Sonnet20240620:
        return 'Claude 3.5 Sonnet';
      case AssistantId.claude3Haiku20240307:
        return 'Claude 3 Haiku';
      case AssistantId.gemini15FlashLatest:
        return 'Gemini 1.5 Flash';
      case AssistantId.gemini15ProLatest:
        return 'Gemini 1.5 Pro';
      case AssistantId.gpt4O:
        return 'GPT-4o';
      case AssistantId.gpt4OMini:
        return 'GPT-4o Mini';
    }
  }
}

enum AssistantModel {
  dify('dify'),
  openai('openai'),
  anthropic('anthropic');

  final String value;
  const AssistantModel(this.value);

  static AssistantModel fromString(String value) {
    return AssistantModel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AssistantModel.dify,
    );
  }
}

/// Assistant DTO
class AssistantDto {
  final String id;
  final String model;
  final String name;

  AssistantDto({required this.id, required this.model, required this.name});

  factory AssistantDto.fromJson(Map<String, dynamic> json) {
    return AssistantDto(
      id: json['id'] as String,
      model: json['model'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'model': model, 'name': name};
  }

  AssistantDto copyWith({String? id, String? model, String? name}) {
    return AssistantDto(
      id: id ?? this.id,
      model: model ?? this.model,
      name: name ?? this.name,
    );
  }
}

/// API Chat Message (from conversation history API)
/// This is the format returned by the API
class ApiChatMessage {
  final String answer;
  final int createdAt;
  final List<String> files;
  final String query;

  ApiChatMessage({
    required this.answer,
    required this.createdAt,
    required this.files,
    required this.query,
  });

  factory ApiChatMessage.fromJson(Map<String, dynamic> json) {
    return ApiChatMessage(
      answer: json['answer'] as String? ?? '',
      createdAt: json['createdAt'] as int? ?? 0,
      files:
          (json['files'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      query: json['query'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'createdAt': createdAt,
      'files': files,
      'query': query,
    };
  }

  ApiChatMessage copyWith({
    String? answer,
    int? createdAt,
    List<String>? files,
    String? query,
  }) {
    return ApiChatMessage(
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
      files: files ?? this.files,
      query: query ?? this.query,
    );
  }
}

/// Metadata for AI Chat
class AiChatMetadata {
  final ConversationMetadata conversation;

  AiChatMetadata({required this.conversation});

  factory AiChatMetadata.fromJson(Map<String, dynamic> json) {
    return AiChatMetadata(
      conversation: ConversationMetadata.fromJson(
        json['conversation'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'conversation': conversation.toJson()};
  }
}

class ConversationMetadata {
  final List<Map<String, dynamic>> messages;

  ConversationMetadata({required this.messages});

  factory ConversationMetadata.fromJson(Map<String, dynamic> json) {
    return ConversationMetadata(
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'messages': messages};
  }
}

/// Send Message Request
class AiSendMessageRequest {
  final String content;
  final List<String> files;
  final AiChatMetadata metadata;
  final AssistantDto assistant;

  AiSendMessageRequest({
    required this.content,
    required this.files,
    required this.metadata,
    required this.assistant,
  });

  factory AiSendMessageRequest.fromJson(Map<String, dynamic> json) {
    return AiSendMessageRequest(
      content: json['content'] as String,
      files:
          (json['files'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      metadata: AiChatMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      assistant: AssistantDto.fromJson(
        json['assistant'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'files': files,
      'metadata': metadata.toJson(),
      'assistant': assistant.toJson(),
    };
  }
}

/// Message Response (after sending message)
class MessageResponse {
  final String conversationId;
  final String message;
  final int remainingUsage;

  MessageResponse({
    required this.conversationId,
    required this.message,
    required this.remainingUsage,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      conversationId: json['conversationId'] as String? ?? '',
      message: json['message'] as String? ?? '',
      remainingUsage: json['remainingUsage'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'message': message,
      'remainingUsage': remainingUsage,
    };
  }

  MessageResponse copyWith({
    String? conversationId,
    String? message,
    int? remainingUsage,
  }) {
    return MessageResponse(
      conversationId: conversationId ?? this.conversationId,
      message: message ?? this.message,
      remainingUsage: remainingUsage ?? this.remainingUsage,
    );
  }
}

/// Conversation History Response
class ConversationHistoryResponse {
  final String? cursor;
  final bool hasMore;
  final int limit;
  final List<ApiChatMessage> items;

  ConversationHistoryResponse({
    this.cursor,
    required this.hasMore,
    required this.limit,
    required this.items,
  });

  factory ConversationHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ConversationHistoryResponse(
      cursor: json['cursor'] as String?,
      hasMore: json['has_more'] as bool? ?? false,
      limit: json['limit'] as int? ?? 20,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ApiChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cursor': cursor,
      'has_more': hasMore,
      'limit': limit,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  ConversationHistoryResponse copyWith({
    String? cursor,
    bool? hasMore,
    int? limit,
    List<ApiChatMessage>? items,
  }) {
    return ConversationHistoryResponse(
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
      limit: limit ?? this.limit,
      items: items ?? this.items,
    );
  }
}

/// Thread/Conversation Item
class ThreadItemModel {
  final String title;
  final String id;
  final int createdAt;

  ThreadItemModel({
    required this.title,
    required this.id,
    required this.createdAt,
  });

  factory ThreadItemModel.fromJson(Map<String, dynamic> json) {
    return ThreadItemModel(
      title: json['title'] as String? ?? '',
      id: json['id'] as String? ?? '',
      createdAt: json['createdAt'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'id': id, 'createdAt': createdAt};
  }

  ThreadItemModel copyWith({String? title, String? id, int? createdAt}) {
    return ThreadItemModel(
      title: title ?? this.title,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Conversation List Response
class ConversationListResponse {
  final String? cursor;
  final bool hasMore;
  final int limit;
  final List<ThreadItemModel> items;

  ConversationListResponse({
    this.cursor,
    required this.hasMore,
    required this.limit,
    required this.items,
  });

  factory ConversationListResponse.fromJson(Map<String, dynamic> json) {
    return ConversationListResponse(
      cursor: json['cursor'] as String?,
      hasMore: json['has_more'] as bool? ?? false,
      limit: json['limit'] as int? ?? 20,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => ThreadItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cursor': cursor,
      'has_more': hasMore,
      'limit': limit,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  ConversationListResponse copyWith({
    String? cursor,
    bool? hasMore,
    int? limit,
    List<ThreadItemModel>? items,
  }) {
    return ConversationListResponse(
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
      limit: limit ?? this.limit,
      items: items ?? this.items,
    );
  }
}
