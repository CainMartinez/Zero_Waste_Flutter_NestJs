import 'package:flutter/material.dart';
import 'package:pub_diferent/core/widgets/app_badge.dart';
import 'package:pub_diferent/features/settings/presentation/controllers/settings_controller.dart';
import 'package:pub_diferent/features/home/presentation/widgets/home_hero_header.dart';
import 'package:pub_diferent/features/home/presentation/widgets/featured_big_card.dart';
import 'package:pub_diferent/features/home/presentation/widgets/info_small_card.dart';
import 'package:pub_diferent/features/home/presentation/widgets/loyalty_gradient_banner.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        HomeHeroHeader(
          titlePrimary: 'Comida Deliciosa',
          titleAccent: 'Sin Desperdicios',
          subtitle:
              'Disfruta de la mejor comida para llevar mientras cuidamos nuestro planeta. Envases reutilizables, ingredientes locales y cero desperdicios.',
          badges: const [
            AppBadge(
              label: 'Cero Desperdicios',
              icon: Icons.eco,
              color: Colors.teal,
            ),
            AppBadge(
              label: 'Recogida rápida',
              icon: Icons.schedule,
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const FeaturedBigCard(
          image: AssetImage('assets/images/home.jpg'),
          badge: AppBadge(
            label: '100% Sostenible',
            icon: Icons.energy_savings_leaf,
            color: Colors.green,
          ),
          title: 'Envases compostables y reutilizables',
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(
              child: InfoSmallCard(
                icon: Icons.eco,
                title: 'Comida Ecológica',
                subtitle: 'Zero Waste',
                color: Colors.teal,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: InfoSmallCard(
                icon: Icons.flash_on,
                title: 'Recogida rápida',
                subtitle: 'Sin esperas',
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const LoyaltyGradientBanner(
          title: '¡PROGRAMA DE FIDELIDAD! 10 compras = 1 menú GRATIS',
          subtitle: 'Acumula puntos y canjéalos por recompensas deliciosas.',
          showNewBadge: true,
        ),
        const SizedBox(height: 96),
      ],
    );
  }
}