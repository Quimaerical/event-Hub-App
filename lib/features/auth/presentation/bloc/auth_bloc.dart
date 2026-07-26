import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/oauth_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  late final OAuthService _oAuthService;

  AuthBloc({required this.authRepository, OAuthService? oAuthService})
    : super(AuthInitial()) {
    _oAuthService = oAuthService ?? OAuthService(apiClient: ApiClient());
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<GoogleOAuthRequested>(_onGoogleOAuthRequested);
    on<GitHubOAuthRequested>(_onGitHubOAuthRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final token = await authRepository.getToken();
      final email = await authRepository.getEmail();
      if (token != null && email != null) {
        emit(Authenticated(email: email));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.login(event.email, event.password);
      emit(Authenticated(email: event.email));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.register(event.nombre, event.email, event.password);
      emit(Authenticated(email: event.email));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onGoogleOAuthRequested(
    GoogleOAuthRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AuthBloc Debug] Processing GoogleOAuthRequested event...');
    emit(AuthLoading());
    try {
      final res = await _oAuthService.loginWithGoogle();
      if (res != null && res.containsKey('token')) {
        final token = res['token'].toString();
        final user = res['user'] as Map<String, dynamic>?;
        final email = user?['email']?.toString() ?? 'google_user';
        final userId = user?['id'] as int?;
        final userRole = user?['role_nombre']?.toString();

        await authRepository.saveSession(token, email);
        emit(Authenticated(email: email, userId: userId, userRole: userRole));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      debugPrint('[AuthBloc Debug] Google OAuth Error: $e');
      emit(AuthFailure(error: 'Error al iniciar sesión con Google: $e'));
    }
  }

  Future<void> _onGitHubOAuthRequested(
    GitHubOAuthRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AuthBloc Debug] Processing GitHubOAuthRequested event...');
    try {
      await _oAuthService.loginWithGitHub();
    } catch (e) {
      debugPrint('[AuthBloc Debug] GitHub OAuth Error: $e');
      emit(AuthFailure(error: 'Error al iniciar sesión con GitHub: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.clearSession();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }
}
