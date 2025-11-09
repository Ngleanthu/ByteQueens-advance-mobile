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

  
  List<User> getAllUsers() {
    return _mockUsers;
  }
}
