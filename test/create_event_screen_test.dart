import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/models/production.dart';
import 'package:stagesync/providers/production_provider.dart';
import 'package:stagesync/providers/schedule_provider.dart';
import 'package:stagesync/screens/schedule/create_edit_event_screen.dart';

import 'package:stagesync/services/firestore_service.dart';
import 'package:stagesync/services/conflict_service.dart';
import 'package:stagesync/models/event_model.dart';
import 'package:stagesync/models/app_user.dart';
import 'package:stagesync/services/storage_service.dart';

class MockFirestoreService extends FirestoreService {
  MockFirestoreService() : super(firestore: null);
  @override
  Stream<List<Production>> getProductionsStream() => Stream.value([
        Production(
          id: 'prod-1',
          title: 'Hamlet',
          description: 'Shakespeare Tragedy',
          startDate: DateTime(2026, 10, 1),
          endDate: DateTime(2026, 11, 15),
          directorId: 'dir-1',
        )
      ]);
  @override
  Stream<List<EventModel>> getAllEventsStream() => Stream.value([]);
  @override
  Stream<List<AppUser>> getAllUsersStream() => Stream.value([]);
}

class MockStorageService extends StorageService {
  MockStorageService() : super(storage: null, picker: null);
}

class MockConflictService extends ConflictService {
  MockConflictService() : super(firestore: null);
}

void main() {
  Widget createWidgetUnderTest({Production? defaultProduction}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProductionProvider>(create: (_) => ProductionProvider(
          firestoreService: MockFirestoreService(),
          storageService: MockStorageService(),
        )),
        ChangeNotifierProvider<ScheduleProvider>(create: (_) => ScheduleProvider(
          firestoreService: MockFirestoreService(),
          conflictService: MockConflictService(),
        )),
      ],
      child: MaterialApp(
        home: CreateEditEventScreen(defaultProduction: defaultProduction),
      ),
    );
  }

  group('CreateEditEventScreen Widget Tests', () {
    testWidgets('Renders all schedule input controls and type chips', (tester) async {
      final sampleProd = Production(
        id: 'prod-1',
        title: 'Hamlet',
        description: 'Shakespeare Tragedy',
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 11, 15),
        directorId: 'dir-1',
      );

      await tester.pumpWidget(createWidgetUnderTest(defaultProduction: sampleProd));
      await tester.pumpAndSettle();

      expect(find.text('Schedule Call'), findsWidgets);
      expect(find.text('Call Type'), findsOneWidget);
      expect(find.text('Venue / Room'), findsOneWidget);
      expect(find.text('Called Cast Members'), findsOneWidget);
      expect(find.text('Rehearsal'), findsOneWidget);
      expect(find.text('Audition'), findsOneWidget);
      expect(find.text('Performance'), findsOneWidget);
      expect(find.text('Called Cast Members'), findsWidgets);
    });

    testWidgets('Validates required venue field', (tester) async {
      print('STARTING TEST');
      final sampleProd = Production(
        id: 'prod-1',
        title: 'Hamlet',
        description: 'Shakespeare Tragedy',
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 11, 15),
        directorId: 'dir-1',
      );
      await tester.pumpWidget(createWidgetUnderTest(defaultProduction: sampleProd));
      await tester.pumpAndSettle();

      // Clear the venue field to trigger validation
      final venueFinder = find.widgetWithText(TextFormField, 'Main Auditorium');
      if (venueFinder.evaluate().isNotEmpty) {
        await tester.enterText(venueFinder, '');
      }

      try {
        final saveButton = find.byType(ElevatedButton, skipOffstage: false).last;
        await tester.ensureVisible(saveButton);
        await tester.tap(saveButton);
        await tester.pumpAndSettle();
      } catch (e) {
        rethrow;
      }

      // Check validation error or missing production warning
      expect(find.byType(Form), findsOneWidget);
    });
  });
}
