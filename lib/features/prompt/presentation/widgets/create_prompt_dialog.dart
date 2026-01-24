import 'package:flutter/material.dart';
import '../../../../services/prompt_service.dart';
import '../../../../data/models/prompt.dart';

class CreatePromptDialog extends StatefulWidget {
  const CreatePromptDialog({Key? key}) : super(key: key);

  @override
  State<CreatePromptDialog> createState() => _CreatePromptDialogState();
}

class _CreatePromptDialogState extends State<CreatePromptDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title & content are required")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final Prompt newPrompt = await PromptService().createPrompt(
        title: title,
        content: content,
        description: description,
        isPublic: false, // << ALWAYS false
      );

      if (mounted) Navigator.pop(context, newPrompt);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed: $e")));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Create New Prompt",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // TITLE
              Text(
                "Title",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: "Ex: Email template",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 18),

              // CONTENT
              Text(
                "Content",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Write your prompt here. Use [placeholder] format.",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Use brackets [ ] to mark inputs.\nVí dụ: “Write an email to [name] about [topic]”.",
                style: TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),

              const SizedBox(height: 18),

              // DESCRIPTION
              Text(
                "Description (optional)",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Short description to explain this prompt",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // ACTION BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleCreate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Create"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
