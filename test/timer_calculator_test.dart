import 'package:reye/features/timer/application/timer_calculator.dart';
import 'package:reye/features/timer/domain/eye_break_timer_state.dart';
import 'package:reye/features/timer/domain/timer_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = TimerCalculator();

  test('calculates remaining time from real timestamps', () {
    final start = DateTime(2026, 1, 1, 10);
    final remaining = calculator.remaining(
      now: start.add(const Duration(minutes: 7)),
      cycleStartTime: start,
      focusDuration: const Duration(minutes: 20),
    );

    expect(remaining, const Duration(minutes: 13));
  });

  test('transitions from running to final countdown', () {
    final status = calculator.statusFor(
      currentStatus: TimerStatus.running,
      remaining: const Duration(seconds: 20),
      finalCountdownDuration: const Duration(seconds: 20),
    );

    expect(status, TimerStatus.finalCountdown);
  });

  test('transitions from final countdown to break due', () {
    final status = calculator.statusFor(
      currentStatus: TimerStatus.finalCountdown,
      remaining: Duration.zero,
      finalCountdownDuration: const Duration(seconds: 20),
    );

    expect(status, TimerStatus.breakDue);
  });

  test('pause and resume preserve remaining time', () {
    final now = DateTime(2026, 1, 1, 10);
    final state = EyeBreakTimerState.initial(
      now: now,
      focusDuration: const Duration(minutes: 20),
    ).copyWith(remaining: const Duration(minutes: 8));

    final paused = calculator.pause(state);
    final resumed = calculator.resume(
      state: paused,
      now: now.add(const Duration(minutes: 2)),
    );

    expect(paused.status, TimerStatus.paused);
    expect(resumed.status, TimerStatus.running);
    expect(resumed.remaining, const Duration(minutes: 8));
    expect(resumed.cycleEndTime, now.add(const Duration(minutes: 10)));
  });

  test('snooze delays the next reminder by 5 minutes', () {
    final now = DateTime(2026, 1, 1, 10);
    final state = EyeBreakTimerState.initial(
      now: now.subtract(const Duration(minutes: 20)),
      focusDuration: const Duration(minutes: 20),
    ).copyWith(status: TimerStatus.breakDue, remaining: Duration.zero);

    final snoozed = calculator.snooze(
      state: state,
      now: now,
      snoozeDuration: const Duration(minutes: 5),
    );

    expect(snoozed.status, TimerStatus.running);
    expect(snoozed.remaining, const Duration(minutes: 5));
    expect(snoozed.cycleEndTime, now.add(const Duration(minutes: 5)));
  });

  test('reopen after expiry resolves to break due', () {
    final start = DateTime(2026, 1, 1, 10);
    final state = EyeBreakTimerState.initial(
      now: start,
      focusDuration: const Duration(minutes: 20),
    );

    final recalculated = calculator.recalculate(
      state: state,
      now: start.add(const Duration(minutes: 25)),
      finalCountdownDuration: const Duration(seconds: 20),
    );

    expect(recalculated.remaining, Duration.zero);
    expect(recalculated.status, TimerStatus.breakDue);
  });
}
