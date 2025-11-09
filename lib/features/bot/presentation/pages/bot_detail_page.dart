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
                          
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  
}
