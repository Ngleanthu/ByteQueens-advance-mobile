import 'package:flutter/material.dart';
import '../../../../data/models/prompt.dart';
import '../widgets/prompt_item.dart';
import '../widgets/create_prompt_dialog.dart';
import '../widgets/edit_prompt_dialog.dart';
import '../widgets/category_chip.dart';
import '../../../../services/prompt_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadPrompts();
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

  void _handleFilterChange() => _loadPrompts();

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildFilterTabs() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildFilterTab(
            label: 'Public Prompts',
            selected: _showPublicPrompts,
            onTap: () {
              setState(() => _showPublicPrompts = true);
              _handleFilterChange();
            },
          ),
          _buildFilterTab(
            label: 'My Prompts',
            selected: !_showPublicPrompts,
            onTap: () {
              setState(() => _showPublicPrompts = false);
              _handleFilterChange();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: selected
                ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: TextField(
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search prompts...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              filled: true,
              fillColor: isDark
                  ? Colors.grey[800]
                  : const Color.fromARGB(255, 248, 248, 248),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (_searchQuery.isNotEmpty)
          IconButton(
            icon: Icon(
              Icons.clear,
              color: isDark ? Colors.grey[400] : Colors.grey,
            ),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
      ],
    );
  }

  Widget _buildPromptList() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPrompts,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (filteredPrompts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No prompts match your search'
                  : 'No prompts found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPrompts,
      child: ListView.separated(
        itemCount: filteredPrompts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final p = filteredPrompts[i];
          return PromptItem(
            prompt: p,
            onToggleFavorite: () => _handleFavoriteToggle(p),
            onPreview: () => _showPreviewDialog(p),
            onUse: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Using: ${p.title}'))),
          );
        },
      ),
    );
  }

  void _showPreviewDialog(Prompt p) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(p.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (p.description != null) ...[
                Text(
                  p.description!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
              ],
              Text(p.content),
            ],
          ),
        ),

        // ★★★ Add actions based on isPublic ★★★
        actions: [
          // nút edit và delete nếu là prompt của user (not public)
          if (p.isPublic == false) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: "Edit",
              onPressed: () async {
                Navigator.pop(dialogCtx); // close preview dialog

                // show EditPromptDialog, truyền prompt hiện tại
                final updatedPrompt = await showDialog<Prompt>(
                  context: context,
                  builder: (_) => EditPromptDialog(prompt: p),
                );

                // nếu người dùng save, cập nhật list
                if (updatedPrompt != null && mounted) {
                  setState(() {
                    final index = _prompts.indexWhere(
                      (item) => item.id == updatedPrompt.id,
                    );
                    if (index != -1) {
                      _prompts[index] = updatedPrompt;
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Prompt updated successfully"),
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: "Delete",
              onPressed: () async {
                // Close preview dialog first
                Navigator.pop(dialogCtx);

                // Show confirm dialog
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx2) => AlertDialog(
                    title: const Text("Delete Prompt"),
                    content: const Text(
                      "Are you sure you want to delete this prompt?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx2, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.pop(ctx2, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                // If user cancels, do nothing
                if (confirm != true) return;

                // Call API to delete
                try {
                  await _service.deletePrompt(p.id);

                  if (!mounted) return; // check widget still mounted

                  // Remove prompt from local list instead of reload full list
                  setState(() {
                    _prompts.removeWhere((item) => item.id == p.id);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Prompt deleted successfully"),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
                }
              },
            ),
          ],

          // nút close
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _buildAppBarTitle(),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFilterTabs(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            CategoryChipsWidget(
              selectedCategory: _selectedCategory,
              onCategorySelected: (c) {
                setState(() => _selectedCategory = c);
                _handleFilterChange();
              },
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildPromptList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Prompts Library",
          style: TextStyle(
            fontSize: 20,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.add,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: (_) => const CreatePromptDialog(),
                );
                if (result == true) _loadPrompts();
              },
            ),
            IconButton(
              icon: Icon(
                _filterFavoritesOnly ? Icons.star : Icons.star_border,
                color: _filterFavoritesOnly
                    ? Colors.amber
                    : (isDark ? Colors.white : Colors.black),
              ),
              onPressed: () {
                setState(() => _filterFavoritesOnly = !_filterFavoritesOnly);
                _handleFilterChange();
              },
            ),
          ],
        ),
      ],
    );
  }
}
