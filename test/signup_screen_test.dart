import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:stagesync/services/auth_service.dart';
import 'package:stagesync/providers/auth_provider.dart';
import 'package:stagesync/screens/auth/signup_screen.dart';

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
        home: SignUpScreen(),
      ),
    );
  }

  group('SignUpScreen Widget Tests', () {
    testWidgets('Renders all registration fields and role choices', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsWidgets);
      expect(find.text('Director'), findsOneWidget);
      expect(find.text('Cast Member'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4)); // Name, Email, Password, Confirm Password
      expect(find.widgetWithText(ElevatedButton, 'Create Account'), findsOneWidget);
    });

    testWidgets('Validates password match and length constraints', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Jane Doe');
      await tester.enterText(textFields.at(1), 'jane@theatre.edu');
      await tester.enterText(textFields.at(2), '12345'); // Too short
      await tester.enterText(textFields.at(3), '123456'); // Mismatched

      final registerButton = find.widgetWithText(ElevatedButton, 'Create Account');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
