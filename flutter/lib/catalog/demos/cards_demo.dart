import 'package:flutter/material.dart';
import 'package:eco_bocado/catalog/widgets/showcase_scaffold.dart';
import 'package:eco_bocado/features/orders/presentation/widgets/order_card.dart';
import 'package:eco_bocado/features/shop/presentation/widgets/food_menu_card.dart';

class CardsDemo extends StatelessWidget {
  const CardsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ShowcaseScaffold(
      title: 'Tarjetas',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de uso en la app
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Usado en la aplicación',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildUsageItem(theme, 'Home: FeaturedBigCard con hero header'),
                  _buildUsageItem(theme, 'Shop: FoodMenuCard - menú de platos'),
                  _buildUsageItem(theme, 'Orders: OrderCard - historial y estado de pedidos'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          
          // FoodMenuCard
          Text(
            'FoodMenuCard',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'features/shop/presentation/widgets/food_menu_card.dart',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tarjeta especializada para mostrar platos del menú con imagen, badges, '
            'precio y disponibilidad. Usado en Home y Shop.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          FoodMenuCard(
            dishName: 'Ensalada César Premium',
            description: 'Lechuga romana, pollo a la parrilla, parmesano y aderezo césar casero.',
            price: 12.50,
            imageUrl: 'https://picsum.photos/seed/demo1/800/450',
            badges: const ['Recomendado', 'Zero Waste'],
            onTap: () {},
          ),

          const SizedBox(height: 24),
          Text(
            'Estado: No disponible',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          FoodMenuCard(
            dishName: 'Pizza Margarita',
            description: 'Tomate, mozzarella fresca y albahaca.',
            price: 10.00,
            imageUrl: 'https://picsum.photos/seed/demo2/800/450',
            badges: const [],
            isAvailable: false,
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          
          // OrderCard
          Text(
            'OrderCard',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'features/orders/presentation/widgets/order_card.dart',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tarjeta especializada para pedidos con fecha, número de orden, '
            'estado (AppBadge), lista de items y total. Usado en Home y Orders.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          OrderCard(
            orderNumber: '1234',
            orderDate: DateTime.now().subtract(const Duration(minutes: 15)),
            status: OrderStatus.preparing,
            total: 25.50,
            items: const [
              OrderItem(name: 'Ensalada César', quantity: 2, price: 15.00),
              OrderItem(name: 'Agua Mineral', quantity: 1, price: 10.50),
            ],
            onTap: () {},
          ),

          const SizedBox(height: 16),
          Text(
            'Estado: Entregado',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          OrderCard(
            orderNumber: '1233',
            orderDate: DateTime.now().subtract(const Duration(hours: 2)),
            status: OrderStatus.delivered,
            total: 18.00,
            items: const [
              OrderItem(name: 'Pizza Margarita', quantity: 1, price: 18.00),
            ],
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
