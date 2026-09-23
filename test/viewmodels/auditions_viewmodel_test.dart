import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stagesync/services/audition_service.dart';
import 'package:stagesync/viewmodels/auditions_viewmodel.dart';

class MockAuditionService extends Mock implements AuditionService {}

void main() {
  late MockAuditionService mockAuditionService;
  late AuditionsViewModel viewModel;

  setUp(() {
    mockAuditionService = MockAuditionService();
    viewModel = AuditionsViewModel(auditionService: mockAuditionService);
  });

  group('AuditionsViewModel.signUp Tests', () {
    test('signUp returns true and clears errorMessage on success', () async {
      when(() => mockAuditionService.signUp('prod_1', 'aud_1', 'cast_user_1'))
          .thenAnswer((_) async {});

      final result = await viewModel.signUp('prod_1', 'aud_1', 'cast_user_1');

      expect(result, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      verify(() => mockAuditionService.signUp('prod_1', 'aud_1', 'cast_user_1'))
          .called(1);
    });

    test('signUp handles service error gracefully', () async {
      when(() => mockAuditionService.signUp(any(), any(), any()))
          .thenThrow(Exception('Firestore update permission denied'));

      final result = await viewModel.signUp('prod_1', 'aud_1', 'cast_user_1');

      expect(result, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Failed to sign up for audition'));
    });
  });

  group('AuditionsViewModel.withdraw Tests', () {
    test('withdraw returns true and clears errorMessage on success', () async {
      when(() => mockAuditionService.withdraw('prod_1', 'aud_1', 'cast_user_1'))
          .thenAnswer((_) async {});

      final result =
          await viewModel.withdraw('prod_1', 'aud_1', 'cast_user_1');

      expect(result, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      verify(() =>
              mockAuditionService.withdraw('prod_1', 'aud_1', 'cast_user_1'))
          .called(1);
    });

    test('withdraw handles service error gracefully', () async {
      when(() => mockAuditionService.withdraw(any(), any(), any()))
          .thenThrow(Exception('Firestore update permission denied'));

      final result =
          await viewModel.withdraw('prod_1', 'aud_1', 'cast_user_1');

      expect(result, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(
          viewModel.errorMessage, contains('Failed to withdraw from audition'));
    });
  });
}
