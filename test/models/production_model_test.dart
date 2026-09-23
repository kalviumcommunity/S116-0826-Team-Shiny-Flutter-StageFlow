import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagesync/models/production_model.dart';

void main() {
  group('ProductionModel Serialization and Parsing Tests', () {
    test('parses complete map correctly', () {
      final now = DateTime.now();
      final map = {
        'title': 'The Crucible',
        'description': 'Salem witch trials drama',
        'startDate': Timestamp.fromDate(now),
        'endDate': Timestamp.fromDate(now.add(const Duration(days: 30))),
        'directorId': 'director_123',
        'imageURL': 'https://example.com/poster.jpg',
        'memberIds': ['director_123', 'actor_456'],
        'createdAt': Timestamp.fromDate(now),
      };

      final model = ProductionModel.fromMap(map, 'prod_789');

      expect(model.id, 'prod_789');
      expect(model.title, 'The Crucible');
      expect(model.description, 'Salem witch trials drama');
      expect(model.directorId, 'director_123');
      expect(model.imageURL, 'https://example.com/poster.jpg');
      expect(model.memberIds, ['director_123', 'actor_456']);
    });

    test('handles null and missing imageURL safely without crashes', () {
      final now = DateTime.now();
      final map = {
        'title': 'Hamlet',
        'description': 'Shakespeare tragedy',
        'startDate': now,
        'endDate': now.add(const Duration(days: 10)),
        'directorId': 'dir_1',
        'imageURL': null,
        'memberIds': ['dir_1'],
        'createdAt': now,
      };

      final model = ProductionModel.fromMap(map, 'prod_hamlet');

      expect(model.id, 'prod_hamlet');
      expect(model.imageURL, isNull);
      expect(model.title, 'Hamlet');

      final outputMap = model.toMap();
      expect(outputMap['imageURL'], isNull);
      expect(outputMap['title'], 'Hamlet');
    });

    test('coerces different date types (DateTime, Timestamp, String, int)', () {
      final now = DateTime.now();
      final map = {
        'title': 'Macbeth',
        'startDate': now.toIso8601String(),
        'endDate': now.millisecondsSinceEpoch,
        'directorId': 'dir_2',
        'createdAt': null, // fallback
      };

      final model = ProductionModel.fromMap(map, 'prod_macbeth');

      expect(model.startDate.year, now.year);
      expect(model.endDate.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      expect(model.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });
  });
}
