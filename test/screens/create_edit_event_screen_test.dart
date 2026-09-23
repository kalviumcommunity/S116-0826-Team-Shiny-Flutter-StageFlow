import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/models/event_model.dart';
import 'package:stagesync/models/role_model.dart';
import 'package:stagesync/screens/event/create_edit_event_screen.dart';
import 'package:stagesync/theme/theme.dart';
import 'package:stagesync/viewmodels/auth_viewmodel.dart';
import 'package:stagesync/viewmodels/events_viewmodel.dart';
import 'package:stagesync/viewmodels/roles_viewmodel.dart';
import 'package:stagesync/widgets/common/error_banner.dart';
import 'package:stagesync/widgets/common/primary_button.dart';

class FakeEventsViewModel extends ChangeNotifier implements EventsViewModel {
  @override
  bool isLoading = false;
  @override
  String? errorMessage;
  @override
  String? conflictMessage;
  @override
  List<EventModel> events = const [];

  bool shouldFailWithConflict = false;
  bool shouldSucceed = true;
  bool createEventCalled = false;

  @override
  void clearMessages() {
    errorMessage = null;
    conflictMessage = null;
    notifyListeners();
  }

  @override
  Future<bool> createEvent(String prodId, EventModel newEvent) async {
    createEventCalled = true;
    if (shouldFailWithConflict) {
      conflictMessage = 'Venue conflict: "Main Stage" is already booked.';
      notifyListeners();
      return false;
    }
    notifyListeners();
    return shouldSucceed;
  }

  @override
  Future<bool> updateEvent(
      String prodId, String eventId, EventModel updatedEvent) async {
    return shouldSucceed;
  }

  @override
  Future<bool> deleteEvent(String prodId, String eventId) async {
    return shouldSucceed;
  }

  @override
  void startWatching(String prodId) {}
}

class MockRolesViewModel extends Mock implements RolesViewModel {}

class MockAuthViewModel extends Mock implements AuthViewModel {}

void main() {
  late FakeEventsViewModel fakeEventsVm;
  late MockRolesViewModel mockRolesVm;
  late MockAuthViewModel mockAuthVm;

  setUp(() {
    fakeEventsVm = FakeEventsViewModel();
    mockRolesVm = MockRolesViewModel();
    mockAuthVm = MockAuthViewModel();

    when(() => mockRolesVm.roles).thenReturn(<RoleModel>[]);
    when(() => mockAuthVm.currentUser).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: StageSyncTheme.light,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<EventsViewModel>.value(value: fakeEventsVm),
          ChangeNotifierProvider<RolesViewModel>.value(value: mockRolesVm),
          ChangeNotifierProvider<AuthViewModel>.value(value: mockAuthVm),
        ],
        child: const CreateEditEventScreen(prodId: 'test_prod_1'),
      ),
    );
  }

  group('CreateEditEventScreen Widget Tests', () {
    testWidgets(
        '1. End time before start shows client-side validation error and does not save',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(tester.view.resetPhysicalSize);

      final invalidTimeEvent = EventModel(
        id: 'ev_invalid',
        date: DateTime(2026, 10, 15),
        start: DateTime(2026, 10, 15, 18, 0), // 6:00 PM
        end: DateTime(2026, 10, 15, 16, 0), // 4:00 PM (end before start)
        type: 'Rehearsal',
        venue: 'Main Stage',
        venueKey: 'main stage',
        castIds: const [],
        notes: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: StageSyncTheme.light,
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<EventsViewModel>.value(
                  value: fakeEventsVm),
              ChangeNotifierProvider<RolesViewModel>.value(value: mockRolesVm),
              ChangeNotifierProvider<AuthViewModel>.value(value: mockAuthVm),
            ],
            child: CreateEditEventScreen(
              prodId: 'test_prod_1',
              initialEvent: invalidTimeEvent,
            ),
          ),
        ),
      );

      // Scroll to button and tap Save
      await tester.ensureVisible(find.byType(PrimaryButton));
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('End time must be after start time.'), findsOneWidget);
      expect(fakeEventsVm.createEventCalled, isFalse);
    });

    testWidgets(
        '2. EventsViewModel.conflictMessage after save renders warning ErrorBanner and does not pop',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(tester.view.resetPhysicalSize);

      fakeEventsVm.shouldFailWithConflict = true;

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Venue *'),
        'Main Stage',
      );

      await tester.ensureVisible(find.byType(PrimaryButton));
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      // Warning banner is displayed
      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.text('Double-Booking Conflict Detected'), findsOneWidget);
      expect(
        find.text('Venue conflict: "Main Stage" is already booked.'),
        findsOneWidget,
      );

      // Verify screen has NOT popped
      expect(find.byType(CreateEditEventScreen), findsOneWidget);
    });

    testWidgets('3. Successful save navigates away',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(tester.view.resetPhysicalSize);

      fakeEventsVm.shouldSucceed = true;

      await tester.pumpWidget(
        MaterialApp(
          theme: StageSyncTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider<EventsViewModel>.value(
                            value: fakeEventsVm,
                          ),
                          ChangeNotifierProvider<RolesViewModel>.value(
                            value: mockRolesVm,
                          ),
                          ChangeNotifierProvider<AuthViewModel>.value(
                            value: mockAuthVm,
                          ),
                        ],
                        child: const CreateEditEventScreen(
                          prodId: 'test_prod_1',
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Open Event Screen'),
              ),
            ),
          ),
        ),
      );

      // Open screen
      await tester.tap(find.text('Open Event Screen'));
      await tester.pumpAndSettle();
      expect(find.byType(CreateEditEventScreen), findsOneWidget);

      // Fill venue
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Venue *'),
        'Main Stage',
      );

      // Scroll to button and tap Save
      await tester.ensureVisible(find.byType(PrimaryButton));
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      // Screen popped!
      expect(find.byType(CreateEditEventScreen), findsNothing);
      expect(find.text('Open Event Screen'), findsOneWidget);
    });
  });
}
