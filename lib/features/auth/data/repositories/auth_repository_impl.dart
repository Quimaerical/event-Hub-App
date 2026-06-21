import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/constants.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.apiClient,
    required this.secureStorage,
  });

  @override
  Future<String> login(String email, String password) async {
    try {
      // Send credentials URL-encoded matching Gin c.PostForm
      final response = await apiClient.dio.post(
        AppConstants.login,
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false, // intercept the cookie before redirecting
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      // Attempt to extract from cookies
      String? token = _extractTokenFromCookies(response.headers['set-cookie']);

      // Fallback: check JSON response
      if (token == null && response.data is Map) {
        token = response.data['token']?.toString();
      }

      if (token == null) {
        throw const HttpException('Credenciales inválidas o sesión fallida.');
      }

      await saveSession(token, email);
      return token;
    } on DioException catch (e) {
      throw HttpException(e.error?.toString() ?? 'Error al iniciar sesión');
    }
  }

  @override
  Future<String> register(String nombre, String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        AppConstants.register,
        data: {
          'nombre': nombre,
          'email': email,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      String? token = _extractTokenFromCookies(response.headers['set-cookie']);
      if (token == null && response.data is Map) {
        token = response.data['token']?.toString();
      }

      if (token == null) {
        throw const HttpException('Error al crear la cuenta. Compruebe los datos e intente de nuevo.');
      }

      await saveSession(token, email);
      return token;
    } on DioException catch (e) {
      throw HttpException(e.error?.toString() ?? 'Error al registrar el usuario');
    }
  }

  @override
  Future<void> saveSession(String token, String email) async {
    await secureStorage.write(key: AppConstants.tokenKey, value: token);
    await secureStorage.write(key: AppConstants.emailKey, value: email);
  }

  @override
  Future<void> clearSession() async {
    await secureStorage.delete(key: AppConstants.tokenKey);
    await secureStorage.delete(key: AppConstants.emailKey);
    await secureStorage.delete(key: AppConstants.userIdKey);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: AppConstants.tokenKey);
  }

  @override
  Future<String?> getEmail() async {
    return await secureStorage.read(key: AppConstants.emailKey);
  }

  String? _extractTokenFromCookies(List<String>? setCookieHeaders) {
    if (setCookieHeaders == null) return null;
    for (var header in setCookieHeaders) {
      final parts = header.split(';');
      if (parts.isNotEmpty) {
        final cookie = parts[0];
        final kv = cookie.split('=');
        if (kv.length == 2 && kv[0].trim() == 'session_token') {
          return kv[1].trim();
        }
      }
    }
    return null;
  }
}
