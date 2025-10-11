import 'package:flutter/material.dart';
import 'package:pub_diferent/core/widgets/app_badge.dart';

/// Tarjeta para mostrar un pedido activo o del historial
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.orderNumber,
    required this.orderDate,
    required this.items,
    required this.total,
    required this.status,
    this.onTap,
  });

  final String orderNumber;
  final DateTime orderDate;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusDetails = _statusDetailsOf(status);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#$orderNumber',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(orderDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pedido: ${_formatTime(orderDate)} • Recogida: ${_formatTime(orderDate.add(const Duration(minutes: 30)))}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppBadge(
                        label: statusDetails.label,
                        color: statusDetails.color,
                        icon: statusDetails.icon,
                        size: AppBadgeSize.small,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '€${total.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${items.length} ${items.length == 1 ? 'producto' : 'productos'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ...items
                      .take(3)
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(
                              Icons.restaurant_menu,
                              size: 20,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ver detalles',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final orderDay = DateTime(date.year, date.month, date.day);

    if (orderDay == today) {
      return 'Hoy, ${_formatTime(date)}';
    } else if (orderDay == yesterday) {
      return 'Ayer, ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${_formatTime(date)}';
    }
  }
}

class OrderItem {
  const OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String name;
  final int quantity;
  final double price;
}

enum OrderStatus { pending, preparing, ready, delivered, cancelled }

_OrderStatusDetails _statusDetailsOf(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return const _OrderStatusDetails(
        label: 'Pendiente',
        color: Colors.orange,
        icon: Icons.timelapse,
      );
    case OrderStatus.preparing:
      return const _OrderStatusDetails(
        label: 'Preparando',
        color: Colors.blue,
        icon: Icons.restaurant,
      );
    case OrderStatus.ready:
      return const _OrderStatusDetails(
        label: 'Listo',
        color: Colors.green,
        icon: Icons.check_circle,
      );
    case OrderStatus.delivered:
      return const _OrderStatusDetails(
        label: 'Entregado',
        color: Colors.teal,
        icon: Icons.delivery_dining,
      );
    case OrderStatus.cancelled:
      return const _OrderStatusDetails(
        label: 'Cancelado',
        color: Colors.red,
        icon: Icons.cancel,
      );
  }
}

class _OrderStatusDetails {
  const _OrderStatusDetails({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}
