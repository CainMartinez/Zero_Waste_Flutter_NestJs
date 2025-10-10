import 'package:flutter/material.dart';
import 'package:pub_diferent/catalog/catalog_page.dart';
import 'package:pub_diferent/core/widgets/app_badge.dart';
import 'package:pub_diferent/core/widgets/app_button.dart';
import 'package:pub_diferent/features/orders/presentation/widgets/order_card.dart';
import 'package:pub_diferent/features/settings/presentation/controllers/settings_controller.dart';
import 'package:pub_diferent/features/settings/presentation/pages/settings_page.dart';
import 'package:pub_diferent/features/shop/presentation/widgets/food_menu_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.settingsController});

  final SettingsController settingsController;

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsPage(controller: settingsController),
      ),
    );
  }

  void _openCatalog(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CatalogPage()));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Preferencias',
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Bienvenido a Pub Diferent', style: textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(
            'Reserva, paga y recoge sin esperas. Preparamos cada pedido bajo demanda para evitar desperdicios.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              AppBadge(
                label: 'Abierto hoy',
                color: Colors.green,
                icon: Icons.schedule,
              ),
              AppBadge(
                label: 'Zero Waste',
                color: Colors.teal,
                icon: Icons.eco,
              ),
            ],
          ),
         
          const SizedBox(height: 32),
           Text(
            'Cards que se usarán en otras pages:',
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text('Sugerencia del chef', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          FoodMenuCard(
            dishName: 'Bowl mediterráneo',
            description:
                'Quinoa, hummus casero, verduras asadas y aderezo de limón.',
            price: 9.80,
            badges: const ['Vegetariano', 'Zero Waste'],
            imageUrl: 'https://picsum.photos/seed/chef/800/450',
          ),
          const SizedBox(height: 32),
          Text('Último pedido', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          OrderCard(
            orderNumber: '8421',
            orderDate: DateTime.now().subtract(const Duration(minutes: 12)),
            items: const [
              OrderItem(name: 'Wrap veggie', quantity: 1, price: 7.50),
              OrderItem(name: 'Kombucha', quantity: 1, price: 3.20),
            ],
            total: 10.70,
            status: OrderStatus.preparing,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Ir al catálogo',
            onPressed: () => _openCatalog(context),
          ),
        ],
      ),
    );
  }
}
