import 'package:flutter/material.dart';
import 'package:eco_bocado/app/theme/app_palette.dart';

class AppHeaderLogo extends StatelessWidget {
  const AppHeaderLogo({
    super.key,
    this.title,
    this.subtitle,
    this.spacing = 12,
  });

  final String? title;
  final String? subtitle;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final palette = appPaletteOf(context);
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 84,
          width: 84,
          decoration: BoxDecoration(
            color: palette.secondary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(28),
          ),
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/logo.jpg',
              height: 68,
              width: 68,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: spacing),
        Text(
          title ?? 'EcoBocado',
          style: tt.headlineSmall,
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: tt.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}