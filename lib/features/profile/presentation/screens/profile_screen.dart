import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_drawer.dart';

typedef ProfileView = ProfileScreen;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiClient = ApiClient();
  final _deptController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _deptController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.get('/auth/me');
      if (res is Map<String, dynamic> && res.containsKey('user')) {
        final user = res['user'] as Map<String, dynamic>;
        _deptController.text = user['departamento']?.toString() ?? '';
        _phoneController.text = user['telefono']?.toString() ?? '';
      }
    } catch (_) {
      // Fallback defaults
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);
    try {
      await _apiClient.put(
        '/perfil',
        data: {
          'departamento': _deptController.text.trim(),
          'telefono': _phoneController.text.trim(),
        },
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: AppTheme.accentEmerald,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error al actualizar perfil: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: 'profile'),
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.brandViolet),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: AppTheme.darkGlassDecoration,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.brandDeep,
                          child: Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Detalles de tu Perfil',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'DEPARTAMENTO / ÁREA',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _deptController,
                          decoration: const InputDecoration(
                            hintText: 'Ej. Ingeniería en Computación',
                            prefixIcon: Icon(
                              Icons.business_outlined,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'TELÉFONO DE CONTACTO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Ej. +584141234567',
                            prefixIcon: Icon(
                              Icons.phone_outlined,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton.icon(
                          onPressed: _updateProfile,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Guardar Cambios'),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
