import 'dart:async';

import 'exceptions.dart';
import 'scheduler.dart';

class DeterministicScheduler implements Scheduler {
  DateTime _currentTime;
  bool _isShutdown = false;
  final List<_ScheduleTask> _tasks = <_ScheduleTask>[];

  DeterministicScheduler([DateTime? startTime])
    : _currentTime = startTime ?? DateTime.now();

  factory DeterministicScheduler.epoch() => 
    DeterministicScheduler(DateTime.fromMillisecondsSinceEpoch(0, isUtc: true));

  DateTime get currentTime => _currentTime;

  @override
  bool get isShutdown => _isShutdown;

  @override
  Future<T> submit<T>(Future<T> Function() task) =>
      schedule(task, Duration.zero);

  @override
  Future<void> submitVoid(void Function() task) =>
      scheduleVoid(task, Duration.zero);

  @override
  Future<T> schedule<T>(Future<T> Function() callable, Duration delay) {
    final task = _ScheduleTask<T>(callable, _currentTime.add(delay));
    _enqueue(task);
    return task.future;
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
    final scheduleTask = _ScheduleTask<void>(
      () {
        task();
        return Future<void>.value();
      },
      _currentTime.add(initialDelay),
      delay: delay,
    );
    _enqueue(scheduleTask);
    return scheduleTask.future;
  }

  @override
  Future<void> scheduleAtFixedRate(
    void Function() task,
    Duration initialDelay,
    Duration period,
  ) {
    final scheduleTask = _ScheduleTask<void>(
      () {
        task();
        return Future<void>.value();
      },
      _currentTime.add(initialDelay),
      period: period,
    );
    _enqueue(scheduleTask);
    return scheduleTask.future;
  }

  void _enqueue<T>(_ScheduleTask<T> task) {
    if (!_isShutdown) {
      _tasks.add(task);
      _tasks.sort();
    }
  }

  @override
  Future<void> shutdown() async {
    _isShutdown = true;
  }

  void clear() => _tasks.clear();

  bool isIdle() => _tasks.isEmpty || _tasks.first.timeToRun.isAfter(_currentTime);

  void runUntilIdle() => tick(Duration.zero);

  void tick(Duration duration) {
    final endOfPeriod = _currentTime.add(duration);

    while (_runNextTask(endOfPeriod)) {
      // Continue running tasks
    }
    _currentTime = endOfPeriod;
  }

  bool _runNextTask(DateTime endOfPeriod) {
    if (_tasks.isEmpty) return false;

    final task = _tasks.removeAt(0);
    if (task.isCancelled) return _tasks.isNotEmpty;

    final executionTime = task.timeToRun;
    if (executionTime.isAfter(endOfPeriod)) {
      _tasks.insert(0, task); // Put it back
      _tasks.sort();
      return false;
    }

    _currentTime = executionTime;
    final success = task.execute();

    if (task.isPeriodic && success && !task.isCancelled) {
      _enqueue(task.atNextExecutionTimeAfter(executionTime));
    }

    return true;
  }

  Future<bool> awaitTermination(Duration timeout) {
    if (_isShutdown) return Future.value(true);
    throw UnsupportedSynchronousOperationException(
      'cannot perform blocking wait on a task scheduled on a DeterministicScheduler',
    );
  }
}

class _ScheduleTask<T> implements Comparable<_ScheduleTask> {
  final Future<T> Function() _callable;
  final Duration? _period;
  final Duration? _delay;
  final DateTime timeToRun;

  bool _isCancelled = false;
  final Completer<T> _completer = Completer<T>();

  _ScheduleTask(
    this._callable,
    this.timeToRun, {
    Duration? period,
    Duration? delay,
  }) : _period = period,
       _delay = delay {
    if (period != null && period.isNegative) {
      throw ArgumentError('period/rate must be > 0');
    }
    if (delay != null && delay.isNegative) {
      throw ArgumentError('delay must be > 0');
    }
  }

  bool get isPeriodic => _period != null || _delay != null;

  bool get isCancelled => _isCancelled;

  Future<T> get future => _completer.future;

  void cancel() {
    if (!_completer.isCompleted) {
      _isCancelled = true;
      _completer.completeError(StateError('Task was cancelled'));
    }
  }

  bool execute() {
    if (_isCancelled) return false;

    try {
      final result = _callable();
      if (result is Future<T>) {
        result.then(_completer.complete).catchError(_completer.completeError);
      } else {
        _completer.complete(result as T);
      }
      return true;
    } catch (e, stackTrace) {
      _completer.completeError(e, stackTrace);
      return false;
    }
  }

  _ScheduleTask<T> atNextExecutionTimeAfter(DateTime clock) {
    final nextTime = _delay != null ? clock.add(_delay!) : clock.add(_period!);

    return _ScheduleTask<T>(
      _callable,
      nextTime,
      period: _period,
      delay: _delay,
    );
  }

  @override
  int compareTo(_ScheduleTask other) => timeToRun.compareTo(other.timeToRun);
}
