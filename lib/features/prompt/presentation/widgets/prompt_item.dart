import 'package:flutter/material.dart';
import '../../../../data/models/prompt.dart';

class PromptItem extends StatelessWidget {
  final Prompt prompt;
  final VoidCallback onToggleFavorite;
  final VoidCallback onPreview;
  final VoidCallback onUse;

  const PromptItem({
    Key? key,
    required this.prompt,
    required this.onToggleFavorite,
    required this.onPreview,
    required this.onUse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    prompt.isFavorite ? Icons.star : Icons.star_border,
                  ),
                  color: prompt.isFavorite ? Colors.amber : Colors.grey,
                  onPressed: onToggleFavorite,
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.grey),
                  onPressed: onPreview,
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              prompt.description?.isNotEmpty == true
                  ? prompt.description!
                  : 'No description available.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
