import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  // Obfuscated representation of fallback: "https://event-hub-back.vercel.app/api/v1"
  // XOR key used: 90 (0x5A)
  static const int _xorKey = 90;
  static const List<int> _obfuscatedBaseUrl = [
    50,
    46,
    46,
    42,
    41,
    96,
    117,
    117,
    63,
    44,
    63,
    52,
    46,
    119,
    50,
    47,
    56,
    119,
    56,
    59,
    57,
    49,
    116,
    44,
    63,
    40,
    57,
    63,
    54,
    116,
    59,
    42,
    42,
    117,
    59,
    42,
    51,
    117,
    44,
    107,
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
    if (dotenv.isInitialized) {
      final String? dotEnvVal = dotenv.env['API_BASE_URL'];
      if (dotEnvVal != null && dotEnvVal.isNotEmpty) {
        return dotEnvVal;
      }
    }

    // 3. Fallback to XOR-obfuscated URL
    return decodeUrl(_obfuscatedBaseUrl, _xorKey);
  }
}
