// ignore_for_file: must_be_immutable
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavajato/domain/entities/car_entity.dart';
import 'package:lavajato/domain/entities/user_entity.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';
import 'package:lavajato/screens/profile/profile_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {
  final _userController = StreamController<UserEntity?>.broadcast();
  final _carsController = StreamController<List<CarEntity>>.broadcast();

  MockAuthRepository() {
    _userController.add(
      UserEntity(
        id: '123',
        name: 'Test User',
        email: 'test@example.com',
        phone: '123456789',
        address: '123 Test St',
      ),
    );
    _carsController.add([]); // Start with an empty list of cars
  }

  @override
  Stream<UserEntity?> get user => _userController.stream;

  @override
  Stream<List<CarEntity>> getCars(String userId) => _carsController.stream;
}

void main() {
  testWidgets('ProfileScreen shows user data correctly in TextFormFields',
      (WidgetTester tester) async {
    final mockAuthRepository = MockAuthRepository();

    await tester.pumpWidget(
      Provider<AuthRepository>.value(
        value: mockAuthRepository,
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    // Wait for the stream to emit data and the UI to build
    await tester.pumpAndSettle();

    // Verify user information is displayed in the TextFormFields
    expect(
        (tester.widget(find.widgetWithText(TextFormField, 'Nome'))
                as TextFormField)
            .controller
            ?.text,
        'Test User');
    expect(
        (tester.widget(find.widgetWithText(TextFormField, 'Telefone'))
                as TextFormField)
            .controller
            ?.text,
        '123456789');
    expect(
        (tester.widget(find.widgetWithText(TextFormField, 'Endereço'))
                as TextFormField)
            .controller
            ?.text,
        '123 Test St');

    // Verify the car list placeholder and button are present
    expect(find.text('Nenhum veículo cadastrado.'), findsOneWidget);
    expect(
        find.widgetWithText(ElevatedButton, 'Adicionar Veículo'), findsOneWidget);
  });
}
