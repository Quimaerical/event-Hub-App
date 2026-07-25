import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';

/// Alias for conventional naming
typedef RegisterView = RegisterScreen;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        RegisterRequested(
          nombre: _nombreController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarse'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
              (route) => false,
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                decoration: AppTheme.darkGlassDecoration,
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _RegisterHeader(),
                      const SizedBox(height: 28),
                      const _RegisterInputLabel(label: 'NOMBRE COMPLETO'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nombreController,
                        validator: (val) =>
                            AppValidators.validateRequired(val, 'El nombre'),
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          hintText: 'Ej. Juan Pérez',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _RegisterInputLabel(label: 'CORREO ELECTRÓNICO'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        validator: AppValidators.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'ejemplo@correo.com',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _RegisterInputLabel(label: 'CONTRASEÑA'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        validator: AppValidators.validatePassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Mínimo 6 caracteres',
                          prefixIcon: Icon(
                            Icons.lock_outlined,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _RegisterSubmitButton(onPressed: _submit),
                      const SizedBox(height: 24),
                      const _RegisterOAuthSection(),
                      const SizedBox(height: 24),
                      const _LoginFooterLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'CREAR CUENTA',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textLight,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Regístrate para comenzar a crear y unirte a eventos',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}

class _RegisterInputLabel extends StatelessWidget {
  final String label;

  const _RegisterInputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppTheme.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _RegisterSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RegisterSubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.skyBlue),
          );
        }
        return ElevatedButton(
          onPressed: onPressed,
          child: const Text('Registrarse'),
        );
      },
    );
  }
}

class _RegisterOAuthSection extends StatelessWidget {
  const _RegisterOAuthSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider(color: AppTheme.borderDark)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'O REGISTRARSE CON',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppTheme.borderDark)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Redirigiendo a Google OAuth...'),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.g_mobiledata,
                  color: AppTheme.skyBlue,
                  size: 22,
                ),
                label: const Text(
                  'Google',
                  style: TextStyle(color: AppTheme.textLight, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.borderDark),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Redirigiendo a GitHub OAuth...'),
                    ),
                  );
                },
                icon: const Icon(Icons.code, color: AppTheme.skyBlue, size: 18),
                label: const Text(
                  'GitHub',
                  style: TextStyle(color: AppTheme.textLight, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.borderDark),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoginFooterLink extends StatelessWidget {
  const _LoginFooterLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '¿Ya tienes cuenta? ',
          style: TextStyle(color: AppTheme.textMuted),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Inicia Sesión',
            style: TextStyle(
              color: AppTheme.skyBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
