class KnowledgeUnit {
  final String id;
  final String knowledgeId;
  final String name;
  final String type;
  final String status;
  final int sizeInBytes;
  final DateTime createdAt;

  KnowledgeUnit({
    required this.id,
    required this.knowledgeId,
    required this.name,
    required this.type,
    required this.status,
    required this.sizeInBytes,
    required this.createdAt,
  });

  factory KnowledgeUnit.fromJson(Map<String, dynamic> json) {
    return KnowledgeUnit(
      id: json['id']?.toString() ?? '',
      knowledgeId: json['knowledgeId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      sizeInBytes: json['size'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'knowledgeId': knowledgeId,
      'name': name,
      'type': type,
      'status': status,
      'size': sizeInBytes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
