import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AddKnowledgeUnitDialog extends StatelessWidget {
  const AddKnowledgeUnitDialog({super.key});

  static const primaryBlue = Color(0xFF2196F3);
  static const textDark = Color(0xFF1A1D2E);
  static const textGray = Color(0xFF6B7280);
  static const cardWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Knowledge Sources',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark, color: textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Source Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildSourceOption(
                    context,
                    icon: CupertinoIcons.doc_text,
                    iconColor: const Color(0xFF3B82F6),
                    title: 'Local files',
                    subtitle: 'Upload PDFs, docs, and more',
                    source: 'local_files',
                  ),
                  const SizedBox(height: 12),
                  _buildSourceOption(
                    context,
                    icon: CupertinoIcons.globe,
                    iconColor: const Color(0xFF06B6D4),
                    title: 'Website',
                    subtitle: 'Sync any website content instantly',
                    source: 'website',
                  ),
                  const SizedBox(height: 12),
                  _buildSourceOption(
                    context,
                    iconWidget: Image.asset(
                      'assets/icons/google_drive.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (_, __, ___) => const Icon(
                        CupertinoIcons.cloud,
                        color: Color(0xFF34A853),
                        size: 28,
                      ),
                    ),
                    title: 'Google Drive',
                    subtitle: 'Access your Drive files seamlessly',
                    source: 'google_drive',
                  ),
                  const SizedBox(height: 12),
                  _buildSourceOption(
                    context,
                    iconWidget: Image.asset(
                      'assets/icons/slack.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (_, __, ___) => const Icon(
                        CupertinoIcons.chat_bubble_2,
                        color: Color(0xFFE01E5A),
                        size: 28,
                      ),
                    ),
                    title: 'Slack',
                    subtitle: 'Connect your team conversations',
                    source: 'slack',
                  ),
                  const SizedBox(height: 12),
                  _buildSourceOption(
                    context,
                    iconWidget: Image.asset(
                      'assets/icons/confluence.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (_, __, ___) => const Icon(
                        CupertinoIcons.folder,
                        color: Color(0xFF0052CC),
                        size: 28,
                      ),
                    ),
                    title: 'Confluence',
                    subtitle: 'Import your knowledge base',
                    source: 'confluence',
                  ),
                  const SizedBox(height: 12),
                  _buildSourceOption(
                    context,
                    iconWidget: Image.asset(
                      'assets/icons/notion.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (_, __, ___) => const Icon(
                        CupertinoIcons.square_on_square,
                        color: textDark,
                        size: 28,
                      ),
                    ),
                    title: 'Notion',
                    subtitle: 'Sync your Notion workspace',
                    source: 'notion',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    IconData? icon,
    Color? iconColor,
    Widget? iconWidget,
    required String title,
    required String subtitle,
    required String source,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.pop(context, source),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color:
                      iconColor?.withOpacity(0.1) ??
                      primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child:
                      iconWidget ??
                      Icon(
                        icon ?? CupertinoIcons.question,
                        color: iconColor ?? primaryBlue,
                        size: 28,
                      ),
                ),
              ),
              const SizedBox(width: 16),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: textGray.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              const Icon(
                CupertinoIcons.chevron_right,
                color: textGray,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
