import 'package:flutter/material.dart';
import 'package:eco_bocado/core/widgets/app_badge.dart';
import 'package:eco_bocado/features/home/presentation/widgets/home_hero_header.dart';
import 'package:eco_bocado/features/home/presentation/widgets/featured_big_card.dart';
import 'package:eco_bocado/features/home/presentation/widgets/loyalty_gradient_banner.dart';
import 'package:eco_bocado/app/theme/app_palette.dart';
import 'package:eco_bocado/core/l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = appPaletteOf(context);
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        HomeHeroHeader(
          titlePrimary: l10n.homePageTitle,
          titleAccent: l10n.homePageTitleAccent,
          subtitle: l10n.homePageSubtitle,
          badges: [
            AppBadge(
              label: l10n.badgeZeroWaste,
              icon: Icons.recycling,
              color: Colors.teal,
            ),
            AppBadge(
              label: l10n.badgeVeganMenus,
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
                        l10n.featureEcoFriendlyFood,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.featureZeroWaste,
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
                        l10n.featureFastPickup,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.featureNoWaiting,
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
        FeaturedBigCard(
          image: const AssetImage('assets/images/home.jpg'),
          badge: AppBadge(
            label: l10n.featuredCard100Sustainable,
            icon: Icons.energy_savings_leaf,
            color: Colors.green,
          ),
          title: l10n.featuredCardTitle,
        ),
        const SizedBox(height: 4),
        LoyaltyGradientBanner(
          title: l10n.loyaltyBannerTitle,
          subtitle: l10n.loyaltyBannerSubtitle,
          showNewBadge: true,
        ),
      ],
    );
  }
}