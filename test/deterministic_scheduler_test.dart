import 'package:test/test.dart';
import 'package:time4d/time4d.dart';

void main() {
  group('DeterministicScheduler', () {
    late DeterministicScheduler scheduler;

    setUp(() {
      scheduler = DeterministicScheduler.epoch();
    });

    test('executes tasks in order', () async {
      final results = <String>[];

      scheduler.scheduleVoid(
        () => results.add('task1'),
        Duration(milliseconds: 100),
      );
      scheduler.scheduleVoid(
        () => results.add('task2'),
        Duration(milliseconds: 50),
      );
      scheduler.scheduleVoid(
        () => results.add('task3'),
        Duration(milliseconds: 150),
      );

      scheduler.tick(Duration(milliseconds: 200));

      expect(results, equals(['task2', 'task1', 'task3']));
    });

    test('runs until idle', () {
      final results = <String>[];

      scheduler.scheduleVoid(() => results.add('immediate'), Duration.zero);
      scheduler.scheduleVoid(
        () => results.add('delayed'),
        Duration(milliseconds: 100),
      );

      scheduler.runUntilIdle();

      expect(results, equals(['immediate']));

      scheduler.tick(Duration(milliseconds: 100));
      expect(results, equals(['immediate', 'delayed']));
    });

    test('is idle when no tasks are ready', () {
      expect(scheduler.isIdle(), isTrue);

      scheduler.scheduleVoid(() {}, Duration(milliseconds: 100));
      expect(scheduler.isIdle(), isTrue);

      scheduler.scheduleVoid(() {}, Duration.zero);
      expect(scheduler.isIdle(), isFalse);
    });

    test('advances time correctly', () {
      final startTime = scheduler.currentTime;

      scheduler.tick(Duration(seconds: 5));

      expect(
        scheduler.currentTime,
        equals(startTime.add(Duration(seconds: 5))),
      );
    });

    test('schedules periodic tasks', () async {
      final results = <int>[];
      int counter = 0;

      scheduler.scheduleAtFixedRate(
        () => results.add(++counter),
        Duration(milliseconds: 100),
        Duration(milliseconds: 50),
      );

      scheduler.tick(Duration(milliseconds: 250));

      expect(results.length, greaterThan(2));
      expect(results, equals([1, 2, 3, 4]));
    });

    test('can be shut down', () {
      expect(scheduler.isShutdown, isFalse);

      scheduler.shutdown();

      expect(scheduler.isShutdown, isTrue);
    });

    test('can clear pending tasks', () {
      scheduler.scheduleVoid(() {}, Duration(milliseconds: 100));
      expect(scheduler.isIdle(), isTrue);

      scheduler.clear();
      scheduler.tick(Duration(milliseconds: 200));

      expect(scheduler.isIdle(), isTrue);
    });
  });
}
