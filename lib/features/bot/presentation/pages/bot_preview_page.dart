import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/services/bot_service.dart';
import 'package:bytequeens_adm/services/kb_chat_service.dart';
import 'package:bytequeens_adm/data/models/bot.dart';

class BotPreviewPage extends StatefulWidget {
  final String botId;

  const BotPreviewPage({super.key, required this.botId});

  @override
  State<BotPreviewPage> createState() => _BotPreviewPageState();
}

class _BotPreviewPageState extends State<BotPreviewPage> {
  final _botService = BotService();
  final _chatService = KBChatService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  Bot? _bot;
  bool _isLoading = true;
  bool _isSending = false;
  bool _useRealApi = true; // Toggle for testing

  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadBot();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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

      _addMessage(
        ChatMessage(
          text:
              'Hi! I\'m ${bot!.name}. ${bot.description ?? "I'm here to help you"}. How can I help you today?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading bot: $e')));
      }
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    // Add user message
    _addMessage(
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    );

    _messageController.clear();
    setState(() => _isSending = true);

    try {
      String response;

      if (_useRealApi && _bot != null) {
        // Use KB API
        response = await _chatService.previewChat(
          botId: _bot!.id,
          message: text,
        );
      } else {
        // Fallback to mock response
        await Future.delayed(const Duration(seconds: 1));
        response = _generateMockResponse(text);
      }

      _addMessage(
        ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
      );
    } catch (e) {
      print('Error sending message: $e');

      // Show error message
      _addMessage(
        ChatMessage(
          text:
              'Sorry, I encountered an error: ${e.toString()}. Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  String _generateMockResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'Hello! How can I assist you today?';
    } else if (lowerMessage.contains('help')) {
      return 'I\'m here to help! You can ask me about ${_bot?.name ?? 'topics'} based on my knowledge base.';
    } else if (lowerMessage.contains('what') &&
        lowerMessage.contains('expertise')) {
      return 'I have expertise in the areas covered by my knowledge base. Feel free to ask me specific questions!';
    } else if (lowerMessage.contains('knowledge')) {
      return 'My knowledge comes from ${_bot?.knowledgeSources.length ?? 0} source(s) that have been added to my knowledge base.';
    } else {
      return 'That\'s an interesting question! Based on my knowledge base, I can provide information about ${_bot?.name ?? 'various topics'}. Could you be more specific?';
    }
  }

  /// Clear conversation and start new conversation
  void _clearThread() {
    if (_bot != null) {
      _chatService.clearConversation(_bot!.id);
    }
    setState(() {
      _messages.clear();
    });
    _loadBot(); // Reload welcome message

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Started new conversation'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppTheme.darkBackground : Colors.white;
    final surfaceColor = isDark ? AppTheme.darkSurface : Colors.white;
    final textColor = isDark ? AppTheme.lightText : AppTheme.darkBlue;
    final subtitleColor = isDark
        ? AppTheme.lightText.withValues(alpha: 0.7)
        : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.smart_toy, color: AppTheme.primaryBlue, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _bot?.name ?? 'Bot',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppConstants.previewMode,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Clear thread button
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: textColor),
            onSelected: (value) {
              if (value == 'clear') {
                _clearThread();
              } else if (value == 'toggle_api') {
                setState(() {
                  _useRealApi = !_useRealApi;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _useRealApi ? 'Using KB API' : 'Using Mock responses',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('New Thread'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_api',
                child: Row(
                  children: [
                    Icon(_useRealApi ? Icons.cloud_off : Icons.cloud, size: 20),
                    SizedBox(width: 8),
                    Text(_useRealApi ? 'Use Mock' : 'Use API'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    Expanded(
                      child: _messages.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final message = _messages[index];
                                return _buildMessageBubble(message);
                              },
                            ),
                    ),

                    if (_isSending)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppTheme.primaryBlue.withValues(
                                alpha: 0.1,
                              ),
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
                                color: isDark
                                    ? AppTheme.darkCard
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildTypingDot(),
                                  const SizedBox(width: 4),
                                  _buildTypingDot(delay: 200),
                                  const SizedBox(width: 4),
                                  _buildTypingDot(delay: 400),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.darkCard
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: TextField(
                                controller: _messageController,
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  hintText: AppConstants.askMeAnything,
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? AppTheme.lightText.withValues(
                                            alpha: 0.5,
                                          )
                                        : Colors.grey[400],
                                  ),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (_) => _sendMessage(),
                                maxLines: null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _sendMessage,
                            icon: Icon(
                              Icons.send,
                              color: _messageController.text.trim().isEmpty
                                  ? (isDark ? Colors.grey[600] : Colors.grey)
                                  : AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
            Icons.chat_bubble_outline,
            size: 64,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            AppConstants.startConversation,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
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
                  _formatTimestamp(message.timestamp),
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

  Widget _buildTypingDot({int delay = 0}) {
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
        if (mounted && _isSending) {
          setState(() {});
        }
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
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
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
