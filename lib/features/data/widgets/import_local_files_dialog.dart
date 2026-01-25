import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';

class ImportLocalFilesDialog extends StatefulWidget {
  const ImportLocalFilesDialog({super.key});

  @override
  State<ImportLocalFilesDialog> createState() => _ImportLocalFilesDialogState();
}

class _ImportLocalFilesDialogState extends State<ImportLocalFilesDialog> {
  final _schemaController = TextEditingController();
  final _nameController = TextEditingController();

  final List<File> _selectedFiles = [];
  bool _isPickingFiles = false;

  static const primaryBlue = Color(0xFF2196F3);
  static const textDark = Color(0xFF1A1D2E);
  static const textGray = Color(0xFF6B7280);
  static const borderColor = Color(0xFFE5E7EB);

  // File size limits
  static const int maxFileSize = 15 * 1024 * 1024; // 15MB
  static const int maxFiles = 5;

  // Supported file types
  static const List<String> allowedExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
    'csv',
    'json',
    'xml',
    'jpg',
    'jpeg',
    'png',
    'gif',
    'svg',
    'py',
    'js',
    'ts',
    'dart',
    'java',
    'cpp',
    'c',
    'h',
    'md',
    'html',
    'css',
  ];

  @override
  void dispose() {
    _schemaController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// ✅ Handle file selection
  Future<void> _handleSelectFiles() async {
    if (_isPickingFiles) return;

    setState(() {
      _isPickingFiles = true;
    });

    try {
      print('📁 Opening file picker...');

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        withData: false, // Don't load data immediately
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        print('📊 Selected ${result.files.length} files');

        final List<File> validFiles = [];
        final List<String> errors = [];

        // Validate each file
        for (var platformFile in result.files) {
          if (platformFile.path == null) {
            print('⚠️ File has no path: ${platformFile.name}');
            continue;
          }

          final file = File(platformFile.path!);

          // Check if file exists
          if (!await file.exists()) {
            errors.add('${platformFile.name}: File not found');
            continue;
          }

          // Check file size
          final fileSize = await file.length();
          if (fileSize > maxFileSize) {
            errors.add(
              '${platformFile.name}: Too large (${_formatBytes(fileSize)} > 15MB)',
            );
            continue;
          }

          // Check total files limit
          if (_selectedFiles.length + validFiles.length >= maxFiles) {
            errors.add('Maximum $maxFiles files allowed');
            break;
          }

          validFiles.add(file);
          print('  ✅ ${platformFile.name} (${_formatBytes(fileSize)})');
        }

        // Show errors if any
        if (errors.isNotEmpty && mounted) {
          _showErrorDialog(errors);
        }

        // Update selected files
        if (validFiles.isNotEmpty && mounted) {
          setState(() {
            _selectedFiles.addAll(validFiles);
          });
          print('✅ Total ${_selectedFiles.length} files selected');
        }
      } else {
        print('⚠️ No files selected');
      }
    } catch (e) {
      print('❌ Error picking files: $e');
      if (mounted) {
        _showSnackBar('Error selecting files: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFiles = false;
        });
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<String> _getFileSize(File file) async {
    try {
      final size = await file.length();
      return _formatBytes(size);
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getFileName(File file) {
    return file.path.split('/').last;
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();

    switch (ext) {
      case 'pdf':
        return CupertinoIcons.doc_text_fill;
      case 'doc':
      case 'docx':
        return CupertinoIcons.doc_text;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return CupertinoIcons.table;
      case 'ppt':
      case 'pptx':
        return CupertinoIcons.play_rectangle;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'svg':
        return CupertinoIcons.photo;
      case 'zip':
      case 'rar':
        return CupertinoIcons.archivebox;
      case 'py':
      case 'js':
      case 'ts':
      case 'dart':
      case 'java':
      case 'cpp':
      case 'c':
      case 'h':
      case 'html':
      case 'css':
      case 'json':
      case 'xml':
        return CupertinoIcons
            .chevron_left_slash_chevron_right; 
      case 'txt':
      case 'md':
        return CupertinoIcons.doc_plaintext;
      default:
        return CupertinoIcons.doc;
    }
  }
  void _showErrorDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('File Selection Errors'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(errors.join('\n')),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// ✅ Show snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
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

              // Name Field
              const Text(
                'Datasource Name *',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter datasource name',
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // File Upload Area
              GestureDetector(
                onTap: _isPickingFiles ? null : _handleSelectFiles,
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
                      if (_isPickingFiles)
                        const CupertinoActivityIndicator()
                      else
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
                      Text(
                        _isPickingFiles ? 'Selecting files...' : 'Select files',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Up to $maxFiles files, 15MB each',
                        style: const TextStyle(fontSize: 14, color: textGray),
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
                Text(
                  'Selected Files (${_selectedFiles.length}/$maxFiles)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(_selectedFiles.length, (index) {
                  final file = _selectedFiles[index];
                  final fileName = _getFileName(file);

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
                          Icon(
                            _getFileIcon(fileName),
                            color: primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fileName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                FutureBuilder<String>(
                                  future: _getFileSize(file),
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data ?? 'Loading...',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: textGray,
                                      ),
                                    );
                                  },
                                ),
                              ],
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
                      onPressed:
                          _selectedFiles.isEmpty ||
                              _nameController.text.trim().isEmpty
                          ? null
                          : () {
                              Navigator.pop(context, {
                                'name': _nameController.text.trim(),
                                'files': _selectedFiles,
                                'schema': _schemaController.text.trim(),
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
