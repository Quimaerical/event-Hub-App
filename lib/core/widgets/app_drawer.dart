import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/events/presentation/screens/create_event_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/tablon_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, this.currentRoute = ''});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.darkBg,
      child: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String userEmail = 'Usuario';
            String userRole = 'Usuario';
            if (state is Authenticated) {
              userEmail = state.email;
              userRole = state.userRole ?? 'Usuario';
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Glassmorphic Drawer Header matching Stitch design
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(12),
                  decoration: AppTheme.darkGlassDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppTheme.brandDeep,
                            child: Text(
                              userEmail.isNotEmpty
                                  ? userEmail[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userEmail.split('@').first,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userEmail,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.brandDark.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.brandViolet.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          userRole.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brandLight,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Navigation Menu Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _DrawerTile(
                        icon: Icons.grid_view_rounded,
                        title: 'Cartelera Principal',
                        isActive: currentRoute == 'dashboard',
                        onTap: () {
                          Navigator.of(context).pop();
                          if (currentRoute != 'dashboard') {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const DashboardScreen(),
                              ),
                            );
                          }
                        },
                      ),
                      _DrawerTile(
                        icon: Icons.dashboard_customize_outlined,
                        title: 'Mi Tablón de Eventos',
                        isActive: currentRoute == 'tablon',
                        onTap: () {
                          Navigator.of(context).pop();
                          if (currentRoute != 'tablon') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TablonScreen(),
                              ),
                            );
                          }
                        },
                      ),
                      _DrawerTile(
                        icon: Icons.add_circle_outline,
                        title: 'Crear Evento',
                        isActive: currentRoute == 'create_event',
                        onTap: () {
                          Navigator.of(context).pop();
                          if (currentRoute != 'create_event') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CreateEventScreen(),
                              ),
                            );
                          }
                        },
                      ),
                      const Divider(color: AppTheme.borderDark, height: 24),
                      _DrawerTile(
                        icon: Icons.person_outline,
                        title: 'Mi Perfil',
                        isActive: currentRoute == 'profile',
                        onTap: () {
                          Navigator.of(context).pop();
                          if (currentRoute != 'profile') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          }
                        },
                      ),
                      _DrawerTile(
                        icon: Icons.settings_outlined,
                        title: 'Configuración',
                        isActive: currentRoute == 'settings',
                        onTap: () {
                          Navigator.of(context).pop();
                          if (currentRoute != 'settings') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          }
                        },
                      ),
                      _DrawerTile(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'Gestión de Usuarios',
                        isActive: currentRoute == 'admin_users',
                        onTap: () {
                          Navigator.of(context).pop();
                          if (currentRoute != 'admin_users') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AdminUsersScreen(),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Logout Footer Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.read<AuthBloc>().add(LogoutRequested());
                    },
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.brandDeep.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? Border.all(color: AppTheme.brandViolet.withValues(alpha: 0.4))
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppTheme.brandViolet : AppTheme.textMuted,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppTheme.textLight : AppTheme.textMuted,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
