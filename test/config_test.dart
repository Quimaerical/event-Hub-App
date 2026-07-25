import 'package:flutter_test/flutter_test.dart';
import 'package:eventhubapp/core/config/app_config.dart';

void main() {
  test('AppConfig decodeUrl decrypts production URL correctly', () {
    const targetUrl = 'https://event-hub-back.vercel.app/api/v1';
    const key = 90;
    final obfuscated = targetUrl.codeUnits.map((c) => c ^ key).toList();

    final decoded = AppConfig.decodeUrl(obfuscated, key);
    expect(decoded, equals(targetUrl));
  });

  test('AppConfig apiBaseUrl returns production URL by default', () {
    expect(
      AppConfig.apiBaseUrl,
      equals('https://event-hub-back.vercel.app/api/v1'),
    );
  });
}
