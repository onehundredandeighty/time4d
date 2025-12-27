import 'dart:async';

abstract class Scheduler {
  Future<T> schedule<T>(Future<T> Function() task, Duration delay);

  Future<void> scheduleVoid(void Function() task, Duration delay);

  Future<void> scheduleWithFixedDelay(
    void Function() task,
    Duration initialDelay,
    Duration delay,
  );

  Future<void> scheduleAtFixedRate(
    void Function() task,
    Duration initialDelay,
    Duration period,
  );

  void shutdown();
  bool get isShutdown;

  Future<T> submit<T>(Future<T> Function() task);
  Future<void> submitVoid(void Function() task);
}

class SchedulerService implements Scheduler {
  bool _isShutdown = false;
  final Set<Timer> _timers = <Timer>{};
  final Set<StreamSubscription> _subscriptions = <StreamSubscription>{};

  @override
  Future<T> schedule<T>(Future<T> Function() callable, Duration delay) {
    if (_isShutdown) throw StateError('Scheduler is shutdown');

    final completer = Completer<T>();
    final timer = Timer(delay, () async {
      try {
        final result = await callable();
        completer.complete(result);
      } catch (e, stackTrace) {
        completer.completeError(e, stackTrace);
      }
    });

    _timers.add(timer);
    return completer.future;
  }

  @override
  Future<void> scheduleVoid(void Function() task, Duration delay) =>
      schedule(() {
        task();
        return Future<void>.value();
      }, delay);

  @override
  Future<void> scheduleWithFixedDelay(
    void Function() task,
    Duration initialDelay,
    Duration delay,
  ) {
    if (_isShutdown) throw StateError('Scheduler is shutdown');

    void scheduleNext() {
      if (!_isShutdown) {
        final nextTimer = Timer(delay, () {
          task();
          scheduleNext();
        });
        _timers.add(nextTimer);
      }
    }

    final initialTimer = Timer(initialDelay, () {
      task();
      scheduleNext();
    });

    _timers.add(initialTimer);
    return Future<void>.value();
  }

  @override
  Future<void> scheduleAtFixedRate(
    void Function() task,
    Duration initialDelay,
    Duration period,
  ) {
    if (_isShutdown) throw StateError('Scheduler is shutdown');

    final timer = Timer.periodic(period, (_) => task());
    _timers.add(timer);

    return Future.delayed(initialDelay, task);
  }

  @override
  void shutdown() {
    _isShutdown = true;
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  @override
  bool get isShutdown => _isShutdown;

  @override
  Future<T> submit<T>(Future<T> Function() task) =>
      schedule(task, Duration.zero);

  @override
  Future<void> submitVoid(void Function() task) =>
      scheduleVoid(task, Duration.zero);
}
