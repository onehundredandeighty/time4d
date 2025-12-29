/// A clock that can be manually advanced for testing.
abstract class TickableClock {
  /// Returns the current time as a UTC [DateTime].
  DateTime call();

  /// Advances the clock by the specified amount or default tick duration.
  /// Returns this clock for method chaining.
  TickableClock tick([Duration? amount]);
}

/// A clock with fixed time that only advances when manually ticked.
/// 
/// This clock is ideal for deterministic testing where you need precise
/// control over time progression. All returned times are in UTC.
/// 
/// Example:
/// ```dart
/// final clock = FixedClock(
///   time: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
///   tick: Duration(seconds: 1),
/// );
/// 
/// print(clock()); // 1970-01-01 00:00:00.000Z
/// clock.tick();
/// print(clock()); // 1970-01-01 00:00:01.000Z
/// ```
class FixedClock implements TickableClock {
  /// The Unix epoch time (1970-01-01 00:00:00.000Z).
  static final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );

  DateTime _current;
  final Duration _defaultTick;

  /// Creates a fixed clock with optional starting time and tick duration.
  /// 
  /// - [time]: Starting time (defaults to Unix epoch). Automatically converted to UTC.
  /// - [tick]: Default duration to advance when [tick] is called without parameters.
  FixedClock({DateTime? time, Duration tick = const Duration(seconds: 1)})
    : _current = (time ?? epoch).toUtc(),
      _defaultTick = tick {
    if (tick.isNegative) {
      throw ArgumentError('Time can only tick forwards, not by $tick');
    }
  }

  @override
  DateTime call() => _current;

  @override
  TickableClock tick([Duration? amount]) {
    final tickAmount = amount ?? _defaultTick;
    if (tickAmount.isNegative) {
      throw ArgumentError('Time can only tick forwards, not by $tickAmount');
    }
    _current = _current.add(tickAmount).toUtc();
    return this;
  }
}

/// A clock that automatically advances each time it is called.
/// 
/// This clock wraps another [TickableClock] and automatically ticks it
/// forward by the configured amount every time the time is retrieved.
/// All returned times are in UTC.
/// 
/// Example:
/// ```dart
/// final clock = AutoTickingClock(
///   time: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
///   tick: Duration(seconds: 2),
/// );
/// 
/// print(clock()); // 1970-01-01 00:00:00.000Z
/// print(clock()); // 1970-01-01 00:00:02.000Z (auto-advanced)
/// ```
class AutoTickingClock implements TickableClock {
  final TickableClock _underlying;

  /// Creates an auto-ticking clock with optional starting time and tick duration.
  /// 
  /// - [time]: Starting time (defaults to Unix epoch). Automatically converted to UTC.
  /// - [tick]: Duration to advance automatically on each call.
  AutoTickingClock({DateTime? time, Duration tick = const Duration(seconds: 1)})
    : _underlying = FixedClock(time: time, tick: tick);

  /// Creates an auto-ticking clock from an existing tickable clock.
  AutoTickingClock.fromClock(TickableClock underlying)
    : _underlying = underlying;

  @override
  DateTime call() {
    final result = _underlying.call();
    _underlying.tick();
    return result;
  }

  @override
  TickableClock tick([Duration? amount]) {
    _underlying.tick(amount);
    return this;
  }
}
