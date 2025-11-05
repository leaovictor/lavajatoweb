import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavajato/data/services/firestore_service.dart';
import 'package:lavajato/models/appointment_model.dart';
import 'package:lavajato/screens/admin/daily_appointments_view.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class MockFirestoreService extends Mock implements FirestoreService {
  final _controller = StreamController<QuerySnapshot>.broadcast();

  @override
  Stream<QuerySnapshot> getAllAppointmentsForDay(DateTime day) {
    final now = DateTime.now();
    final appointment = Appointment(
      id: '1',
      userId: 'test_user',
      serviceName: 'Lavagem Completa',
      startTime: now.add(const Duration(hours: 1)),
      endTime: now.add(const Duration(hours: 2)),
      carInfo: 'Fiat Uno - ABC-1234',
      status: 'Confirmado',
    );

    final fakeSnapshot = MockQuerySnapshot();
    final docs = [_getMockDocumentSnapshot(appointment)];
    when(fakeSnapshot.docs).thenReturn(docs);
    _controller.add(fakeSnapshot);
    return _controller.stream;
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
  testWidgets('DailyAppointmentsView allows cancelling an appointment', (WidgetTester tester) async {
    final mockFirestoreService = MockFirestoreService();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StreamProvider<QuerySnapshot>.value(
            value: mockFirestoreService.getAllAppointmentsForDay(DateTime.now()),
            initialData: MockQuerySnapshot(),
            child: const DailyAppointmentsView(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify the appointment is displayed
    expect(find.text('Lavagem Completa'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);

    // Tap the cancel button
    await tester.tap(find.text('Cancelar'));
    await tester.pump();

    // Verify that the cancelAppointment method was called
    verify(mockFirestoreService.cancelAppointment('1')).called(1);
  });
}
