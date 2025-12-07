class Prompt {
  final String id;
  final String title;
  final String? description;
  final String content;
  final bool isPublic;
  final String? userId;
  final String? userName;
  bool isFavorite;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Prompt({
    required this.id,
    required this.title,
    required this.content,
    required this.description,
    required this.isPublic,
    this.userId,
    this.userName,
    this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
    this.category,
  });

  factory Prompt.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return Prompt(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      description: json['description'] ?? '',
      isPublic: json['isPublic'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      userId: json['userId'],
      userName: json['userName'],
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }
  Map<String, dynamic> toJsonForCreate() {
    return {
      'title': title,
      'content': content,
      'description': description,
      'isPublic': isPublic,
    };
  }
}
