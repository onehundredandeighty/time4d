typedef Clock = DateTime Function();

final Clock systemTime = DateTime.now;

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
