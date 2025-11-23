import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pub_diferent/core/l10n/app_localizations.dart';
import 'package:pub_diferent/features/admin/presentation/providers/product_admin_provider.dart';

class ProductAllergenSection extends ConsumerWidget {
  final Map<String, Map<String, bool>> selectedAllergens;
  final Function(String code, Map<String, bool>? value) onAllergenChanged;

  const ProductAllergenSection({
    super.key,
    required this.selectedAllergens,
    required this.onAllergenChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productAdminProvider);

    if (state.isLoadingAllergens) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.allergens.isEmpty) {
      return Text(AppLocalizations.of(context)!.noAllergensAvailable);
    }

    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.allergensOptional,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.allergens.map((allergen) {
            final code = allergen['code'] as String;
            final nameEs = allergen['nameEs'] as String;
            final nameEn = allergen['nameEn'] as String;
            final locale = Localizations.localeOf(context);
            final name = locale.languageCode == 'en' ? nameEn : nameEs;
            final isSelected = selectedAllergens.containsKey(code);
            final contains = selectedAllergens[code]?['contains'] ?? true;

            return InkWell(
              onTap: () {
                if (!isSelected) {
                  onAllergenChanged(code, {'contains': true, 'mayContain': false});
                } else if (contains) {
                  onAllergenChanged(code, {'contains': false, 'mayContain': true});
                } else {
                  onAllergenChanged(code, null);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (contains ? Colors.red.shade100 : Colors.orange.shade100)
                      : Colors.grey.shade200,
                  border: Border.all(
                    color: isSelected
                        ? (contains ? Colors.red.shade400 : Colors.orange.shade400)
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? (contains ? Icons.warning : Icons.info_outline)
                          : Icons.circle_outlined,
                      size: 18,
                      color: isSelected
                          ? (contains ? Colors.red.shade700 : Colors.orange.shade700)
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? (contains ? Colors.red.shade900 : Colors.orange.shade900)
                            : Colors.grey.shade800,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 4),
                      Text(
                        contains ? '✓' : '~',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: contains ? Colors.red.shade700 : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.selectAllergens,
          style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
