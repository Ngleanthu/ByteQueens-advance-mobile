import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/string_extension.dart';

class ModernDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const ModernDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primaryBlue,
            ),
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(12),
            items: items
                .map(
                  (e) =>
                      DropdownMenuItem(value: e, child: Text(e.capitalize())),
                )
                .toList(),
            onChanged: (v) => onChanged(v!),
          ),
        ),
      ),
    );
  }
}
