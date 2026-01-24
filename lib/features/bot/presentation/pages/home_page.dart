import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/services/auth_service.dart';
import 'package:bytequeens_adm/services/bot_service.dart';
import 'package:bytequeens_adm/services/prompt_service.dart';
import 'package:bytequeens_adm/data/models/bot.dart';
import 'package:bytequeens_adm/data/models/prompt.dart';
import 'package:bytequeens_adm/app.dart';
import 'package:bytequeens_adm/features/bot/presentation/widgets/chat_input_section.dart';
import 'package:bytequeens_adm/features/bot/presentation/widgets/prompt_suggestion_overlay.dart';
import 'package:bytequeens_adm/features/bot/presentation/widgets/left_menu_drawer.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/chat_page.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/chat_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _messageController = TextEditingController();
  final _botService = BotService();
  final _promptService = PromptService();
  String _selectedModel = 'GPT-4o Mini';
  String _selectedModelId = 'gpt-4o-mini';
  List<Bot> _userBots = [];
  List<Prompt> _suggestedPrompts = [];
  bool _isMenuExpanded = true;
  bool _isLoadingPrompts = true;

  @override
  void initState() {
    super.initState();
    _loadUserBots();
    _loadSuggestedPrompts();
  }

  Future<void> _loadUserBots() async {
    try {
      final bots = await _botService.getAllBots();
      setState(() {
        _userBots = bots;
      });
    } catch (e) {
      // Handle error silently or show a snackbar
    }
  }

  Future<void> _loadSuggestedPrompts() async {
    try {
      final prompts = await _promptService.getPrompts(
        isPublic: true,
        limit: 5,
        offset: 0,
      );
      setState(() {
        _suggestedPrompts = prompts;
        _isLoadingPrompts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPrompts = false;
      });
      // Handle error silently
    }
  }

  void _handleModelChange(String modelId, String modelName) {
    setState(() {
      _selectedModelId = modelId;
      _selectedModel = modelName;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.navyBlue,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.white),
                title: const Text(
                  'Chat',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Already on home, so just close menu
                },
              ),
              ListTile(
                leading: const Icon(Icons.smart_toy, color: Colors.white),
                title: const Text(
                  AppConstants.myBots,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppConstants.botsListRoute);
                },
              ),
              ListTile(
                leading: const Icon(Icons.group, color: Colors.white),
                title: const Text(
                  AppConstants.myGroups,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppConstants.groupsListRoute);
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_6, color: Colors.white),
                title: const Text(
                  'Theme Mode',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showThemeModeDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text(
                  AppConstants.profile,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  AppConstants.logout,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutConfirmation();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeModeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme Mode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_auto),
                title: const Text('System Default'),
                onTap: () {
                  MyApp.of(context)?.setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('Light Mode'),
                onTap: () {
                  MyApp.of(context)?.setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                onTap: () {
                  MyApp.of(context)?.setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppConstants.logout),
          content: const Text(AppConstants.logoutConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(AppConstants.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                // Hiển thị loading
                // Lưu context trước khi async
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );

                // Gọi API logout
                final result = await AuthService().logout();

                // Đóng loading dialog
                navigator.pop();

                // Hiển thị kết quả
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(result.message),
                    backgroundColor: result.success ? Colors.green : Colors.red,
                  ),
                );

                // Chuyển về trang sign in
                navigator.pushNamedAndRemoveUntil(
                  AppConstants.signInRoute,
                  (route) => false,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(AppConstants.logout),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBlue : Colors.white,
      body: Row(
        children: [
          // Left menu for web
          if (isWeb)
            LeftMenuDrawer(
              isExpanded: _isMenuExpanded,
              onToggle: () {
                setState(() {
                  _isMenuExpanded = !_isMenuExpanded;
                });
              },
            ),

          // Main content
          Expanded(
            child: Column(
              children: [
                // AppBar only for mobile
                if (!isWeb)
                  AppBar(
                    backgroundColor: isDark ? AppTheme.navyBlue : Colors.white,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: isDark ? Colors.white : AppTheme.darkBlue,
                        ),
                        onPressed: _openMenu,
                      ),
                    ],
                  ),

                // Content with max width constraint
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: SafeArea(
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.all(isWeb ? 48 : 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '👋',
                                      style: TextStyle(fontSize: 32),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      AppConstants.greeting,
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : AppTheme.darkBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppConstants.personalAssistant,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppTheme.navyBlue
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            AppConstants.upgradePro,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Colors.white
                                                  : AppTheme.darkBlue,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          RichText(
                                            text: TextSpan(
                                              text:
                                                  AppConstants.orInviteFriends +
                                                  ' ',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                              ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      AppConstants.freePremium,
                                                  style: TextStyle(
                                                    color: AppTheme.primaryBlue,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                TextSpan(text: '.'),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {},
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppTheme.primaryBlue,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 14,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    AppConstants.startFreeTrial,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () {},
                                                  style: OutlinedButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 14,
                                                        ),
                                                    side: BorderSide(
                                                      color:
                                                          AppTheme.primaryBlue,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    AppConstants.inviteFriends,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppTheme.primaryBlue,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    InkWell(
                                      onTap: () {
                                        // TODO: Navigate to download page
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            const Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    AppConstants
                                                        .useOnAllPlatforms,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppTheme.darkBlue,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    AppConstants.downloadDesc,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            AppConstants.dontKnowPrompt,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              AppConstants.promptListRoute,
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                AppTheme.primaryBlue,
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

                                    // Dynamic prompt list from library
                                    _isLoadingPrompts
                                        ? const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(20.0),
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          )
                                        : _suggestedPrompts.isEmpty
                                        ? Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                20.0,
                                              ),
                                              child: Text(
                                                'No prompts available',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Column(
                                            children: _suggestedPrompts
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                                  final index = entry.key;
                                                  final prompt = entry.value;
                                                  return Column(
                                                    children: [
                                                      if (index > 0)
                                                        const SizedBox(
                                                          height: 12,
                                                        ),
                                                      _buildPromptCard(
                                                        prompt.title,
                                                        onTap: () =>
                                                            _handlePromptTap(
                                                              prompt,
                                                            ),
                                                      ),
                                                    ],
                                                  );
                                                })
                                                .toList(),
                                          ),
                                  ],
                                ),
                              ),
                            ),

                            // New Chat Input Section Widget with Prompt Suggestions
                            PromptSuggestionOverlay(
                              messageController: _messageController,
                              child: ChatInputSection(
                                messageController: _messageController,
                                selectedModel: _selectedModel,
                                freeMessagesRemaining: 45,
                                userBots: _userBots,
                                onModelChanged: _handleModelChange,
                                onSendMessage: () {
                                  // Handle send message
                                  if (_messageController.text
                                      .trim()
                                      .isNotEmpty) {
                                    final message = _messageController.text
                                        .trim();
                                    _messageController.clear();

                                    // Navigate to chat page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                          initialMessage: message,
                                          modelId: _selectedModelId,
                                          modelName: _selectedModel,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onCreateBot: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppConstants.botsListRoute,
                                  );
                                },
                                onHistoryTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ChatHistoryPage(),
                                    ),
                                  );
                                },
                                onNewChat: () {
                                  // Clear message input for new chat
                                  _messageController.clear();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptCard(String text, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.navyBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppTheme.mediumBlue.withOpacity(0.5)
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : AppTheme.darkBlue,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  void _handlePromptTap(Prompt prompt) {
    // Fill the message input with the prompt content
    _messageController.text = prompt.content;

    // Optionally navigate to chat with the prompt
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          initialMessage: prompt.content,
          modelId: _selectedModelId,
          modelName: _selectedModel,
        ),
      ),
    );
  }
}
