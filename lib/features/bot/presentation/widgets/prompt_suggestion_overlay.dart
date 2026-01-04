import 'package:flutter/material.dart';
import 'package:bytequeens_adm/data/models/prompt.dart';
import 'package:bytequeens_adm/services/prompt_service.dart';

/// Widget wrapper that adds prompt suggestion overlay to any TextField
/// Usage: Wrap your input widget with PromptSuggestionOverlay
class PromptSuggestionOverlay extends StatefulWidget {
  final Widget child;
  final TextEditingController messageController;
  final Function(String content)? onPromptSelected;

  const PromptSuggestionOverlay({
    super.key,
    required this.child,
    required this.messageController,
    this.onPromptSelected,
  });

  @override
  State<PromptSuggestionOverlay> createState() =>
      _PromptSuggestionOverlayState();
}

class _PromptSuggestionOverlayState extends State<PromptSuggestionOverlay> {
  final _promptService = PromptService();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  List<Prompt> _availablePrompts = [];
  List<Prompt> _filteredPrompts = [];
  bool _showPromptSuggestions = false;

  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(_onTextChanged);
    _loadPrompts();
  }

  @override
  void dispose() {
    widget.messageController.removeListener(_onTextChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.messageController.text;
    if (text.startsWith('/') && text.length > 1) {
      final query = text.substring(1).toLowerCase();
      setState(() {
        _filteredPrompts = _availablePrompts
            .where(
              (p) =>
                  p.title.toLowerCase().contains(query) ||
                  (p.description?.toLowerCase().contains(query) ?? false),
            )
            .toList();
        _showPromptSuggestions = _filteredPrompts.isNotEmpty;
      });
      if (_showPromptSuggestions) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    } else if (text.startsWith('/') && text.length == 1) {
      setState(() {
        _filteredPrompts = _availablePrompts;
        _showPromptSuggestions = _availablePrompts.isNotEmpty;
      });
      if (_showPromptSuggestions) {
        _showOverlay();
      }
    } else {
      _removeOverlay();
      setState(() {
        _showPromptSuggestions = false;
      });
    }
  }

  Future<void> _loadPrompts() async {
    try {
      final prompts = await _promptService.getPrompts();
      if (mounted) {
        setState(() {
          _availablePrompts = prompts;
        });
      }
    } catch (e) {
      // Silently fail - feature is optional
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  List<Prompt> get _publicPrompts =>
      _filteredPrompts.where((p) => p.isPublic).toList();
  List<Prompt> get _myPrompts =>
      _filteredPrompts.where((p) => !p.isPublic && p.userId != null).toList();

  OverlayEntry _createOverlayEntry() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 1200 ? 1200.0 : screenWidth;

    return OverlayEntry(
      builder: (context) => Positioned(
        left: (screenWidth - maxWidth) / 2 + 16,
        right: (screenWidth - maxWidth) / 2 + 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 140,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Colors.grey[850] : Colors.white,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // My Prompts Section
                if (_myPrompts.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'My Prompts',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._myPrompts.map(
                    (prompt) => _buildPromptItem(prompt, isDark),
                  ),
                  if (_publicPrompts.isNotEmpty)
                    Divider(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      height: 16,
                      thickness: 1,
                    ),
                ],

                // Public Prompts Section
                if (_publicPrompts.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.public,
                          size: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Public Prompts',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._publicPrompts.map(
                    (prompt) => _buildPromptItem(prompt, isDark),
                  ),
                ],

                // Empty state
                if (_myPrompts.isEmpty && _publicPrompts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No prompts found',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromptItem(Prompt prompt, bool isDark) {
    return ListTile(
      dense: true,
      leading: Icon(
        Icons.lightbulb_outline,
        size: 20,
        color: isDark ? Colors.blue[300] : Colors.blue,
      ),
      title: Text(
        prompt.title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        prompt.description ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      onTap: () => _selectPrompt(prompt),
    );
  }

  void _selectPrompt(Prompt prompt) {
    widget.messageController.text = prompt.content;
    _removeOverlay();
    setState(() {
      _showPromptSuggestions = false;
    });

    // Callback if provided
    widget.onPromptSelected?.call(prompt.content);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(link: _layerLink, child: widget.child);
  }
}
