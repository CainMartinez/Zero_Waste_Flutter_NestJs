import 'package:flutter/material.dart';
import 'app_filter_chip.dart';

/// Selector de categorías con chips
class CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;
  final List<CategoryOption> categories;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Chip "Todos"
          AppFilterChip(
            label: 'Todos',
            selected: selectedCategory == null,
            onTap: () => onCategoryChanged(null),
          ),
          const SizedBox(width: 8),
          // Chips de categorías
          ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AppFilterChip(
                  label: category.label,
                  selected: selectedCategory == category.code,
                  onTap: () => onCategoryChanged(category.code),
                  icon: category.icon,
                ),
              )),
        ],
      ),
    );
  }
}

/// Opción de categoría
class CategoryOption {
  final String code;
  final String label;
  final IconData? icon;

  const CategoryOption({
    required this.code,
    required this.label,
    this.icon,
  });
}
