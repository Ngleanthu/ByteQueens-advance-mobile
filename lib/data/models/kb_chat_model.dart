/// Knowledge Base Chat Models
/// Models for KB chat endpoints and Jarvis chat integration
library;

/// KB Ask Bot Request - For preview/testing chat
class KBChatRequest {
  final String message;

  KBChatRequest({required this.message});

  Map<String, dynamic> toJson() {
    return {'message': message};
  }

  factory KBChatRequest.fromJson(Map<String, dynamic> json) {
    return KBChatRequest(message: json['message'] as String);
  }
}

/// KB Chat Response
class KBChatResponse {
  final String content;
  final String? conversationId;

  KBChatResponse({required this.content, this.conversationId});

  factory KBChatResponse.fromJson(Map<String, dynamic> json) {
    return KBChatResponse(
      content: json['content'] as String,
      conversationId: json['conversationId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      if (conversationId != null) 'conversationId': conversationId,
    };
  }
}

/// Assistant info for Jarvis chat
class JarvisAssistant {
  final String id;
  final String model;
  final String name;

  JarvisAssistant({required this.id, required this.model, required this.name});

  factory JarvisAssistant.fromJson(Map<String, dynamic> json) {
    return JarvisAssistant(
      id: json['id'] as String,
      model: json['model'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'model': model, 'name': name};
  }
}

/// Message in conversation history
class ConversationMessage {
  final String role; // 'user' or 'model'
  final String content;
  final List<dynamic>? files;
  final JarvisAssistant assistant;

  ConversationMessage({
    required this.role,
    required this.content,
    this.files,
    required this.assistant,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      files: json['files'] as List<dynamic>?,
      assistant: JarvisAssistant.fromJson(
        json['assistant'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      if (files != null) 'files': files,
      'assistant': assistant.toJson(),
    };
  }
}

/// Conversation metadata
class ConversationMetadata {
  final List<ConversationMessage> messages;

  ConversationMetadata({required this.messages});

  factory ConversationMetadata.fromJson(Map<String, dynamic> json) {
    return ConversationMetadata(
      messages: (json['messages'] as List)
          .map(
            (item) =>
                ConversationMessage.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'messages': messages.map((msg) => msg.toJson()).toList()};
  }
}

/// Metadata wrapper for Jarvis chat
class JarvisChatMetadata {
  final ConversationMetadata conversation;

  JarvisChatMetadata({required this.conversation});

  factory JarvisChatMetadata.fromJson(Map<String, dynamic> json) {
    return JarvisChatMetadata(
      conversation: ConversationMetadata.fromJson(
        json['conversation'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'conversation': conversation.toJson()};
  }
}

/// Jarvis Chat Request - For production chat with bot
class JarvisChatRequest {
  final String content;
  final List<dynamic> files;
  final JarvisChatMetadata metadata;
  final JarvisAssistant assistant;

  JarvisChatRequest({
    required this.content,
    required this.files,
    required this.metadata,
    required this.assistant,
  });

  factory JarvisChatRequest.fromJson(Map<String, dynamic> json) {
    return JarvisChatRequest(
      content: json['content'] as String,
      files: json['files'] as List<dynamic>,
      metadata: JarvisChatMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      assistant: JarvisAssistant.fromJson(
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

/// Jarvis Chat Response
class JarvisChatResponse {
  final String message;
  final int? remainingUsage;

  JarvisChatResponse({required this.message, this.remainingUsage});

  factory JarvisChatResponse.fromJson(Map<String, dynamic> json) {
    return JarvisChatResponse(
      message: json['message'] as String,
      remainingUsage: json['remainingUsage'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (remainingUsage != null) 'remainingUsage': remainingUsage,
    };
  }
}

/// Helper class to build Jarvis chat request
class JarvisChatRequestBuilder {
  String? _content;
  List<dynamic> _files = [];
  List<ConversationMessage> _messages = [];
  JarvisAssistant? _assistant;

  JarvisChatRequestBuilder setContent(String content) {
    _content = content;
    return this;
  }

  JarvisChatRequestBuilder setFiles(List<dynamic> files) {
    _files = files;
    return this;
  }

  JarvisChatRequestBuilder setAssistant(JarvisAssistant assistant) {
    _assistant = assistant;
    return this;
  }

  JarvisChatRequestBuilder addMessage(ConversationMessage message) {
    _messages.add(message);
    return this;
  }

  JarvisChatRequestBuilder setMessages(List<ConversationMessage> messages) {
    _messages = messages;
    return this;
  }

  JarvisChatRequest build() {
    if (_content == null || _assistant == null) {
      throw Exception('Content and assistant are required');
    }

    return JarvisChatRequest(
      content: _content!,
      files: _files,
      metadata: JarvisChatMetadata(
        conversation: ConversationMetadata(messages: _messages),
      ),
      assistant: _assistant!,
    );
  }
}
