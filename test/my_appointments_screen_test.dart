import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavajato/data/services/firestore_service.dart';
import 'package:lavajato/models/appointment_model.dart';
import 'package:lavajato/screens/appointments/my_appointments_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class MockFirestoreService extends Mock implements FirestoreService {
  @override
  Stream<QuerySnapshot> getMyAppointments(String userId) {
    final now = DateTime.now();
    final upcomingAppointment = Appointment(
      id: '1',
      userId: userId,
      serviceName: 'Lavagem Completa',
      startTime: now.add(const Duration(days: 1)),
      endTime: now.add(const Duration(days: 1, hours: 1)),
      carInfo: 'Fiat Uno - ABC-1234',
    );
    final pastAppointment = Appointment(
      id: '2',
      userId: userId,
      serviceName: 'Polimento',
      startTime: now.subtract(const Duration(days: 1)),
      endTime: now.subtract(const Duration(days: 1, hours: -1)),
      carInfo: 'VW Gol - XYZ-5678',
    );

    final fakeSnapshot = MockQuerySnapshot();
    final docs = [
      _getMockDocumentSnapshot(upcomingAppointment),
      _getMockDocumentSnapshot(pastAppointment),
    ];

    when(fakeSnapshot.docs).thenReturn(docs);

    return Stream.value(fakeSnapshot);
  }

  MockDocumentSnapshot _getMockDocumentSnapshot(Appointment appointment) {
    final mockDoc = MockDocumentSnapshot();
    when(mockDoc.id).thenReturn(appointment.id);
    when(mockDoc.data()).thenReturn(appointment.toMap());
    return mockDoc;
  }
}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}


void main() {
  testWidgets('MyAppointmentsScreen shows upcoming and past appointments', (WidgetTester tester) async {
    final mockFirestoreService = MockFirestoreService();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StreamProvider<QuerySnapshot>.value(
            value: mockFirestoreService.getMyAppointments('test_user'),
            initialData: MockQuerySnapshot(),
            child: const MyAppointmentsScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Próximos Agendamentos'), findsOneWidget);
    expect(find.text('Agendamentos Passados'), findsOneWidget);
    expect(find.text('Lavagem Completa'), findsOneWidget);
    expect(find.text('Polimento'), findsOneWidget);
  });
}
