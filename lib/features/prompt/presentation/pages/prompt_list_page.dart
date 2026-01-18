import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../data/models/prompt.dart';
import '../widgets/prompt_item.dart';
import '../widgets/create_prompt_dialog.dart';
import '../widgets/edit_prompt_dialog.dart';
import '../widgets/category_chip.dart';
import '../widgets/search_bar.dart';
import '../widgets/filter_tabs.dart';
import '../widgets/empty_state.dart';
import '../widgets/preview_dialog.dart';
import '../../../../services/prompt_service.dart';
import '../../../bot/presentation/pages/chat_page.dart';
import '../../../bot/presentation/widgets/prompt_input_dialog.dart';

class PromptListPage extends StatefulWidget {
  const PromptListPage({super.key});

  @override
  State<PromptListPage> createState() => _PromptListPageState();
}

class _PromptListPageState extends State<PromptListPage> {
  final PromptService _service = PromptService();
  final TextEditingController _searchController = TextEditingController();

  List<Prompt> _prompts = [];
  bool _loading = true;
  String? _errorMessage;
  String _searchQuery = '';
  bool _filterFavoritesOnly = false;
  bool _showPublicPrompts = true;
  String _selectedCategory = 'all';

  // Color constants
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
    _loadPrompts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleUsePrompt(BuildContext context, Prompt prompt) {
    // Extract placeholders from prompt content
    final regex = RegExp(r'\[([^\]]+)\]');
    final matches = regex.allMatches(prompt.content);
    final hasPlaceholders = matches.isNotEmpty;

    if (hasPlaceholders) {
      // Show input dialog for placeholders
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PromptInputDialog(
          prompt: prompt,
          onSend: (finalContent) {
            // Navigate to ChatPage with filled content
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  initialMessage: finalContent,
                  modelId: 'gpt-4o-mini', // Default model
                  modelName: 'GPT-4o Mini',
                ),
              ),
            );
          },
        ),
      );
    } else {
      // No placeholders - navigate directly to ChatPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            initialMessage: prompt.content,
            modelId: 'gpt-4o-mini', // Default model
            modelName: 'GPT-4o Mini',
          ),
        ),
      );
    }
  }

  Future<void> _loadPrompts() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final prompts = await _service.getPrompts(
        isPublic: _showPublicPrompts,
        category: _selectedCategory == 'all' ? null : _selectedCategory,
        isFavorite: _filterFavoritesOnly ? true : null,
        limit: 100,
        offset: 0,
      );

      setState(() {
        _prompts = prompts;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Failed to load prompts: $e';
      });
    }
  }

  List<Prompt> get filteredPrompts {
    if (_searchQuery.isEmpty) return _prompts;

    final q = _searchQuery.toLowerCase();
    return _prompts.where((p) {
      return p.title.toLowerCase().contains(q) ||
          (p.description?.toLowerCase().contains(q) ?? false) ||
          p.content.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _handleFavoriteToggle(Prompt p) async {
    try {
      if (p.isFavorite) {
        await _service.removeFavorite(p.id);
      } else {
        await _service.addFavorite(p.id);
      }

      if (_filterFavoritesOnly) {
        _loadPrompts();
      } else {
        setState(() => p.isFavorite = !p.isFavorite);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showPreviewDialog(Prompt p) {
    showDialog(
      context: context,
      builder: (dialogCtx) => PreviewDialog(
        prompt: p,
        onEdit: p.isPublic == false
            ? () async {
                Navigator.pop(dialogCtx);
                final updatedPrompt = await showDialog<Prompt>(
                  context: context,
                  builder: (_) => EditPromptDialog(prompt: p),
                );

                if (updatedPrompt != null && mounted) {
                  setState(() {
                    final index = _prompts.indexWhere(
                      (item) => item.id == updatedPrompt.id,
                    );
                    if (index != -1) {
                      _prompts[index] = updatedPrompt;
                    }
                  });
                  _showSnackBar("Prompt updated successfully");
                }
              }
            : null,
        onDelete: p.isPublic == false
            ? () async {
                Navigator.pop(dialogCtx);
                final confirm = await _showDeleteConfirmDialog();
                if (confirm != true) return;

                try {
                  await _service.deletePrompt(p.id);
                  if (!mounted) return;

                  setState(() {
                    _prompts.removeWhere((item) => item.id == p.id);
                  });
                  _showSnackBar("Prompt deleted successfully");
                } catch (e) {
                  if (!mounted) return;
                  _showSnackBar("Delete failed: $e", isError: true);
                }
              }
            : null,
        onUse: () {
          Navigator.pop(dialogCtx);
          _handleUsePrompt(context, p);
          // TODO: Implement actual "Use Now" logic here
        },
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Delete Prompt"),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text("Are you sure you want to delete this prompt?"),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptList() {
    if (_loading) {
      return const Center(child: CupertinoActivityIndicator(radius: 16));
    }

    if (_errorMessage != null) {
      return EmptyStateWidget(
        icon: CupertinoIcons.exclamationmark_triangle,
        title: "Error Loading Prompts",
        message: _errorMessage!,
        actionLabel: "Retry",
        onAction: _loadPrompts,
      );
    }

    if (filteredPrompts.isEmpty) {
      return EmptyStateWidget(
        icon: _searchQuery.isNotEmpty
            ? CupertinoIcons.search
            : CupertinoIcons.doc_text,
        title: _searchQuery.isNotEmpty ? "No Results Found" : "No Prompts Yet",
        message: _searchQuery.isNotEmpty
            ? "Try adjusting your search"
            : "Create your first prompt to get started",
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPrompts,
      color: primaryBlue,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: filteredPrompts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final p = filteredPrompts[i];
          return PromptItem(
            prompt: p,
            onToggleFavorite: () => _handleFavoriteToggle(p),
            onPreview: () => _showPreviewDialog(p),
            onUse: () => _showSnackBar('Using: ${p.title}'),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Filter Tabs
                    FilterTabsWidget(
                      showPublicPrompts: _showPublicPrompts,
                      onPublicTap: () {
                        setState(() => _showPublicPrompts = true);
                        _loadPrompts();
                      },
                      onMyPromptsTap: () {
                        setState(() => _showPublicPrompts = false);
                        _loadPrompts();
                      },
                    ),

                    const SizedBox(height: 16),

                    // Search Bar
                    SearchBarWidget(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      onClear: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),

                    const SizedBox(height: 16),

                    // Category Chips
                    CategoryChipsWidget(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (c) {
                        setState(() => _selectedCategory = c);
                        _loadPrompts();
                      },
                    ),

                    const SizedBox(height: 16),

                    // Prompt List
                    Expanded(child: _buildPromptList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: BoxDecoration(
        color: cardWhite,
        border: Border(
          bottom: BorderSide(color: borderColor.withOpacity(0.5), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: backgroundWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: const Icon(CupertinoIcons.back, color: textDark, size: 20),
            ),
          ),

          const SizedBox(width: 12),

          // Title
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Prompts Library",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "Browse and manage prompts",
                  style: TextStyle(
                    fontSize: 13,
                    color: textGray,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Favorite Filter Button
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() => _filterFavoritesOnly = !_filterFavoritesOnly);
              _loadPrompts();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: _filterFavoritesOnly
                    ? const LinearGradient(
                        colors: [Color(0xFFFFB800), Color(0xFFFF9500)],
                      )
                    : null,
                color: _filterFavoritesOnly ? null : backgroundWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _filterFavoritesOnly
                      ? Colors.transparent
                      : borderColor,
                  width: 1,
                ),
                boxShadow: _filterFavoritesOnly
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFB800).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                _filterFavoritesOnly
                    ? CupertinoIcons.star_fill
                    : CupertinoIcons.star,
                color: _filterFavoritesOnly ? Colors.white : textGray,
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Add Button
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (_) => const CreatePromptDialog(),
              );
              if (result != null && mounted) _loadPrompts();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryBlue, lightBlue],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
