import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavajato/screens/appointments/my_appointments_screen.dart';
import 'package.flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';
import 'package:lavajato/domain/repositories/appointment_repository.dart';

// Mocks
class MockAuthRepository extends Mock implements AuthRepository {}
class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  testWidgets('MyAppointmentsScreen renders correctly', (WidgetTester tester) async {
    // Create mock repositories
    final mockAuthRepository = MockAuthRepository();
    final mockAppointmentRepository = MockAppointmentRepository();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: mockAuthRepository),
          Provider<AppointmentRepository>.value(value: mockAppointmentRepository),
        ],
        child: const MaterialApp(
          home: MyAppointmentsScreen(),
        ),
      ),
    );

    // Verify that the title is rendered.
    expect(find.text('Meus Agendamentos'), findsOneWidget);

    // Verify that the tabs are rendered.
    expect(find.text('Próximos'), findsOneWidget);
    expect(find.text('Histórico'), findsOneWidget);
  });
}
