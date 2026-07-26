import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';

class OAuthService {
  final ApiClient apiClient;

  OAuthService({required this.apiClient});

  /// Initiates Google OAuth Login flow with full debug printing
  Future<Map<String, dynamic>?> loginWithGoogle() async {
    debugPrint('[OAuth Debug] ========================================');
    debugPrint('[OAuth Debug] STARTING GOOGLE OAUTH FLOW');
    debugPrint('[OAuth Debug] API Base URL: ${AppConfig.apiBaseUrl}');

    // Construct Google Auth web URL endpoint
    final authUrl = '${AppConfig.apiBaseUrl}/auth/google';
    debugPrint('[OAuth Debug] Target Google Auth URL: $authUrl');

    try {
      final uri = Uri.parse(authUrl);
      debugPrint('[OAuth Debug] Parsed URI: $uri');

      final canLaunch = await canLaunchUrl(uri);
      debugPrint('[OAuth Debug] Can launch URL ($uri): $canLaunch');

      if (canLaunch) {
        debugPrint(
          '[OAuth Debug] Launching Google OAuth URL in external browser/tab...',
        );
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('[OAuth Debug] URL launch result: $launched');
      } else {
        debugPrint('[OAuth Debug] ERROR: System cannot launch URL: $authUrl');
      }
    } catch (e, stackTrace) {
      debugPrint('[OAuth Debug] EXCEPTION during Google OAuth launch: $e');
      debugPrint('[OAuth Debug] Stack trace:\n$stackTrace');
    }

    debugPrint('[OAuth Debug] ========================================');
    return null;
  }

  /// Initiates GitHub OAuth Login flow with full debug printing
  Future<Map<String, dynamic>?> loginWithGitHub() async {
    debugPrint('[OAuth Debug] ========================================');
    debugPrint('[OAuth Debug] STARTING GITHUB OAUTH FLOW');
    debugPrint('[OAuth Debug] API Base URL: ${AppConfig.apiBaseUrl}');

    // Construct GitHub Auth web URL endpoint
    final authUrl = '${AppConfig.apiBaseUrl}/auth/github';
    debugPrint('[OAuth Debug] Target GitHub Auth URL: $authUrl');

    try {
      final uri = Uri.parse(authUrl);
      debugPrint('[OAuth Debug] Parsed URI: $uri');

      final canLaunch = await canLaunchUrl(uri);
      debugPrint('[OAuth Debug] Can launch URL ($uri): $canLaunch');

      if (canLaunch) {
        debugPrint(
          '[OAuth Debug] Launching GitHub OAuth URL in external browser/tab...',
        );
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('[OAuth Debug] URL launch result: $launched');
      } else {
        debugPrint('[OAuth Debug] ERROR: System cannot launch URL: $authUrl');
      }
    } catch (e, stackTrace) {
      debugPrint('[OAuth Debug] EXCEPTION during GitHub OAuth launch: $e');
      debugPrint('[OAuth Debug] Stack trace:\n$stackTrace');
    }

    debugPrint('[OAuth Debug] ========================================');
    return null;
  }
}
