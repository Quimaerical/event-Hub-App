import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';

class OAuthService {
  final ApiClient apiClient;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '859661498769-6cr9gfs0ckeehm0crafpvqmeg9fq91ev.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  OAuthService({required this.apiClient});

  /// Initiates Native Google Sign-In and exchanges profile with backend /api/v1/auth/oauth-login
  Future<Map<String, dynamic>?> loginWithGoogle() async {
    debugPrint('[OAuth Debug] ========================================');
    debugPrint('[OAuth Debug] STARTING NATIVE GOOGLE OAUTH FLOW');
    debugPrint('[OAuth Debug] API Base URL: ${AppConfig.apiBaseUrl}');

    try {
      debugPrint('[OAuth Debug] Prompting Google Native Account Selector...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('[OAuth Debug] Google Sign-In was cancelled by the user.');
        debugPrint('[OAuth Debug] ========================================');
        return null;
      }

      debugPrint('[OAuth Debug] Google Account Selected:');
      debugPrint('[OAuth Debug]   ID: ${googleUser.id}');
      debugPrint('[OAuth Debug]   Email: ${googleUser.email}');
      debugPrint('[OAuth Debug]   DisplayName: ${googleUser.displayName}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      debugPrint(
        '[OAuth Debug] Google idToken retrieved: ${googleAuth.idToken != null}',
      );

      final payload = {
        'provider': 'google',
        'email': googleUser.email,
        'name': googleUser.displayName ?? googleUser.email.split('@').first,
        'provider_id': googleUser.id,
      };

      debugPrint(
        '[OAuth Debug] Sending payload to Backend POST /api/v1/auth/oauth-login...',
      );
      final response = await apiClient.post('/auth/oauth-login', data: payload);

      debugPrint('[OAuth Debug] Backend OAuth Response Success:');
      debugPrint('[OAuth Debug]   Message: ${response['message']}');
      debugPrint(
        '[OAuth Debug]   Token Length: ${(response['token'] as String?)?.length ?? 0}',
      );
      debugPrint('[OAuth Debug] ========================================');

      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      debugPrint('[OAuth Debug] EXCEPTION during Native Google OAuth: $e');
      debugPrint('[OAuth Debug] Stack trace:\n$stackTrace');
      debugPrint('[OAuth Debug] ========================================');
      rethrow;
    }
  }

  /// Initiates GitHub OAuth Flow with full debug printing and backend token exchange
  Future<Map<String, dynamic>?> loginWithGitHub() async {
    debugPrint('[OAuth Debug] ========================================');
    debugPrint('[OAuth Debug] STARTING GITHUB OAUTH FLOW');
    debugPrint('[OAuth Debug] API Base URL: ${AppConfig.apiBaseUrl}');

    final authUrl = '${AppConfig.apiBaseUrl}/auth/github';
    debugPrint('[OAuth Debug] Target GitHub Auth URL: $authUrl');

    try {
      final uri = Uri.parse(authUrl);
      final canLaunch = await canLaunchUrl(uri);
      debugPrint('[OAuth Debug] Can launch URL ($uri): $canLaunch');

      if (canLaunch) {
        debugPrint(
          '[OAuth Debug] Launching GitHub OAuth URL in external browser...',
        );
        await launchUrl(uri, mode: LaunchMode.externalApplication);
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
