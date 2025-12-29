import 'package:test/test.dart';
import 'package:time4d/time4d.dart';

void main() {
  group('AutoTickingClock', () {
    test('getting the time ticks by configured amount', () {
      final start = DateTime.now().toUtc();
      final tick = Duration(seconds: 2);

      final clock = AutoTickingClock(time: start, tick: tick);

      expect(clock(), equals(start));
      expect(clock(), equals(start.add(tick)));
      expect(clock(), equals(start.add(tick).add(tick)));
    });

    test('ticked by configured amount', () {
      final now = DateTime.now().toUtc();
      final tick = Duration(seconds: 1);

      final clock = AutoTickingClock(time: now, tick: tick);

      expect(clock(), equals(now));

      clock.tick();

      expect(clock(), equals(now.add(tick).add(tick)));
    });

    test('ticked by explicit amount', () {
      final now = DateTime.fromMillisecondsSinceEpoch(1000, isUtc: true);
      final configuredTick = Duration(seconds: 10);
      final explicitTick = Duration(seconds: 1);

      final fixed = AutoTickingClock(time: now, tick: configuredTick);

      expect(fixed(), equals(now));

      fixed.tick(explicitTick);

      expect(fixed(), equals(now.add(configuredTick).add(explicitTick)));
      expect(
        fixed(),
        equals(now.add(configuredTick).add(explicitTick).add(configuredTick)),
      );
    });
  });
}
