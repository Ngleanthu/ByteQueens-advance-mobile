import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/chat_page.dart';
import 'package:bytequeens_adm/services/auth_service.dart';
import 'package:bytequeens_adm/data/repositories/ai_chat_repository.dart';
import 'package:bytequeens_adm/data/models/ai_chat_models.dart';

class ChatHistory {
  final String id;
  final String firstMessage;
  final DateTime timestamp;
  final List<Map<String, dynamic>> messages;
  bool isCurrent;

  ChatHistory({
    required this.id,
    required this.firstMessage,
    required this.timestamp,
    this.messages = const [],
    this.isCurrent = false,
  });
}

class ChatHistoryPage extends StatefulWidget {
  final String? currentConversationId;

  const ChatHistoryPage({Key? key, this.currentConversationId})
    : super(key: key);

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  final _authService = AuthService();
  final _aiChatRepo = AiChatRepository();

  String? _selectedChatId;
  String? _currentConversationId;
  List<ChatHistory> _chatHistories = [];
  bool _isLoading = true;

  // Mock data backup (if API fails)
  final List<ChatHistory> _mockChatHistories = [
    ChatHistory(
      id: '1',
      firstMessage: 'Hi, can you introduce your tas?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      isCurrent: false,
      messages: [
        {
          'content': 'Hi, can you introduce your tas?',
          'isUser': true,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 2)),
        },
        {
          'content':
              "Hello! I'm ByteQueens AI, your friendly and creative assistant. I'm here to help you with a wide range of topics, whether you need information, ideas, or just someone to chat with.",
          'isUser': false,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 2)),
          'modelName': 'GPT-4o Mini',
        },
      ],
    ),
    ChatHistory(
      id: '2',
      firstMessage: 'Tôi muốn thông tin về Việt Nam',
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      isCurrent: false,
      messages: [
        {
          'content': 'Tôi muốn thông tin về Việt Nam',
          'isUser': true,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 4)),
        },
        {
          'content':
              'Việt Nam là một quốc gia nằm ở Đông Nam Á với diện tích khoảng 331,212 km². Thủ đô là Hà Nội và thành phố lớn nhất là Thành phố Hồ Chí Minh. Dân số khoảng 98 triệu người.',
          'isUser': false,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 4)),
          'modelName': 'GPT-4o Mini',
        },
      ],
    ),
    ChatHistory(
      id: '3',
      firstMessage: 'Hi',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isCurrent: false,
      messages: [
        {
          'content': 'Hi',
          'isUser': true,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        },
        {
          'content': 'Hello! How can I help you today?',
          'isUser': false,
          'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
          'modelName': 'GPT-4o Mini',
        },
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentConversationId = widget.currentConversationId;
    _loadChatHistories();
  }

  Future<void> _loadChatHistories() async {
    // Check auth
    final token = _authService.getAccessToken();
    if (token == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to view chat history'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacementNamed(context, '/signin');
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // print('📱 Loading chat histories...');
      // print('   Token: ${token.isNotEmpty ? "Available (${token.substring(0, 10)}...)" : "Missing"}');

      // Load conversations from API
      final conversations = await _aiChatRepo.getConversationList(
        assistantId: AppConstants.defaultAssistantId,
        assistantModel: AppConstants.defaultAssistantModel,
        limit: 50,
      );

      // print('✅ Loaded ${conversations.items.length} conversations');

      if (mounted) {
        setState(() {
          _chatHistories = conversations.items.map((thread) {
            // Store assistantId in messages for later use
            final messages = thread.assistantId != null
                ? [
                    {'_assistantId': thread.assistantId},
                  ]
                : <Map<String, dynamic>>[];

            // Kiểm tra nếu đây là conversation hiện tại
            final isCurrent =
                _currentConversationId != null &&
                thread.id == _currentConversationId;

            return ChatHistory(
              id: thread.id,
              firstMessage: thread.title,
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                thread.createdAt * 1000,
              ),
              messages: messages, // Store assistantId for later
              isCurrent: isCurrent,
            );
          }).toList();

          // Tự động select conversation hiện tại nếu có
          if (_currentConversationId != null) {
            _selectedChatId = _currentConversationId;
          } else {
            _selectedChatId = null;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      // Keep error logging for debugging
      print('❌ Error loading chat histories:');
      print('   Error: $e');

      // Fallback to mock data on error
      if (mounted) {
        setState(() {
          _chatHistories = _mockChatHistories;
          // Don't select any item by default
          _selectedChatId = null;
          _isLoading = false;
        });

        // Show user-friendly error
        final errorMsg = _getFriendlyErrorMessage(e.toString());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                _loadChatHistories();
              },
            ),
          ),
        );
      }
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }

  String _getFriendlyErrorMessage(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('unauthorized') || errorLower.contains('401')) {
      return 'Please login again to view history';
    } else if (errorLower.contains('timeout')) {
      return 'Request timed out. Please try again';
    } else if (errorLower.contains('no internet') ||
        errorLower.contains('socket')) {
      return 'No internet connection. Please check your network';
    } else if (errorLower.contains('server error') ||
        errorLower.contains('500')) {
      return 'Server error. Please try again later';
    } else {
      return 'Failed to load chat history. Please try again';
    }
  }

  void _deleteChat(String chatId) {
    setState(() {
      _chatHistories.removeWhere((chat) => chat.id == chatId);
      if (_selectedChatId == chatId && _chatHistories.isNotEmpty) {
        _chatHistories[0].isCurrent = true;
        _selectedChatId = _chatHistories[0].id;
      }
    });
  }

  void _showDeleteDialog(String chatId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Are you sure you want to delete this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteChat(chatId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
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
            Icons.close,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chat History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatHistories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No chat history yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _chatHistories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final chat = _chatHistories[index];
                return _buildChatHistoryItem(chat, isDark);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Chat History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildChatHistoryItem(ChatHistory chat, bool isDark) {
    final isSelected = _selectedChatId == chat.id;

    return InkWell(
      onTap: () async {
        // Update selected chat
        setState(() {
          // Clear previous selection
          for (var c in _chatHistories) {
            c.isCurrent = false;
          }
          // Set current selection
          chat.isCurrent = true;
          _selectedChatId = chat.id;
          // Update current conversation ID
          _currentConversationId = chat.id;
        });

        // Load messages for this conversation
        try {
          setState(() {
            _isLoading = true;
          });

          // Get assistantId from conversation metadata if available
          String actualAssistantId = AppConstants.defaultAssistantId;
          if (chat.messages.isNotEmpty &&
              chat.messages[0].containsKey('_assistantId')) {
            actualAssistantId = chat.messages[0]['_assistantId'] as String;
          }

          // Use the actual assistant ID from conversation
          final history = await _aiChatRepo.getConversationHistory(
            conversationId: chat.id,
            assistantId: actualAssistantId,
            assistantModel: AppConstants.defaultAssistantModel,
            limit: 100, // Increase limit to get more history
          );

          // Convert ApiChatMessage to UI format
          // Each ApiChatMessage contains both query and answer for one exchange
          final messages = <Map<String, dynamic>>[];

          // Sort by timestamp ascending (oldest first) for proper display order
          final sortedItems = history.items.toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          for (var msg in sortedItems) {
            final timestamp = DateTime.fromMillisecondsSinceEpoch(
              msg.createdAt * 1000,
            );

            // Add user message (query) if exists
            if (msg.query.isNotEmpty) {
              messages.add({
                'content': msg.query,
                'isUser': true,
                'timestamp': timestamp,
              });
            }

            // Add AI response (answer) if exists - right after the query
            if (msg.answer.isNotEmpty) {
              // Get model name from message's assistant info
              String? modelName;
              String? modelId;

              if (msg.assistant != null) {
                // Use assistant info from this specific message
                final assistantId = AssistantId.fromString(msg.assistant!.id);
                modelName = assistantId.displayName;
                modelId = msg.assistant!.id;
              } else {
                // Fallback to conversation's assistant
                final assistantId = AssistantId.fromString(actualAssistantId);
                modelName = assistantId.displayName;
                modelId = actualAssistantId;
              }

              messages.add({
                'content': msg.answer,
                'isUser': false,
                'timestamp': timestamp,
                'modelName': modelName,
                'modelId': modelId,
                'messageId': 'm${msg.createdAt}',
                'files': msg.files,
              });
            }
          }

          setState(() {
            _isLoading = false;
          });

          // Get default model name for page title (use first message's model or fallback)
          String pageModelName = 'AI Chat';
          if (messages.isNotEmpty) {
            // Find first AI response to get model name
            final firstAiMsg = messages.firstWhere(
              (m) => m['isUser'] == false,
              orElse: () => <String, dynamic>{},
            );
            if (firstAiMsg.isNotEmpty && firstAiMsg['modelName'] != null) {
              pageModelName = firstAiMsg['modelName'] as String;
            }
          }

          // Navigate to chat page with history
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage.withHistory(
                  chatId: chat.id,
                  existingMessages: messages,
                  modelName: pageModelName,
                ),
              ),
            );
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });

          if (mounted) {
            // Show user-friendly error
            final errorMsg = _getFriendlyErrorMessage(e.toString());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
                backgroundColor: Colors.orange.shade700,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? AppTheme.primaryBlue.withOpacity(0.15)
                    : AppTheme.primaryBlue.withOpacity(0.1))
              : (isDark ? AppTheme.navyBlue : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : (isDark
                      ? AppTheme.mediumBlue.withOpacity(0.3)
                      : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (chat.isCurrent) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'current',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          chat.firstMessage,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getTimeAgo(chat.timestamp),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 20,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    // TODO: Edit chat title
                  },
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showDeleteDialog(chat.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
