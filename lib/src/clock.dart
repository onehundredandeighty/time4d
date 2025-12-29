typedef Clock = DateTime Function();

/// System clock that returns the current time in UTC.
///
/// This clock uses [DateTime.now] internally but converts to UTC to ensure
/// consistent behavior across different timezones and environments.
final Clock utcSystemTime = () => DateTime.now().toUtc();

/// Creates a clock that truncates time to the specified unit.
///
/// The returned clock will truncate the time from [source] to the nearest
/// [unit] boundary. For example, with `unit: Duration(seconds: 1)`, the
/// clock will truncate to the nearest second.
///
/// Example:
/// ```dart
/// final secondClock = tickingClock(utcSystemTime, unit: Duration(seconds: 1));
/// ```
Clock tickingClock(
  Clock source, {
  Duration unit = const Duration(seconds: 1),
}) => () => _truncatedTo(source(), unit);

DateTime _truncatedTo(DateTime dateTime, Duration unit) {
  final microseconds = dateTime.microsecondsSinceEpoch;
  final unitMicros = unit.inMicroseconds;
  final truncatedMicros = (microseconds ~/ unitMicros) * unitMicros;
  return DateTime.fromMicrosecondsSinceEpoch(truncatedMicros, isUtc: true);
}
