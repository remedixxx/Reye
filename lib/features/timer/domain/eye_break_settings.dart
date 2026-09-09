import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

enum ReminderDisplayMode { compactBanner, mediumCard, fullScreen }

enum ReminderSize { small, medium, large }

enum DesktopPosition { topLeft, topRight, bottomLeft, bottomRight }

enum AppLanguage { english, persian }

class EyeBreakSettings {
  const EyeBreakSettings({
    required this.focusIntervalMinutes,
    required this.finalCountdownSeconds,
    required this.breakDurationSeconds,
    required this.soundEnabled,
    required this.reminderDisplayMode,
    required this.reminderSize,
    required this.desktopPosition,
    required this.androidOpenReminderScreen,
    required this.androidPauseWhenScreenOff,
    required this.launchOnStartupEnabled,
    required this.themeMode,
    required this.language,
  });

  factory EyeBreakSettings.defaults() {
    return const EyeBreakSettings(
      focusIntervalMinutes: AppConstants.defaultFocusMinutes,
      finalCountdownSeconds: AppConstants.defaultFinalCountdownSeconds,
      breakDurationSeconds: AppConstants.defaultBreakSeconds,
      soundEnabled: true,
      reminderDisplayMode: ReminderDisplayMode.mediumCard,
      reminderSize: ReminderSize.medium,
      desktopPosition: DesktopPosition.topRight,
      androidOpenReminderScreen: false,
      androidPauseWhenScreenOff: false,
      launchOnStartupEnabled: false,
      themeMode: ThemeMode.system,
      language: AppLanguage.english,
    );
  }

  final int focusIntervalMinutes;
  final int finalCountdownSeconds;
  final int breakDurationSeconds;
  final bool soundEnabled;
  final ReminderDisplayMode reminderDisplayMode;
  final ReminderSize reminderSize;
  final DesktopPosition desktopPosition;
  final bool androidOpenReminderScreen;
  final bool androidPauseWhenScreenOff;
  final bool launchOnStartupEnabled;
  final ThemeMode themeMode;
  final AppLanguage language;

  Duration get focusDuration => Duration(minutes: focusIntervalMinutes);
  Duration get finalCountdownDuration =>
      Duration(seconds: finalCountdownSeconds);
  Duration get breakDuration => Duration(seconds: breakDurationSeconds);
  int get maxFinalCountdownSeconds => focusDuration.inSeconds;

  EyeBreakSettings validated() {
    final safeFocusMinutes = focusIntervalMinutes.clamp(
      AppConstants.minFocusMinutes,
      AppConstants.maxFocusMinutes,
    );
    final safeFocusSeconds = Duration(minutes: safeFocusMinutes).inSeconds;
    return copyWith(
      focusIntervalMinutes: safeFocusMinutes,
      finalCountdownSeconds: finalCountdownSeconds.clamp(
        AppConstants.minFinalCountdownSeconds,
        safeFocusSeconds,
      ),
      breakDurationSeconds: breakDurationSeconds.clamp(
        AppConstants.minBreakSeconds,
        AppConstants.maxBreakSeconds,
      ),
    );
  }

  EyeBreakSettings copyWith({
    int? focusIntervalMinutes,
    int? finalCountdownSeconds,
    int? breakDurationSeconds,
    bool? soundEnabled,
    ReminderDisplayMode? reminderDisplayMode,
    ReminderSize? reminderSize,
    DesktopPosition? desktopPosition,
    bool? androidOpenReminderScreen,
    bool? androidPauseWhenScreenOff,
    bool? launchOnStartupEnabled,
    ThemeMode? themeMode,
    AppLanguage? language,
  }) {
    return EyeBreakSettings(
      focusIntervalMinutes: focusIntervalMinutes ?? this.focusIntervalMinutes,
      finalCountdownSeconds:
          finalCountdownSeconds ?? this.finalCountdownSeconds,
      breakDurationSeconds: breakDurationSeconds ?? this.breakDurationSeconds,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      reminderDisplayMode: reminderDisplayMode ?? this.reminderDisplayMode,
      reminderSize: reminderSize ?? this.reminderSize,
      desktopPosition: desktopPosition ?? this.desktopPosition,
      androidOpenReminderScreen:
          androidOpenReminderScreen ?? this.androidOpenReminderScreen,
      androidPauseWhenScreenOff:
          androidPauseWhenScreenOff ?? this.androidPauseWhenScreenOff,
      launchOnStartupEnabled:
          launchOnStartupEnabled ?? this.launchOnStartupEnabled,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }
}
