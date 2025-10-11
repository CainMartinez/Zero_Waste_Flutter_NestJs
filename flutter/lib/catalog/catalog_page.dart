import 'package:flutter/material.dart';
import 'package:pub_diferent/catalog/demos/buttons_demo.dart';
import 'package:pub_diferent/catalog/demos/cards_demo.dart';
import 'package:pub_diferent/catalog/demos/inputs_demo.dart';
import 'package:pub_diferent/catalog/demos/badges_demo.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Componentes'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Botones'),
            subtitle: const Text('AppButton – usado en Home y formularios'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ButtonsDemo()));
            },
          ),
          ListTile(
            title: const Text('Tarjetas'),
            subtitle: const Text('FoodMenuCard & OrderCard'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const CardsDemo()));
            },
          ),
          ListTile(
            title: const Text('Formularios'),
            subtitle: const Text(
              'SettingsSwitchTile y controles de formulario',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const InputsDemo()));
            },
          ),
          ListTile(
            title: const Text('Etiquetas'),
            subtitle: const Text('AppBadge – tags y estados de pedidos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const BadgesDemo()));
            },
          ),
        ],
      ),
    );
  }
}
