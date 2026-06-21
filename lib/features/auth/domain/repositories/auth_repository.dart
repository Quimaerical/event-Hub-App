import 'package:flutter/foundation.dart';

@immutable
abstract class AuthRepository {
  // Submit credentials to backend and retrieve a JWT token string
  Future<String> login(String email, String password);
  
  // Create a new user profile
  Future<String> register(String nombre, String email, String password);
  
  // Persist session tokens securely
  Future<void> saveSession(String token, String email);
  
  // Clear persistent tokens
  Future<void> clearSession();
  
  // Get active session token
  Future<String?> getToken();
  
  // Get active user email
  Future<String?> getEmail();
}
