import 'package:flutter/material.dart';

/// Widget para mostrar el badge de rol (Admin/Usuario)
class ProfileRoleBadge extends StatelessWidget {
  final bool isAdmin;

  const ProfileRoleBadge({
    super.key,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Admin usa error (rojo), Usuario usa primary (azul)
    final backgroundColor = isAdmin
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;
    
    final textColor = isAdmin
        ? colorScheme.onErrorContainer
        : colorScheme.onPrimaryContainer;
    
    return Chip(
      label: Text(
        isAdmin ? 'Administrador' : 'Usuario',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}
