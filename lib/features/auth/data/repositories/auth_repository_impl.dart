import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/constants.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({required this.apiClient, required this.secureStorage});

  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        AppConstants.login,
        data: {'email': email, 'password': password},
      );

      String? token;
      int? userId;

      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        token = data['token']?.toString();
        if (data['user'] is Map) {
          userId = data['user']['id'] as int?;
        }
      }

      if (token == null || token.isEmpty) {
        throw const HttpException('Credenciales inválidas o sesión fallida.');
      }

      await saveSession(token, email, userId: userId);
      return token;
    } on DioException catch (e) {
      final message =
          e.response?.data is Map && e.response?.data['error'] != null
          ? e.response!.data['error'].toString()
          : (e.error?.toString() ?? 'Error al iniciar sesión');
      throw HttpException(message);
    }
  }

  @override
  Future<String> register(String nombre, String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        AppConstants.register,
        data: {'nombre': nombre, 'email': email, 'password': password},
      );

      String? token;
      int? userId;

      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        token = data['token']?.toString();
        if (data['user'] is Map) {
          userId = data['user']['id'] as int?;
        }
      }

      if (token == null || token.isEmpty) {
        throw const HttpException(
          'Error al crear la cuenta. Compruebe los datos e intente de nuevo.',
        );
      }

      await saveSession(token, email, userId: userId);
      return token;
    } on DioException catch (e) {
      final message =
          e.response?.data is Map && e.response?.data['error'] != null
          ? e.response!.data['error'].toString()
          : (e.error?.toString() ?? 'Error al registrar el usuario');
      throw HttpException(message);
    }
  }

  @override
  Future<void> saveSession(String token, String email, {int? userId}) async {
    await secureStorage.write(key: AppConstants.tokenKey, value: token);
    await secureStorage.write(key: AppConstants.emailKey, value: email);
    if (userId != null) {
      await secureStorage.write(
        key: AppConstants.userIdKey,
        value: userId.toString(),
      );
    }
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
}
