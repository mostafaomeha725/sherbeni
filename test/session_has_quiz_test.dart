import 'package:flutter_test/flutter_test.dart';
import 'package:qrattendance/features/atendance/data/model/session_model.dart';

void main() {
  group('Session hasQuiz Data Layer Tests', () {
    test('1. Backend returns hasQuiz: true -> Session.hasQuiz == true', () {
      final json = {'id': '1', 'name': 'test', 'hasQuiz': true};
      final model = SessionModel.fromJson(json);
      expect(model.hasQuiz, isTrue);
    });

    test('2. Backend returns hasQuiz: false -> Session.hasQuiz == false', () {
      final json = {'id': '1', 'name': 'test', 'hasQuiz': false};
      final model = SessionModel.fromJson(json);
      expect(model.hasQuiz, isFalse);
    });

    test('3. Backend omits hasQuiz -> Session.hasQuiz == true (Fallback)', () {
      final json = {'id': '1', 'name': 'test'};
      final model = SessionModel.fromJson(json);
      expect(model.hasQuiz, isTrue);
    });

    test(
      '4. Backend returns hasQuiz: null -> Session.hasQuiz == true (Fallback)',
      () {
        final json = {'id': '1', 'name': 'test', 'hasQuiz': null};
        final model = SessionModel.fromJson(json);
        expect(model.hasQuiz, isTrue);
      },
    );

    test(
      '9. Verify explicit backend false is NOT overridden by the fallback',
      () {
        final json = {'id': '1', 'name': 'test', 'hasQuiz': false};
        final model = SessionModel.fromJson(json);
        expect(model.hasQuiz, isFalse); // Explicitly false should stay false
      },
    );
  });

  group('Session hasQuiz Entity & Cache Mapping', () {
    test(
      '5. Existing old cached Session without hasQuiz -> hasQuiz == true',
      () {
        final cachedJson = {'id': '1', 'title': 'test', 'courseId': 'c1'};
        // Simulating Hive loading an old JSON or model without hasQuiz
        final model = SessionModel.fromJson(cachedJson);
        expect(model.hasQuiz, isTrue);
      },
    );

    test('Model to Entity preserves hasQuiz', () {
      final model = SessionModel(
        id: '1',
        title: 'test',
        description: '',
        courseId: 'c1',
        courseTitle: '',
        startTime: '',
        endTime: '',
        status: '',
        hasHomework: false,
        totalAttendance: 0,
        attendedCount: 0,
        lateCount: 0,
        hasQuiz: false, // Testing false mapping
      );
      final entity = model.toEntity();
      expect(entity.hasQuiz, isFalse);
    });
  });
}
