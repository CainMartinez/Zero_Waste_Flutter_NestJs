import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return Column(
      children: [
        TextFormField(
          controller: nameEsCtrl,
          decoration: const InputDecoration(
            labelText: 'Nombre (ES) *',
            prefixIcon: Icon(Icons.text_fields),
          ),
          validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: nameEnCtrl,
          decoration: const InputDecoration(
            labelText: 'Nombre (EN) *',
            prefixIcon: Icon(Icons.text_fields),
          ),
          validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descEsCtrl,
          decoration: const InputDecoration(
            labelText: 'Descripción (ES) *',
            prefixIcon: Icon(Icons.description_outlined),
          ),
          maxLines: 3,
          validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descEnCtrl,
          decoration: const InputDecoration(
            labelText: 'Descripción (EN) *',
            prefixIcon: Icon(Icons.description_outlined),
          ),
          maxLines: 3,
          validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: priceCtrl,
          decoration: const InputDecoration(
            labelText: 'Precio *',
            prefixIcon: Icon(Icons.euro),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Requerido';
            final val = double.tryParse(v);
            if (val == null || val < 0) {
              return 'Debe ser un número válido >= 0';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: isVegan,
          onChanged: (val) => onVeganChanged(val ?? false),
          title: const Text('Es vegano'),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
