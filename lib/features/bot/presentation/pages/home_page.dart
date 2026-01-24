import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/services/auth_service.dart';
import 'package:bytequeens_adm/services/bot_service.dart';
import 'package:bytequeens_adm/services/prompt_service.dart';
import 'package:bytequeens_adm/services/waitlist_service.dart';
import 'package:bytequeens_adm/services/calendar_booking_service.dart';
import 'package:bytequeens_adm/services/google_drive_upload_service.dart';
import 'package:bytequeens_adm/services/subscription_service.dart';
import 'package:bytequeens_adm/services/ad_service.dart';
import 'package:bytequeens_adm/data/models/subscription_models.dart';
import 'package:bytequeens_adm/data/models/bot.dart';
import 'package:bytequeens_adm/data/models/prompt.dart';
import 'package:bytequeens_adm/app.dart';
import 'package:bytequeens_adm/features/bot/presentation/widgets/chat_input_section.dart';
import 'package:bytequeens_adm/features/bot/presentation/widgets/prompt_suggestion_overlay.dart';
import 'package:bytequeens_adm/features/bot/presentation/widgets/calendar_booking_dialog.dart';
import 'package:bytequeens_adm/features/bot/presentation/widgets/drive_upload_dialog.dart';
import 'package:bytequeens_adm/features/bot/presentation/widgets/left_menu_drawer.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/chat_page.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/chat_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _messageController = TextEditingController();
  final _botService = BotService();
  final _promptService = PromptService();
  final _waitlistService = WaitlistService();
  final _calendarService = CalendarBookingService();
  final _driveUploadService = GoogleDriveUploadService();
  final _subscriptionService = SubscriptionService();
  String _selectedModel = 'GPT-4o Mini';
  String _selectedModelId = 'gpt-4o-mini';
  List<Bot> _userBots = [];
  List<Prompt> _suggestedPrompts = [];
  bool _isMenuExpanded = true;
  bool _isLoadingPrompts = true;
  TokenUsage? _tokenUsage;
  SubscriptionPlan? _subscriptionPlan;
  bool _isLoadingSubscription = true;

  @override
  void initState() {
    super.initState();
    _loadUserBots();
    _loadSuggestedPrompts();
    _loadSubscriptionInfo();
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

  Future<void> _loadSubscriptionInfo() async {
    try {
      final tokenUsage = await _subscriptionService.getTokenUsage();
      final plan = await _subscriptionService.getSubscriptionPlan();

      if (mounted) {
        setState(() {
          _tokenUsage = tokenUsage;
          _subscriptionPlan = plan;
          _isLoadingSubscription = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSubscription = false;
        });
      }
    }
  }

  void _handleModelChange(String modelId, String modelName) {
    setState(() {
      _selectedModelId = modelId;
      _selectedModel = modelName;
    });
  }

  Future<void> _handleJoinWaitlist() async {
    final userEmail = AuthService().getCurrentUserEmail();
    if (userEmail == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to join the waitlist'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
        ),
      ),
    );

    try {
      final response = await _waitlistService.addToWaitlist(email: userEmail);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: response.success
                ? SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again later.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleBookCalendar() {
    showDialog(
      context: context,
      builder: (context) => CalendarBookingDialog(
        onConfirm: (title, description, dateTime, duration) async {
          _createCalendarEvent(title, description, dateTime, duration);
        },
      ),
    );
  }

  Future<void> _createCalendarEvent(
    String title,
    String description,
    DateTime dateTime,
    int duration,
  ) async {
    final userEmail = AuthService().getCurrentUserEmail();
    if (userEmail == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to create calendar event'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
        ),
      ),
    );

    try {
      final response = await _calendarService.createEvent(
        email: userEmail,
        title: title,
        description: description,
        startDateTime: dateTime,
        durationMinutes: duration,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: response.success
                ? SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again later.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleUploadToDrive() {
    showDialog(
      context: context,
      builder: (context) => DriveUploadDialog(
        onConfirm: (file, folderName) async {
          _uploadFileToDrive(file, folderName);
        },
      ),
    );
  }

  Future<void> _uploadFileToDrive(File file, String? folderName) async {
    final userEmail = AuthService().getCurrentUserEmail();
    if (userEmail == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to upload files'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ),
    );

    try {
      final response = await _driveUploadService.uploadFile(
        email: userEmail,
        file: file,
        folderName: folderName,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: response.success
                ? SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again later.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
                leading: const Icon(Icons.email, color: Colors.white),
                title: const Text(
                  'Create Email',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppConstants.createEmailRoute);
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

                                    // Upgrade to Pro Section - Only show for Free users
                                    if (_tokenUsage?.isPro != true)
                                      Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppTheme.primaryBlue.withOpacity(0.1),
                                              AppTheme.primaryBlue.withOpacity(0.05),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: AppTheme.primaryBlue.withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.workspace_premium,
                                                color: AppTheme.primaryBlue,
                                                size: 28,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Jarvis Pro',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryBlue,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            AppConstants.upgradePro,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Colors.white
                                                  : AppTheme.darkBlue,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          // Pro Benefits
                                          _buildProBenefit(
                                            Icons.all_inclusive,
                                            'Unlimited tokens',
                                            isDark,
                                          ),
                                          const SizedBox(height: 12),
                                          _buildProBenefit(
                                            Icons.flash_on,
                                            'Priority access to new features',
                                            isDark,
                                          ),
                                          const SizedBox(height: 12),
                                          _buildProBenefit(
                                            Icons.support_agent,
                                            'Premium support',
                                            isDark,
                                          ),
                                          const SizedBox(height: 24),
                                          // Show current plan if loaded
                                          if (!_isLoadingSubscription && _subscriptionPlan != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _subscriptionPlan!.isPro
                                                    ? Colors.green.withOpacity(0.1)
                                                    : Colors.orange.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                _subscriptionPlan!.isPro
                                                    ? '✓ You have Pro Plan'
                                                    : 'Current: ${_subscriptionPlan!.name} Plan',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: _subscriptionPlan!.isPro
                                                      ? Colors.green[700]
                                                      : Colors.orange[700],
                                                ),
                                              ),
                                            ),
                                          if (!_isLoadingSubscription && _subscriptionPlan != null)
                                            const SizedBox(height: 16),
                                          // Start Free Trial Button
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: _subscriptionPlan?.isPro == true
                                                  ? null
                                                  : () async {
                                                      // Navigate to pricing page and reload when returned
                                                      await Navigator.pushNamed(
                                                        context,
                                                        AppConstants.pricingRoute,
                                                      );
                                                      // Reload subscription info after returning
                                                      _loadSubscriptionInfo();
                                                    },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.primaryBlue,
                                                padding: const EdgeInsets.symmetric(
                                                  vertical: 16,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                elevation: 2,
                                              ),
                                              child: Text(
                                                _subscriptionPlan?.isPro == true
                                                    ? 'You\'re on Pro ✓'
                                                    : AppConstants.startFreeTrial,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Waitlist Banner
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFFF3E0),
                                            Color(0xFFFFE0B2),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            AppConstants.waitlistBannerTitle,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFE65100),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            AppConstants
                                                .waitlistBannerDescription,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6D4C41),
                                              height: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: _handleJoinWaitlist,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFFFF6F00,
                                                ),
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                elevation: 4,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(
                                                    Icons.email_outlined,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    AppConstants.joinWaitlist,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Calendar Booking Banner
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFE3F2FD),
                                            Color(0xFFBBDEFB),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryBlue
                                                .withOpacity(0.2),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            AppConstants.calendarBannerTitle,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0D47A1),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            AppConstants
                                                .calendarBannerDescription,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF1565C0),
                                              height: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: _handleBookCalendar,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppTheme.primaryBlue,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                elevation: 4,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    AppConstants.bookCalendar,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Google Drive Upload Banner
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFE8F5E9),
                                            Color(0xFFC8E6C9),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            AppConstants.driveUploadBannerTitle,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1B5E20),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            AppConstants
                                                .driveUploadBannerDescription,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF2E7D32),
                                              height: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: _handleUploadToDrive,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                elevation: 4,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(
                                                    Icons.cloud_upload,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    AppConstants.uploadToDrive,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
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

                            // Banner Ad for Free users
                            if (_tokenUsage?.isPro != true)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: AdBannerWidget(
                                  onAdLoaded: () => print('✅ Banner ad loaded'),
                                  onAdFailedToLoad: (error) =>
                                      print('❌ Banner ad failed: $error'),
                                ),
                              ),

                            // New Chat Input Section Widget with Prompt Suggestions
                            PromptSuggestionOverlay(
                              messageController: _messageController,
                              child: ChatInputSection(
                                messageController: _messageController,
                                selectedModel: _selectedModel,
                                tokenUsage: _tokenUsage,
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
                                onImageUpload: () {
                                  // Navigate to chat page to handle image upload
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        modelId: _selectedModelId,
                                        modelName: _selectedModel,
                                        shouldPickImage:
                                            true, // Trigger image picker
                                      ),
                                    ),
                                  );
                                },
                                onCameraCapture: () {
                                  // Navigate to chat page to handle camera capture
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        modelId: _selectedModelId,
                                        modelName: _selectedModel,
                                        shouldOpenCamera:
                                            true, // Trigger camera
                                      ),
                                    ),
                                  );
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

  Widget _buildProBenefit(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppTheme.darkBlue,
            ),
          ),
        ),
        Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 20,
        ),
      ],
    );
  }
}
