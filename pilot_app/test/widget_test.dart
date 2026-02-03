import 'package:flutter_test/flutter_test.dart';
import 'package:sendit_pilot/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SendItPilotApp());
    // Basic smoke test - app should render
    expect(find.text('SendIt Pilot'), findsOneWidget);
  });
}
