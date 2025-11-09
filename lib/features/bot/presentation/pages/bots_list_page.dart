import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/services/bot_service.dart';
import 'package:bytequeens_adm/data/models/bot.dart';
import 'package:bytequeens_adm/data/models/ai_model.dart';

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

  @override
  void initState() {
    super.initState();
    _loadBots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBots() async {
    setState(() => _isLoading = true);
    
    try {
      final bots = await _botService.getAllBots();
      setState(() {
        _bots = bots;
        _applyFiltersAndSort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bots: $e')),
        );
      }
    }
  }

  void _applyFiltersAndSort() {
    List<Bot> filtered = _bots;

    
    if (_filterType == 'favorites') {
      filtered = filtered.where((bot) => bot.isFavorite).toList();
    }

    
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((bot) {
        return bot.name.toLowerCase().contains(query) ||
            (bot.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    
    filtered = _botService.sortBots(filtered, _sortBy);

    setState(() {
      _filteredBots = filtered;
    });
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(AppConstants.allBots),
              trailing: _filterType == 'all' ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _filterType = 'all');
                _applyFiltersAndSort();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(AppConstants.favorites),
              trailing: _filterType == 'favorites' ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _filterType = 'favorites');
                _applyFiltersAndSort();
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text(AppConstants.sortByName),
              trailing: _sortBy == 'name' ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _sortBy = 'name');
                _applyFiltersAndSort();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(AppConstants.sortByDate),
              trailing: _sortBy == 'date' ? const Icon(Icons.check) : null,
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          AppConstants.botsTitle,
          style: TextStyle(
            color: AppTheme.darkBlue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.darkBlue),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFiltersAndSort(),
              decoration: InputDecoration(
                hintText: AppConstants.searchBots,
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _showFilterMenu,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.filter_list, size: 20, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                _filterType == 'all' ? AppConstants.allBots : AppConstants.favorites,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Row(
                      children: [
                        const Icon(Icons.smart_toy, color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        const Icon(Icons.add, color: Colors.white, size: 20),
                      ],
                    ),
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        AppConstants.createBotRoute,
                      );
                      if (result == true) {
                        _loadBots();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          
          Expanded(
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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            AppConstants.noBots,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first bot to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotCard(Bot bot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkBlue,
                  ),
                ),
              ),
              
              IconButton(
                icon: const Icon(Icons.share, size: 20),
                color: Colors.grey[600],
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  bot.isFavorite ? Icons.star : Icons.star_outline,
                  size: 20,
                ),
                color: bot.isFavorite ? Colors.amber : Colors.grey[600],
                onPressed: () async {
                  await _botService.toggleFavorite(bot.id);
                  _loadBots();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                color: Colors.grey[600],
                onPressed: () => _confirmDelete(bot),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            bot.description ?? AppConstants.noDescription,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
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
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.psychology, size: 14, color: Colors.grey[700]),
                    const SizedBox(width: 4),
                    Text(
                      bot.model.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
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
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppConstants.botDetailRoute,
                      arguments: bot.id,
                    );
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
                      AppConstants.botPreviewRoute,
                      arguments: bot.id,
                    );
                  },
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text(AppConstants.chatNow),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bot'),
        content: Text('Are you sure you want to delete "${bot.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _botService.deleteBot(bot.id);
              _loadBots();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bot deleted')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
