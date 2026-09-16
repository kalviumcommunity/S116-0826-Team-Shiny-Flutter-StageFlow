import 'package:flutter_test/flutter_test.dart';
import 'package:stagesync/repositories/stageflow_repository.dart';

void main() {
  group('StageFlow Repository Tests', () {
    late MockStageFlowRepository repository;

    setUp(() {
      repository = MockStageFlowRepository();
    });

    test('getProductions returns active season productions', () async {
      final productions = await repository.getProductions();
      expect(productions.length, greaterThanOrEqualTo(4));
      expect(productions.any((p) => p.title == 'Hamlet'), isTrue);
      expect(productions.any((p) => p.title == 'Macbeth'), isTrue);
    });

    test('getEvents returns schedule calls with conflicts', () async {
      final events = await repository.getEvents();
      expect(events.isNotEmpty, isTrue);
      final conflicts = events.where((e) => e.hasConflict);
      expect(conflicts.length, greaterThanOrEqualTo(1));
    });

    test('resolveConflict resolves double booking and updates venue status', () async {
      final conflicts = await repository.getConflicts();
      final unresolved = conflicts.firstWhere((c) => !c.isResolved);
      expect(unresolved, isNotNull);

      final success = await repository.resolveConflict(unresolved.id, unresolved.resolutionOptions.first);
      expect(success, isTrue);

      final updatedConflicts = await repository.getConflicts();
      final resolvedConflict = updatedConflicts.firstWhere((c) => c.id == unresolved.id);
      expect(resolvedConflict.isResolved, isTrue);

      final venues = await repository.getVenues();
      final mainStage = venues.firstWhere((v) => v.name == 'Main Stage');
      expect(mainStage.status, equals('Available'));
    });
  });
}
