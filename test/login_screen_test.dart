import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stagesync/providers/auth_provider.dart';
import 'package:stagesync/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:stagesync/services/auth_service.dart';

class MockAuthService extends AuthService {
  MockAuthService() : super(auth: null, firestore: null);

  @override
  Stream<User?> get authStateChanges => Stream.value(null);
}

void main() {
  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(authService: MockAuthService()),
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('Renders all core login fields and buttons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('StageSync'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email & Password
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
      expect(find.text("Don't have an account?"), findsOneWidget);
    });

    testWidgets('Triggers validation error on empty fields', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      expect(find.text('Email address is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('Validates invalid email format', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'invalidemail');
      await tester.enterText(textFields.last, 'password123');

      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });
  });
}
