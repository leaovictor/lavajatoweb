import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavajato/screens/admin/admin_dashboard_screen.dart';

void main() {
  testWidgets('AdminDashboardScreen has tabs for appointments and clients', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AdminDashboardScreen(),
    ));

    expect(find.text('Dashboard Administrativo'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(find.text('Agendamentos do Dia'), findsOneWidget);
    expect(find.byIcon(Icons.people), findsOneWidget);
    expect(find.text('Clientes'), findsOneWidget);
  });
}
