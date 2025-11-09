import 'package:bytequeens_adm/data/models/user.dart';

/// Group Model
class Group {
  final String id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final List<User> members;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int messageCount;

  Group({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    required this.members,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.messageCount = 0,
  });

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    List<User>? members,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      members: members ?? this.members,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
    );
  }

  int get memberCount => members.length;
}
