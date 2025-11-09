import 'package:bytequeens_adm/data/models/group.dart';
import 'package:bytequeens_adm/data/models/user.dart';

class GroupService {
  
  static final GroupService _instance = GroupService._internal();
  factory GroupService() => _instance;
  GroupService._internal() {
    _initializeMockData();
  }

  
  final Map<String, Group> _groups = {};

  
}
