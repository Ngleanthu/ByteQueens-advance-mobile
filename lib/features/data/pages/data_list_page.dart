import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../data/models/knowledge_base.dart';
import '../../../services/knowledge_service.dart';
import '../widgets/knowledge_item.dart';
import '../widgets/create_knowledge_dialog.dart';
import '../widgets/edit_knowledge_dialog.dart';

class KnowledgeListPage extends StatefulWidget {
  final bool selectionMode;

  const KnowledgeListPage({super.key, this.selectionMode = false});

  @override
  State<KnowledgeListPage> createState() => _KnowledgeListPageState();
}

class _KnowledgeListPageState extends State<KnowledgeListPage> {
  final TextEditingController _searchController = TextEditingController();
  final KnowledgeService _knowledgeService = KnowledgeService();

  List<KnowledgeBase> _knowledgeBases = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  final Set<String> _selectedKnowledgeIds = {}; // For selection mode

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
    print(
      '🔍 KnowledgeListPage initialized with selectionMode: ${widget.selectionMode}',
    );
    _loadKnowledgeBases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Safe setState - only call if mounted
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  /// Load knowledge bases from API
  Future<void> _loadKnowledgeBases() async {
    _safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _knowledgeService.getKnowledges(
        query: _searchQuery.isEmpty ? null : _searchQuery,
        order: 'DESC',
        orderField: 'createdAt',
        offset: 0,
        limit: 20,
      );

      if (!mounted) return; // ✅ Check before processing response

      if (response.data != null && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        _safeSetState(() {
          _knowledgeBases = data.map((item) {
            return KnowledgeBase(
              id:
                  item['id']?.toString() ??
                  '', // ✅ Changed from 'knowledgeId' to 'id'
              name: item['knowledgeName']?.toString() ?? '',
              description: item['description']?.toString() ?? '',
              unitCount:
                  item['numUnits'] ??
                  0, // ✅ Changed from 'unitCount' to 'numUnits'
              sizeInBytes:
                  item['totalSize'] ??
                  0, // ✅ Changed from 'size' to 'totalSize'
              createdAt: item['createdAt'] != null
                  ? DateTime.parse(item['createdAt'])
                  : DateTime.now(),
              updatedAt: item['updatedAt'] != null
                  ? DateTime.parse(item['updatedAt'])
                  : DateTime.now(),
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        _safeSetState(() {
          _knowledgeBases = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return; // ✅ Check before showing error

      _safeSetState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
      _showSnackBar('Error loading data: $_errorMessage', isError: true);
    }
  }

  List<KnowledgeBase> get filteredKnowledgeBases {
    return _knowledgeBases;
  }

  /// Handle create knowledge
  Future<void> _handleCreate() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const CreateKnowledgeDialog(),
    );

    if (result != null && mounted) {
      _safeSetState(() => _isLoading = true);

      try {
        final response = await _knowledgeService.createKnowledge(
          knowledgeName: result['name']!,
          description: result['description']!,
        );

        if (!mounted) return; // ✅ Check after async operation

        if (response.statusCode == 201 || response.statusCode == 200) {
          _showSnackBar('Knowledge base created successfully');
          await _loadKnowledgeBases();
        }
      } catch (e) {
        if (!mounted) return; // ✅ Check before showing error

        _safeSetState(() => _isLoading = false);
        _showSnackBar(
          'Failed to create: ${e.toString().replaceAll('Exception: ', '')}',
          isError: true,
        );
      }
    }
  }

  /// Handle edit knowledge
  Future<void> _handleEdit(KnowledgeBase kb) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => EditKnowledgeDialog(knowledge: kb),
    );

    if (result != null && mounted) {
      _safeSetState(() => _isLoading = true);

      try {
        final response = await _knowledgeService.updateKnowledge(
          kb.id,
          knowledgeName: result['name']!,
          description: result['description']!,
        );

        if (!mounted) return; // ✅ Check after async operation

        if (response.statusCode == 200) {
          _showSnackBar('Knowledge base updated successfully');
          await _loadKnowledgeBases();
        }
      } catch (e) {
        if (!mounted) return; // ✅ Check before showing error

        _safeSetState(() => _isLoading = false);
        _showSnackBar(
          'Failed to update: ${e.toString().replaceAll('Exception: ', '')}',
          isError: true,
        );
      }
    }
  }

  /// Handle delete knowledge
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
      _safeSetState(() => _isLoading = true);

      try {
        await _knowledgeService.deleteKnowledge(kb.id);

        if (!mounted) return; // ✅ Check after async operation

        _showSnackBar('Knowledge base deleted successfully');
        await _loadKnowledgeBases();
      } catch (e) {
        if (!mounted) return; // ✅ Check before showing error

        _safeSetState(() => _isLoading = false);
        _showSnackBar(
          'Failed to delete: ${e.toString().replaceAll('Exception: ', '')}',
          isError: true,
        );
      }
    }
  }

  /// Show snackbar message
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return; // ✅ Check before showing snackbar

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Handle search with debounce
  void _handleSearch(String value) {
    _safeSetState(() => _searchQuery = value);

    // Debounce search to avoid too many API calls
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return; // ✅ Check before loading
      if (_searchQuery == value) {
        _loadKnowledgeBases();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardWhite,
        centerTitle: false,
        title: Text(
          widget.selectionMode
              ? 'Select Knowledges (${_selectedKnowledgeIds.length})'
              : 'Knowledge Base',
          style: const TextStyle(
            color: textDark,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: primaryBlue),
        shadowColor: Colors.black.withOpacity(0.05),
        actions: [
          if (widget.selectionMode && _selectedKnowledgeIds.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() => _selectedKnowledgeIds.clear());
              },
              child: const Text('Clear'),
            ),
          IconButton(
            icon: const Icon(CupertinoIcons.refresh, color: primaryBlue),
            onPressed: _isLoading ? null : _loadKnowledgeBases,
          ),
        ],
      ),
      body: Column(
        children: [
          // Selection mode indicator banner
          if (widget.selectionMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: primaryBlue.withOpacity(0.3)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select knowledges to import to your bot',
                      style: TextStyle(
                        color: primaryBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Create Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _isLoading ? null : _handleCreate,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: _isLoading
                        ? [textGray.withOpacity(0.5), textGray.withOpacity(0.5)]
                        : [primaryBlue, lightBlue],
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
                onChanged: _handleSearch,
                enabled: !_isLoading,
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
                            _handleSearch('');
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
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                ? _buildErrorState()
                : filteredKnowledgeBases.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadKnowledgeBases,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredKnowledgeBases.length,
                      itemBuilder: (context, index) {
                        final kb = filteredKnowledgeBases[index];
                        final isSelected = _selectedKnowledgeIds.contains(
                          kb.id,
                        );

                        return widget.selectionMode
                            ? _buildSelectableKnowledgeItem(kb, isSelected)
                            : KnowledgeItem(
                                knowledge: kb,
                                onTap: () {
                                  _showSnackBar('Opening: ${kb.name}');
                                },
                                onEdit: () => _handleEdit(kb),
                                onDelete: () => _handleDelete(kb),
                              );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton:
          widget.selectionMode && _selectedKnowledgeIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _handleImportSelected,
              backgroundColor: primaryBlue,
              icon: const Icon(Icons.check),
              label: Text('Import (${_selectedKnowledgeIds.length})'),
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CupertinoActivityIndicator(radius: 16));
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 40,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Error Loading Data',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Unknown error',
              style: TextStyle(fontSize: 15, color: textGray.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          CupertinoButton(
            onPressed: _loadKnowledgeBases,
            child: const Text('Retry'),
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

  /// Build selectable knowledge item with checkbox
  Widget _buildSelectableKnowledgeItem(KnowledgeBase kb, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? primaryBlue : borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedKnowledgeIds.remove(kb.id);
            } else {
              _selectedKnowledgeIds.add(kb.id);
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? primaryBlue : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? primaryBlue : textGray.withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),

              // Knowledge icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.book,
                  color: primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Knowledge info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kb.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kb.description.isNotEmpty
                          ? kb.description
                          : 'No description',
                      style: TextStyle(
                        fontSize: 13,
                        color: textGray.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.doc_text,
                          size: 12,
                          color: textGray.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${kb.unitCount} units',
                          style: TextStyle(
                            fontSize: 12,
                            color: textGray.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle import selected knowledges
  void _handleImportSelected() {
    if (_selectedKnowledgeIds.isEmpty) return;

    // Return selected knowledge IDs back to bot detail page
    final selectedKnowledges = _knowledgeBases
        .where((kb) => _selectedKnowledgeIds.contains(kb.id))
        .toList();

    print('🎯 Returning ${selectedKnowledges.length} selected knowledge(s)');
    Navigator.pop(context, selectedKnowledges);
  }
}
