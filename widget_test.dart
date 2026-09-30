import 'package:flutter_test/flutter_test.dart';
import 'package:smart_calculator/main.dart';

void main() {
  testWidgets('2 + 3 = 5', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await tester.tap(find.text('2'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('3'));
    await tester.tap(find.text('='));
    await tester.pump();
    expect(find.text('5'), findsWidgets);
  });
}
