import 'package:bytequeens_adm/data/models/ai_model.dart';
import 'package:bytequeens_adm/data/models/knowledge_source.dart';

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
    };
  }

  Bot copyWith({
    String? name,
    String? description,
    String? instructions,
    AIModel? model,
    List<KnowledgeSource>? knowledgeSources,
    bool? isFavorite,
  }) {
    return Bot(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      model: model ?? this.model,
      knowledgeSources: knowledgeSources ?? this.knowledgeSources,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isFavorite: isFavorite ?? this.isFavorite,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerEmail: ownerEmail,
    );
  }

  String get knowledgeBaseId => '${id}_knowledge_base';
  
  String get knowledgeBaseName => '$name\'s Knowledge Base - ${id.substring(0, 8)}';
}
