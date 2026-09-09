import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../android/android_screen_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_strings.dart';
import '../../../notifications/notification_service.dart';
import '../../../windows/floating_window_controller.dart';
import '../domain/eye_break_settings.dart';
import '../domain/eye_break_timer_state.dart';
import '../domain/timer_status.dart';
import 'settings_controller.dart';
import 'timer_calculator.dart';

final timerCalculatorProvider = Provider<TimerCalculator>(
  (ref) => const TimerCalculator(),
);

final timerControllerProvider =
    StateNotifierProvider<TimerController, EyeBreakTimerState>((ref) {
      final controller = TimerController(ref);
      ref.listen(settingsControllerProvider, controller.onSettingsChanged);
      ref.onDispose(controller.dispose);
      return controller;
    });

class TimerController extends StateNotifier<EyeBreakTimerState> {
  TimerController(this._ref)
    : super(
        EyeBreakTimerState.initial(
          focusDuration: _ref.read(settingsControllerProvider).focusDuration,
        ),
      ) {
    _load();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
    if (Platform.isAndroid) {
      _screenSubscription = _ref
          .read(androidScreenServiceProvider)
          .events
          .listen(_handleAndroidScreenEvent);
    }
  }

  final Ref _ref;
  final TimerCalculator _calculator = const TimerCalculator();
  Timer? _ticker;
  StreamSubscription<AndroidScreenEvent>? _screenSubscription;
  bool _isForeground = true;
  bool _pausedByScreenOff = false;

  static const _timerStatus = 'timerStatus';
  static const _cycleStartTime = 'cycleStartTime';
  static const _pausedRemainingSeconds = 'pausedRemainingSeconds';
  static const _snoozeUntil = 'snoozeUntil';

  @override
  void dispose() {
    _ticker?.cancel();
    _screenSubscription?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = _ref.read(settingsControllerProvider);
    final startMs = prefs.getInt(_cycleStartTime);
    final statusName = prefs.getString(_timerStatus);
    final status = _enumByName(
      TimerStatus.values,
      statusName,
      TimerStatus.running,
    );
    final cycleStartTime = startMs == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(startMs);
    final pausedRemaining = prefs.getInt(_pausedRemainingSeconds);
    final snoozeMs = prefs.getInt(_snoozeUntil);

    state = EyeBreakTimerState(
      status: status,
      cycleStartTime: cycleStartTime,
      focusDuration: settings.focusDuration,
      remaining: settings.focusDuration,
      pausedRemaining: pausedRemaining == null
          ? null
          : Duration(seconds: pausedRemaining),
      snoozeUntil: snoozeMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(snoozeMs),
      hasTriggeredBreakEffects: false,
    );
    tick();
    await _scheduleCountdownNotificationIfActive();
  }

  void tick() {
    final previous = state;
    final settings = _ref.read(settingsControllerProvider);
    state = _calculator.recalculate(
      state: state,
      now: DateTime.now(),
      finalCountdownDuration: settings.finalCountdownDuration,
    );
    _persist();
    _handleEffects(previous, state, settings);
  }

  Future<void> start() async {
    final settings = _ref.read(settingsControllerProvider);
    state = _calculator.restart(
      now: DateTime.now(),
      focusDuration: settings.focusDuration,
    );
    await _ref
        .read(notificationServiceProvider)
        .scheduleBreakReminder(
          state.cycleEndTime,
          settings.language.strings.notificationCopy,
          openAppOnBreakDue: settings.androidOpenReminderScreen,
        );
    await _hidePlatformReminder();
    await _persist();
  }

  Future<void> pause() async {
    state = _calculator.pause(state);
    await _ref.read(notificationServiceProvider).cancelBreakReminder();
    await _hidePlatformReminder();
    await _persist();
  }

  Future<void> resume() async {
    state = _calculator.resume(state: state, now: DateTime.now());
    await _ref
        .read(notificationServiceProvider)
        .scheduleBreakReminder(
          state.cycleEndTime,
          _ref
              .read(settingsControllerProvider)
              .language
              .strings
              .notificationCopy,
          openAppOnBreakDue: _ref
              .read(settingsControllerProvider)
              .androidOpenReminderScreen,
        );
    await _persist();
  }

  Future<void> reset() async {
    await start();
  }

  Future<void> confirmBreakCompleted() async {
    await start();
  }

  Future<void> snooze() async {
    state = _calculator.snooze(
      state: state,
      now: DateTime.now(),
      snoozeDuration: const Duration(minutes: AppConstants.snoozeMinutes),
    );
    await _hidePlatformReminder();
    await _ref
        .read(notificationServiceProvider)
        .scheduleBreakReminder(
          state.cycleEndTime,
          _ref
              .read(settingsControllerProvider)
              .language
              .strings
              .notificationCopy,
          openAppOnBreakDue: _ref
              .read(settingsControllerProvider)
              .androidOpenReminderScreen,
        );
    await _persist();
  }

  Future<void> onAppBackgrounded() async {
    _isForeground = false;
    await _persist();
    if (state.status == TimerStatus.running ||
        state.status == TimerStatus.finalCountdown) {
      await _ref
          .read(notificationServiceProvider)
          .scheduleBreakReminder(
            state.cycleEndTime,
            _ref
                .read(settingsControllerProvider)
                .language
                .strings
                .notificationCopy,
            openAppOnBreakDue: _ref
                .read(settingsControllerProvider)
                .androidOpenReminderScreen,
          );
    }
  }

