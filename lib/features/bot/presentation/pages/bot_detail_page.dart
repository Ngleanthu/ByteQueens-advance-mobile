import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/services/bot_service.dart';
import 'package:bytequeens_adm/data/models/bot.dart';
import 'package:bytequeens_adm/data/models/ai_model.dart';

class BotDetailPage extends StatefulWidget {
  final String botId;

  const BotDetailPage({Key? key, required this.botId}) : super(key: key);

  @override
  State<BotDetailPage> createState() => _BotDetailPageState();
}

class _BotDetailPageState extends State<BotDetailPage>
    with SingleTickerProviderStateMixin {
  final _botService = BotService();
  late TabController _tabController;

  Bot? _bot;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBot();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBot() async {
    setState(() => _isLoading = true);

    try {
      final bot = await _botService.getBotById(widget.botId);
      setState(() {
        _bot = bot;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bot: $e')),
        );
      }
    }
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
        title: Row(
          children: [
            Icon(Icons.smart_toy, color: AppTheme.primaryBlue, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _bot?.name ?? 'Bot',
                style: const TextStyle(
                  color: AppTheme.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.darkBlue),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              _bot?.isFavorite == true ? Icons.star : Icons.star_outline,
              color: _bot?.isFavorite == true ? Colors.amber : AppTheme.darkBlue,
            ),
            onPressed: () async {
              if (_bot != null) {
                await _botService.toggleFavorite(_bot!.id);
                _loadBot();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppTheme.darkBlue),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.darkBlue),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bot == null
              ? const Center(child: Text('Bot not found'))
              : Column(
                  children: [
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppTheme.primaryBlue,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppTheme.primaryBlue,
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.book),
                            text: AppConstants.knowledge,
                          ),
                          Tab(
                            icon: Icon(Icons.chat_bubble_outline),
                            text: AppConstants.preview,
                          ),
                          Tab(
                            icon: Icon(Icons.settings),
                            text: AppConstants.settings,
                          ),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildKnowledgeTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildKnowledgeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        
        Row(
          children: [
            Icon(Icons.book, size: 20, color: AppTheme.darkBlue),
            const SizedBox(width: 8),
            const Text(
              AppConstants.knowledgeBaseTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.knowledgeBaseDesc,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.storage, color: AppTheme.primaryBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _bot!.knowledgeBaseName,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () {},
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),

        const SizedBox(height: 24),

        
        OutlinedButton.icon(
          onPressed: () {
            
          },
          icon: const Icon(Icons.add),
          label: const Text(AppConstants.addKnowledgeSource),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryBlue,
            side: BorderSide(
              color: AppTheme.primaryBlue,
              style: BorderStyle.solid,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),

        const SizedBox(height: 32),

        
        Row(
          children: [
            Icon(Icons.people, size: 20, color: AppTheme.darkBlue),
            const SizedBox(width: 8),
            const Text(
              AppConstants.shareYourBot,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        
        TextField(
          decoration: InputDecoration(
            hintText: AppConstants.searchByGroupOrEmail,
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
        ),

        const SizedBox(height: 16),

        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Text(
                  _bot!.ownerName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _bot!.ownerName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            AppConstants.user,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _bot!.ownerEmail,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.stars, size: 14, color: Colors.amber[700]),
                    const SizedBox(width: 4),
                    Text(
                      AppConstants.owner,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  
}
