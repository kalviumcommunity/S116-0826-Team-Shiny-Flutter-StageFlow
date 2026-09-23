import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/screens/auth/login_screen.dart';
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
        child: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets(
        '1. Empty submit shows validation errors and does not call signIn',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap Sign In button without entering data
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);
      verifyNever(() => mockAuthViewModel.signIn(any(), any()));
    });

    testWidgets('2. Invalid email shows validation error',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'not-an-email',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      verifyNever(() => mockAuthViewModel.signIn(any(), any()));
    });

    testWidgets('3. Valid credentials triggers signIn with entered values',
        (WidgetTester tester) async {
      when(() => mockAuthViewModel.signIn(any(), any()))
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'director@stagesync.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'supersecret',
      );

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      verify(() => mockAuthViewModel.signIn(
            'director@stagesync.com',
            'supersecret',
          )).called(1);
    });

    testWidgets(
        '4. AuthViewModel.errorMessage displays ErrorBanner with exact message',
        (WidgetTester tester) async {
      const errorText = 'No account was found for that email.';
      when(() => mockAuthViewModel.errorMessage).thenReturn(errorText);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(ErrorBanner), findsOneWidget);
      expect(find.text(errorText), findsOneWidget);
    });

    testWidgets(
        '5. isLoading == true renders loading indicator and disables button',
        (WidgetTester tester) async {
      when(() => mockAuthViewModel.isLoading).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());

      // Should show loading spinner inside the button
      expect(find.byType(LoadingIndicator), findsOneWidget);

      // Attempting to tap the button does not trigger signIn
      await tester.tap(find.byType(PrimaryButton));
      verifyNever(() => mockAuthViewModel.signIn(any(), any()));
    });
  });
}