  Future<void> onAppResumed() async {
    _isForeground = true;
    tick();
    await _scheduleCountdownNotificationIfActive();
  }

  void onSettingsChanged(EyeBreakSettings? previous, EyeBreakSettings next) {
    if (previous == null) {
      return;
    }
    if (previous.focusDuration != next.focusDuration) {
      state = _calculator.applyFocusDurationChange(
        state: state,
        now: DateTime.now(),
        newFocusDuration: next.focusDuration,
      );
    }
    if (previous.androidPauseWhenScreenOff &&
        !next.androidPauseWhenScreenOff &&
        _pausedByScreenOff) {
      unawaited(_resumeFromScreenOff());
    }
    tick();
    unawaited(_scheduleCountdownNotificationIfActive());
  }

  Future<void> _handleEffects(
    EyeBreakTimerState previous,
    EyeBreakTimerState current,
    EyeBreakSettings settings,
  ) async {
    if (current.status == TimerStatus.finalCountdown) {
      await _showFinalCountdown(settings, current.remaining.inSeconds);
      return;
    }

    if (previous.status == TimerStatus.finalCountdown &&
        current.status == TimerStatus.running) {
      await _hidePlatformReminder();
    }

    if (current.status == TimerStatus.breakDue &&
        !current.hasTriggeredBreakEffects) {
      state = current.copyWith(hasTriggeredBreakEffects: true);
      await _showBreakDue(settings);
      await _persist();
    }
  }

  Future<void> _showFinalCountdown(
    EyeBreakSettings settings,
    int seconds,
  ) async {
    if (Platform.isWindows) {
      await _ref.read(floatingWindowControllerProvider).showCountdown();
    }
  }

  Future<void> _showBreakDue(EyeBreakSettings settings) async {
    if (settings.soundEnabled) {
      await SystemSound.play(SystemSoundType.alert);
    }

    if (!_isForeground) {
      await _ref
          .read(notificationServiceProvider)
          .showImmediateBreakReminder(
            settings.language.strings.notificationCopy,
            openAppOnBreakDue: settings.androidOpenReminderScreen,
          );
    }

    if (Platform.isWindows) {
      await _ref.read(floatingWindowControllerProvider).showReminder(settings);
    }
  }

  Future<void> _hidePlatformReminder() async {
    if (Platform.isWindows) {
      await _ref.read(floatingWindowControllerProvider).hide();
    }
  }

  Future<void> _scheduleCountdownNotificationIfActive() async {
    if (!Platform.isAndroid) {
      return;
    }
    if (state.status == TimerStatus.running ||
        state.status == TimerStatus.finalCountdown) {
      await _ref
          .read(notificationServiceProvider)
          .scheduleBreakReminder(
            state.cycleEndTime,
            _ref
                .read(settingsControllerProvider)
                .language
                .strings
                .notificationCopy,
            openAppOnBreakDue: _ref
                .read(settingsControllerProvider)
                .androidOpenReminderScreen,
          );
    }
  }

  void _handleAndroidScreenEvent(AndroidScreenEvent event) {
    final settings = _ref.read(settingsControllerProvider);
    if (!settings.androidPauseWhenScreenOff) {
      return;
    }
    switch (event) {
      case AndroidScreenEvent.screenOff:
        unawaited(_pauseForScreenOff());
      case AndroidScreenEvent.screenOn:
        unawaited(_resumeFromScreenOff());
    }
  }

  Future<void> _pauseForScreenOff() async {
    if (_pausedByScreenOff ||
        (state.status != TimerStatus.running &&
            state.status != TimerStatus.finalCountdown)) {
      return;
    }
    _pausedByScreenOff = true;
    state = _calculator.pause(state);
    await _ref.read(notificationServiceProvider).cancelBreakReminder();
    await _persist();
  }

  Future<void> _resumeFromScreenOff() async {
    if (!_pausedByScreenOff) {
      return;
    }
    _pausedByScreenOff = false;
    final settings = _ref.read(settingsControllerProvider);
    state = _calculator.resume(state: state, now: DateTime.now());
    await _ref.read(notificationServiceProvider).scheduleBreakReminder(
      state.cycleEndTime,
      settings.language.strings.notificationCopy,
      openAppOnBreakDue: settings.androidOpenReminderScreen,
    );
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timerStatus, state.status.name);
    await prefs.setInt(
      _cycleStartTime,
      state.cycleStartTime.millisecondsSinceEpoch,
    );
    if (state.pausedRemaining == null) {
      await prefs.remove(_pausedRemainingSeconds);
    } else {
      await prefs.setInt(
        _pausedRemainingSeconds,
        state.pausedRemaining!.inSeconds,
      );
    }
    if (state.snoozeUntil == null) {
      await prefs.remove(_snoozeUntil);
    } else {
      await prefs.setInt(
        _snoozeUntil,
        state.snoozeUntil!.millisecondsSinceEpoch,
      );
    }
  }
}

T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  if (name == null) {
    return fallback;
  }
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return fallback;
}
