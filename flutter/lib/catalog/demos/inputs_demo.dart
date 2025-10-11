import 'package:flutter/material.dart';
import 'package:pub_diferent/catalog/widgets/showcase_scaffold.dart';
import 'package:pub_diferent/core/widgets/app_button.dart';
import 'package:pub_diferent/features/settings/presentation/widgets/settings_switch_tile.dart';

class InputsDemo extends StatefulWidget {
  const InputsDemo({super.key});

  @override
  State<InputsDemo> createState() => _InputsDemoState();
}

class _InputsDemoState extends State<InputsDemo> {
  final _textController = TextEditingController();
  bool _checkbox = false;
  bool _customSwitch = true;
  String _dropdown = 'value1';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Inputs & Formularios',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'TextField con decoración base',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ejemplo de entrada alineada con la guía de estilos del tema.',
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Etiqueta',
              hintText: 'Texto de ayuda aquí',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'SettingsSwitchTile',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Interruptor reutilizable usado en la pantalla de Preferencias '
            'para secciones de notificaciones.',
          ),
          const SizedBox(height: 8),
          SettingsSwitchTile(
            label: 'Recordar última búsqueda',
            value: _customSwitch,
            onChanged: (value) => setState(() => _customSwitch = value),
          ),

          const SizedBox(height: 24),
          const Text(
            'Campo de Texto Multilínea',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notas',
              hintText: 'Introduce múltiples líneas...',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Desplegable',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _dropdown,
            decoration: const InputDecoration(
              labelText: 'Selecciona una opción',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'value1', child: Text('Opción 1')),
              DropdownMenuItem(value: 'value2', child: Text('Opción 2')),
              DropdownMenuItem(value: 'value3', child: Text('Opción 3')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _dropdown = value);
            },
          ),

          const SizedBox(height: 24),
          const Text(
            'Casilla de Verificación',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _checkbox,
            onChanged: (value) => setState(() => _checkbox = value ?? false),
            title: const Text('Opción de casilla'),
            subtitle: const Text('Descripción adicional'),
          ),

          const SizedBox(height: 24),
          const Text(
            'Botones de Radio',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          RadioGroup<String>(
            child: const Column(
              children: [
                RadioListTile<String>(
                  value: 'option1',
                  title: Text('Opción 1'),
                ),
                RadioListTile<String>(
                  value: 'option2',
                  title: Text('Opción 2'),
                ),
              ],
            ),
            onChanged: (value) {},
          ),

          const SizedBox(height: 24),
          AppButton(
            label: 'Enviar',
            onPressed: () {},
            variant: AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }
}
