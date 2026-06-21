import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ApiClient({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Dynamic Interceptors mapping token authorization to Go headers
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
          final message = _handleError(e);
          final customException = DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: message,
          );
          return handler.next(customException);
        },
      ),
    );
  }

  Dio get dio => _dio;

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tiempo de espera de conexión agotado. Intente de nuevo.';
      case DioExceptionType.sendTimeout:
        return 'Tiempo de espera de envío agotado. Intente de nuevo.';
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de espera de recepción agotado. Intente de nuevo.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        if (data is Map && data.containsKey('error')) {
          return data['error'].toString();
        }
        if (statusCode == 401) {
          return 'No autorizado. Por favor inicie sesión de nuevo.';
        } else if (statusCode == 403) {
          return 'Acceso denegado. No posee privilegios suficentes.';
        } else if (statusCode == 404) {
          return 'El recurso solicitado no fue encontrado.';
        } else if (statusCode == 500) {
          return 'Error interno del servidor backend.';
        }
        return 'Error de servidor no catalogado: $statusCode';
      case DioExceptionType.cancel:
        return 'La solicitud de red fue cancelada.';
      case DioExceptionType.connectionError:
        return 'Error de conexión. Compruebe su internet y verifique si el servidor Go está encendido.';
      default:
        return 'Ocurrió un error inesperado al conectar con el servidor.';
    }
  }
}
