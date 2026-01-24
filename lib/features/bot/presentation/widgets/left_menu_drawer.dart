import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/app.dart';
import 'package:bytequeens_adm/services/auth_service.dart';

class LeftMenuDrawer extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback? onToggle;

  const LeftMenuDrawer({Key? key, this.isExpanded = true, this.onToggle})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: isExpanded ? 240 : 56,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.navyBlue : const Color(0xFFF0F4F9),
        border: Border(
          right: BorderSide(
            color: isDark
                ? AppTheme.mediumBlue.withOpacity(0.3)
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo and toggle
          Padding(
            padding: EdgeInsets.all(isExpanded ? 16 : 8),
            child: isExpanded
                ? Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryBlue, AppTheme.mediumBlue],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'ByteQueens',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu_open, size: 20),
                        onPressed: onToggle,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryBlue, AppTheme.mediumBlue],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        icon: const Icon(Icons.menu, size: 20),
                        onPressed: onToggle,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 8),

          // Menu items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.chat,
                    label: 'Chat',
                    isSelected: true,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.smart_toy,
                    label: AppConstants.myBots,
                    onTap: () {
                      Navigator.pushNamed(context, AppConstants.botsListRoute);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.group,
                    label: AppConstants.myGroups,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppConstants.groupsListRoute,
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.brightness_6,
                    label: 'Theme Mode',
                    onTap: () {
                      _showThemeModeDialog(context);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.person,
                    label: AppConstants.profile,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Logout at bottom
          _buildMenuItem(
            context,
            icon: Icons.logout,
            label: AppConstants.logout,
            onTap: () {
              _showLogoutConfirmation(context);
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isExpanded ? 8 : 4,
          vertical: 2,
        ),
        padding: EdgeInsets.all(isExpanded ? 12 : 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? AppTheme.primaryBlue.withOpacity(0.2)
                    : AppTheme.primaryBlue.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: isExpanded
            ? Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? AppTheme.primaryBlue
                        : (isDark ? Colors.grey[400] : Colors.grey[700]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : (isDark ? Colors.grey[400] : Colors.grey[700]),
                ),
              ),
      ),
    );
  }

  void _showThemeModeDialog(BuildContext context) {
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

  void _showLogoutConfirmation(BuildContext context) {
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

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );

                final result = await AuthService().logout();

                if (context.mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      backgroundColor: result.success
                          ? Colors.green
                          : Colors.red,
                    ),
                  );

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppConstants.signInRoute,
                    (route) => false,
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(AppConstants.logout),
            ),
          ],
        );
      },
    );
  }
}
