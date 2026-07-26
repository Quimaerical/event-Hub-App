class AppConstants {
  // Storage Keys
  static const String tokenKey = 'session_token';
  static const String emailKey = 'user_email';
  static const String userIdKey = 'user_id';

  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String fcmToken = '/auth/fcm-token';
  static const String events = '/eventos';
  static const String createEvent = '/eventos';
  static const String suggestDescription = '/eventos/sugerir-descripcion';
  static const String categories = '/categorias';
  static const String spaces = '/espacios';
  static const String tablon = '/tablon';

  // Local Config
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;
}
