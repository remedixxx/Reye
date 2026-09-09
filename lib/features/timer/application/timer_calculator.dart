import '../domain/eye_break_timer_state.dart';
import '../domain/timer_status.dart';

class TimerCalculator {
  const TimerCalculator();

  Duration remaining({
    required DateTime now,
    required DateTime cycleStartTime,
    required Duration focusDuration,
  }) {
    final elapsed = now.difference(cycleStartTime);
    final remaining = focusDuration - elapsed;
    if (remaining.isNegative) {
      return Duration.zero;
    }
    return remaining;
  }

  TimerStatus statusFor({
    required TimerStatus currentStatus,
    required Duration remaining,
    required Duration finalCountdownDuration,
  }) {
    if (currentStatus == TimerStatus.paused ||
        currentStatus == TimerStatus.idle ||
        currentStatus == TimerStatus.breakInProgress) {
      return currentStatus;
    }
    if (remaining <= Duration.zero) {
      return TimerStatus.breakDue;
    }
    if (remaining <= finalCountdownDuration) {
      return TimerStatus.finalCountdown;
    }
    return TimerStatus.running;
  }

  EyeBreakTimerState recalculate({
    required EyeBreakTimerState state,
    required DateTime now,
    required Duration finalCountdownDuration,
  }) {
    if (state.status == TimerStatus.paused) {
      return state.copyWith(
        remaining: state.pausedRemaining ?? state.remaining,
      );
    }

    final nextRemaining = remaining(
      now: now,
      cycleStartTime: state.cycleStartTime,
      focusDuration: state.focusDuration,
    );
    final nextStatus = statusFor(
      currentStatus: state.status,
      remaining: nextRemaining,
      finalCountdownDuration: finalCountdownDuration,
    );

    return state.copyWith(
      status: nextStatus,
      remaining: nextRemaining,
      hasTriggeredBreakEffects: nextStatus == TimerStatus.breakDue
          ? state.hasTriggeredBreakEffects
          : false,
    );
  }

  EyeBreakTimerState pause(EyeBreakTimerState state) {
    return state.copyWith(
      status: TimerStatus.paused,
      pausedRemaining: state.remaining,
    );
  }

  EyeBreakTimerState resume({
    required EyeBreakTimerState state,
    required DateTime now,
  }) {
    final remaining = state.pausedRemaining ?? state.remaining;
    return state.copyWith(
      status: TimerStatus.running,
      cycleStartTime: now.subtract(state.focusDuration - remaining),
      remaining: remaining,
      clearPausedRemaining: true,
      hasTriggeredBreakEffects: false,
    );
  }

  EyeBreakTimerState restart({
    required DateTime now,
    required Duration focusDuration,
  }) {
    return EyeBreakTimerState.initial(now: now, focusDuration: focusDuration);
  }

  EyeBreakTimerState snooze({
    required EyeBreakTimerState state,
    required DateTime now,
    required Duration snoozeDuration,
  }) {
    final focusDuration = state.focusDuration;
    final cycleStartTime = now.add(snoozeDuration).subtract(focusDuration);
    return state.copyWith(
      status: TimerStatus.running,
      cycleStartTime: cycleStartTime,
      focusDuration: focusDuration,
      remaining: snoozeDuration,
      snoozeUntil: now.add(snoozeDuration),
      clearPausedRemaining: true,
      hasTriggeredBreakEffects: false,
    );
  }

  EyeBreakTimerState applyFocusDurationChange({
    required EyeBreakTimerState state,
    required DateTime now,
    required Duration newFocusDuration,
  }) {
    if (state.status == TimerStatus.paused) {
      final previous = state.focusDuration.inSeconds == 0
          ? 1
          : state.focusDuration.inSeconds;
      final progress =
          1 - ((state.pausedRemaining ?? state.remaining).inSeconds / previous);
      final nextRemainingSeconds = (newFocusDuration.inSeconds * (1 - progress))
          .round();
      final nextRemaining = Duration(
        seconds: nextRemainingSeconds.clamp(0, newFocusDuration.inSeconds),
      );
      return state.copyWith(
        focusDuration: newFocusDuration,
        remaining: nextRemaining,
        pausedRemaining: nextRemaining,
      );
    }

    final elapsed = now.difference(state.cycleStartTime);
    final nextRemaining = newFocusDuration - elapsed;
    return state.copyWith(
      focusDuration: newFocusDuration,
      remaining: nextRemaining.isNegative ? Duration.zero : nextRemaining,
    );
  }
}
