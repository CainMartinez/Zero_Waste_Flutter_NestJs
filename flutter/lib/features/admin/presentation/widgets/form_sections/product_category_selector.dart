import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pub_diferent/features/admin/presentation/providers/product_admin_provider.dart';

class ProductCategorySelector extends ConsumerWidget {
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategoryChanged;

  const ProductCategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productAdminProvider);
    
    if (state.isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<int>(
      value: selectedCategoryId,
      decoration: const InputDecoration(
        labelText: 'Categoría *',
        prefixIcon: Icon(Icons.category_outlined),
      ),
      items: state.categories.map((cat) {
        return DropdownMenuItem<int>(
          value: cat['id'] as int,
          child: Text(cat['nameEs'] as String),
        );
      }).toList(),
      onChanged: onCategoryChanged,
      validator: (v) => v == null ? 'Selecciona una categoría' : null,
    );
  }
}
