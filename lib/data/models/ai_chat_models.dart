/// Enums for AI Chat
enum AssistantId {
  // Claude Models
  claude35Sonnet20240620('claude-3-5-sonnet-20240620'),
  claude35Haiku('claude-3-5-haiku'),
  claude3Haiku20240307('claude-3-haiku-20240307'),

  // Gemini Models
  gemini15FlashLatest('gemini-1.5-flash-latest'),
  gemini15ProLatest('gemini-1.5-pro-latest'),
  gemini15Pro('gemini-1.5-pro'),

  // GPT Models
  gpt4O('gpt-4o'),
  gpt4OMini('gpt-4o-mini'),
  azureGpt4O('azure-gpt-4o'),
  azureGpt4OMini('azure-gpt-4o-mini');

  final String value;
  const AssistantId(this.value);

  static AssistantId fromString(String value) {
    // Normalize value for better matching
    final normalized = value.toLowerCase().trim();

    return AssistantId.values.firstWhere(
      (e) => e.value.toLowerCase() == normalized,
      orElse: () {
        // Fallback: try partial matching
        if (normalized.contains('gpt-4o-mini') ||
            normalized.contains('azure-gpt-4o-mini')) {
          return AssistantId.gpt4OMini;
        }
        if (normalized.contains('gpt-4o') ||
            normalized.contains('azure-gpt-4o')) {
          return AssistantId.gpt4O;
        }
        if (normalized.contains('gemini-1.5-pro')) {
          return AssistantId.gemini15ProLatest;
        }
        if (normalized.contains('gemini-1.5-flash')) {
          return AssistantId.gemini15FlashLatest;
        }
        if (normalized.contains('claude-3-5-sonnet')) {
          return AssistantId.claude35Sonnet20240620;
        }
        if (normalized.contains('claude-3-5-haiku')) {
          return AssistantId.claude35Haiku;
        }
        if (normalized.contains('claude-3-haiku')) {
          return AssistantId.claude3Haiku20240307;
        }
        return AssistantId.gemini15FlashLatest;
      },
    );
  }

  /// Helper: Get display name for UI
  String get displayName {
    switch (this) {
      case AssistantId.claude35Sonnet20240620:
        return 'Claude 3.5 Sonnet';
      case AssistantId.claude35Haiku:
        return 'Claude 3 Haiku';
      case AssistantId.claude3Haiku20240307:
        return 'Claude 3 Haiku';
      case AssistantId.gemini15FlashLatest:
        return 'Gemini 1.5 Flash';
      case AssistantId.gemini15ProLatest:
        return 'Gemini 1.5 Pro';
      case AssistantId.gemini15Pro:
        return 'Gemini 1.5 Pro';
      case AssistantId.gpt4O:
        return 'GPT-4o';
      case AssistantId.gpt4OMini:
        return 'GPT-4o Mini';
      case AssistantId.azureGpt4O:
        return 'GPT-4o';
      case AssistantId.azureGpt4OMini:
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
  final AssistantDto? assistant; // Assistant info for this message

  ApiChatMessage({
    required this.answer,
    required this.createdAt,
    required this.files,
    required this.query,
    this.assistant,
  });

  factory ApiChatMessage.fromJson(Map<String, dynamic> json) {
    // Parse createdAt - có thể là int (timestamp) hoặc String (ISO date)
    int createdAtValue = 0;
    final createdAtRaw = json['createdAt'];

    if (createdAtRaw is int) {
      createdAtValue = createdAtRaw;
    } else if (createdAtRaw is String) {
      try {
        // Parse ISO 8601 date string và convert sang timestamp (seconds)
        final dateTime = DateTime.parse(createdAtRaw);
        createdAtValue = dateTime.millisecondsSinceEpoch ~/ 1000;
      } catch (e) {
        print('⚠️ Failed to parse createdAt in message: $createdAtRaw');
        createdAtValue = 0;
      }
    }

    // Parse assistant from inputs.assistant field
    AssistantDto? assistant;

    // Try to get assistant from inputs.assistant first
    if (json['inputs'] != null && json['inputs'] is Map<String, dynamic>) {
      final inputs = json['inputs'] as Map<String, dynamic>;
      final assistantId = inputs['assistant'] as String?;

      if (assistantId != null && assistantId.isNotEmpty) {
        try {
          assistant = AssistantDto(
            id: assistantId,
            model: 'agentic', // Default model from API
            name: AssistantId.fromString(assistantId).displayName,
          );
        } catch (e) {
          print('⚠️ Failed to create assistant from inputs: $e');
        }
      }
    }

    // Fallback: try assistant field directly
    if (assistant == null &&
        json['assistant'] != null &&
        json['assistant'] is Map<String, dynamic>) {
      try {
        assistant = AssistantDto.fromJson(
          json['assistant'] as Map<String, dynamic>,
        );
      } catch (e) {
        print('⚠️ Failed to parse assistant in message: $e');
      }
    }

    return ApiChatMessage(
      answer: json['answer'] as String? ?? '',
      createdAt: createdAtValue,
      files:
          (json['files'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      query: json['query'] as String? ?? '',
      assistant: assistant,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'answer': answer,
      'createdAt': createdAt,
      'files': files,
      'query': query,
    };
    if (assistant != null) {
      json['assistant'] = assistant!.toJson();
    }
    return json;
  }

  ApiChatMessage copyWith({
    String? answer,
    int? createdAt,
    List<String>? files,
    String? query,
    AssistantDto? assistant,
  }) {
    return ApiChatMessage(
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
      files: files ?? this.files,
      query: query ?? this.query,
      assistant: assistant ?? this.assistant,
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
  final String? id;

  ConversationMetadata({required this.messages, this.id});

  factory ConversationMetadata.fromJson(Map<String, dynamic> json) {
    return ConversationMetadata(
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {'messages': messages};
    if (id != null) {
      json['id'] = id!;
    }
    return json;
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
  final String? assistantId; // Store assistant ID for display

  ThreadItemModel({
    required this.title,
    required this.id,
    required this.createdAt,
    this.assistantId,
  });

  factory ThreadItemModel.fromJson(Map<String, dynamic> json) {
    // Parse createdAt - có thể là int (timestamp) hoặc String (ISO date)
    int createdAtValue = 0;
    final createdAtRaw = json['createdAt'];

    if (createdAtRaw is int) {
      createdAtValue = createdAtRaw;
    } else if (createdAtRaw is String) {
      try {
        // Parse ISO 8601 date string và convert sang timestamp (seconds)
        final dateTime = DateTime.parse(createdAtRaw);
        createdAtValue = dateTime.millisecondsSinceEpoch ~/ 1000;
      } catch (e) {
        print('⚠️ Failed to parse createdAt: $createdAtRaw');
        createdAtValue = 0;
      }
    }

    // Lấy assistantId từ bot.id nếu có
    String? assistantId;
    if (json['bot'] != null && json['bot'] is Map<String, dynamic>) {
      assistantId = json['bot']['id'] as String?;
    }

    return ThreadItemModel(
      title: json['title'] as String? ?? '',
      id: json['id'] as String? ?? '',
      createdAt: createdAtValue,
      assistantId: assistantId,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {'title': title, 'id': id, 'createdAt': createdAt};
    if (assistantId != null) json['assistantId'] = assistantId!;
    return json;
  }

  ThreadItemModel copyWith({
    String? title,
    String? id,
    int? createdAt,
    String? assistantId,
  }) {
    return ThreadItemModel(
      title: title ?? this.title,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      assistantId: assistantId ?? this.assistantId,
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
