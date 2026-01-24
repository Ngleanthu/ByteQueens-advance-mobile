import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FilterTabsWidget extends StatelessWidget {
  final bool showPublicPrompts;
  final VoidCallback onPublicTap;
  final VoidCallback onMyPromptsTap;

  const FilterTabsWidget({
    super.key,
    required this.showPublicPrompts,
    required this.onPublicTap,
    required this.onMyPromptsTap,
  });

  static const primaryBlue = Color(0xFF2196F3);
  static const lightBlue = Color(0xFF4A90E2);
  static const backgroundWhite = Color(0xFFFAFBFF);
  static const textDark = Color(0xFF1A1D2E);
  static const textGray = Color(0xFF6B7280);
  static const borderColor = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              label: 'Public Prompts',
              selected: showPublicPrompts,
              onTap: onPublicTap,
            ),
          ),
          Expanded(
            child: _buildTab(
              label: 'My Prompts',
              selected: !showPublicPrompts,
              onTap: onMyPromptsTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(colors: [primaryBlue, lightBlue])
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? Colors.white : textGray,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
