import 'package:time4d/time4d.dart';

void main() async {
  print('=== Time4d Example ===\n');

  // Basic time sources
  print('1. Basic Clock:');
  final systemClock = systemTime;
  print('System time: ${systemClock()}');

  final ticking = tickingClock(systemTime, unit: Duration(seconds: 1));
  print('Ticking time (truncated to seconds): ${ticking()}');

  // Test time sources
  print('\n2. Test Time Sources:');
  final fixedTime = FixedClock(
    time: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    tick: Duration(seconds: 1),
  );

  print('Fixed time initial: ${fixedTime()}');
  fixedTime.tick();
  print('Fixed time after tick: ${fixedTime()}');

  final autoTicking = AutoTickingClock(
    time: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    tick: Duration(seconds: 2),
  );

  print('Auto-ticking time first call: ${autoTicking()}');
  print('Auto-ticking time second call: ${autoTicking()}');

  // Deterministic scheduler
  print('\n3. Deterministic Scheduler:');
  final scheduler = DeterministicScheduler.epoch();

  print('Scheduler start time: ${scheduler.currentTime}');

  final results = <String>[];
  scheduler.scheduleVoid(
    () => results.add('Task 1 (100ms)'),
    Duration(milliseconds: 100),
  );

  scheduler.scheduleVoid(
    () => results.add('Task 2 (50ms)'),
    Duration(milliseconds: 50),
  );

  scheduler.scheduleVoid(
    () => results.add('Task 3 (150ms)'),
    Duration(milliseconds: 150),
  );

  print('Scheduler is idle: ${scheduler.isIdle()}');

  // Execute first 100ms worth of tasks
  scheduler.tick(Duration(milliseconds: 100));
  print('After 100ms: $results');
  print('Current time: ${scheduler.currentTime}');

  // Execute remaining tasks
  scheduler.tick(Duration(milliseconds: 100));
  print('After 200ms: $results');
  print('Final time: ${scheduler.currentTime}');

  print('Scheduler is idle: ${scheduler.isIdle()}');

  // Production scheduler example
  print('\n4. Production Scheduler:');
  final prodScheduler = SchedulerService();

  print('Scheduling async task...');
  await prodScheduler.schedule(() async {
    await Future.delayed(Duration(milliseconds: 100));
    print('Async task completed!');
    return 'result';
  }, Duration(milliseconds: 50));

  prodScheduler.shutdown();
  print('Production scheduler shut down.');
}
