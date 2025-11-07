import 'package:flutter/material.dart';

/// Widget para mostrar el avatar del perfil con fallback
class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.radius = 60,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(fontSize: radius * 0.66),
            )
          : null,
    );
  }
}
