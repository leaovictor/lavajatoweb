import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavajato/screens/booking/select_service_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:lavajato/domain/repositories/service_repository.dart';

// Mocks
class MockServiceRepository extends Mock implements ServiceRepository {}

void main() {
  testWidgets('SelectServiceScreen renders correctly', (WidgetTester tester) async {
    // Create mock repository
    final mockServiceRepository = MockServiceRepository();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ServiceRepository>.value(value: mockServiceRepository),
        ],
        child: const MaterialApp(
          home: SelectServiceScreen(),
        ),
      ),
    );

    // Verify that the title is rendered.
    expect(find.text('Selecione um Serviço'), findsOneWidget);
  });
}
