import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eco_bocado/core/l10n/app_localizations.dart';

class ProductBasicInfoForm extends StatelessWidget {
  final TextEditingController nameEsCtrl;
  final TextEditingController nameEnCtrl;
  final TextEditingController descEsCtrl;
  final TextEditingController descEnCtrl;
  final TextEditingController priceCtrl;
  final bool isVegan;
  final ValueChanged<bool> onVeganChanged;

  const ProductBasicInfoForm({
    super.key,
    required this.nameEsCtrl,
    required this.nameEnCtrl,
    required this.descEsCtrl,
    required this.descEnCtrl,
    required this.priceCtrl,
    required this.isVegan,
    required this.onVeganChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        TextFormField(
          controller: nameEsCtrl,
          decoration: InputDecoration(
            labelText: l10n.nameEs,
            prefixIcon: const Icon(Icons.text_fields),
          ),
          validator: (v) => v == null || v.trim().isEmpty ? l10n.required : null,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: nameEnCtrl,
          decoration: InputDecoration(
            labelText: l10n.nameEn,
            prefixIcon: const Icon(Icons.text_fields),
          ),
          validator: (v) => v == null || v.trim().isEmpty ? l10n.required : null,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descEsCtrl,
          decoration: InputDecoration(
            labelText: l10n.descriptionEs,
            prefixIcon: const Icon(Icons.description_outlined),
          ),
          maxLines: 3,
          validator: (v) => v == null || v.trim().isEmpty ? l10n.required : null,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descEnCtrl,
          decoration: InputDecoration(
            labelText: l10n.descriptionEn,
            prefixIcon: const Icon(Icons.description_outlined),
          ),
          maxLines: 3,
          validator: (v) => v == null || v.trim().isEmpty ? l10n.required : null,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: priceCtrl,
          decoration: InputDecoration(
            labelText: l10n.price,
            prefixIcon: const Icon(Icons.euro),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return l10n.required;
            final val = double.tryParse(v);
            if (val == null || val < 0) {
              return l10n.mustBeValidNumber;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: isVegan,
          onChanged: (val) => onVeganChanged(val ?? false),
          title: Text(l10n.isVegan),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
