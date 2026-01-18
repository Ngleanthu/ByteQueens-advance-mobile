import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../data/models/knowledge_base.dart';
import '../widgets/knowledge_item.dart';
import '../widgets/create_knowledge_dialog.dart';
import '../widgets/edit_knowledge_dialog.dart';

class KnowledgeListPage extends StatefulWidget {
  const KnowledgeListPage({super.key});

  @override
  State<KnowledgeListPage> createState() => _KnowledgeListPageState();
}

class _KnowledgeListPageState extends State<KnowledgeListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<KnowledgeBase> _knowledgeBases = [];
  String _searchQuery = '';

  static const primaryBlue = Color(0xFF2196F3);
  static const lightBlue = Color(0xFF4A90E2);
  static const backgroundWhite = Color(0xFFFAFBFF);
  static const cardWhite = Colors.white;
  static const textDark = Color(0xFF1A1D2E);
  static const textGray = Color(0xFF6B7280);
  static const borderColor = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    // Mock data for demonstration
    setState(() {
      _knowledgeBases = [
        KnowledgeBase(
          id: '1',
          name: 'Kiến thức toán học',
          description: '1+1=2',
          unitCount: 0,
          sizeInBytes: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    });
  }

  List<KnowledgeBase> get filteredKnowledgeBases {
    if (_searchQuery.isEmpty) return _knowledgeBases;

    final query = _searchQuery.toLowerCase();
    return _knowledgeBases.where((kb) {
      return kb.name.toLowerCase().contains(query) ||
          kb.description.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _handleCreate() async {
    final result = await showDialog<KnowledgeBase>(
      context: context,
      builder: (_) => const CreateKnowledgeDialog(),
    );

    if (result != null && mounted) {
      setState(() {
        _knowledgeBases.add(result);
      });
      _showSnackBar('Knowledge base created successfully');
    }
  }

  Future<void> _handleEdit(KnowledgeBase kb) async {
    final result = await showDialog<KnowledgeBase>(
      context: context,
      builder: (_) => EditKnowledgeDialog(knowledge: kb),
    );

    if (result != null && mounted) {
      setState(() {
        final index = _knowledgeBases.indexWhere((item) => item.id == kb.id);
        if (index != -1) {
          _knowledgeBases[index] = result;
        }
      });
      _showSnackBar('Knowledge base updated successfully');
    }
  }

  Future<void> _handleDelete(KnowledgeBase kb) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Knowledge Base'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('Are you sure you want to delete "${kb.name}"?'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        _knowledgeBases.removeWhere((item) => item.id == kb.id);
      });
      _showSnackBar('Knowledge base deleted successfully');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardWhite,
        centerTitle: false,
        title: const Text(
          'Knowledge Base',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: primaryBlue),
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      body: Column(
        children: [
          // Create Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _handleCreate,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [primaryBlue, lightBlue],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.add_circled_solid,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Create Knowledge',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search knowledge base',
                  hintStyle: TextStyle(
                    color: textGray.withOpacity(0.6),
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    CupertinoIcons.search,
                    color: textGray,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            CupertinoIcons.xmark_circle_fill,
                            color: textGray,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Knowledge Base List
          Expanded(
            child: filteredKnowledgeBases.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredKnowledgeBases.length,
                    itemBuilder: (context, index) {
                      final kb = filteredKnowledgeBases[index];
                      return KnowledgeItem(
                        knowledge: kb,
                        onTap: () {
                          // Navigate to knowledge detail page
                          _showSnackBar('Opening: ${kb.name}');
                        },
                        onEdit: () => _handleEdit(kb),
                        onDelete: () => _handleDelete(kb),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _searchQuery.isNotEmpty
                  ? CupertinoIcons.search
                  : CupertinoIcons.layers_alt,
              size: 40,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty ? 'No Results Found' : 'No Knowledge Bases',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search'
                : 'Create your first knowledge base to get started',
            style: TextStyle(fontSize: 15, color: textGray.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
