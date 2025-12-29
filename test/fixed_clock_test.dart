import 'package:test/test.dart';
import 'package:time4d/time4d.dart';

void main() {
  group('FixedClock', () {
    test('ticked by configured amount', () {
      final start = DateTime.now().toUtc();
      final tick = Duration(seconds: 2);

      final clock = FixedClock(time: start, tick: tick);

      expect(clock(), equals(start));

      clock.tick();
      expect(clock(), equals(start.add(tick)));
    });

    test('ticked by explicit amount', () {
      final now = DateTime.now().toUtc();
      final tick = Duration(seconds: 1);

      final fixed = FixedClock(time: now, tick: Duration(seconds: 10));
      expect(fixed(), equals(now));
      expect(fixed.tick(tick)(), equals(now.add(tick)));
    });

    test('getting the time does not progress time', () {
      final now = DateTime.now().toUtc();
      final tick = Duration(seconds: 1);

      final clock = FixedClock(time: now, tick: Duration(seconds: 10));

      expect(clock(), equals(now));
      expect(clock(), equals(now));
      expect(clock(), equals(now));

      clock.tick(tick);

      expect(clock(), equals(now.add(tick)));
      expect(clock(), equals(now.add(tick)));
      expect(clock(), equals(now.add(tick)));
    });

    test('throws error for negative tick duration', () {
      expect(
        () => FixedClock(tick: Duration(seconds: -1)),
        throwsArgumentError,
      );
    });

    test('throws error when ticking backwards', () {
      final clock = FixedClock();
      expect(() => clock.tick(Duration(seconds: -1)), throwsArgumentError);
    });
  });
}
