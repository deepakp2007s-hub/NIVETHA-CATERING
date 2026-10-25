
import 'package:flutter_test/flutter_test.dart';
import 'package:nivetha_customer_flutter/main.dart';

void main() {
  testWidgets('Nivetha Catering app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const NivethaCustomerApp());

    await tester.pump();

    expect(find.byType(NivethaCustomerApp), findsOneWidget);
  });
}
