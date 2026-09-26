import 'package:flutter_test/flutter_test.dart';
import 'package:stagesync/app/app.dart';

void main() {
  testWidgets('StageFlow App launches and renders Logo Screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StageFlowApp());
    await tester.pumpAndSettle();

    expect(find.text('StageFlow'), findsOneWidget);
    expect(find.text('Enter Command Center'), findsOneWidget);
  });

  testWidgets('StageFlow App renders Login screen without ProviderNotFoundException when uninitialized', (WidgetTester tester) async {
    await tester.pumpWidget(const StageFlowApp(isFirebaseInitialized: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enter Command Center'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('PRODUCTION PORTAL • STAGE LIVE'), findsOneWidget);
  });
}
