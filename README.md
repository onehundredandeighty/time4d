# Time4d

[![Dart](https://img.shields.io/badge/dart-3.7%2B-blue)](https://dart.dev)
[![License](https://img.shields.io/badge/license-Apache2-green)](LICENSE)

Time abstraction and scheduler for Dart. A port of the [time4k](https://github.com/fork-handles/forkhandles/tree/trunk/time4k) Kotlin library, providing controllable clocks and deterministic scheduling for testing.

## Features

- 🕐 **Time Abstractions** - Functional time sources with `Clock` typedef
- 🔄 **Production Scheduling** - `SchedulerService` for real async scheduling
- ⏱️ **Test Time Control** - `FixedClock` and `AutoTickingClock` for deterministic testing
- 📅 **Deterministic Scheduling** - `DeterministicScheduler` for predictable task execution in tests
- 🧪 **Testing Support** - Full control over time progression in tests
- 🎯 **Dart Idiomatic** - Uses `Future`, `Duration`, `DateTime` and sound null safety

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  time4d: ^1.0.0

dev_dependencies:
  time4d: ^1.0.0  # for testing utilities
```

## Quick Start

```dart
import 'package:time4d/time4d.dart';

// Basic UTC Clock
final clock = utcSystemTime;
print('Current time: ${clock()}');

// Deterministic testing
final scheduler = DeterministicScheduler.epoch();
scheduler.scheduleVoid(() => print('Task executed!'), Duration(seconds: 1));
scheduler.tick(Duration(seconds: 1)); // Execute scheduled tasks
```

## Core Concepts

### Clock (Time Sources)

A `Clock` is simply a function that returns the current time:

```dart
typedef Clock = DateTime Function();

// System time
final systemClock = utcSystemTime; // Uses DateTime.now.toUtc

// Ticking clock (truncates to specified unit)
final secondClock = tickingClock(utcSystemTime, unit: Duration(seconds: 1));
```

### Test Time Sources

Control time in your tests with tickable clocks:

```dart
final fixed = FixedClock(time: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));
print(fixed()); // 1970-01-01 00:00:00.000Z
fixed.tick();   // Manually advance time
print(fixed()); // 1970-01-01 00:00:01.000Z
```

### Schedulers

For deterministic testing and production scheduling:

```dart
// Testing - controllable time
final scheduler = DeterministicScheduler.epoch();
scheduler.scheduleVoid(() => print('Task executed!'), Duration(seconds: 1));
scheduler.tick(Duration(seconds: 1)); // Execute scheduled tasks

// Production - real async scheduling  
final prodScheduler = SchedulerService();
await prodScheduler.schedule(() async => 'result', Duration(seconds: 1));
```


## Working with UTC Times

Time4d operates exclusively with UTC `DateTime` objects for deterministic testing and cross-platform consistency. Convert to local time at the presentation layer:

```dart
final utcTime = utcSystemTime(); // Always UTC
final localTime = utcTime.toLocal(); // Convert for display
```

## Best Practices

1. **Use factory constructors**: `DeterministicScheduler.epoch()` for tests
2. **Inject schedulers**: Always make clocks and schedulers dependencies for testability
3. **Clean shutdown**: Always call `shutdown()` on production schedulers
4. **Test time control**: Use `tick()` and `runUntilIdle()` to control test execution
5. **Avoid real time in tests**: Use `DeterministicScheduler` instead of `SchedulerService`
6. **Keep UTC in business logic**: Convert to local timezone only at the presentation layer

## Examples

**📁 [Complete working examples](example/)** - See the `/example` folder for comprehensive demos of all features including:
- Clock usage patterns
- Deterministic scheduler testing
- Production scheduler setup  
- UTC timezone handling
- Real-world usage scenarios

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create a feature branch
3. Add tests for your changes
4. Ensure all tests pass: `dart test`
5. Submit a pull request

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Original [time4k](https://github.com/fork-handles/forkhandles/tree/trunk/time4k) Kotlin library by the fork-handles team
- Inspiration from Java's `ScheduledExecutorService` and `Clock` abstractions
- The Dart community for excellent async/await patterns
