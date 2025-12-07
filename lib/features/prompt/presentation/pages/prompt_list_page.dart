import 'package:flutter/material.dart';
import '../../../../data/models/prompt.dart';
import '../widgets/prompt_item.dart';
import '../widgets/create_prompt_dialog.dart';
import '../widgets/category_chip.dart';
import '../../../../services/prompt_service.dart';

class PromptListPage extends StatefulWidget {
  const PromptListPage({Key? key}) : super(key: key);

  @override
  State<PromptListPage> createState() => _PromptListPageState();
}

class _PromptListPageState extends State<PromptListPage> {
  final PromptService _service = PromptService();
  List<Prompt> _prompts = [];
  bool _loading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
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
      final bool? isPublic = _showPublicPrompts ? true : false;
      final String? category = _selectedCategory == 'all'
          ? null
          : _selectedCategory;

      bool? isFavorite = _filterFavoritesOnly ? true : null;

      final prompts = await _service.getPrompts(
        isPublic: isPublic,
        category: category,
        isFavorite: isFavorite,
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
        _errorMessage = 'Failed to load prompts: ${e.toString()}';
      });
    }
  }

  List<Prompt> get filtered {
    if (_searchQuery.isEmpty) {
      return _prompts;
    }

    return _prompts.where((p) {
      final searchLower = _searchQuery.toLowerCase();
      return p.title.toLowerCase().contains(searchLower) ||
          (p.description?.toLowerCase().contains(searchLower) ?? false) ||
          p.content.toLowerCase().contains(searchLower);
    }).toList();
  }

  void _onFilterChanged() {
    _loadPrompts();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _onFilterChanged();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Prompts Library",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const CreatePromptDialog();
                      },
                    );
                    if (result == true) {
                      _loadPrompts();
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    _filterFavoritesOnly ? Icons.star : Icons.star_border,
                    color: _filterFavoritesOnly ? Colors.amber : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _filterFavoritesOnly = !_filterFavoritesOnly;
                    });
                    _onFilterChanged();
                  },
                ),
              ],
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab selector (Public prompts / My Prompts)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _showPublicPrompts = true);
                        _onFilterChanged();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _showPublicPrompts
                              ? Colors.blue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: _showPublicPrompts
                              ? [
                                  const BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'Public Prompts',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: _showPublicPrompts
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _showPublicPrompts
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _showPublicPrompts = false);
                        _onFilterChanged();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_showPublicPrompts
                              ? Colors.blue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: !_showPublicPrompts
                              ? [
                                  const BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'My Prompts',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: !_showPublicPrompts
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _showPublicPrompts
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      // Search là client-side, không cần reload từ server
                    },
                    decoration: InputDecoration(
                      hintText: 'Search prompts...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 248, 248, 248),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Category chips - Sử dụng widget mới
            CategoryChipsWidget(
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
            ),
            const SizedBox(height: 16),

            // Prompts list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
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
                    )
                  : filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No prompts match your search'
                                : 'No prompts found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPrompts,
                      child: ListView.separated(
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final p = filtered[i];
                          return PromptItem(
                            prompt: p,
                            onToggleFavorite: () async {
                              // TODO: Gọi API để toggle favorite
                              setState(() {
                                p.isFavorite = !p.isFavorite;
                              });

                              // Nếu đang filter favorites và vừa unfavorite
                              // thì reload để remove item khỏi list
                              if (_filterFavoritesOnly && !p.isFavorite) {
                                _loadPrompts();
                              }
                            },
                            onPreview: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(p.title),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (p.description != null) ...[
                                          Text(
                                            p.description ?? "",
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
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onUse: () {
                              // TODO: Implement use prompt functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Using: ${p.title}')),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
