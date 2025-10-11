import 'package:flutter/material.dart';
import 'package:pub_diferent/catalog/widgets/showcase_scaffold.dart';
import 'package:pub_diferent/core/widgets/app_button.dart';

class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Botones',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'AppButton',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'CTA principal de la app. Se usa en Home (acceso al catálogo) '
            'y en formularios para acciones confirmatorias.',
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Confirmar',
            onPressed: () {},
            variant: AppButtonVariant.primary,
          ),

          const SizedBox(height: 24),
          const Text(
            'Estados y variantes',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Cancelar',
            onPressed: () {},
            variant: AppButtonVariant.danger,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Botón deshabilitado',
            onPressed: null,
            variant: AppButtonVariant.primary,
          ),

          const SizedBox(height: 24),
          const Text('Composición en layouts'),
          const SizedBox(height: 8),
          const Text('Distribución responsive usando Expanded en filas.'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Aceptar',
                  onPressed: () {},
                  variant: AppButtonVariant.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Cancelar',
                  onPressed: () {},
                  variant: AppButtonVariant.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
