import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../data/models/knowledge_base.dart';
import '../../data/models/knowledge_unit.dart';
import '../widgets/knowledge_unit_item.dart';
import '../widgets/add_knowledge_unit_dialog.dart';
import '../widgets/import_local_files_dialog.dart';
import '../widgets/import_website_dialog.dart';
import '../widgets/import_google_drive_dialog.dart';
import '../widgets/import_slack_dialog.dart';
import '../widgets/import_confluence_dialog.dart';

class KnowledgeDetailPage extends StatefulWidget {
  final KnowledgeBase knowledge;

  const KnowledgeDetailPage({super.key, required this.knowledge});

  @override
  State<KnowledgeDetailPage> createState() => _KnowledgeDetailPageState();
}

class _KnowledgeDetailPageState extends State<KnowledgeDetailPage> {
  final TextEditingController _searchController = TextEditingController();

  List<KnowledgeUnit> _allUnits = []; // Store all units
  List<KnowledgeUnit> _knowledgeUnits = []; // Filtered units
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

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
    _loadKnowledgeUnits();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  /// Load mock knowledge units
  Future<void> _loadKnowledgeUnits() async {
    _safeSetState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    try {
      // 🎯 MOCK DATA - Replace with API call later
      final mockUnits = [
        KnowledgeUnit(
          id: '1',
          knowledgeId: widget.knowledge.id,
          name: 'Product Documentation.pdf',
          type: 'pdf',
          status: 'active',
          sizeInBytes: 2547896, // 2.4 MB
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        KnowledgeUnit(
          id: '2',
          knowledgeId: widget.knowledge.id,
          name: 'Company Website Content',
          type: 'website',
          status: 'active',
          sizeInBytes: 1234567, // 1.2 MB
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        KnowledgeUnit(
          id: '3',
          knowledgeId: widget.knowledge.id,
          name: 'Team Meeting Notes Q4',
          type: 'google_drive',
          status: 'processing',
          sizeInBytes: 456789, // 446 KB
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        KnowledgeUnit(
          id: '4',
          knowledgeId: widget.knowledge.id,
          name: '#general Channel History',
          type: 'slack',
          status: 'active',
          sizeInBytes: 3456789, // 3.3 MB
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        KnowledgeUnit(
          id: '5',
          knowledgeId: widget.knowledge.id,
          name: 'Project Wiki & Guidelines',
          type: 'confluence',
          status: 'failed',
          sizeInBytes: 987654, // 964 KB
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        KnowledgeUnit(
          id: '6',
          knowledgeId: widget.knowledge.id,
          name: 'Design System Documentation',
          type: 'notion',
          status: 'active',
          sizeInBytes: 2345678, // 2.2 MB
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        KnowledgeUnit(
          id: '7',
          knowledgeId: widget.knowledge.id,
          name: 'API Reference Guide v2.1.pdf',
          type: 'document',
          status: 'active',
          sizeInBytes: 5678901, // 5.4 MB
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        KnowledgeUnit(
          id: '8',
          knowledgeId: widget.knowledge.id,
          name: 'Tech Blog Articles Collection',
          type: 'website',
          status: 'processing',
          sizeInBytes: 4567890, // 4.4 MB
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];

      _safeSetState(() {
        _allUnits = mockUnits;
        _filterUnits();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      _safeSetState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
      _showSnackBar('Error loading units: $_errorMessage', isError: true);
    }
  }

  /// Filter units based on search query
  void _filterUnits() {
    if (_searchQuery.isEmpty) {
      _knowledgeUnits = List.from(_allUnits);
    } else {
      final query = _searchQuery.toLowerCase();
      _knowledgeUnits = _allUnits.where((unit) {
        return unit.name.toLowerCase().contains(query) ||
            unit.type.toLowerCase().contains(query) ||
            unit.status.toLowerCase().contains(query);
      }).toList();
    }
  }

  void _onAddKnowledgeUnitPressed() async {
    final source = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddKnowledgeUnitDialog(),
    );

    if (source != null && mounted) {
      await _handleSourceTap(context, source);
    }
  }

  Future<void> _handleDeleteUnit(KnowledgeUnit unit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Knowledge Unit'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('Are you sure you want to delete "${unit.name}"?'),
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

      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // 🎯 MOCK: Remove from list
      _safeSetState(() {
        _allUnits.removeWhere((u) => u.id == unit.id);
        _filterUnits();
        _isLoading = false;
      });

      _showSnackBar('Knowledge unit deleted successfully');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

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

  void _handleSearch(String value) {
    _safeSetState(() {
      _searchQuery = value;
      _filterUnits();
    });
  }

  Future<void> _handleSourceTap(BuildContext context, String source) async {
    Widget dialog;

    switch (source) {
      case 'local_files':
        dialog = const ImportLocalFilesDialog();
        break;
      case 'website':
        dialog = const ImportWebsiteDialog();
        break;
      case 'google_drive':
        dialog = const ImportGoogleDriveDialog();
        break;
      case 'slack':
        dialog = const ImportSlackDialog();
        break;
      case 'confluence':
        dialog = const ImportConfluenceDialog();
        break;
      default:
        return;
    }

    final result = await showDialog(context: context, builder: (_) => dialog);

    if (result != null) {
      // Handle import result
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardWhite,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.knowledge.name,
              style: const TextStyle(
                color: textDark,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              widget.knowledge.description,
              style: TextStyle(
                color: textGray.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.xmark, color: textDark),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Add Knowledge Unit Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _isLoading ? null : _onAddKnowledgeUnitPressed,
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
                      'Add Knowledge Unit',
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
                  hintText: 'Search knowledge units...',
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

          // Knowledge Units List
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                ? _buildErrorState()
                : _knowledgeUnits.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadKnowledgeUnits,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _knowledgeUnits.length,
                      itemBuilder: (context, index) {
                        final unit = _knowledgeUnits[index];
                        return KnowledgeUnitItem(
                          unit: unit,
                          onTap: () {
                            _showSnackBar('Opening: ${unit.name}');
                          },
                          onDelete: () => _handleDeleteUnit(unit),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
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
            onPressed: _loadKnowledgeUnits,
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
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _searchQuery.isNotEmpty
                  ? CupertinoIcons.search
                  : CupertinoIcons.doc_text_search,
              size: 60,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty
                ? 'No knowledge units found'
                : 'No knowledge units found',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search'
                  : 'Click here to add new knowledge',
              style: TextStyle(
                fontSize: 15,
                color: primaryBlue,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
