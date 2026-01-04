import 'package:flutter/material.dart';

class CategoryChipsWidget extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryChipsWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<Map<String, String>> categories = [
    {'value': 'all', 'label': 'All'},
    {'value': 'chatbot', 'label': 'Chatbot'},
    {'value': 'coding', 'label': 'Coding'},
    {'value': 'writing', 'label': 'Writing'},
    {'value': 'career', 'label': 'Career'},
    {'value': 'education', 'label': 'Education'},
    {'value': 'marketing', 'label': 'Marketing'},
    {'value': 'fun', 'label': 'Fun'},
    {'value': 'business', 'label': 'Business'},
    {'value': 'productivity', 'label': 'Productivity'},
    {'value': 'ai_painting', 'label': 'AI Painting'},
    {'value': 'seo', 'label': 'SEO'},
    {'value': 'bni', 'label': 'BNI'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, index) {
          final category = categories[index];
          final value = category['value']!;
          final label = category['label']!;
          final isSelected = selectedCategory == value;

          return GestureDetector(
            onTap: () => onCategorySelected(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue
                    : (isDark ? Colors.grey[800] : Colors.grey[100]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
