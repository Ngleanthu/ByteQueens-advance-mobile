import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            CupertinoIcons.search,
            color: textGray.withOpacity(0.6),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 15,
                color: textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Search prompts...',
                hintStyle: TextStyle(
                  color: textGray.withOpacity(0.5),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller.text.isNotEmpty) ...[
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onClear,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: textGray.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.xmark,
                  color: textGray.withOpacity(0.6),
                  size: 12,
                ),
              ), minimumSize: Size(0, 0),
            ),
            const SizedBox(width: 12),
          ] else
            const SizedBox(width: 12),
        ],
      ),
    );
  }
}