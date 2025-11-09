import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/services/bot_service.dart';
import 'package:bytequeens_adm/data/models/bot.dart';
import 'package:bytequeens_adm/data/models/ai_model.dart';

class BotDetailPage extends StatefulWidget {
  final String botId;

  const BotDetailPage({super.key, required this.botId});

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
                            color: Colors.black.withValues(alpha: 0.05),
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
                          _buildPreviewTab(),
                          _buildSettingsTab(),
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

  Widget _buildPreviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        
        Row(
          children: [
            Icon(Icons.chat_bubble_outline, size: 20, color: AppTheme.darkBlue),
            const SizedBox(width: 8),
            const Text(
              AppConstants.previewTitle,
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
          AppConstants.previewDesc,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),

        const SizedBox(height: 32),

        
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Icon(Icons.smart_toy, size: 64, color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              const Text(
                AppConstants.testYourBot,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.testYourBotDesc,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              _buildSamplePrompt(
                '"What topics do you have expertise in?"',
              ),
              const SizedBox(height: 12),
              _buildSamplePrompt(
                '"What are the key insights from your knowledge base?"',
              ),
              const SizedBox(height: 12),
              _buildSamplePrompt(
                '"How current is your knowledge?"',
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.psychology, size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 6),
                  Text(
                    _bot!.model.displayName,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppConstants.botPreviewRoute,
                  arguments: widget.botId,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                foregroundColor: AppTheme.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(AppConstants.newThread),
            ),
          ],
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
              Icon(Icons.code, size: 20, color: Colors.grey[400]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppConstants.askMeAnything,
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ),
              Icon(Icons.send, size: 20, color: Colors.grey[400]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSamplePrompt(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: AppTheme.darkBlue),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        
        Row(
          children: [
            Icon(Icons.settings, size: 20, color: AppTheme.darkBlue),
            const SizedBox(width: 8),
            const Text(
              AppConstants.settingsTitle,
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
          AppConstants.settingsDesc,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),

        const SizedBox(height: 24),

        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${AppConstants.instructions} (${_bot!.instructions?.length ?? 0} chars)',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(AppConstants.save),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: TextEditingController(text: _bot!.instructions),
            maxLines: null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter bot instructions...',
            ),
          ),
        ),

        const SizedBox(height: 16),

        
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppConstants.settingsTip.split(':')[0]}:',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  AppConstants.settingsTip.split(': ')[1],
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.darkBlue.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
