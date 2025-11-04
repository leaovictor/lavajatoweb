import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavajato/data/repositories/auth_repository_impl.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';
import 'package:lavajato/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('LoginScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<AuthRepository>(
        create: (_) => AuthRepositoryImpl(),
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify that the email and password fields are present.
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);

    // Verify that the login and Google sign-in buttons are present.
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Entrar com Google'), findsOneWidget);
  });
}
