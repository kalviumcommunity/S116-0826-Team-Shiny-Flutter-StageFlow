import 'package:flutter_test/flutter_test.dart';
import 'package:stagesync/app/app.dart';

void main() {
  testWidgets('StageFlow App launches and renders Logo Screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StageFlowApp());
    await tester.pumpAndSettle();

    expect(find.text('StageFlow'), findsOneWidget);
    expect(find.text('Enter Command Center'), findsOneWidget);
  });
}
