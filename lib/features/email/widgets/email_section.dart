// lib/widgets/email_section.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EmailSection extends StatelessWidget {
  final String title;
  final Widget child;

  const EmailSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                letterSpacing: 0.3,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
