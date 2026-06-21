import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/events/presentation/bloc/event_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load local configurations
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Fallback if .env fails to load
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Initialize core network and secure storage
    const secureStorage = FlutterSecureStorage();
    final apiClient = ApiClient(secureStorage: secureStorage);
    final authRepository = AuthRepositoryImpl(
      apiClient: apiClient,
      secureStorage: secureStorage,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>.value(value: apiClient),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository: authRepository)..add(CheckAuthStatus()),
          ),
          BlocProvider<DashboardBloc>(
            create: (context) => DashboardBloc(apiClient: apiClient),
          ),
          BlocProvider<EventBloc>(
            create: (context) => EventBloc(apiClient: apiClient),
          ),
        ],
        child: MaterialApp(
          title: 'Event Hub',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const AuthGate(),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const DashboardScreen();
        } else if (state is Unauthenticated || state is AuthFailure) {
          return const LoginScreen();
        }
        
        // Splash / Loader
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'EventHub',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryViolet,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 24),
                CircularProgressIndicator(color: AppTheme.primaryViolet),
              ],
            ),
          ),
        );
      },
    );
  }
}
