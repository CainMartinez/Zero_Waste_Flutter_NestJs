import 'package:flutter/material.dart';
import 'package:pub_diferent/catalog/widgets/showcase_scaffold.dart';
import 'package:pub_diferent/features/orders/presentation/widgets/order_card.dart';
import 'package:pub_diferent/features/shop/presentation/widgets/food_menu_card.dart';

class CardsDemo extends StatelessWidget {
  const CardsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Tarjetas',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'FoodMenuCard',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tarjeta usada en Home para destacar sugerencias del menú. Permite mostrar badges, imagen y acción rápida.',
          ),
          const SizedBox(height: 12),
          FoodMenuCard(
            dishName: 'Nombre del Plato',
            description: 'Breve descripción del plato aquí.',
            price: 12.50,
            imageUrl: 'https://picsum.photos/seed/demo1/800/450',
            badges: const ['Etiqueta 1', 'Etiqueta 2'],
            onTap: () {},
          ),

          const SizedBox(height: 24),
          const Text(
            'Variación – sin stock',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          FoodMenuCard(
            dishName: 'Plato No Disponible',
            description: 'Este artículo no está disponible.',
            price: 10.00,
            imageUrl: 'https://picsum.photos/seed/demo2/800/450',
            badges: const [],
            isAvailable: false,
          ),

          const SizedBox(height: 32),
          const Text(
            'OrderCard',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tarjeta usada en Home para mostrar el estado del último pedido y en listados de historial.',
          ),
          const SizedBox(height: 12),
          OrderCard(
            orderNumber: '1234',
            orderDate: DateTime.now().subtract(const Duration(minutes: 15)),
            status: OrderStatus.preparing,
            total: 25.50,
            items: const [
              OrderItem(name: 'Artículo 1', quantity: 2, price: 15.00),
              OrderItem(name: 'Artículo 2', quantity: 1, price: 10.50),
            ],
            onTap: () {},
          ),

          const SizedBox(height: 16),
          OrderCard(
            orderNumber: '1233',
            orderDate: DateTime.now().subtract(const Duration(hours: 2)),
            status: OrderStatus.delivered,
            total: 18.00,
            items: const [
              OrderItem(name: 'Artículo 3', quantity: 1, price: 18.00),
            ],
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
