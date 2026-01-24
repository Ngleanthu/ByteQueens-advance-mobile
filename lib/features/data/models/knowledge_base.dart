class KnowledgeBase {
  final String id;
  final String name;
  final String description;
  final int unitCount;
  final int sizeInBytes;
  final DateTime createdAt;
  final DateTime updatedAt;

  KnowledgeBase({
    required this.id,
    required this.name,
    required this.description,
    required this.unitCount,
    required this.sizeInBytes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Format size to human readable format
  String get formattedSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Copy with method for updates
  KnowledgeBase copyWith({
    String? id,
    String? name,
    String? description,
    int? unitCount,
    int? sizeInBytes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KnowledgeBase(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      unitCount: unitCount ?? this.unitCount,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // From JSON
  factory KnowledgeBase.fromJson(Map<String, dynamic> json) {
    return KnowledgeBase(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      unitCount: json['unitCount'] as int? ?? 0,
      sizeInBytes: json['sizeInBytes'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unitCount': unitCount,
      'sizeInBytes': sizeInBytes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
