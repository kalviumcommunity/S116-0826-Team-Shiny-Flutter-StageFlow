import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagesync/app.dart';
import 'package:stagesync/theme/theme.dart';
import 'package:stagesync/widgets/common/common.dart';

void main() {
  testWidgets('StageSyncApp boots with StageSyncTheme and displays initial text',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StageSyncApp());
    expect(find.text('StageSync'), findsOneWidget);
  });

  group('PrimaryButton Widget Tests', () {
    testWidgets('renders label and triggers onPressed', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: StageSyncTheme.light,
          home: Scaffold(
            body: PrimaryButton(
              label: 'Save Cue',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Save Cue'), findsOneWidget);
      await tester.tap(find.text('Save Cue'));
      expect(pressed, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StageSyncTheme.light,
          home: Scaffold(
            body: PrimaryButton(
              label: 'Save Cue',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save Cue'), findsNothing);
    });
  });

  group('LoadingIndicator Widget Tests', () {
    testWidgets('renders CircularProgressIndicator and optional message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StageSyncTheme.light,
          home: const Scaffold(
            body: LoadingIndicator(message: 'Loading production data...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading production data...'), findsOneWidget);
    });
  });

  group('ErrorBanner Widget Tests', () {
    testWidgets('renders error message, title, and handles dismiss',
        (WidgetTester tester) async {
      bool dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: StageSyncTheme.light,
          home: Scaffold(
            body: ErrorBanner(
              title: 'Schedule Conflict',
              message: 'Lead Actor is double-booked for Scene 2 and Scene 4.',
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      expect(find.text('Schedule Conflict'), findsOneWidget);
      expect(
        find.text('Lead Actor is double-booked for Scene 2 and Scene 4.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      expect(dismissed, isTrue);
    });
  });
}
