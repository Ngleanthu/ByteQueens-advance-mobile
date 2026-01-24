import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bytequeens_adm/data/models/prompt.dart';

class PromptInputDialog extends StatefulWidget {
  final Prompt prompt;
  final Function(String finalContent) onSend;

  const PromptInputDialog({
    super.key,
    required this.prompt,
    required this.onSend,
  });

  @override
  State<PromptInputDialog> createState() => _PromptInputDialogState();
}

class _PromptInputDialogState extends State<PromptInputDialog> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  List<String> _placeholders = [];

  static const primaryBlue = Color(0xFF2196F3);
  static const lightBlue = Color(0xFF4A90E2);
  static const backgroundWhite = Color(0xFFFAFBFF);
  static const cardWhite = Colors.white;
  static const textDark = Color(0xFF1A1D2E);
  static const textGray = Color(0xFF6B7280);
  static const borderColor = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _extractPlaceholders();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _extractPlaceholders() {
    final regex = RegExp(r'\[([^\]]+)\]');
    final matches = regex.allMatches(widget.prompt.content);

    _placeholders = matches.map((m) => m.group(1)!).toList();

    // Create controllers for each unique placeholder
    for (var placeholder in _placeholders.toSet()) {
      _controllers[placeholder] = TextEditingController();
      _focusNodes[placeholder] = FocusNode();
    }

    // Auto focus first input
    if (_focusNodes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes.values.first.requestFocus();
      });
    }
  }

  String _buildFinalContent() {
    String result = widget.prompt.content;

    _controllers.forEach((placeholder, controller) {
      final value = controller.text.trim();
      if (value.isNotEmpty) {
        result = result.replaceAll('[$placeholder]', value);
      }
    });

    return result;
  }

  bool _canSend() {
    return _controllers.values.every(
      (controller) => controller.text.trim().isNotEmpty,
    );
  }

  void _handleSend() {
    if (!_canSend()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill in all fields"),
          backgroundColor: Colors.orange.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final finalContent = _buildFinalContent();
    Navigator.pop(context);
    widget.onSend(finalContent);
  }

  Widget _buildInputField(String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.square_pencil,
                size: 16,
                color: primaryBlue.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                placeholder,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: backgroundWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNodes[placeholder]!.hasFocus
                  ? primaryBlue
                  : borderColor,
              width: _focusNodes[placeholder]!.hasFocus ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controllers[placeholder],
            focusNode: _focusNodes[placeholder],
            style: const TextStyle(fontSize: 15, color: textDark, height: 1.4),
            decoration: InputDecoration(
              hintText: 'Enter $placeholder...',
              hintStyle: TextStyle(
                color: textGray.withOpacity(0.6),
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryBlue.withOpacity(0.05),
                    lightBlue.withOpacity(0.02),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryBlue, lightBlue],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.sparkles,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.prompt.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.prompt.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.prompt.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: textGray.withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Prompt content preview
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.doc_text,
                                size: 16,
                                color: textGray.withOpacity(0.7),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Prompt Template',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textGray.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.prompt.content,
                            style: const TextStyle(
                              fontSize: 14,
                              color: textDark,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_placeholders.isNotEmpty) ...[
                      const SizedBox(height: 24),

                      // Input fields for placeholders
                      ...(_placeholders.toSet().map((placeholder) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildInputField(placeholder),
                        );
                      }).toList()),
                    ],
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: backgroundWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textGray,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _canSend() ? _handleSend : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: _canSend()
                              ? const LinearGradient(
                                  colors: [primaryBlue, lightBlue],
                                )
                              : null,
                          color: _canSend() ? null : textGray.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _canSend()
                              ? [
                                  BoxShadow(
                                    color: primaryBlue.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.paperplane_fill,
                              color: _canSend()
                                  ? Colors.white
                                  : textGray.withOpacity(0.5),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Send Message",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _canSend()
                                    ? Colors.white
                                    : textGray.withOpacity(0.5),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
