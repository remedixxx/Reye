import 'timer_status.dart';

class EyeBreakTimerState {
  const EyeBreakTimerState({
    required this.status,
    required this.cycleStartTime,
    required this.focusDuration,
    required this.remaining,
    required this.pausedRemaining,
    required this.snoozeUntil,
    required this.hasTriggeredBreakEffects,
  });

  factory EyeBreakTimerState.initial({
    DateTime? now,
    Duration focusDuration = const Duration(minutes: 20),
  }) {
    final start = now ?? DateTime.now();
    return EyeBreakTimerState(
      status: TimerStatus.running,
      cycleStartTime: start,
      focusDuration: focusDuration,
      remaining: focusDuration,
      pausedRemaining: null,
      snoozeUntil: null,
      hasTriggeredBreakEffects: false,
    );
  }

  final TimerStatus status;
  final DateTime cycleStartTime;
  final Duration focusDuration;
  final Duration remaining;
  final Duration? pausedRemaining;
  final DateTime? snoozeUntil;
  final bool hasTriggeredBreakEffects;

  DateTime get cycleEndTime => cycleStartTime.add(focusDuration);

  EyeBreakTimerState copyWith({
    TimerStatus? status,
    DateTime? cycleStartTime,
    Duration? focusDuration,
    Duration? remaining,
    Duration? pausedRemaining,
    bool clearPausedRemaining = false,
    DateTime? snoozeUntil,
    bool clearSnoozeUntil = false,
    bool? hasTriggeredBreakEffects,
  }) {
    return EyeBreakTimerState(
      status: status ?? this.status,
      cycleStartTime: cycleStartTime ?? this.cycleStartTime,
      focusDuration: focusDuration ?? this.focusDuration,
      remaining: remaining ?? this.remaining,
      pausedRemaining: clearPausedRemaining
          ? null
          : pausedRemaining ?? this.pausedRemaining,
      snoozeUntil: clearSnoozeUntil ? null : snoozeUntil ?? this.snoozeUntil,
      hasTriggeredBreakEffects:
          hasTriggeredBreakEffects ?? this.hasTriggeredBreakEffects,
    );
  }
}
