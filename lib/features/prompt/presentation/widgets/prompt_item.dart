import 'package:flutter/material.dart';
import '../../../../data/models/prompt.dart';

class PromptItem extends StatelessWidget {
  final Prompt prompt;
  final VoidCallback onToggleFavorite;
  final VoidCallback onPreview;
  final VoidCallback onUse;

  const PromptItem({
    super.key,
    required this.prompt,
    required this.onToggleFavorite,
    required this.onPreview,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? Colors.grey[850] : Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    prompt.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    prompt.isFavorite ? Icons.star : Icons.star_border,
                  ),
                  color: prompt.isFavorite
                      ? Colors.amber
                      : (isDark ? Colors.grey[400] : Colors.grey),
                  onPressed: onToggleFavorite,
                ),
                IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: isDark ? Colors.grey[400] : Colors.grey,
                  ),
                  onPressed: onPreview,
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              prompt.description?.isNotEmpty == true
                  ? prompt.description!
                  : 'No description available.',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey.shade700,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
