import 'package:flutter/material.dart';
import 'package.flutter_test/flutter_test.dart';
import 'package:lavajato/data/services/firestore_service.dart';
import 'package:lavajato/models/plan_model.dart';
import 'package:lavajato/screens/subscription/subscription_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class MockFirestoreService extends Mock implements FirestoreService {
  @override
  Stream<QuerySnapshot> getSubscriptionPlans() {
    final plan1 = Plan(
      id: '1',
      name: 'Plano Básico',
      description: 'Lavagem simples',
      price: 25.0,
      stripePriceId: 'price_123',
    );
    final plan2 = Plan(
      id: '2',
      name: 'Plano Premium',
      description: 'Lavagem completa',
      price: 50.0,
      stripePriceId: 'price_456',
    );

    final fakeSnapshot = MockQuerySnapshot();
    final docs = [
      _getMockDocumentSnapshot(plan1),
      _getMockDocumentSnapshot(plan2),
    ];

    when(fakeSnapshot.docs).thenReturn(docs);

    return Stream.value(fakeSnapshot);
  }

  MockDocumentSnapshot _getMockDocumentSnapshot(Plan plan) {
    final mockDoc = MockDocument-Snapshot();
    when(mockDoc.id).thenReturn(plan.id);
    when(mockDoc.data()).thenReturn({
      'name': plan.name,
      'description': plan.description,
      'price': plan.price,
      'stripePriceId': plan.stripePriceId,
    });
    return mockDoc;
  }
}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}


void main() {
  testWidgets('SubscriptionScreen shows a list of plans', (WidgetTester tester) async {
    final mockFirestoreService = MockFirestoreService();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StreamProvider<QuerySnapshot>.value(
            value: mockFirestoreService.getSubscriptionPlans(),
            initialData: MockQuerySnapshot(),
            child: const SubscriptionScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Plano Básico'), findsOneWidget);
    expect(find.text('Plano Premium'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Assinar'), findsNWidgets(2));
  });
}
