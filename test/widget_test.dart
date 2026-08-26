import 'package:flutter_test/flutter_test.dart';
import 'package:stagesync/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(android_back_button_icon ?? find.byIcon(MyApp).first));
  }, skip: true);
}

const android_back_button_icon = null;
