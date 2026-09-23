import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/screens/auth/signup_screen.dart';
import 'package:stagesync/theme/theme.dart';
import 'package:stagesync/viewmodels/auth_viewmodel.dart';
import 'package:stagesync/widgets/common/error_banner.dart';
import 'package:stagesync/widgets/common/loading_indicator.dart';
import 'package:stagesync/widgets/common/primary_button.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}

void main() {
  late MockAuthViewModel mockAuthViewModel;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
    when(() => mockAuthViewModel.isLoading).thenReturn(false);
    when(() => mockAuthViewModel.errorMessage).thenReturn(null);
    when(() => mockAuthViewModel.currentUser).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: StageSyncTheme.light,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthViewModel>.value(
            value: mockAuthViewModel,
          ),
        ],
        child: const SignupScreen(),
      ),
    );
  }

  group('SignupScreen Widget Tests', () {
    testWidgets(
        '1. Empty submit shows validation errors and does not call signUp',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('Name is required.'), findsOneWidget);
      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);
      expect(find.text('Please confirm your password.'), findsOneWidget);
      verifyNever(
        () => mockAuthViewModel.signUp(any(), any(), any(), any()),
      );
    });

    testWidgets('2. Password mismatch shows error',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@stagesync.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'different_pass',
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match.'), findsOneWidget);
      verifyNever(
        () => mockAuthViewModel.signUp(any(), any(), any(), any()),
      );
    });

    testWidgets('3. Valid form with Director role calls signUp correctly',
        (WidgetTester tester) async {
      when(() => mockAuthViewModel.signUp(any(), any(), any(), any()))
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Director Dan',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'director@stagesync.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'secret123',
      );

      // Select 'Director' role
      await tester.tap(find.text('Director'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      verify(() => mockAuthViewModel.signUp(
            'Director Dan',
            'director@stagesync.com',
            'secret123',
            'director',
          )).called(1);
    });

    testWidgets('4. ErrorBanner is shown when errorMessage is set',
        (WidgetTester tester) async {
      const error = 'The email address is already in use.';
      when(() => mockAuthViewModel.errorMessage).thenReturn(error);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.text(error), findsOneWidget);
    });

    testWidgets('5. isLoading renders loading indicator and disables submit',
        (WidgetTester tester) async {
      when(() => mockAuthViewModel.isLoading).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(LoadingIndicator), findsOneWidget);

      await tester.tap(find.byType(PrimaryButton));
      verifyNever(
        () => mockAuthViewModel.signUp(any(), any(), any(), any()),
      );
    });
  });
}
