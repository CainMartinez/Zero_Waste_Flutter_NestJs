import 'package:flutter/material.dart';
import 'package:pub_diferent/core/widgets/app_badge.dart';
import 'package:pub_diferent/features/home/presentation/widgets/home_hero_header.dart';
import 'package:pub_diferent/features/home/presentation/widgets/featured_big_card.dart';
import 'package:pub_diferent/features/home/presentation/widgets/loyalty_gradient_banner.dart';
import 'package:pub_diferent/app/theme/app_palette.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = appPaletteOf(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        HomeHeroHeader(
          titlePrimary: 'Comida Deliciosa',
          titleAccent: 'Sin Desperdicios',
          subtitle:
              'Disfruta de la mejor comida para llevar mientras cuidamos nuestro planeta. Envases reutilizables, ingredientes locales y cero desperdicios.',
          badges: const [
            AppBadge(
              label: 'Cero Desperdicios',
              icon: Icons.recycling,
              color: Colors.teal,
            ),
            AppBadge(
              label: 'Menús Veganos',
              icon: Icons.flatware,
              color: Colors.green,
            ),
          ],
        ),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.eco, 
                        size: 32, 
                        color: palette.success,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Comida Ecológica',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Zero Waste',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 80,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.flash_on, 
                        size: 32, 
                        color: palette.warning,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Recogida rápida',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sin esperas',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const FeaturedBigCard(
          image: AssetImage('assets/images/home.jpg'),
          badge: AppBadge(
            label: '100% Sostenible',
            icon: Icons.energy_savings_leaf,
            color: Colors.green,
          ),
          title: 'Envases compostables y reutilizables',
        ),
        const SizedBox(height: 4),
        const LoyaltyGradientBanner(
          title: '¡PROGRAMA DE FIDELIDAD! 10 compras = 1 menú GRATIS',
          subtitle: 'Acumula puntos y canjéalos por recompensas deliciosas.',
          showNewBadge: true,
        ),
      ],
    );
  }
}