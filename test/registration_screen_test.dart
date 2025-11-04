import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavajato/data/repositories/auth_repository_impl.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';
import 'package:lavajato/screens/auth/registration_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('RegistrationScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<AuthRepository>(
        create: (_) => AuthRepositoryImpl(),
        child: const MaterialApp(
          home: RegistrationScreen(),
        ),
      ),
    );

    // Verify that the name, email, and password fields are present.
    expect(find.widgetWithText(TextFormField, 'Nome'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);

    // Verify that the registration button is present.
    expect(find.widgetWithText(ElevatedButton, 'Cadastrar'), findsOneWidget);
  });
}
