import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavajato/data/repositories/auth_repository_impl.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';
import 'package:lavajato/models/service_model.dart';
import 'package:lavajato/screens/scheduling/scheduling_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('SchedulingScreen renders correctly', (WidgetTester tester) async {
    final service = Service(id: '1', name: 'Lavagem Simples', description: 'Lavagem simples', price: 25.0, duration: 30);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>(create: (_) => AuthRepositoryImpl()),
        ],
        child: MaterialApp(
          home: SchedulingScreen(service: service),
        ),
      ),
    );

    // Verify that the calendar is present.
    expect(find.byType(TableCalendar), findsOneWidget);

    // Verify that the vehicle dropdown is present.
    expect(find.text('Selecione um Veículo'), findsOneWidget);

    // Verify that the time slots section is present.
    expect(find.text('Horários Disponíveis'), findsOneWidget);

    // Verify that the confirm button is present.
    expect(find.widgetWithText(ElevatedButton, 'Ir para Pagamento'), findsOneWidget);
  });
}
