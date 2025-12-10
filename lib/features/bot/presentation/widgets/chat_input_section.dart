import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/data/models/bot.dart';
import 'package:bytequeens_adm/data/models/ai_model.dart';

/// Complete chat input section widget with:
/// - Top bar: Model selector + Create bot button | History icons
/// - Input bar: Icons + TextField + Send button
/// - Bottom bar: Free messages remaining
///
/// Supports dark/light mode and responsive design
class ChatInputSection extends StatefulWidget {
  final TextEditingController messageController;
  final VoidCallback? onSendMessage;
  final VoidCallback? onCreateBot;
  final VoidCallback? onHistoryTap;
  final VoidCallback? onNewChat;
  final String selectedModel;
  final int freeMessagesRemaining;
  final List<Bot> userBots;
  final Function(String modelId, String modelName)? onModelChanged;

  const ChatInputSection({
    Key? key,
    required this.messageController,
    this.onSendMessage,
    this.onCreateBot,
    this.onHistoryTap,
    this.onNewChat,
    this.selectedModel = 'GPT-4o Mini',
    this.freeMessagesRemaining = 45,
    this.userBots = const [],
    this.onModelChanged,
  }) : super(key: key);

  @override
  State<ChatInputSection> createState() => _ChatInputSectionState();
}

class _ChatInputSectionState extends State<ChatInputSection> {
  void _showModelSelector() {
    // Sync với AssistantId enum
    final baseModels = [
      {
        "id": "claude-3-5-sonnet-20240620",
        "name": "Claude 3.5 Sonnet",
        "model": "dify",
      },
      {
        "id": "claude-3-haiku-20240307",
        "name": "Claude 3 Haiku",
        "model": "dify",
      },
      {
        "id": "gemini-1.5-flash-latest",
        "name": "Gemini 1.5 Flash",
        "model": "dify",
      },
      {
        "id": "gemini-1.5-pro-latest",
        "name": "Gemini 1.5 Pro",
        "model": "dify",
      },
      {"id": "gpt-4o", "name": "GPT-4o", "model": "dify"},
      {"id": "gpt-4o-mini", "name": "GPT-4o Mini", "model": "dify"},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.navyBlue : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Select Model',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Your Bots section
                        if (widget.userBots.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Text(
                              'Your Bots',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                          ...widget.userBots.map(
                            (bot) => ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryBlue
                                    .withOpacity(0.2),
                                child: const Icon(
                                  Icons.smart_toy,
                                  color: AppTheme.primaryBlue,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                bot.name,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                bot.model.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                              trailing: widget.selectedModel == bot.name
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: AppTheme.primaryBlue,
                                    )
                                  : null,
                              onTap: () {
                                widget.onModelChanged?.call(bot.id, bot.name);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const Divider(height: 1),
                        ],

                        // Base Models section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'Base Models',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        ...baseModels.map(
                          (model) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryBlue.withOpacity(
                                0.1,
                              ),
                              child: const Icon(
                                Icons.psychology_outlined,
                                color: AppTheme.primaryBlue,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              model['name'] as String,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              model['model'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            trailing: widget.selectedModel == model['name']
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppTheme.primaryBlue,
                                  )
                                : null,
                            onTap: () {
                              widget.onModelChanged?.call(
                                model['id'] as String,
                                model['name'] as String,
                              );
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.navyBlue : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar: Model selector + Create bot | History icons
            _buildTopBar(isDark, isCompact),

            // Input Bar
            _buildInputBar(isDark, isCompact),

            // Bottom Bar: Free messages
            _buildBottomBar(isDark),
          ],
        ),
      ),
    );
  }

  /// Top bar with model selector and actions
  Widget _buildTopBar(bool isDark, bool isCompact) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Left side: Model selector + Create bot button
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Model selector button
                Tooltip(
                  message: 'Select AI Model',
                  child: InkWell(
                    onTap: _showModelSelector,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isCompact ? 120 : 160,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.mediumBlue.withOpacity(0.4)
                            : AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.psychology_outlined,
                            size: 18,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.selectedModel,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppTheme.primaryBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Create bot button
                Tooltip(
                  message: 'Create New Bot',
                  child: InkWell(
                    onTap: widget.onCreateBot,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                          const Icon(Icons.smart_toy, size: 16, color: Colors.white), // icon bot
                          if (!isCompact) ...[
                            const SizedBox(width: 4),
                            const Text(
                              'Create Bot',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right side: History icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: 'Chat History',
                child: IconButton(
                  icon: const Icon(Icons.history, size: 20),
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  onPressed: widget.onHistoryTap,
                ),
              ),
              Tooltip(
                message: 'New Chat',
                child: IconButton(
                  icon: const Icon(Icons.add_circle, size: 22),
                  color: AppTheme.primaryBlue,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  onPressed: widget.onNewChat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Input bar with icons, textfield and send button
  Widget _buildInputBar(bool isDark, bool isCompact) {
    final iconColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final bgColor = isDark ? const Color(0xFF2A3B4C) : const Color(0xFFF5F5F5);
    final borderColor = isDark
        ? const Color(0xFF3E5269)
        : const Color(0xFFE0E0E0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main input row
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                // Attachment icon
                Tooltip(
                  message: 'Attach File',
                  child: IconButton(
                    icon: Icon(Icons.attach_file, size: 20, color: iconColor),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    onPressed: () {},
                  ),
                ),

                // TextField
                Expanded(
                  child: TextField(
                    controller: widget.messageController,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: isCompact
                          ? "Ask me anything..."
                          : "Ask me anything, press '/' for prompts...",
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                  ),
                ),

                // Send button
                Tooltip(
                  message: 'Send Message',
                  child: IconButton(
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: widget.onSendMessage,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          // // Action icons row (below input on compact mode)
          // if (isCompact) ...[
          //   const SizedBox(height: 8),
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       _buildActionIcon(Icons.code, iconColor),
          //       Container(
          //         width: 1,
          //         height: 16,
          //         margin: const EdgeInsets.symmetric(horizontal: 4),
          //         color: borderColor,
          //       ),
          //       _buildActionIcon(Icons.language, iconColor),
          //       _buildActionIcon(Icons.lightbulb_outline, iconColor),
          //       _buildActionIcon(Icons.palette_outlined, iconColor),
          //       _buildActionIcon(Icons.table_chart_outlined, iconColor),
          //     ],
          //   ),
          // ] else ...[
          //   // On larger screens, show icons inline
          //   const SizedBox(height: 4),
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       _buildActionIcon(Icons.code, iconColor),
          //       Container(
          //         width: 1,
          //         height: 16,
          //         margin: const EdgeInsets.symmetric(horizontal: 4),
          //         color: borderColor,
          //       ),
          //       _buildActionIcon(Icons.language, iconColor),
          //       _buildActionIcon(Icons.lightbulb_outline, iconColor),
          //       _buildActionIcon(Icons.palette_outlined, iconColor),
          //       _buildActionIcon(Icons.table_chart_outlined, iconColor),
          //     ],
          //   ),
          // ],
        ],
      ),
    );
  }

  /// Bottom bar showing free messages remaining
  Widget _buildBottomBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 16,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.freeMessagesRemaining}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Upgrade',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              decoration: TextDecoration.underline,
            ),
          ),
          Icon(
            Icons.arrow_forward,
            size: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ],
      ),
    );
  }
}
