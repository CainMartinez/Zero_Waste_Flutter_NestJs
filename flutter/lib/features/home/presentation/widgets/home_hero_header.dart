import 'package:flutter/material.dart';
import 'package:eco_bocado/core/widgets/app_badge.dart';

class HomeHeroHeader extends StatelessWidget {
  const HomeHeroHeader({
    super.key,
    required this.titlePrimary,
    required this.titleAccent,
    required this.subtitle,
    required this.badges,
    this.padding,
    this.actions,
  });

  final String titlePrimary;
  final String titleAccent;
  final String subtitle;
  final List<AppBadge> badges;
  final EdgeInsets? padding;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        cs.secondary.withOpacity(isDark ? 0.22 : 0.16),
        cs.secondary.withOpacity(isDark ? 0.10 : 0.08),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centramos todo
        children: [
          if (actions != null && actions!.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildSeparated(actions!),
            ),

          // Título centrado (RichText)
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: tt.headlineLarge?.copyWith(
                color: cs.onSurface,
                height: 1.15,
              ),
              children: [
                TextSpan(text: '$titlePrimary\n'),
                TextSpan(
                  text: titleAccent,
                  style: tt.headlineLarge?.copyWith(
                    color: cs.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Subtítulo centrado y justificado visualmente
          Text(
            subtitle,
            textAlign: TextAlign.justify,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 16),

          if (badges.isNotEmpty)
            Wrap(
              alignment: WrapAlignment.center, // 🔹 Centramos badges
              spacing: 8,
              runSpacing: 8,
              children: badges,
            ),
        ],
      ),
    );
  }

  List<Widget> _buildSeparated(List<Widget> children) {
    final List<Widget> result = [];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i != children.length - 1) {
        result.add(const SizedBox(width: 8));
      }
    }
    return result;
  }
}