/// Knowledge Base Bot Models
/// Models for KB API bot management endpoints

/// KB Bot - Response model from KB API
class KBBot {
  final String id;
  final String assistantName;
  final String? openAiAssistantId;
  final String? instructions;
  final String? description;
  final String? openAiThreadIdPlay;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String? updatedBy;

  KBBot({
    required this.id,
    required this.assistantName,
    this.openAiAssistantId,
    this.instructions,
    this.description,
    this.openAiThreadIdPlay,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory KBBot.fromJson(Map<String, dynamic> json) {
    return KBBot(
      id: json['id'] as String,
      assistantName: json['assistantName'] as String,
      openAiAssistantId: json['openAiAssistantId'] as String?,
      instructions: json['instructions'] as String?,
      description: json['description'] as String?,
      openAiThreadIdPlay: json['openAiThreadIdPlay'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assistantName': assistantName,
      'openAiAssistantId': openAiAssistantId,
      'instructions': instructions,
      'description': description,
      'openAiThreadIdPlay': openAiThreadIdPlay,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  KBBot copyWith({
    String? assistantName,
    String? openAiAssistantId,
    String? instructions,
    String? description,
    String? openAiThreadIdPlay,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return KBBot(
      id: id,
      assistantName: assistantName ?? this.assistantName,
      openAiAssistantId: openAiAssistantId ?? this.openAiAssistantId,
      instructions: instructions ?? this.instructions,
      description: description ?? this.description,
      openAiThreadIdPlay: openAiThreadIdPlay ?? this.openAiThreadIdPlay,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

/// KB Bot Create/Update Request
class KBBotRequest {
  final String assistantName;
  final String? instructions;
  final String? description;

  KBBotRequest({
    required this.assistantName,
    this.instructions,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'assistantName': assistantName,
      if (instructions != null) 'instructions': instructions,
      if (description != null) 'description': description,
    };
  }

  factory KBBotRequest.fromJson(Map<String, dynamic> json) {
    return KBBotRequest(
      assistantName: json['assistantName'] as String,
      instructions: json['instructions'] as String?,
      description: json['description'] as String?,
    );
  }
}

/// Pagination Meta for list responses
class PaginationMeta {
  final int limit;
  final int total;
  final int offset;
  final bool hasNext;

  PaginationMeta({
    required this.limit,
    required this.total,
    required this.offset,
    required this.hasNext,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      limit: json['limit'] as int,
      total: json['total'] as int,
      offset: json['offset'] as int,
      hasNext: json['hasNext'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'limit': limit,
      'total': total,
      'offset': offset,
      'hasNext': hasNext,
    };
  }
}

/// KB Bots List Response
class KBBotsListResponse {
  final List<KBBot> data;
  final PaginationMeta meta;

  KBBotsListResponse({required this.data, required this.meta});

  factory KBBotsListResponse.fromJson(Map<String, dynamic> json) {
    return KBBotsListResponse(
      data: (json['data'] as List)
          .map((item) => KBBot.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((bot) => bot.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}

/// Query parameters for getting bots
class KBBotsQuery {
  final String? q; // Search query
  final String? order; // ASC or DESC
  final String? orderField; // Field to order by
  final int? offset; // Pagination offset
  final int? limit; // Results per page
  final bool? isFavorite; // Filter favorites
  final bool? isPublished; // Filter published

  KBBotsQuery({
    this.q,
    this.order,
    this.orderField,
    this.offset,
    this.limit,
    this.isFavorite,
    this.isPublished,
  });

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    if (q != null && q!.isNotEmpty) params['q'] = q;
    if (order != null) params['order'] = order;
    if (orderField != null) params['order_field'] = orderField;
    if (offset != null) params['offset'] = offset;
    if (limit != null) params['limit'] = limit;
    if (isFavorite != null) params['is_favorite'] = isFavorite;
    if (isPublished != null) params['is_published'] = isPublished;

    return params;
  }
}

/// Order enum for sorting
enum KBOrder {
  asc('ASC'),
  desc('DESC');

  final String value;
  const KBOrder(this.value);
}
