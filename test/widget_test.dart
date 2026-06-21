import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventhubapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventhubapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventhubapp/features/auth/presentation/screens/login_screen.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<String> login(String email, String password) async => 'fake_token';

  @override
  Future<String> register(String nombre, String email, String password) async => 'fake_token';

  @override
  Future<void> saveSession(String token, String email) async {}

  @override
  Future<void> clearSession() async {}

  @override
  Future<String?> getToken() async => null;

  @override
  Future<String?> getEmail() async => null;
}

void main() {
  group('LoginScreen Widget Tests', () {
    late FakeAuthRepository fakeAuthRepository;
    late AuthBloc authBloc;

    setUp(() {
      fakeAuthRepository = FakeAuthRepository();
      authBloc = AuthBloc(authRepository: fakeAuthRepository);
    });

    tearDown(() {
      authBloc.close();
    });

    testWidgets('renders login screen layout and fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        RepositoryProvider<AuthRepository>.value(
          value: fakeAuthRepository,
          child: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const MaterialApp(
              home: LoginScreen(),
            ),
          ),
        ),
      );

      // Verify that the title and subtitle are rendered
      expect(find.text('EventHub'), findsOneWidget);
      expect(find.text('Inicia sesión en tu cuenta para continuar'), findsOneWidget);

      // Verify that text input fields are present
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Correo Electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);

      // Verify that the login button is present
      expect(find.widgetWithText(ElevatedButton, 'Iniciar Sesión'), findsOneWidget);
    });

    testWidgets('shows validation errors when fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        RepositoryProvider<AuthRepository>.value(
          value: fakeAuthRepository,
          child: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const MaterialApp(
              home: LoginScreen(),
            ),
          ),
        ),
      );

      // Click the login button without typing anything
      await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar Sesión'));
      await tester.pump();

      // Check if validation error text is displayed
      expect(find.text('El correo electrónico es obligatorio'), findsOneWidget);
      expect(find.text('La contraseña es obligatoria'), findsOneWidget);
    });

    testWidgets('shows error for invalid email structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        RepositoryProvider<AuthRepository>.value(
          value: fakeAuthRepository,
          child: BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const MaterialApp(
              home: LoginScreen(),
            ),
          ),
        ),
      );

      // Enter invalid email and valid password
      await tester.enterText(find.bySemanticsLabel('Correo Electrónico'), 'invalid-email');
      await tester.enterText(find.bySemanticsLabel('Contraseña'), '123456');

      // Click the login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar Sesión'));
      await tester.pump();

      // Check if email format validation error is shown
      expect(find.text('Ingrese un correo electrónico válido'), findsOneWidget);
      expect(find.text('La contraseña es obligatoria'), findsNothing);
    });
  });
}
