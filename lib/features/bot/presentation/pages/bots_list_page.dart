import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/services/bot_service.dart';
import 'package:bytequeens_adm/data/models/bot.dart';
import 'package:bytequeens_adm/data/models/ai_model.dart';
import 'package:bytequeens_adm/data/models/api_exception.dart';

class BotsListPage extends StatefulWidget {
  const BotsListPage({super.key});

  @override
  State<BotsListPage> createState() => _BotsListPageState();
}

class _BotsListPageState extends State<BotsListPage> {
  final _botService = BotService();
  final _searchController = TextEditingController();

  List<Bot> _bots = [];
  List<Bot> _filteredBots = [];
  bool _isLoading = true;
  String _filterType = 'all';
  String _sortBy = 'date';

  // Debouncing for search
  Timer? _searchDebounce;
  static const _searchDebounceDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _loadBots();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _searchDebounce?.cancel();

    // Start new timer to call API after user stops typing
    _searchDebounce = Timer(_searchDebounceDelay, () {
      _loadBots(); // Call API with search query
    });
  }

  Future<void> _loadBots({bool forceRefresh = false}) async {
    print('🔄 Loading bots... forceRefresh: $forceRefresh');
    setState(() => _isLoading = true);

    try {
      final searchQuery = _searchController.text.trim();
      final bots = await _botService.getAllBots(
        forceRefresh: forceRefresh,
        searchQuery: searchQuery.isEmpty ? null : searchQuery,
      );
      print('✅ Loaded ${bots.length} bots');
      setState(() {
        _bots = bots;
        _applyFiltersAndSort();
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.userFriendlyMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading bots: $e')));
      }
    }
  }

  void _applyFiltersAndSort() {
    List<Bot> filtered = _bots;

    // Apply favorite filter
    if (_filterType == 'favorites') {
      filtered = filtered.where((bot) => bot.isFavorite).toList();
    }

    // Note: Search filtering is done by API, not locally
    // API already returns filtered results based on search query

    // Apply sorting
    filtered = _botService.sortBots(filtered, _sortBy);

    setState(() {
      _filteredBots = filtered;
    });
  }

  void _showFilterMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.navyBlue : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                AppConstants.allBots,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              trailing: _filterType == 'all'
                  ? Icon(
                      Icons.check,
                      color: isDark ? AppTheme.primaryBlue : AppTheme.darkBlue,
                    )
                  : null,
              onTap: () {
                setState(() => _filterType = 'all');
                _applyFiltersAndSort();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                AppConstants.favorites,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              trailing: _filterType == 'favorites'
                  ? Icon(
                      Icons.check,
                      color: isDark ? AppTheme.primaryBlue : AppTheme.darkBlue,
                    )
                  : null,
              onTap: () {
                setState(() => _filterType = 'favorites');
                _applyFiltersAndSort();
                Navigator.pop(context);
              },
            ),
            Divider(color: isDark ? Colors.grey[800] : Colors.grey[300]),
            ListTile(
              title: Text(
                AppConstants.sortByName,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              trailing: _sortBy == 'name'
                  ? Icon(
                      Icons.check,
                      color: isDark ? AppTheme.primaryBlue : AppTheme.darkBlue,
                    )
                  : null,
              onTap: () {
                setState(() => _sortBy = 'name');
                _applyFiltersAndSort();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                AppConstants.sortByDate,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              trailing: _sortBy == 'date'
                  ? Icon(
                      Icons.check,
                      color: isDark ? AppTheme.primaryBlue : AppTheme.darkBlue,
                    )
                  : null,
              onTap: () {
                setState(() => _sortBy = 'date');
                _applyFiltersAndSort();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBlue : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.navyBlue : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppTheme.darkBlue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppConstants.botsTitle,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.darkBlue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white : AppTheme.darkBlue,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: AppConstants.searchBots,
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[400],
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _applyFiltersAndSort();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark
                            ? AppTheme.navyBlue
                            : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryBlue,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty && !_isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _filteredBots.isEmpty
                              ? 'No bots found for "${_searchController.text}"'
                              : 'Found ${_filteredBots.length} ${_filteredBots.length == 1 ? 'bot' : 'bots'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _showFilterMenu,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.navyBlue : Colors.white,
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.filter_list,
                                    size: 20,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _filterType == 'all'
                                        ? AppConstants.allBots
                                        : AppConstants.favorites,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryBlue,
                            AppTheme.primaryBlue.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Row(
                          children: [
                            const Icon(
                              Icons.smart_toy,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                        onPressed: () async {
                          print('🚀 Opening create bot page...');
                          final result = await Navigator.pushNamed(
                            context,
                            AppConstants.createBotRoute,
                          );
                          print('📥 Create bot result: $result');
                          if (result == true) {
                            print(
                              '✅ Bot created, reloading list with forceRefresh...',
                            );
                            _loadBots(forceRefresh: true);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredBots.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredBots.length,
                        itemBuilder: (context, index) {
                          return _buildBotCard(_filteredBots[index]);
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            AppConstants.noBots,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first bot to get started',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotCard(Bot bot) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.navyBlue : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.smart_toy,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  bot.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.darkBlue,
                  ),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.share, size: 20),
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  bot.isFavorite ? Icons.star : Icons.star_outline,
                  size: 20,
                ),
                color: bot.isFavorite
                    ? Colors.amber
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                onPressed: () async {
                  await _botService.toggleFavorite(bot.id);
                  _loadBots();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                onPressed: () => _confirmDelete(bot),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            bot.description ?? AppConstants.noDescription,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBlue : Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bot.model.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      AppConstants.botDetailRoute,
                      arguments: bot.id,
                    );
                    if (result == true) {
                      _loadBots(); // Refresh list if bot was modified/deleted
                    }
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text(AppConstants.edit),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    side: BorderSide(color: AppTheme.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppConstants.chatRoute,
                      arguments: {
                        'modelId': bot.id,
                        'modelName': bot.name,
                      },
                    );
                  },
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text(AppConstants.chatNow),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue.withValues(
                      alpha: 0.1,
                    ),
                    foregroundColor: AppTheme.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Bot bot) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.navyBlue : Colors.white,
        title: Text(
          'Delete Bot',
          style: TextStyle(color: isDark ? Colors.white : AppTheme.darkBlue),
        ),
        content: Text(
          'Are you sure you want to delete "${bot.name}"?',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : AppTheme.darkBlue,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _botService.deleteBot(bot.id);
              _loadBots();
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Bot deleted')));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
