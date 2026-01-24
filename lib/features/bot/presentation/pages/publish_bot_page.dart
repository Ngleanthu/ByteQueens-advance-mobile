import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/services/kb_service.dart';
import 'package:bytequeens_adm/data/models/api_exception.dart';

class PublishBotPage extends StatefulWidget {
  final String botId;
  final String botName;

  const PublishBotPage({super.key, required this.botId, required this.botName});

  @override
  State<PublishBotPage> createState() => _PublishBotPageState();
}

class _PublishBotPageState extends State<PublishBotPage> {
  final _kbService = KBService();
  final _formKey = GlobalKey<FormState>();

  // Platform selections
  bool _publishToSlack = false;
  bool _publishToTelegram = false;
  bool _publishToMessenger = false;

  // Form controllers
  final _slackWebhookController = TextEditingController();
  final _telegramTokenController = TextEditingController();
  final _messengerTokenController = TextEditingController();

  bool _isPublishing = false;
  final Map<String, bool> _publishedPlatforms =
      {}; // Track which platforms are published

  @override
  void dispose() {
    _slackWebhookController.dispose();
    _telegramTokenController.dispose();
    _messengerTokenController.dispose();
    super.dispose();
  }

  Future<void> _publishBot() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_publishToSlack && !_publishToTelegram && !_publishToMessenger) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one platform'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      // Publish to selected platforms
      final List<Future<void>> publishTasks = [];

      if (_publishToSlack && _slackWebhookController.text.isNotEmpty) {
        publishTasks.add(
          _publishToPlatform('slack', {
            'webhook_url': _slackWebhookController.text,
          }),
        );
      }

      if (_publishToTelegram && _telegramTokenController.text.isNotEmpty) {
        publishTasks.add(
          _publishToPlatform('telegram', {
            'bot_token': _telegramTokenController.text,
          }),
        );
      }

      if (_publishToMessenger && _messengerTokenController.text.isNotEmpty) {
        publishTasks.add(
          _publishToPlatform('messenger', {
            'page_access_token': _messengerTokenController.text,
          }),
        );
      }

      await Future.wait(publishTasks);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bot "${widget.botName}" published successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish bot: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  Future<void> _publishToPlatform(
    String platform,
    Map<String, dynamic> config,
  ) async {
    final response = await _kbService.publishBot(
      assistantId: widget.botId,
      platform: platform,
      config: config,
    );

    setState(() {
      _publishedPlatforms[platform] = true;
    });

    print('✅ Published to $platform: $response');
  }

  Future<void> _unpublishFromPlatform(String platform) async {
    try {
      setState(() => _isPublishing = true);

      await _kbService.unpublishBot(
        assistantId: widget.botId,
        platform: platform,
      );

      setState(() {
        _publishedPlatforms[platform] = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unpublished from ${platform.toUpperCase()}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unpublish: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBlue : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.navyBlue : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? Colors.white : AppTheme.darkBlue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppConstants.publishYourBot,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.darkBlue,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      '${AppConstants.publishYourBot}: "${widget.botName}"',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.publishBotDesc,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Platform Selection Header
                    Text(
                      AppConstants.selectPlatforms,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Slack Platform
                    _buildPlatformCard(
                      isDark: isDark,
                      title: 'Slack',
                      icon: Icons.chat_bubble_outline,
                      isSelected: _publishToSlack,
                      isPublished: _publishedPlatforms['slack'] ?? false,
                      onToggle: (value) =>
                          setState(() => _publishToSlack = value ?? false),
                      onUnpublish: () => _unpublishFromPlatform('slack'),
                      child: _publishToSlack
                          ? Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: TextFormField(
                                controller: _slackWebhookController,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  labelText: AppConstants.slackWebhookUrl,
                                  hintText: AppConstants.webhookUrlHint,
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Colors.grey[600]
                                        : Colors.grey[400],
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? AppTheme.navyBlue
                                      : Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (_publishToSlack &&
                                      (value == null || value.isEmpty)) {
                                    return 'Please enter Slack webhook URL';
                                  }
                                  return null;
                                },
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // Telegram Platform
                    _buildPlatformCard(
                      isDark: isDark,
                      title: 'Telegram',
                      icon: Icons.send,
                      isSelected: _publishToTelegram,
                      isPublished: _publishedPlatforms['telegram'] ?? false,
                      onToggle: (value) =>
                          setState(() => _publishToTelegram = value ?? false),
                      onUnpublish: () => _unpublishFromPlatform('telegram'),
                      child: _publishToTelegram
                          ? Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: TextFormField(
                                controller: _telegramTokenController,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  labelText: AppConstants.telegramBotToken,
                                  hintText: AppConstants.botTokenHint,
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Colors.grey[600]
                                        : Colors.grey[400],
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? AppTheme.navyBlue
                                      : Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (_publishToTelegram &&
                                      (value == null || value.isEmpty)) {
                                    return 'Please enter Telegram bot token';
                                  }
                                  return null;
                                },
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // Messenger Platform
                    _buildPlatformCard(
                      isDark: isDark,
                      title: 'Messenger',
                      icon: Icons.messenger_outline,
                      isSelected: _publishToMessenger,
                      isPublished: _publishedPlatforms['messenger'] ?? false,
                      onToggle: (value) =>
                          setState(() => _publishToMessenger = value ?? false),
                      onUnpublish: () => _unpublishFromPlatform('messenger'),
                      child: _publishToMessenger
                          ? Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: TextFormField(
                                controller: _messengerTokenController,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  labelText: AppConstants.messengerPageToken,
                                  hintText: AppConstants.pageTokenHint,
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Colors.grey[600]
                                        : Colors.grey[400],
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? AppTheme.navyBlue
                                      : Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (_publishToMessenger &&
                                      (value == null || value.isEmpty)) {
                                    return 'Please enter Messenger page token';
                                  }
                                  return null;
                                },
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(height: 32),

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

                    const SizedBox(height: 32),

                    // Publish Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isPublishing ? null : _publishBot,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isPublishing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                AppConstants.publishButton,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required bool isSelected,
    required bool isPublished,
    required Function(bool?) onToggle,
    required VoidCallback onUnpublish,
    Widget? child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.navyBlue : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryBlue
              : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppTheme.darkBlue,
                      ),
                    ),
                    if (isPublished)
                      Text(
                        '${AppConstants.publishedOn} $title',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                        ),
                      ),
                  ],
                ),
              ),
              if (isPublished)
                TextButton(
                  onPressed: onUnpublish,
                  child: Text(
                    AppConstants.unpublishButton,
                    style: TextStyle(color: Colors.red[400], fontSize: 13),
                  ),
                ),
              if (!isPublished)
                Checkbox(
                  value: isSelected,
                  onChanged: onToggle,
                  activeColor: AppTheme.primaryBlue,
                ),
            ],
          ),
          if (child != null) child,
        ],
      ),
    );
  }
}
