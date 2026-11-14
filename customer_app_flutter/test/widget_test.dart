import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app_flutter/main.dart';

void main() {
  testWidgets('Nivetha Catering App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NivethaCateringApp());
    await tester.pump();

    // Verify app renders correctly
    expect(find.byType(NivethaCateringApp), findsOneWidget);
  });
}
