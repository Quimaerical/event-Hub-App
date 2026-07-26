import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../utils/constants.dart';
import 'exceptions.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ApiClient({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    final baseUrl = AppConfig.apiBaseUrl;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectTimeoutMs,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeoutMs,
        ),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Dynamic Interceptors mapping token authorization to Go headers and handling errors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          final apiException = _mapDioException(e);
          // Throwing the ApiException propagates it directly to the caller
          throw apiException;
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return response.data;
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return response.data;
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return response.data;
  }

  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return response.data;
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return response.data;
  }

  ApiException _mapDioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const ApiException(
        'Tiempo de espera de conexión agotado. Intente de nuevo.',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return const ApiException(
        'Error de conexión. Compruebe su internet y verifique si el servidor Go está encendido.',
      );
    }

    if (statusCode == null) {
      return ApiException(
        error.message ?? 'Ocurrió un error de red inesperado.',
      );
    }

    switch (statusCode) {
      case 401:
        String message = 'No autorizado. Por favor inicie sesión de nuevo.';
        if (data is Map && data.containsKey('error')) {
          message = data['error'].toString();
        }
        return UnauthorizedException(message);

      case 429:
        String message =
            'Demasiadas solicitudes. Por favor, inténtelo más tarde.';
        if (data is Map && data.containsKey('error')) {
          message = data['error'].toString();
        }
        return RateLimitException(message);

      case 400:
      case 422:
        final validationErrors = _parseValidationErrors(data);
        String message = 'Error de validación en la solicitud.';
        if (data is Map && data.containsKey('message')) {
          message = data['message'].toString();
        } else if (data is Map &&
            data.containsKey('error') &&
            data['error'] is String) {
          message = data['error'].toString();
        }

        if (validationErrors.isNotEmpty) {
          return ValidationException(message, errors: validationErrors);
        }
        return ApiException(message, statusCode: statusCode);

      case 500:
      case 502:
      case 503:
      case 504:
        return const ServerException('Error interno del servidor backend.');

      default:
        String message = 'Error del servidor: $statusCode';
        if (data is Map && data.containsKey('error')) {
          message = data['error'].toString();
        }
        return ApiException(message, statusCode: statusCode);
    }
  }

  Map<String, List<String>> _parseValidationErrors(dynamic data) {
    final Map<String, List<String>> parsedErrors = {};

    if (data is Map) {
      if (data.containsKey('errors')) {
        final errorsObj = data['errors'];
        if (errorsObj is Map) {
          errorsObj.forEach((key, value) {
            if (value is List) {
              parsedErrors[key.toString()] = value
                  .map((e) => e.toString())
                  .toList();
            } else if (value != null) {
              parsedErrors[key.toString()] = [value.toString()];
            }
          });
        } else if (errorsObj is String) {
          parsedErrors['general'] = [errorsObj];
        }
      } else if (data.containsKey('error')) {
        final errorObj = data['error'];
        if (errorObj is Map) {
          errorObj.forEach((key, value) {
            if (value is List) {
              parsedErrors[key.toString()] = value
                  .map((e) => e.toString())
                  .toList();
            } else if (value != null) {
              parsedErrors[key.toString()] = [value.toString()];
            }
          });
        } else if (errorObj != null) {
          parsedErrors['general'] = [errorObj.toString()];
        }
      } else {
        data.forEach((key, value) {
          if (value is List) {
            parsedErrors[key.toString()] = value
                .map((e) => e.toString())
                .toList();
          } else if (value != null && value is! Map) {
            parsedErrors[key.toString()] = [value.toString()];
          }
        });
      }
    }

    return parsedErrors;
  }
}
