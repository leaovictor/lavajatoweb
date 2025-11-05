import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavajato/domain/entities/service_entity.dart';
import 'package:lavajato/screens/booking/select_date_time_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:lavajato/domain/repositories/appointment_repository.dart';

// Mocks
class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  testWidgets('SelectDateTimeScreen renders correctly', (WidgetTester tester) async {
    // Create mock repository
    final mockAppointmentRepository = MockAppointmentRepository();
    final service = ServiceEntity(id: '1', name: 'Test Service', price: 50.0, durationInMinutes: 60);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppointmentRepository>.value(value: mockAppointmentRepository),
        ],
        child: MaterialApp(
          home: SelectDateTimeScreen(service: service),
        ),
      ),
    );

    // Verify that the title is rendered.
    expect(find.text('Selecione Data e Hora'), findsOneWidget);

    // Verify that the calendar is rendered.
    expect(find.byType(TableCalendar), findsOneWidget);
  });
}
