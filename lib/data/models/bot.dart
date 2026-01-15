import 'package:bytequeens_adm/data/models/ai_model.dart';
import 'package:bytequeens_adm/data/models/knowledge_source.dart';
import 'package:bytequeens_adm/data/models/kb_bot_model.dart';

class Bot {
  final String id;
  final String name;
  final String? description;
  final String? instructions;
  final AIModel model;
  final List<KnowledgeSource> knowledgeSources;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final String ownerId;
  final String ownerName;
  final String ownerEmail;

  // KB API specific fields
  final String? openAiAssistantId;
  final String? openAiThreadIdPlay;
  final String? createdBy;
  final String? updatedBy;

  Bot({
    required this.id,
    required this.name,
    this.description,
    this.instructions,
    required this.model,
    required this.knowledgeSources,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    this.openAiAssistantId,
    this.openAiThreadIdPlay,
    this.createdBy,
    this.updatedBy,
  });

  factory Bot.fromJson(Map<String, dynamic> json) {
    return Bot(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      instructions: json['instructions'],
      model: AIModel.values[json['model']],
      knowledgeSources: (json['knowledgeSources'] as List)
          .map((source) => KnowledgeSource.fromJson(source))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isFavorite: json['isFavorite'] ?? false,
      ownerId: json['ownerId'],
      ownerName: json['ownerName'],
      ownerEmail: json['ownerEmail'],
      openAiAssistantId: json['openAiAssistantId'],
      openAiThreadIdPlay: json['openAiThreadIdPlay'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
    );
  }

  /// Create Bot from KB API response
  factory Bot.fromKBBot(
    KBBot kbBot, {
    AIModel model = AIModel.gpt4o,
    List<KnowledgeSource> knowledgeSources = const [],
    bool isFavorite = false,
    String? ownerId,
    String? ownerName,
    String? ownerEmail,
  }) {
    return Bot(
      id: kbBot.id,
      name: kbBot.assistantName,
      description: kbBot.description,
      instructions: kbBot.instructions,
      model: model,
      knowledgeSources: knowledgeSources,
      createdAt: kbBot.createdAt,
      updatedAt: kbBot.updatedAt,
      isFavorite: isFavorite,
      ownerId: ownerId ?? kbBot.createdBy ?? '',
      ownerName: ownerName ?? '',
      ownerEmail: ownerEmail ?? '',
      openAiAssistantId: kbBot.openAiAssistantId,
      openAiThreadIdPlay: kbBot.openAiThreadIdPlay,
      createdBy: kbBot.createdBy,
      updatedBy: kbBot.updatedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructions': instructions,
      'model': model.index,
      'knowledgeSources': knowledgeSources.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'openAiAssistantId': openAiAssistantId,
      'openAiThreadIdPlay': openAiThreadIdPlay,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  /// Convert Bot to KB API request format
  KBBotRequest toKBBotRequest() {
    return KBBotRequest(
      assistantName: name,
      instructions: instructions,
      description: description,
    );
  }

  /// Create a copy of Bot with updated fields
  Bot copyWith({
    String? id,
    String? name,
    String? description,
    String? instructions,
    AIModel? model,
    List<KnowledgeSource>? knowledgeSources,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    String? ownerId,
    String? ownerName,
    String? ownerEmail,
    String? openAiAssistantId,
    String? openAiThreadIdPlay,
    String? createdBy,
    String? updatedBy,
  }) {
    return Bot(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      model: model ?? this.model,
      knowledgeSources: knowledgeSources ?? this.knowledgeSources,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      openAiAssistantId: openAiAssistantId ?? this.openAiAssistantId,
      openAiThreadIdPlay: openAiThreadIdPlay ?? this.openAiThreadIdPlay,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  String get knowledgeBaseId => '${id}_knowledge_base';

  String get knowledgeBaseName => '$name\'s Knowledge Base';
}
