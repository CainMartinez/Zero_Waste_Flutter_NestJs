import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pub_diferent/features/profile/presentation/providers/profile_provider.dart';
import 'package:pub_diferent/features/profile/presentation/pages/update_profile_page.dart';
import 'package:pub_diferent/features/profile/presentation/pages/change_password_page.dart';
import 'package:pub_diferent/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:pub_diferent/features/profile/presentation/widgets/profile_role_badge.dart';
import 'package:pub_diferent/features/profile/presentation/widgets/profile_info_row.dart';
import 'package:pub_diferent/features/auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(profileProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) => RefreshIndicator(
          onRefresh: () async {
            await ref.read(profileProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar grande
                Center(
                  child: ProfileAvatar(
                    avatarUrl: profile.avatarUrl,
                    name: profile.name,
                    radius: 60,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Nombre
                Center(
                  child: Text(
                    profile.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                
                // Email
                Center(
                  child: Text(
                    profile.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Badge de tipo de usuario
                Center(
                  child: ProfileRoleBadge(isAdmin: profile.isAdmin),
                ),
                const SizedBox(height: 32),

                // Sección de información
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información de Contacto',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        
                        // Teléfono
                        ProfileInfoRow(
                          icon: Icons.phone,
                          label: 'Teléfono',
                          value: profile.phone ?? 'No especificado',
                        ),
                        const SizedBox(height: 12),
                        
                        // Dirección línea 1
                        ProfileInfoRow(
                          icon: Icons.home,
                          label: 'Dirección',
                          value: profile.addressLine1 ?? 'No especificada',
                        ),
                        if (profile.addressLine2 != null && profile.addressLine2!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Text(
                              profile.addressLine2!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        
                        // Ciudad
                        ProfileInfoRow(
                          icon: Icons.location_city,
                          label: 'Ciudad',
                          value: profile.city ?? 'No especificada',
                        ),
                        const SizedBox(height: 12),
                        
                        // Código Postal
                        ProfileInfoRow(
                          icon: Icons.pin_drop,
                          label: 'Código Postal',
                          value: profile.postalCode ?? 'No especificado',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón de editar perfil
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const UpdateProfilePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Perfil'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),

                // Botón de cambiar contraseña (solo para usuarios normales)
                if (profile.isUser) ...[
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.lock),
                    label: const Text('Cambiar Contraseña'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Botón de cerrar sesión
                ElevatedButton.icon(
                  onPressed: () => _handleLogout(context, ref),
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error al cargar perfil',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(profileProvider.notifier).refresh();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(authProvider.notifier).logout();
        
        if (context.mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
