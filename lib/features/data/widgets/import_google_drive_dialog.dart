import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ImportGoogleDriveDialog extends StatefulWidget {
  const ImportGoogleDriveDialog({super.key});

  @override
  State<ImportGoogleDriveDialog> createState() =>
      _ImportGoogleDriveDialogState();
}

class _ImportGoogleDriveDialogState extends State<ImportGoogleDriveDialog> {
  final _nameController = TextEditingController();
  final _schemaController = TextEditingController();

  bool _autoUpdate = true;
  String _selectedInterval = '12 hours';
  bool _filesSelected = false;

  final _intervals = [
    '30 min',
    '1 hour',
    '6 hours',
    '12 hours',
    '1 day',
    '3 days',
    '1 week',
  ];

  static const primaryBlue = Color(0xFF2196F3);
  static const textDark = Color(0xFF1A1D2E);
  static const textGray = Color(0xFF6B7280);
  static const borderColor = Color(0xFFE5E7EB);

  @override
  void dispose() {
    _nameController.dispose();
    _schemaController.dispose();
    super.dispose();
  }

  void _handleChooseFiles() {
    // TODO: Implement Google Drive picker
    setState(() => _filesSelected = true);
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
                    'Import Google Drive Source',
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
                'Name *',
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
                  hintText: 'Enter knowledge unit name',
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
              const SizedBox(height: 20),

              // Google Drive Files/Folders
              const Text(
                'Google Drive Files/Folders *',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _handleChooseFiles,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/google_drive.png',
                        width: 28,
                        height: 28,
                        errorBuilder: (_, __, ___) => const Icon(
                          CupertinoIcons.cloud,
                          color: Color(0xFF34A853),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Choose Files or Folders',
                        style: TextStyle(
                          fontSize: 15,
                          color: textGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!_filesSelected) ...[
                const SizedBox(height: 8),
                const Text(
                  'Please select Google Drive files or folders',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Auto Update Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Keep Files Updated Automatically',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                  CupertinoSwitch(
                    value: _autoUpdate,
                    activeColor: primaryBlue,
                    onChanged: (value) => setState(() => _autoUpdate = value),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Update Interval
              const Text(
                'Check for updates every:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _intervals.map((interval) {
                  final isSelected = _selectedInterval == interval;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedInterval = interval),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryBlue.withOpacity(0.1)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected ? primaryBlue : borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        interval,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected ? primaryBlue : textGray,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
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

              // Limitation Info
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
                      'Current Limitation: ',
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
                        'Back',
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
                      onPressed: () {
                        Navigator.pop(context, {
                          'name': _nameController.text,
                          'autoUpdate': _autoUpdate,
                          'interval': _selectedInterval,
                          'schema': _schemaController.text,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Import',
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
