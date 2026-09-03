import 'package:flutter_test/flutter_test.dart';
import 'package:stagesync/app.dart';

void main() {
  testWidgets('StageSyncApp boots and displays initial text', (WidgetTester tester) async {
    await tester.pumpWidget(const StageSyncApp());
    expect(find.text('StageSync'), findsOneWidget);
  });
}
