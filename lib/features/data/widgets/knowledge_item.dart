import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../data/models/knowledge_base.dart';

class KnowledgeItem extends StatelessWidget {
  final KnowledgeBase knowledge;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool?
  isSelected; // null = not in selection mode, true/false = selected state

  const KnowledgeItem({
    super.key,
    required this.knowledge,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.isSelected,
  });

  static const primaryBlue = Color(0xFF2196F3);
  static const lightBlue = Color(0xFF4A90E2);
  static const backgroundWhite = Color(0xFFFAFBFF);
  static const cardWhite = Colors.white;
  static const textDark = Color(0xFF1A1D2E);
  static const textGray = Color(0xFF6B7280);
  static const borderColor = Color(0xFFE5E7EB);
  static const greenColor = Color(0xFF10B981);
  static const purpleColor = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryBlue, lightBlue],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.layers_alt_fill,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        knowledge.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        knowledge.description.isEmpty
                            ? 'No description'
                            : knowledge.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: knowledge.description.isEmpty
                              ? textGray.withOpacity(0.5)
                              : textGray,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStatChip(
                            '${knowledge.unitCount} units',
                            greenColor,
                          ),
                          const SizedBox(width: 8),
                          _buildStatChip(knowledge.formattedSize, purpleColor),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions or Checkbox
                if (isSelected != null)
                  // Selection mode - show checkbox
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected! ? primaryBlue : Colors.transparent,
                      border: Border.all(
                        color: isSelected! ? primaryBlue : borderColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isSelected!
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  )
                else
                  // Normal mode - show actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null) ...[
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.pencil,
                            size: 20,
                            color: textGray,
                          ),
                          onPressed: onEdit,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (onDelete != null) ...[
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.trash,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                      ],
                      const Icon(
                        CupertinoIcons.chevron_right,
                        size: 20,
                        color: textGray,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
