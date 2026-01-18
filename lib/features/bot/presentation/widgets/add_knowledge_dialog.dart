import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/data/models/knowledge_source.dart';

/// Dialog for adding knowledge sources to a bot
class AddKnowledgeDialog extends StatefulWidget {
  final List<KnowledgeSource> availableKnowledges;
  final List<KnowledgeSource> currentKnowledges;

  const AddKnowledgeDialog({
    super.key,
    required this.availableKnowledges,
    required this.currentKnowledges,
  });

  @override
  State<AddKnowledgeDialog> createState() => _AddKnowledgeDialogState();
}

class _AddKnowledgeDialogState extends State<AddKnowledgeDialog> {
  final List<KnowledgeSource> _selectedKnowledges = [];
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filter out already added knowledges
    final currentIds = widget.currentKnowledges.map((k) => k.id).toSet();
    final available = widget.availableKnowledges
        .where((k) => !currentIds.contains(k.id))
        .toList();

    // Apply search filter
    final filtered = available.where((k) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return k.name.toLowerCase().contains(query) ||
          k.getTypeName().toLowerCase().contains(query);
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.library_add, color: AppTheme.primaryBlue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Add Knowledge Sources',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.darkBlue),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search knowledge sources...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),

            // Empty state with action button
            if (filtered.isEmpty && _searchQuery.isEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.library_books_outlined,
                      size: 48,
                      color: AppTheme.primaryBlue.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No Knowledges Available',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Create a knowledge in Knowledge Management first, then come back here to import it to your bot',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        // Parent will handle navigation
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Go to Knowledge Management'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Selection info
            if (_selectedKnowledges.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedKnowledges.length} selected',
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          setState(() => _selectedKnowledges.clear()),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Knowledge list
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final knowledge = filtered[index];
                        final isSelected = _selectedKnowledges.contains(
                          knowledge,
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedKnowledges.add(knowledge);
                                } else {
                                  _selectedKnowledges.remove(knowledge);
                                }
                              });
                            },
                            title: Text(
                              knowledge.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(knowledge.getTypeName()),
                            secondary: Icon(
                              _getKnowledgeIcon(knowledge.type),
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedKnowledges.isEmpty
                          ? null
                          : () => Navigator.pop(context, _selectedKnowledges),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Add (${_selectedKnowledges.length})'),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No knowledge sources available'
                : 'No results found',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Create knowledge sources first',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getKnowledgeIcon(KnowledgeSourceType type) {
    switch (type) {
      case KnowledgeSourceType.localFiles:
        return Icons.description;
      case KnowledgeSourceType.website:
        return Icons.language;
      case KnowledgeSourceType.googleDrive:
        return Icons.folder;
      case KnowledgeSourceType.slack:
        return Icons.chat;
      case KnowledgeSourceType.confluence:
        return Icons.article;
      case KnowledgeSourceType.notion:
        return Icons.note;
      case KnowledgeSourceType.discord:
        return Icons.forum;
    }
  }
}
