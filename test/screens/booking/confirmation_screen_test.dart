import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavajato/domain/entities/service_entity.dart';
import 'package:lavajato/screens/booking/confirmation_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:lavajato/domain/repositories/appointment_repository.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';

// Mocks
class MockAppointmentRepository extends Mock implements AppointmentRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('ConfirmationScreen renders correctly', (WidgetTester tester) async {
    // Create mock repositories
    final mockAppointmentRepository = MockAppointmentRepository();
    final mockAuthRepository = MockAuthRepository();
    final service = ServiceEntity(id: '1', name: 'Test Service', price: 50.0, durationInMinutes: 60);
    final selectedDateTime = DateTime.now();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppointmentRepository>.value(value: mockAppointmentRepository),
          Provider<AuthRepository>.value(value: mockAuthRepository),
        ],
        child: MaterialApp(
          home: ConfirmationScreen(service: service, selectedDateTime: selectedDateTime),
        ),
      ),
    );

    // Verify that the title is rendered.
    expect(find.text('Confirme seu Agendamento'), findsOneWidget);

    // Verify that the service name is rendered.
    expect(find.text('Test Service'), findsOneWidget);
  });
}
