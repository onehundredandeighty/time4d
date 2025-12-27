abstract class TickableClock {
  DateTime call();

  TickableClock tick([Duration? amount]);
}

class FixedClock implements TickableClock {
  static final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(
    0,
    isUtc: true,
  );

  DateTime _current;
  final Duration _defaultTick;

  FixedClock({DateTime? time, Duration tick = const Duration(seconds: 1)})
    : _current = time ?? epoch,
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
    _current = _current.add(tickAmount);
    return this;
  }
}

class AutoTickingClock implements TickableClock {
  final TickableClock _underlying;

  AutoTickingClock({DateTime? time, Duration tick = const Duration(seconds: 1)})
    : _underlying = FixedClock(time: time, tick: tick);

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
