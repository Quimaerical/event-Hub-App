import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  // Obfuscated representation of fallback: "http://10.0.2.2:8080"
  // XOR key used: 90 (0x5A)
  static const int _xorKey = 90;
  static const List<int> _obfuscatedBaseUrl = [
    50,
    46,
    46,
    42,
    96,
    117,
    117,
    107,
    106,
    116,
    106,
    116,
    104,
    116,
    104,
    96,
    98,
    106,
    98,
    106,
  ];

  /// Decrypts an obfuscated URL using the XOR key.
  static String decodeUrl(List<int> codes, int key) {
    return String.fromCharCodes(codes.map((c) => c ^ key));
  }

  /// Resolves the API base URL checking compile time environment flag,
  /// followed by dotenv and fallback decoded from XOR representation.
  static String get apiBaseUrl {
    // 1. Check compile-time environment flag (e.g. --dart-define=API_BASE_URL=...)
    const String envFlag = String.fromEnvironment('API_BASE_URL');
    if (envFlag.isNotEmpty) {
      return envFlag;
    }

    // 2. Check dotenv fallback
    final String? dotEnvVal = dotenv.env['API_BASE_URL'];
    if (dotEnvVal != null && dotEnvVal.isNotEmpty) {
      return dotEnvVal;
    }

    // 3. Fallback to XOR-obfuscated URL
    return decodeUrl(_obfuscatedBaseUrl, _xorKey);
  }
}
