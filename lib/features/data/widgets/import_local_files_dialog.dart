import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ImportLocalFilesDialog extends StatefulWidget {
  const ImportLocalFilesDialog({super.key});

  @override
  State<ImportLocalFilesDialog> createState() => _ImportLocalFilesDialogState();
}

class _ImportLocalFilesDialogState extends State<ImportLocalFilesDialog> {
  final _schemaController = TextEditingController();

  List<String> _selectedFiles = [];

  static const primaryBlue = Color(0xFF2196F3);
  static const textDark = Color(0xFF1A1D2E);
  static const textGray = Color(0xFF6B7280);
  static const borderColor = Color(0xFFE5E7EB);

  @override
  void dispose() {
    _schemaController.dispose();
    super.dispose();
  }

  void _handleSelectFiles() {
    // TODO: Implement file picker
    setState(() {
      _selectedFiles = ['document1.pdf', 'document2.docx'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Files',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark, color: textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // File Upload Area
              GestureDetector(
                onTap: _handleSelectFiles,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: primaryBlue,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: primaryBlue.withOpacity(0.02),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.arrow_up_doc,
                          size: 40,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Select or drag files',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Up to 5 files, 15MB each',
                        style: TextStyle(fontSize: 14, color: textGray),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'PDF, Word, Excel, images, code files & more',
                        style: TextStyle(fontSize: 14, color: textGray),
                      ),
                    ],
                  ),
                ),
              ),

              // Selected Files
              if (_selectedFiles.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...List.generate(_selectedFiles.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primaryBlue.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.doc_text_fill,
                            color: primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedFiles[index],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textDark,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              CupertinoIcons.xmark_circle_fill,
                              color: textGray,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedFiles.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 24),

              // Schema Generation Prompt (Optional)
              const Text(
                'Schema Generation Prompt (Optional)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _schemaController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      "Describe what data to extract (e.g., 'names, emails, phone numbers')",
                  hintStyle: TextStyle(color: textGray.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryBlue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Help the AI understand what information to extract from your files',
                style: TextStyle(fontSize: 13, color: textGray),
              ),
              const SizedBox(height: 16),

              // View Documentation Link
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.05),
                  border: Border.all(color: primaryBlue.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text(
                      'View documentation ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: primaryBlue,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.question,
                          size: 16,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryBlue, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedFiles.isEmpty
                          ? null
                          : () {
                              Navigator.pop(context, {
                                'files': _selectedFiles,
                                'schema': _schemaController.text,
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        disabledBackgroundColor: textGray.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Add Files',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
