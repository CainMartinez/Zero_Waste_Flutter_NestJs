import 'package:flutter/material.dart';
import 'package:pub_diferent/core/widgets/app_badge.dart';

/// Card grande destacada del home.
/// Recibe un ImageProvider para permitir const con AssetImage.
class FeaturedBigCard extends StatelessWidget {
  const FeaturedBigCard({
    super.key,
    required this.image,
    required this.badge,
    required this.title,
  });

  /// Proveedor de imagen (p.ej. const AssetImage('assets/...') o NetworkImage('...')).
  final ImageProvider image;

  /// Badge principal (ej: "100% Sostenible").
  final AppBadge badge;

  /// Texto superpuesto debajo del badge.
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildImage(cs),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                badge,
                const SizedBox(height: 8),
                Text(
                  title,
                  style: tt.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(ColorScheme cs) {
    // Si es NetworkImage, añadimos loader/errores.
    if (image is NetworkImage) {
      final url = (image as NetworkImage).url;
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: cs.surfaceContainerLow,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
        errorBuilder: (_, __, ___) => _errorBox(cs),
      );
    }

    // Para AssetImage u otros providers.
    return Image(
      image: image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _errorBox(cs),
    );
  }

  Widget _errorBox(ColorScheme cs) => Container(
        color: cs.surfaceContainerLow,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported),
      );
}