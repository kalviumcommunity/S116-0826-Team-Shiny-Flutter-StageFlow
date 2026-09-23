import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagesync/models/production_model.dart';
import 'package:stagesync/theme/theme.dart';
import 'package:stagesync/widgets/production/production_card.dart';

void main() {
  group('ProductionCard Layout Tests', () {
    testWidgets('renders within a 200px height container without RenderFlex overflow',
        (WidgetTester tester) async {
      final sampleProduction = ProductionModel(
        id: 'prod_test',
        title: 'Romeo and Juliet: Extended Cut with Long Title',
        description: 'Test description',
        startDate: DateTime(2026, 9, 24),
        endDate: DateTime(2026, 9, 29),
        directorId: 'dir_1',
        imageURL: null,
        memberIds: ['dir_1', 'cast_1', 'cast_2', 'cast_3'],
        createdAt: DateTime(2026, 9, 1),
      );

      // Render inside a fixed 200px horizontal list context, exactly like HomeDashboardScreen
      await tester.pumpWidget(
        MaterialApp(
          theme: StageSyncTheme.light,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ProductionCard(production: sampleProduction),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Settle layout
      await tester.pumpAndSettle();

      // Verify that no exceptions (such as RenderFlex overflow) were thrown
      expect(tester.takeException(), isNull);

      // Verify expected text content is rendered
      expect(find.text('Romeo and Juliet: Extended Cut with Long Title'),
          findsOneWidget);
      expect(find.text('Sep 24 - Sep 29'), findsOneWidget);
      expect(find.text('4 members'), findsOneWidget);
      expect(find.byIcon(Icons.theater_comedy_rounded), findsOneWidget);
    });
  });
}
