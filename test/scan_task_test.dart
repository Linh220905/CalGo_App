import 'package:flutter_test/flutter_test.dart';
import 'package:calgo/providers/scan_task_provider.dart';

void main() {
  group('ScanTask unrecognized food alert', () {
    ScanTask unrecognizedTask() {
      final task = ScanTask(
        imagePath: '/tmp/meal.jpg',
        authScope: 1,
        payload: 'image',
      );
      task
        ..status = ScanTaskStatus.failed
        ..errorStatusCode = 422
        ..errorDetail = 'Chưa phân tích rõ món ăn';
      return task;
    }

    test('is consumed only once even when Home is rebuilt', () {
      final task = unrecognizedTask();

      expect(task.takeUnrecognizedFoodAlert(), isTrue);
      expect(task.takeUnrecognizedFoodAlert(), isFalse);
    });

    test('can be shown once again after retrying the same task', () {
      final task = unrecognizedTask();

      expect(task.takeUnrecognizedFoodAlert(), isTrue);
      task.resetUnrecognizedFoodAlert();
      expect(task.takeUnrecognizedFoodAlert(), isTrue);
    });

    test('does not consume an alert for another scan failure', () {
      final task = unrecognizedTask()
        ..errorStatusCode = 500
        ..errorDetail = 'Server error';

      expect(task.takeUnrecognizedFoodAlert(), isFalse);
    });
  });
}
