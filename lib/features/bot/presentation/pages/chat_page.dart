import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/features/bot/presentation/widgets/chat_input_section.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/chat_history_page.dart';
import 'package:bytequeens_adm/data/models/bot.dart';
import 'package:bytequeens_adm/services/bot_service.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? modelName;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.modelName,
  });
}

class ChatPage extends StatefulWidget {
  final String initialMessage;
  final String modelId;
  final String modelName;
  final List<Map<String, dynamic>>? existingMessages;
  final String? chatId;

  const ChatPage({
    Key? key,
    required this.initialMessage,
    required this.modelId,
    required this.modelName,
    this.existingMessages,
    this.chatId,
  }) : super(key: key);

  // Named constructor for loading chat history
  const ChatPage.withHistory({
    Key? key,
    required this.chatId,
    required this.existingMessages,
    required this.modelName,
  }) : initialMessage = '',
       modelId = 'gpt-4o-mini',
       super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _botService = BotService();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  List<Bot> _userBots = [];
  String _selectedModel = '';
  String _selectedModelId = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedModel = widget.modelName;
    _selectedModelId = widget.modelId;
    _loadUserBots();

    // Load existing messages if provided (from chat history)
    if (widget.existingMessages != null &&
        widget.existingMessages!.isNotEmpty) {
      _messages = widget.existingMessages!
          .map(
            (msg) => ChatMessage(
              content: msg['content'] as String,
              isUser: msg['isUser'] as bool,
              timestamp: msg['timestamp'] as DateTime,
              modelName: msg['modelName'] as String?,
            ),
          )
          .toList();
    } else if (widget.initialMessage.isNotEmpty) {
      // Add initial user message for new chat
      _messages.add(
        ChatMessage(
          content: widget.initialMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );

      // Simulate AI response
      _sendMessage(widget.initialMessage);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserBots() async {
    try {
      final bots = await _botService.getAllBots();
      setState(() {
        _userBots = bots;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _handleModelChange(String modelId, String modelName) {
    setState(() {
      _selectedModelId = modelId;
      _selectedModel = modelName;
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate AI response
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _messages.add(
        ChatMessage(
          content:
              "Hello! I'm $_selectedModel, your friendly and creative assistant. I'm here to help you with a wide range of topics, whether you need information, ideas, or just someone to chat with. From answering questions and providing explanations to brainstorming creative projects and offering advice, I'm ready to assist you.\n\nWhat can I help you with today?",
          isUser: false,
          timestamp: DateTime.now(),
          modelName: _selectedModel,
        ),
      );
      _isLoading = false;
    });

    // Scroll to bottom
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

  void _handleSendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(content: message, isUser: true, timestamp: DateTime.now()),
      );
    });

    _messageController.clear();
    _sendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBlue : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.navyBlue : Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            // Navigate back safely
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ByteQueens AI: Chat ...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              'bytequeens.cx',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.bookmark_border,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages or welcome screen
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: _messages.isEmpty && !_isLoading
                    ? _buildWelcomeScreen(isDark)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length && _isLoading) {
                            return _buildLoadingMessage(isDark);
                          }
                          return _buildMessage(_messages[index], isDark);
                        },
                      ),
              ),
            ),
          ),

          // Chat input section with max width
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: ChatInputSection(
                messageController: _messageController,
                selectedModel: _selectedModel,
                freeMessagesRemaining: 37,
                userBots: _userBots,
                onModelChanged: _handleModelChange,
                onSendMessage: _handleSendMessage,
                onCreateBot: () {
                  // Navigate to create bot
                },
                onHistoryTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatHistoryPage(),
                    ),
                  );
                },
                onNewChat: () {
                  // Clear current chat and start new one
                  setState(() {
                    _messages.clear();
                    _messageController.clear();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(Icons.auto_awesome, size: 64, color: AppTheme.primaryBlue),
                const SizedBox(height: 16),
                Text(
                  'Start a conversation',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ask me anything or select a prompt below',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Suggested prompts',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          _buildPromptCard('Phân tích Gains Profile', isDark),
          const SizedBox(height: 12),
          _buildPromptCard('Câu hỏi mở về nhu cầu kinh doanh', isDark),
          const SizedBox(height: 12),
          _buildPromptCard('Brainstorm creative ideas', isDark),
          const SizedBox(height: 12),
          _buildPromptCard('Help me with data analysis', isDark),
        ],
      ),
    );
  }

  Widget _buildPromptCard(String text, bool isDark) {
    return InkWell(
      onTap: () {
        _messageController.text = text;
        _handleSendMessage();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.navyBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppTheme.mediumBlue.withOpacity(0.3)
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward,
              size: 18,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: message.isUser
                ? AppTheme.primaryBlue
                : (isDark ? AppTheme.mediumBlue : Colors.grey[300]),
            child: message.isUser
                ? Text(
                    'T',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
          ),
          const SizedBox(width: 12),

          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      message.isUser
                          ? 'You'
                          : (message.modelName ?? _selectedModel),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (!message.isUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.menu,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (!message.isUser) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.copy,
                          size: 18,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          size: 18,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMessage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isDark ? AppTheme.mediumBlue : Colors.grey[300],
            child: Icon(
              Icons.auto_awesome,
              size: 20,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedModel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Thinking...',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
