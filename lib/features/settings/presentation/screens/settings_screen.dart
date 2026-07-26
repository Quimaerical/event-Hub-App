import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_drawer.dart';

typedef SettingsView = SettingsScreen;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: 'settings'),
      appBar: AppBar(title: const Text('Configuración')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  decoration: AppTheme.darkGlassDecoration,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PREFERENCIAS DEL SISTEMA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        value: _notificationsEnabled,
                        onChanged: (val) {
                          setState(() => _notificationsEnabled = val);
                        },
                        title: const Text(
                          'Notificaciones Push (FCM)',
                          style: TextStyle(color: AppTheme.textLight),
                        ),
                        subtitle: const Text(
                          'Recibir alertas de nuevos eventos e inscripciones',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        activeThumbColor: AppTheme.brandViolet,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: AppTheme.darkGlassDecoration,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'INFORMACIÓN DE LA API & SERVIDOR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(
                          Icons.cloud_outlined,
                          color: AppTheme.brandViolet,
                        ),
                        title: const Text(
                          'API Base URL',
                          style: TextStyle(color: AppTheme.textLight),
                        ),
                        subtitle: Text(
                          AppConfig.apiBaseUrl,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Divider(color: AppTheme.borderDark),
                      const ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: AppTheme.brandViolet,
                        ),
                        title: Text(
                          'Versión de la App',
                          style: TextStyle(color: AppTheme.textLight),
                        ),
                        subtitle: Text(
                          'v1.0.0 (Event Hub Flutter)',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
