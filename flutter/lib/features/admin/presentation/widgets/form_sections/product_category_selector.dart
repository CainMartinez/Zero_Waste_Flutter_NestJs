import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_bocado/core/l10n/app_localizations.dart';
import 'package:eco_bocado/features/admin/presentation/providers/product_admin_provider.dart';

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

    final l10n = AppLocalizations.of(context)!;
    return DropdownButtonFormField<int>(
      initialValue: selectedCategoryId,
      decoration: InputDecoration(
        labelText: l10n.category,
        prefixIcon: const Icon(Icons.category_outlined),
      ),
      isExpanded: true,
      items: state.categories.map((cat) {
        final locale = Localizations.localeOf(context);
        final nameEs = cat['nameEs'] as String;
        final nameEn = cat['nameEn'] as String;
        final name = locale.languageCode == 'en' ? nameEn : nameEs;
        return DropdownMenuItem<int>(
          value: cat['id'] as int,
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onCategoryChanged,
      validator: (v) => v == null ? l10n.mustSelectCategory : null,
    );
  }
}
