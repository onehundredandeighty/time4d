import 'package:time4d/time4d.dart';

void main() async {
  print('=== Time4d Example ===\n');

  // Basic time sources - All times are UTC for consistency
  print('1. Basic Clock:');
  final systemClock =
      utcSystemTime; // Returns UTC time for deterministic behavior
  print(
    'System time: ${systemClock()}',
  ); // Notice the "Z" suffix indicating UTC

  final ticking = tickingClock(utcSystemTime, unit: Duration(seconds: 1));
  print('Ticking time (truncated to seconds): ${ticking()}'); // Also UTC

  // Test time sources - Explicit UTC creation for deterministic testing
  print('\n2. Test Time Sources:');
  final fixedTime = FixedClock(
    time: DateTime.fromMillisecondsSinceEpoch(
      0,
      isUtc: true,
    ), // Unix epoch in UTC
    tick: Duration(seconds: 1),
  );

  print('Fixed time initial: ${fixedTime()}'); // 1970-01-01 00:00:00.000Z
  fixedTime.tick();
  print('Fixed time after tick: ${fixedTime()}'); // Advances deterministically

  final autoTicking = AutoTickingClock(
    time: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true), // Same UTC epoch
    tick: Duration(seconds: 2),
  );

  print('Auto-ticking time first call: ${autoTicking()}');
  print('Auto-ticking time second call: ${autoTicking()}'); // Auto-advances

  // Deterministic scheduler - Uses UTC epoch for predictable testing
  print('\n3. Deterministic Scheduler:');
  final scheduler = DeterministicScheduler.epoch(); // Starts at UTC epoch

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

  // UTC timezone handling
  print('\n5. UTC Timezone Handling:');
  final utcTime = utcSystemTime();
  print('System time is UTC: ${utcTime.isUtc}'); // true
  print('UTC time: $utcTime');

  final localTime = utcTime.toLocal();
  print('Local time: $localTime');
  print('Local time is UTC: ${localTime.isUtc}'); // false

  // Demonstrate timezone conversion pattern
  print('\nTimezone Conversion Pattern:');
  String formatTimeForUser(DateTime utcTime) {
    final local = utcTime.toLocal();
    return 'User sees: ${local.toString().split('.')[0]}';
  }

  print(formatTimeForUser(utcTime));
  print('Business logic keeps UTC: $utcTime');
}
