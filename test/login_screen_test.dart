import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavajato/screens/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Verify that the title is rendered.
    expect(find.text('Bem-vindo ao LavaJato'), findsOneWidget);

    // Verify that the email and password fields are rendered.
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);

    // Verify that the login and sign up buttons are rendered.
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Não tem uma conta? Cadastre-se'),
        findsOneWidget);
  });
}
