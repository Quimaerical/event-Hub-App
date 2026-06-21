class AppConstants {
  // Storage Keys
  static const String tokenKey = 'session_token';
  static const String emailKey = 'user_email';
  static const String userIdKey = 'user_id';

  // API Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String events = '/eventos';
  static const String createEvent = '/eventos/crear';
  static const String suggestDescription = '/eventos/sugerir-descripcion';
  
  // Local Config
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;
}
