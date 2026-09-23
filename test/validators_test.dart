import 'package:flutter_test/flutter_test.dart';
import 'package:stagesync/utils/validators.dart';

void main() {
  group('Validators Utility Tests', () {
    test('required validator works for empty and valid strings', () {
      expect(Validators.required(null), isNotNull);
      expect(Validators.required(''), isNotNull);
      expect(Validators.required('   '), isNotNull);
      expect(Validators.required('Hamlet'), isNull);
    });

    test('email validator enforces standard email formatting', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('invalid-email'), isNotNull);
      expect(Validators.email('ananya@stagesync'), isNotNull);
      expect(Validators.email('ananya@example.com'), isNull);
      expect(Validators.email('sarah.cast@theatre.org'), isNull);
    });

    test('password validator enforces minimum 6 characters', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('StrongPass123!'), isNull);
    });

    test('confirmPassword validator validates matching passwords', () {
      expect(Validators.confirmPassword('pass123', 'pass456'), isNotNull);
      expect(Validators.confirmPassword('pass123', 'pass123'), isNull);
    });

    test('isEndAfterStart validates time sequencing', () {
      final start = DateTime(2026, 9, 22, 10, 0);
      final endValid = DateTime(2026, 9, 22, 12, 0);
      final endInvalid = DateTime(2026, 9, 22, 9, 0);
      final endSame = DateTime(2026, 9, 22, 10, 0);

      expect(Validators.isEndAfterStart(start, endValid), isTrue);
      expect(Validators.isEndAfterStart(start, endInvalid), isFalse);
      expect(Validators.isEndAfterStart(start, endSame), isFalse);
    });

    test('isProductionDatesValid validates production range', () {
      final start = DateTime(2026, 9, 1);
      final endLater = DateTime(2026, 10, 1);
      final endSame = DateTime(2026, 9, 1);
      final endBefore = DateTime(2026, 8, 30);

      expect(Validators.isProductionDatesValid(start, endLater), isTrue);
      expect(Validators.isProductionDatesValid(start, endSame), isTrue);
      expect(Validators.isProductionDatesValid(start, endBefore), isFalse);
    });
  });
}
