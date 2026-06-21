import 'package:flutter/foundation.dart';

@immutable
abstract class AuthEvent {}

// Check if user session token already exists in secure storage
class CheckAuthStatus extends AuthEvent {}

// Submit local email/password credentials to login
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

// Register a new profile using email/password
class RegisterRequested extends AuthEvent {
  final String nombre;
  final String email;
  final String password;

  RegisterRequested({
    required this.nombre,
    required this.email,
    required this.password,
  });
}

// Delete session tokens and logout
class LogoutRequested extends AuthEvent {}
