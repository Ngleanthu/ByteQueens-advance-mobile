import 'package:bytequeens_adm/data/models/group.dart';
import 'package:bytequeens_adm/data/models/user.dart';


class GroupService {
  
  static final GroupService _instance = GroupService._internal();
  factory GroupService() => _instance;
  GroupService._internal() {
    _initializeMockData();
  }

  
  final Map<String, Group> _groups = {};

  
  final List<User> _mockUsers = [
    User(
      id: '1',
      email: 'user1@example.com',
      name: 'John Doe',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    User(
      id: '2',
      email: 'user2@example.com',
      name: 'Jane Smith',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    User(
      id: '3',
      email: 'user3@example.com',
      name: 'Bob Johnson',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    User(
      id: '4',
      email: 'user4@example.com',
      name: 'Alice Brown',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  void _initializeMockData() {
    
    final group1 = Group(
      id: 'g1',
      name: 'Product Team',
      description: 'Product development and design team',
      members: [_mockUsers[0], _mockUsers[1], _mockUsers[2]],
      createdBy: _mockUsers[0].id,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      messageCount: 125,
    );

    final group2 = Group(
      id: 'g2',
      name: 'Marketing Team',
      description: 'Marketing and growth discussions',
      members: [_mockUsers[1], _mockUsers[3]],
      createdBy: _mockUsers[1].id,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      messageCount: 87,
    );

    final group3 = Group(
      id: 'g3',
      name: 'Engineering',
      description: 'Software engineering team',
      members: [_mockUsers[0], _mockUsers[2], _mockUsers[3]],
      createdBy: _mockUsers[0].id,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      messageCount: 234,
    );

    _groups[group1.id] = group1;
    _groups[group2.id] = group2;
    _groups[group3.id] = group3;
  }

  
  Future<List<Group>> getAllGroups() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _groups.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  
  Future<Group?> getGroupById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _groups[id];
  }

  
  Future<Group> createGroup({
    required String name,
    String? description,
    required List<User> members,
    required String createdBy,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final group = Group(
      id: 'g${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      members: members,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      messageCount: 0,
    );

    _groups[group.id] = group;
    return group;
  }

  
  Future<Group> updateGroup({
    required String id,
    String? name,
    String? description,
    List<User>? members,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final existingGroup = _groups[id];
    if (existingGroup == null) {
      throw Exception('Group not found');
    }

    final updatedGroup = existingGroup.copyWith(
      name: name,
      description: description,
      members: members,
      updatedAt: DateTime.now(),
    );

    _groups[id] = updatedGroup;
    return updatedGroup;
  }

  
  Future<void> deleteGroup(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _groups.remove(id);
  }

  
  Future<Group> addMember(String groupId, User user) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final group = _groups[groupId];
    if (group == null) {
      throw Exception('Group not found');
    }

    if (group.members.any((m) => m.id == user.id)) {
      throw Exception('User already in group');
    }

    final updatedMembers = [...group.members, user];
    final updatedGroup = group.copyWith(
      members: updatedMembers,
      updatedAt: DateTime.now(),
    );

    _groups[groupId] = updatedGroup;
    return updatedGroup;
  }

  
  Future<Group> removeMember(String groupId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final group = _groups[groupId];
    if (group == null) {
      throw Exception('Group not found');
    }

    final updatedMembers = group.members.where((m) => m.id != userId).toList();
    final updatedGroup = group.copyWith(
      members: updatedMembers,
      updatedAt: DateTime.now(),
    );

    _groups[groupId] = updatedGroup;
    return updatedGroup;
  }

  
  Future<List<Group>> searchGroups(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (query.isEmpty) {
      return getAllGroups();
    }

    final lowerQuery = query.toLowerCase();
    return _groups.values.where((group) {
      return group.name.toLowerCase().contains(lowerQuery) ||
          (group.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  
  Future<List<User>> getAvailableUsers(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final group = _groups[groupId];
    if (group == null) {
      return _mockUsers;
    }

    final memberIds = group.members.map((m) => m.id).toSet();
    return _mockUsers.where((user) => !memberIds.contains(user.id)).toList();
  }

  
  List<User> getAllUsers() {
    return _mockUsers;
  }
}
