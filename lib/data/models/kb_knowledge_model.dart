/// Knowledge Base Knowledge Models
/// Models for knowledge sources and their management

/// KB Knowledge - Represents a knowledge source/unit
class KBKnowledge {
  final String id;
  final String name;
  final String? description;
  final String? type; // Type of knowledge source
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;
  final bool? isActive;
  final Map<String, dynamic>? metadata;

  KBKnowledge({
    required this.id,
    required this.name,
    this.description,
    this.type,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
    this.isActive,
    this.metadata,
  });

  factory KBKnowledge.fromJson(Map<String, dynamic> json) {
    return KBKnowledge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
      isActive: json['isActive'] as bool?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (createdBy != null) 'createdBy': createdBy,
      if (updatedBy != null) 'updatedBy': updatedBy,
      if (isActive != null) 'isActive': isActive,
      if (metadata != null) 'metadata': metadata,
    };
  }

  KBKnowledge copyWith({
    String? name,
    String? description,
    String? type,
    DateTime? updatedAt,
    String? updatedBy,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return KBKnowledge(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// KB Knowledge Response - For single knowledge response
class KBKnowledgeResponse {
  final KBKnowledge knowledge;
  final bool success;
  final String? message;

  KBKnowledgeResponse({
    required this.knowledge,
    this.success = true,
    this.message,
  });

  factory KBKnowledgeResponse.fromJson(Map<String, dynamic> json) {
    return KBKnowledgeResponse(
      knowledge: KBKnowledge.fromJson(
        json['knowledge'] as Map<String, dynamic>,
      ),
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'knowledge': knowledge.toJson(),
      'success': success,
      if (message != null) 'message': message,
    };
  }
}

/// KB Knowledges List Response
class KBKnowledgesListResponse {
  final List<KBKnowledge> data;
  final int? total;
  final int? offset;
  final int? limit;

  KBKnowledgesListResponse({
    required this.data,
    this.total,
    this.offset,
    this.limit,
  });

  factory KBKnowledgesListResponse.fromJson(Map<String, dynamic> json) {
    return KBKnowledgesListResponse(
      data: (json['data'] as List)
          .map((item) => KBKnowledge.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int?,
      offset: json['offset'] as int?,
      limit: json['limit'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((k) => k.toJson()).toList(),
      if (total != null) 'total': total,
      if (offset != null) 'offset': offset,
      if (limit != null) 'limit': limit,
    };
  }
}

/// Bot-Knowledge Association
class BotKnowledgeAssociation {
  final String botId;
  final String knowledgeId;
  final DateTime addedAt;
  final String? addedBy;

  BotKnowledgeAssociation({
    required this.botId,
    required this.knowledgeId,
    required this.addedAt,
    this.addedBy,
  });

  factory BotKnowledgeAssociation.fromJson(Map<String, dynamic> json) {
    return BotKnowledgeAssociation(
      botId: json['botId'] as String,
      knowledgeId: json['knowledgeId'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
      addedBy: json['addedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'botId': botId,
      'knowledgeId': knowledgeId,
      'addedAt': addedAt.toIso8601String(),
      if (addedBy != null) 'addedBy': addedBy,
    };
  }
}

/// Import/Remove Knowledge Response
class KnowledgeOperationResponse {
  final bool success;
  final String message;
  final String? botId;
  final String? knowledgeId;

  KnowledgeOperationResponse({
    required this.success,
    required this.message,
    this.botId,
    this.knowledgeId,
  });

  factory KnowledgeOperationResponse.fromJson(dynamic json) {
    // API có thể trả về TRUE string hoặc Map với success field
    bool success = false;
    String? message;
    String? botId;
    String? knowledgeId;

    if (json is bool) {
      success = json;
      message = 'Operation completed';
    } else if (json is String) {
      success = json.toLowerCase() == 'true';
      message = 'Operation completed';
    } else if (json is Map<String, dynamic>) {
      success = json['success'] as bool? ?? false;
      message = json['message'] as String? ?? 'Operation completed';
      botId = json['botId'] as String?;
      knowledgeId = json['knowledgeId'] as String?;
    }

    return KnowledgeOperationResponse(
      success: success,
      message: message ?? 'Operation completed',
      botId: botId,
      knowledgeId: knowledgeId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (botId != null) 'botId': botId,
      if (knowledgeId != null) 'knowledgeId': knowledgeId,
    };
  }
}
