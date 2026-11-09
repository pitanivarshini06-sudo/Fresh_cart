
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_cart/main.dart';

void main() {
  testWidgets('FreshCart app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('FreshCart'), findsWidgets);
  });
}
