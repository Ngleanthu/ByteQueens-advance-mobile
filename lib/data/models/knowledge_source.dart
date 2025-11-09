enum KnowledgeSourceType {
  localFiles,
  website,
  googleDrive,
  slack,
  confluence,
  notion,
  discord,
}

class KnowledgeSource {
  final String id;
  final String name;
  final KnowledgeSourceType type;
  final String? url;
  final String? token;
  final List<String>? files;
  final bool autoUpdate;
  final DateTime createdAt;

  KnowledgeSource({
    required this.id,
    required this.name,
    required this.type,
    this.url,
    this.token,
    this.files,
    this.autoUpdate = false,
    required this.createdAt,
  });

  factory KnowledgeSource.fromJson(Map<String, dynamic> json) {
    return KnowledgeSource(
      id: json['id'],
      name: json['name'],
      type: KnowledgeSourceType.values[json['type']],
      url: json['url'],
      token: json['token'],
      files: json['files'] != null ? List<String>.from(json['files']) : null,
      autoUpdate: json['autoUpdate'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'url': url,
      'token': token,
      'files': files,
      'autoUpdate': autoUpdate,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String getIconName() {
    switch (type) {
      case KnowledgeSourceType.localFiles:
        return 'description';
      case KnowledgeSourceType.website:
        return 'language';
      case KnowledgeSourceType.googleDrive:
        return 'folder';
      case KnowledgeSourceType.slack:
        return 'chat';
      case KnowledgeSourceType.confluence:
        return 'article';
      case KnowledgeSourceType.notion:
        return 'note';
      case KnowledgeSourceType.discord:
        return 'forum';
    }
  }

  String getTypeName() {
    switch (type) {
      case KnowledgeSourceType.localFiles:
        return 'Local Files';
      case KnowledgeSourceType.website:
        return 'Website';
      case KnowledgeSourceType.googleDrive:
        return 'Google Drive';
      case KnowledgeSourceType.slack:
        return 'Slack';
      case KnowledgeSourceType.confluence:
        return 'Confluence';
      case KnowledgeSourceType.notion:
        return 'Notion';
      case KnowledgeSourceType.discord:
        return 'Discord';
    }
  }
}
