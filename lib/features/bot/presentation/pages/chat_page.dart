import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/features/bot/presentation/widgets/chat_input_section.dart';
import 'package:bytequeens_adm/features/bot/presentation/widgets/prompt_suggestion_overlay.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/chat_history_page.dart';
import 'package:bytequeens_adm/data/models/bot.dart';
import 'package:bytequeens_adm/services/bot_service.dart';
import 'package:bytequeens_adm/services/auth_service.dart';
import 'package:bytequeens_adm/data/repositories/ai_chat_repository.dart';
import 'package:bytequeens_adm/data/models/ai_chat_models.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? modelName;
  final String? modelId;
  final String? messageId;
  final List<String> files;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.modelName,
    this.modelId,
    this.messageId,
    this.files = const [],
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
  final _authService = AuthService();
  final _aiChatRepo = AiChatRepository();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  List<Bot> _userBots = [];
  String _selectedModel = '';
  String _selectedModelId = '';
  String? _conversationId;
  int _remainingUsage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedModel = widget.modelName;
    _selectedModelId = widget.modelId;

    // Load messages IMMEDIATELY if provided
    if (widget.existingMessages != null &&
        widget.existingMessages!.isNotEmpty) {
      _messages = widget.existingMessages!
          .map(
            (msg) => ChatMessage(
              content: msg['content'] as String,
              isUser: msg['isUser'] as bool,
              timestamp: msg['timestamp'] as DateTime,
              modelName: msg['modelName'] as String?,
              modelId: msg['modelId'] as String?,
              messageId: msg['messageId'] as String?,
              files:
                  (msg['files'] as List<dynamic>?)
                      ?.map((e) => e as String)
                      .toList() ??
                  [],
            ),
          )
          .toList();
      _conversationId = widget.chatId;

      // Scroll to bottom after loading history
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else if (widget.initialMessage.isNotEmpty) {
      // Add initial message IMMEDIATELY
      _messages.add(
        ChatMessage(
          content: widget.initialMessage,
          isUser: true,
          timestamp: DateTime.now(),
          modelId: _selectedModelId,
          messageId: 'm${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

      // Set loading state to trigger rebuild and show the message
      _isLoading = true;
    }

    // Then do async init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndInit();
    });
  }

  Future<void> _checkAuthAndInit() async {
    // Check if user is logged in
    final token = _authService.getAccessToken();
    if (token == null) {
      // Redirect to login
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to use AI Chat'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacementNamed(context, '/signin');
      }
      return;
    }

    // Load user bots
    await _loadUserBots();

    // If initial message exists, send it to AI
    if (widget.initialMessage.isNotEmpty) {
      await _sendMessage(widget.initialMessage);
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

      // Giữ nguyên conversation - cho phép nhiều model trong 1 đoạn chat
      // Show info message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to $modelName'),
          backgroundColor: AppTheme.primaryBlue,
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create assistant from selected model
      final assistant = _getAssistantFromModelId(_selectedModelId);

      MessageResponse response;

      if (_conversationId == null) {
        // Create new thread
        response = await _aiChatRepo.createNewThread(
          content: message,
          assistant: assistant,
        );
        _conversationId = response.conversationId;
      } else {
        // Build conversation history from existing messages
        // Format theo API spec: mỗi message cần có assistant, role, content, files, id
        final conversationHistory = _messages.map((msg) {
          // Get assistant info for this message
          final msgModelId = msg.modelId ?? _selectedModelId;
          final msgAssistant = _getAssistantFromModelId(msgModelId);

          return {
            'assistant': {'id': msgAssistant.id, 'model': msgAssistant.model},
            'role': msg.isUser ? 'user' : 'assistant',
            'content': msg.content,
            'files': msg.files,
            'id': msg.messageId ?? 'm${DateTime.now().millisecondsSinceEpoch}',
          };
        }).toList();

        print('📝 Building conversation history:');
        print('   Total messages: ${conversationHistory.length}');
        print(
          '   Last message role: ${conversationHistory.isNotEmpty ? conversationHistory.last['role'] : 'none'}',
        );

        // Send message in existing conversation with full history
        response = await _aiChatRepo.sendMessage(
          content: message,
          assistant: assistant,
          conversationHistory: conversationHistory,
          conversationId:
              _conversationId, // Pass conversation ID to maintain context
        );

        // Update conversationId if it changed (should stay the same for existing conversation)
        if (response.conversationId != _conversationId) {
          print(
            '⚠️ ConversationId changed! Old: $_conversationId, New: ${response.conversationId}',
          );
        }
        _conversationId = response.conversationId;
      }

      print('💬 Current ConversationId: $_conversationId');

      // Update UI with AI response
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              content: response.message,
              isUser: false,
              timestamp: DateTime.now(),
              modelName: _selectedModel,
              modelId: _selectedModelId,
              messageId: 'm${DateTime.now().millisecondsSinceEpoch}',
            ),
          );
          _remainingUsage = response.remainingUsage;
          _isLoading = false;
        });

        // Scroll to bottom
        _scrollToBottom();
      }
    } catch (e) {
      // Handle error - Show friendly AI message instead of error
      if (mounted) {
        // Tạo message xin lỗi thân thiện từ AI
        final errorMessage = _getErrorMessage(e.toString());

        setState(() {
          _messages.add(
            ChatMessage(
              content: errorMessage,
              isUser: false,
              timestamp: DateTime.now(),
              modelName: _selectedModel,
              modelId: _selectedModelId,
              messageId: 'm${DateTime.now().millisecondsSinceEpoch}',
            ),
          );
          _isLoading = false;
        });

        // Scroll to bottom
        _scrollToBottom();

        // Optional: Show subtle error notification (không quá chói)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Connection issue - please try again'),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _getErrorMessage(String error) {
    final errorLower = error.toLowerCase();

    // Xác định loại lỗi và trả về message thân thiện
    if (errorLower.contains('unauthorized') || errorLower.contains('401')) {
      return "I apologize, but I'm having trouble verifying your access. Please try logging in again to continue our conversation. 🔐";
    } else if (errorLower.contains('login again')) {
      return "I apologize, but your session has expired. Please log in again to continue our conversation. 🔐";
    } else if (errorLower.contains('timeout') ||
        errorLower.contains('connection timeout') ||
        errorLower.contains('request timeout')) {
      return "I'm sorry, but I'm taking longer than usual to respond. The network seems a bit slow right now. Could you please try sending your message again? 🌐";
    } else if (errorLower.contains('no internet') ||
        errorLower.contains('socketexception') ||
        errorLower.contains('network is unreachable')) {
      return "Oops! It seems like you're offline right now. Please check your internet connection and try again. I'll be here waiting! 📡";
    } else if (errorLower.contains('connection refused') ||
        errorLower.contains('cannot reach server')) {
      return "I'm having trouble connecting to my servers right now. Please check your internet connection and try again in a moment. 🌐";
    } else if (errorLower.contains('too many requests') ||
        errorLower.contains('429')) {
      return "I'm receiving a lot of messages right now! Please wait a moment and try again. Thank you for your patience! ⏳";
    } else if (errorLower.contains('server error') ||
        errorLower.contains('500') ||
        errorLower.contains('502') ||
        errorLower.contains('503') ||
        errorLower.contains('bad gateway') ||
        errorLower.contains('service unavailable')) {
      return "I apologize for the inconvenience, but I'm experiencing some technical difficulties on my end. Our team is working to fix this. Please try again in a few moments. 🔧";
    } else if (errorLower.contains('not found') || errorLower.contains('404')) {
      return "Hmm, I seem to have lost track of our conversation. Let's start fresh! Feel free to ask me anything. 🔍";
    } else if (errorLower.contains('forbidden') || errorLower.contains('403')) {
      return "I apologize, but I don't have permission to process this request. Please contact support if this persists. 🚫";
    } else if (errorLower.contains('bad request') ||
        errorLower.contains('400')) {
      return "I'm sorry, but I couldn't understand that request properly. Could you please rephrase your message and try again? 💭";
    } else if (errorLower.contains('empty response') ||
        errorLower.contains('null')) {
      return "I apologize, but I received an incomplete response. Please try sending your message again. 🔄";
    } else if (errorLower.contains('ssl') ||
        errorLower.contains('certificate') ||
        errorLower.contains('handshake')) {
      return "I'm having trouble establishing a secure connection. Please check your internet settings and try again. 🔒";
    } else if (errorLower.contains('cancelled') ||
        errorLower.contains('cancel')) {
      return "It looks like the request was cancelled. Feel free to send your message again! 🔄";
    } else {
      // Generic friendly error message
      return "I apologize, but I encountered an unexpected issue while processing your message. Don't worry though! Please try sending your message again, and I'll do my best to help you. 💬";
    }
  }

  AssistantDto _getAssistantFromModelId(String modelId) {
    // Map model ID to AssistantId enum
    try {
      final assistantId = AssistantId.fromString(modelId);
      return _aiChatRepo.createAssistant(
        assistantId: assistantId,
        assistantModel: AssistantModel.dify,
      );
    } catch (e) {
      // Default to Gemini 1.5 Flash
      return _aiChatRepo.getDefaultAssistant();
    }
  }

  void _scrollToBottom() {
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
        ChatMessage(
          content: message,
          isUser: true,
          timestamp: DateTime.now(),
          modelId: _selectedModelId,
          messageId: 'm${DateTime.now().millisecondsSinceEpoch}',
        ),
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
            // Navigate to home page directly
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
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
              child: PromptSuggestionOverlay(
                messageController: _messageController,
                child: ChatInputSection(
                  messageController: _messageController,
                  selectedModel: _selectedModel,
                  freeMessagesRemaining: _remainingUsage,
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
                        builder: (context) => ChatHistoryPage(
                          currentConversationId: _conversationId,
                        ),
                      ),
                    );
                  },
                  onNewChat: () {
                    // Clear current chat and start new one
                    setState(() {
                      _messages.clear();
                      _messageController.clear();
                      _conversationId = null;
                    });
                  },
                ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Suggested prompts',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppConstants.promptListRoute);
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                ),
                child: Text(
                  AppConstants.viewAll,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                    inherit: true,
                  ),
                ),
              ),
            ],
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
                message.isUser
                    ? Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      )
                    : MarkdownBody(
                        data: message.content,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          code: TextStyle(
                            backgroundColor: isDark
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          blockquote: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          h1: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          h2: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          h3: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          listBullet: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
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
