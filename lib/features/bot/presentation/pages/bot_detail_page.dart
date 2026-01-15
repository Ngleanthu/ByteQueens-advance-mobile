import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/services/bot_service.dart';
import 'package:bytequeens_adm/services/kb_service.dart';
import 'package:bytequeens_adm/services/kb_chat_service.dart';
import 'package:bytequeens_adm/data/models/bot.dart';
import 'package:bytequeens_adm/data/models/knowledge_source.dart';
import 'package:bytequeens_adm/data/models/api_exception.dart';
import 'package:bytequeens_adm/features/bot/presentation/widgets/add_knowledge_dialog.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/publish_bot_page.dart';

class BotDetailPage extends StatefulWidget {
  final String botId;

  const BotDetailPage({super.key, required this.botId});

  @override
  State<BotDetailPage> createState() => _BotDetailPageState();
}

class _BotDetailPageState extends State<BotDetailPage>
    with SingleTickerProviderStateMixin {
  final _botService = BotService();
  final _kbService = KBService();
  final _kbChatService = KBChatService();
  late TabController _tabController;

  Bot? _bot;
  bool _isLoading = true;
  bool _isLoadingKnowledges = false;
  bool _isSaving = false;
  List<KnowledgeSource> _botKnowledges = [];
  List<KnowledgeSource> _availableKnowledges = [];

  // Controllers for bot fields
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();

  // Preview chat
  final _previewMessageController = TextEditingController();
  final _previewScrollController = ScrollController();
  final List<PreviewMessage> _previewMessages = [];
  bool _isSendingPreview = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _previewMessageController.addListener(() {
      setState(() {}); // Update send button color
    });
    _loadBot();
    _loadAvailableKnowledges();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _previewMessageController.dispose();
    _previewScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBot() async {
    setState(() => _isLoading = true);

    try {
      final bot = await _botService.getBotById(widget.botId);
      setState(() {
        _bot = bot;
        _nameController.text = bot?.name ?? '';
        _descriptionController.text = bot?.description ?? '';
        _instructionsController.text = bot?.instructions ?? '';
        _isLoading = false;
      });

      // Add welcome message for preview
      if (_previewMessages.isEmpty && bot != null) {
        _previewMessages.add(
          PreviewMessage(
            text:
                'Hi! I\'m ${bot.name}. ${bot.description ?? "I\'m here to help you"}. How can I help you today?',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      }

      // Load bot's knowledge sources
      await _loadBotKnowledges();
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
        ).showSnackBar(SnackBar(content: Text('Error loading bot: $e')));
      }
    }
  }

  Future<void> _loadBotKnowledges() async {
    if (_bot == null) return;

    setState(() => _isLoadingKnowledges = true);

    try {
      // Mock data for now - Replace with actual API call when available
      // final knowledges = await _kbService.getBotKnowledges(_bot!.id);

      // For now, use mock data based on bot's knowledgeBaseName
      setState(() {
        _botKnowledges = _generateMockKnowledges();
        _isLoadingKnowledges = false;
      });
    } catch (e) {
      setState(() => _isLoadingKnowledges = false);
      print('Error loading bot knowledges: $e');
    }
  }

  List<KnowledgeSource> _generateMockKnowledges() {
    // Generate some mock knowledge sources for demo
    return [
      KnowledgeSource(
        id: '1',
        name: 'Product Documentation',
        type: KnowledgeSourceType.website,
        url: 'https://docs.example.com',
        autoUpdate: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      KnowledgeSource(
        id: '2',
        name: 'FAQ Database',
        type: KnowledgeSourceType.localFiles,
        files: ['faq.pdf', 'support.docx'],
        autoUpdate: false,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  Future<void> _loadAvailableKnowledges() async {
    try {
      // Mock available knowledge sources - Replace with actual API call
      setState(() {
        _availableKnowledges = [
          KnowledgeSource(
            id: '3',
            name: 'Marketing Materials',
            type: KnowledgeSourceType.googleDrive,
            url: 'https://drive.google.com/...',
            autoUpdate: true,
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          KnowledgeSource(
            id: '4',
            name: 'Team Wiki',
            type: KnowledgeSourceType.confluence,
            url: 'https://wiki.example.com',
            autoUpdate: true,
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
          ),
          KnowledgeSource(
            id: '5',
            name: 'Support Tickets',
            type: KnowledgeSourceType.slack,
            url: 'https://slack.com/...',
            autoUpdate: false,
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
          ),
          KnowledgeSource(
            id: '6',
            name: 'Tutorial Videos',
            type: KnowledgeSourceType.website,
            url: 'https://tutorials.example.com',
            autoUpdate: true,
            createdAt: DateTime.now().subtract(const Duration(days: 20)),
          ),
        ];
      });
    } catch (e) {
      print('Error loading available knowledges: $e');
    }
  }

  Future<void> _addKnowledgeSources() async {
    final selectedKnowledges = await showDialog<List<KnowledgeSource>>(
      context: context,
      builder: (context) => AddKnowledgeDialog(
        availableKnowledges: _availableKnowledges,
        currentKnowledges: _botKnowledges,
      ),
    );

    if (selectedKnowledges != null && selectedKnowledges.isNotEmpty) {
      setState(() => _isLoadingKnowledges = true);

      try {
        // Add each knowledge source to the bot via KB API
        for (final knowledge in selectedKnowledges) {
          await _kbService.addKnowledgeToBot(
            assistantId: _bot!.id,
            knowledgeId: knowledge.id,
          );
        }

        // Reload the bot's knowledge sources
        await _loadBotKnowledges();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully added ${selectedKnowledges.length} knowledge source(s)',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoadingKnowledges = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding knowledge sources: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _removeKnowledgeSource(KnowledgeSource knowledge) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.navyBlue : Colors.white,
        title: Text(
          'Remove Knowledge Source',
          style: TextStyle(color: isDark ? Colors.white : AppTheme.darkBlue),
        ),
        content: Text(
          'Are you sure you want to remove "${knowledge.name}" from this bot?',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : AppTheme.darkBlue,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoadingKnowledges = true);

      try {
        await _kbService.removeKnowledgeFromBot(
          assistantId: _bot!.id,
          knowledgeId: knowledge.id,
        );
        await _loadBotKnowledges();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Removed "${knowledge.name}" successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoadingKnowledges = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing knowledge source: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleDelete() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.navyBlue : Colors.white,
        title: Text(
          'Delete Bot',
          style: TextStyle(color: isDark ? Colors.white : AppTheme.darkBlue),
        ),
        content: Text(
          'Are you sure you want to delete "${_bot!.name}"? This action cannot be undone.',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : AppTheme.darkBlue,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _botService.deleteBot(_bot!.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${_bot!.name}" deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return to list and refresh
        }
      } on ApiException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.userFriendlyMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting bot: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
        title: Row(
          children: [
            Icon(Icons.smart_toy, color: AppTheme.primaryBlue, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _bot?.name ?? 'Bot',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.darkBlue,
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
            icon: Icon(
              _bot?.isFavorite == true ? Icons.star : Icons.star_outline,
              color: _bot?.isFavorite == true
                  ? Colors.amber
                  : (isDark ? Colors.white : AppTheme.darkBlue),
            ),
            onPressed: () async {
              if (_bot != null) {
                await _botService.toggleFavorite(_bot!.id);
                _loadBot();
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: isDark ? Colors.white : AppTheme.darkBlue,
            ),
            onPressed: _handleDelete,
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white : AppTheme.darkBlue,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bot == null
          ? const Center(child: Text('Bot not found'))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.navyBlue : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.05,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: AppTheme.primaryBlue,
                        unselectedLabelColor: isDark
                            ? Colors.grey[400]
                            : Colors.grey,
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
                          Tab(
                            icon: Icon(Icons.share),
                            text: AppConstants.publish,
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
                          _buildPublishTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKnowledgeTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.book,
              size: 20,
              color: isDark ? AppTheme.primaryBlue : AppTheme.darkBlue,
            ),
            const SizedBox(width: 8),
            Text(
              AppConstants.knowledgeBaseTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.darkBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.knowledgeBaseDesc,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),

        // Knowledge Base Name (read-only display)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.navyBlue : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.storage, color: AppTheme.primaryBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _bot!.knowledgeBaseName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_botKnowledges.length} knowledge source(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Knowledge Sources Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.source,
                  size: 18,
                  color: isDark ? AppTheme.primaryBlue : AppTheme.darkBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Knowledge Sources',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.darkBlue,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: _addKnowledgeSources,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Knowledge Sources List
        if (_isLoadingKnowledges)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_botKnowledges.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.navyBlue : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.folder_open,
                  size: 48,
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No knowledge sources added yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _addKnowledgeSources,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Knowledge Source'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    side: const BorderSide(color: AppTheme.primaryBlue),
                  ),
                ),
              ],
            ),
          )
        else
          ..._botKnowledges.map((knowledge) => _buildKnowledgeCard(knowledge)),

        const SizedBox(height: 32),

        // Share Your Bot Section
        Row(
          children: [
            Icon(
              Icons.people,
              size: 20,
              color: isDark ? AppTheme.primaryBlue : AppTheme.darkBlue,
            ),
            const SizedBox(width: 8),
            Text(
              AppConstants.shareYourBot,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.darkBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Search field
        TextField(
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: AppConstants.searchByGroupOrEmail,
            hintStyle: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            prefixIcon: Icon(
              Icons.search,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark ? AppTheme.navyBlue : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Owner card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.navyBlue : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
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
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkBlue
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            AppConstants.user,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey[400] : Colors.grey,
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
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget _buildKnowledgeCard(KnowledgeSource knowledge) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDark ? AppTheme.navyBlue : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getKnowledgeIcon(knowledge.type),
                color: AppTheme.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    knowledge.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        knowledge.getTypeName(),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      if (knowledge.autoUpdate) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sync,
                                size: 10,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Auto',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (knowledge.url != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      knowledge.url!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (knowledge.files != null &&
                      knowledge.files!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${knowledge.files!.length} file(s)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                size: 20,
              ),
              color: isDark ? AppTheme.navyBlue : Colors.white,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 18),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Remove', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'remove') {
                  _removeKnowledgeSource(knowledge);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getKnowledgeIcon(KnowledgeSourceType type) {
    switch (type) {
      case KnowledgeSourceType.localFiles:
        return Icons.description;
      case KnowledgeSourceType.website:
        return Icons.language;
      case KnowledgeSourceType.googleDrive:
        return Icons.folder;
      case KnowledgeSourceType.slack:
        return Icons.chat;
      case KnowledgeSourceType.confluence:
        return Icons.article;
      case KnowledgeSourceType.notion:
        return Icons.note;
      case KnowledgeSourceType.discord:
        return Icons.forum;
    }
  }

  Widget _buildPreviewTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.navyBlue : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Preview Chat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.darkBlue,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                color: AppTheme.primaryBlue,
                onPressed: _clearPreviewChat,
                tooltip: 'New conversation',
              ),
            ],
          ),
        ),

        // Chat messages
        Expanded(
          child: _previewMessages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Start a conversation',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _previewScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _previewMessages.length,
                  itemBuilder: (context, index) {
                    if (index >= _previewMessages.length) {
                      return const SizedBox.shrink();
                    }
                    final message = _previewMessages[index];
                    return _buildPreviewMessageBubble(message);
                  },
                ),
        ),

        // Typing indicator
        if (_isSendingPreview)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.smart_toy,
                    size: 18,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : Colors.grey[100],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTypingDot(),
                      const SizedBox(width: 4),
                      _buildTypingDot(),
                      const SizedBox(width: 4),
                      _buildTypingDot(),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 8),

        // Input field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.navyBlue : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _previewMessageController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppTheme.lightText.withValues(alpha: 0.5)
                            : Colors.grey[400],
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendPreviewMessage(),
                    maxLines: null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isSendingPreview ? null : _sendPreviewMessage,
                icon: Icon(
                  Icons.send,
                  color:
                      ((_previewMessageController.text.isEmpty) ||
                          _isSendingPreview)
                      ? (isDark ? Colors.grey[600] : Colors.grey)
                      : AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveBot() async {
    if (_bot == null) return;

    // Validate name
    if (_nameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bot name is required'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedBot = _bot!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        instructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
      );

      await _botService.updateBot(updatedBot);

      setState(() {
        _bot = updatedBot;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bot updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on ApiException catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.userFriendlyMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSettingsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(
              Icons.settings,
              size: 20,
              color: isDark ? AppTheme.primaryBlue : AppTheme.darkBlue,
            ),
            const SizedBox(width: 8),
            Text(
              'Edit Bot Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.darkBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your bot\'s name, description, and instructions',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),

        const SizedBox(height: 24),

        // Bot Name Field
        Text(
          'Bot Name *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'Enter bot name',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark ? AppTheme.navyBlue : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Bot Description Field
        Text(
          'Description',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'Enter bot description',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark ? AppTheme.navyBlue : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Bot Instructions Field
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Instructions (${_instructionsController.text.length} chars)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.navyBlue : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          child: TextField(
            controller: _instructionsController,
            maxLines: null,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter bot instructions...',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
            onChanged: (value) {
              setState(() {}); // Update char count
            },
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.primaryBlue.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tip: Clear instructions help your bot understand its role and respond accurately. Be specific about tone, format, and expertise.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppTheme.darkBlue.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Save Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveBot,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  // Preview chat methods
  void _addPreviewMessage(PreviewMessage message) {
    setState(() {
      _previewMessages.add(message);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_previewScrollController.hasClients) {
        _previewScrollController.animateTo(
          _previewScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendPreviewMessage() async {
    final text = _previewMessageController.text.trim();
    if (text.isEmpty || _isSendingPreview || _bot == null) return;

    print('📨 Starting preview chat...');
    print('   Bot ID: ${_bot!.id}');
    print('   Bot Name: ${_bot!.name}');
    print('   Message: $text');

    _addPreviewMessage(
      PreviewMessage(text: text, isUser: true, timestamp: DateTime.now()),
    );

    _previewMessageController.clear();
    setState(() => _isSendingPreview = true);

    try {
      print('🔄 Calling previewChat...');
      final response = await _kbChatService.previewChat(
        botId: _bot!.id,
        message: text,
      );

      print('✅ Preview chat response received: $response');
      _addPreviewMessage(
        PreviewMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } on ApiException catch (e) {
      print('❌ ApiException in preview chat:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   User Message: ${e.userFriendlyMessage}');
      _addPreviewMessage(
        PreviewMessage(
          text: 'Error: ${e.userFriendlyMessage}',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e, stackTrace) {
      print('❌ Unexpected error in preview chat:');
      print('   Error: $e');
      print('   Stack: $stackTrace');
      _addPreviewMessage(
        PreviewMessage(
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      setState(() => _isSendingPreview = false);
      print('🏁 Preview chat completed');
    }
  }

  void _clearPreviewChat() {
    if (_bot != null) {
      _kbChatService.clearConversation(_bot!.id);
    }
    setState(() {
      _previewMessages.clear();
      // Re-add welcome message
      if (_bot != null) {
        _previewMessages.add(
          PreviewMessage(
            text:
                'Hi! I\'m ${_bot!.name}. ${_bot!.description ?? "I\'m here to help you"}. How can I help you today?',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Started new conversation'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildPreviewMessageBubble(PreviewMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
              child: Icon(
                Icons.smart_toy,
                size: 18,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppTheme.primaryBlue
                        : (isDark ? AppTheme.darkCard : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(18).copyWith(
                      topLeft: message.isUser
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                      topRight: message.isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: message.isUser
                          ? Colors.white
                          : (isDark ? AppTheme.lightText : AppTheme.darkBlue),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPreviewTimestamp(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[600] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundColor: isDark
                  ? Colors.green[900]!.withValues(alpha: 0.3)
                  : Colors.green[100],
              child: Text(
                'U',
                style: TextStyle(
                  color: isDark ? Colors.green[300] : Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingDot() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.lightText.withValues(alpha: 0.2 + (value * 0.3))
                : Colors.grey.withValues(alpha: 0.3 + (value * 0.4)),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        if (mounted && _isSendingPreview) {
          setState(() {});
        }
      },
    );
  }

  String _formatPreviewTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildPublishTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.share,
              size: 20,
              color: isDark ? AppTheme.primaryBlue : AppTheme.darkBlue,
            ),
            const SizedBox(width: 8),
            Text(
              AppConstants.publishYourBot,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.darkBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.publishBotDesc,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),

        // Publish Button
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.navyBlue : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.rocket_launch,
                        size: 64,
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Make your bot available everywhere',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppTheme.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Publish your bot to Slack, Telegram, or Messenger',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (_bot != null) {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PublishBotPage(
                                    botId: _bot!.id,
                                    botName: _bot!.name,
                                  ),
                                ),
                              );

                              if (result == true && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      AppConstants.botPublishedSuccess,
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.share),
                          label: const Text(
                            AppConstants.publishButton,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Learn more about publishing bots at jarvis.cx/help/knowledge-base/publish-bot/',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white.withOpacity(0.8)
                                : AppTheme.darkBlue.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PreviewMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  PreviewMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
