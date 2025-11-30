class Prompt {
  final String id;
  final String title;
  final String? description;
  final String content;
  final bool isPublic;
  bool isFavorite;
  final String? category;

  Prompt({
    required this.id,
    required this.title,
    required this.content,
    required this.isPublic,
    this.description,
    this.isFavorite = false,
    this.category,
  });
}
