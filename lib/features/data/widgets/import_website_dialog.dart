import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ImportWebsiteDialog extends StatefulWidget {
  const ImportWebsiteDialog({super.key});

  @override
  State<ImportWebsiteDialog> createState() => _ImportWebsiteDialogState();
}

class _ImportWebsiteDialogState extends State<ImportWebsiteDialog> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();

  bool _autoUpdate = true;
  String _selectedInterval = '12 hours';
  String _importType = 'single';

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
    _urlController.dispose();
    super.dispose();
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
                    'Import Web Source',
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

              // Web URL Field
              const Text(
                'Web URL *',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'https://example.com',
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

              // Import Type
              const Text(
                'Import Type',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              RadioListTile<String>(
                value: 'single',
                groupValue: _importType,
                activeColor: primaryBlue,
                title: const Text('Single page'),
                contentPadding: EdgeInsets.zero,
                onChanged: (value) => setState(() => _importType = value!),
              ),
              RadioListTile<String>(
                value: 'whole',
                groupValue: _importType,
                activeColor: primaryBlue,
                title: const Text('Whole sites'),
                contentPadding: EdgeInsets.zero,
                onChanged: (value) => setState(() => _importType = value!),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Limitation:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Importing the entire website may take some time to complete. You can load up to 64 pages at a time',
                      style: TextStyle(
                        fontSize: 14,
                        color: textDark,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          '• Need more? ',
                          style: TextStyle(fontSize: 14, color: textDark),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'hello@jarvis.cx',
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
                        // TODO: Handle import
                        Navigator.pop(context, {
                          'name': _nameController.text,
                          'url': _urlController.text,
                          'autoUpdate': _autoUpdate,
                          'interval': _selectedInterval,
                          'type': _importType,
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
