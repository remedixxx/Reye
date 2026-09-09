import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/eye_break_settings.dart';

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, EyeBreakSettings>((ref) {
      return SettingsController()..load();
    });

class SettingsController extends StateNotifier<EyeBreakSettings> {
  SettingsController() : super(EyeBreakSettings.defaults());

  static const _focusIntervalMinutes = 'focusIntervalMinutes';
  static const _finalCountdownSeconds = 'finalCountdownSeconds';
  static const _breakDurationSeconds = 'breakDurationSeconds';
  static const _soundEnabled = 'soundEnabled';
  static const _reminderDisplayMode = 'reminderDisplayMode';
  static const _reminderSize = 'reminderSize';
  static const _desktopPosition = 'desktopPosition';
  static const _androidOpenReminderScreen = 'androidOpenReminderScreen';
  static const _androidPauseWhenScreenOff = 'androidPauseWhenScreenOff';
  static const _launchOnStartupEnabled = 'launchOnStartupEnabled';
  static const _themeMode = 'themeMode';
  static const _language = 'language';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = EyeBreakSettings(
      focusIntervalMinutes:
          prefs.getInt(_focusIntervalMinutes) ?? state.focusIntervalMinutes,
      finalCountdownSeconds:
          prefs.getInt(_finalCountdownSeconds) ?? state.finalCountdownSeconds,
      breakDurationSeconds:
          prefs.getInt(_breakDurationSeconds) ?? state.breakDurationSeconds,
      soundEnabled: prefs.getBool(_soundEnabled) ?? state.soundEnabled,
      reminderDisplayMode: _enumByName(
        ReminderDisplayMode.values,
        prefs.getString(_reminderDisplayMode),
        state.reminderDisplayMode,
      ),
      reminderSize: _enumByName(
        ReminderSize.values,
        prefs.getString(_reminderSize),
        state.reminderSize,
      ),
      desktopPosition: _enumByName(
        DesktopPosition.values,
        prefs.getString(_desktopPosition),
        state.desktopPosition,
      ),
      androidOpenReminderScreen:
          prefs.getBool(_androidOpenReminderScreen) ??
          state.androidOpenReminderScreen,
      androidPauseWhenScreenOff:
          prefs.getBool(_androidPauseWhenScreenOff) ??
          state.androidPauseWhenScreenOff,
      launchOnStartupEnabled:
          prefs.getBool(_launchOnStartupEnabled) ??
          state.launchOnStartupEnabled,
      themeMode: _enumByName(
        ThemeMode.values,
        prefs.getString(_themeMode),
        state.themeMode,
      ),
      language: _enumByName(
        AppLanguage.values,
        prefs.getString(_language),
        state.language,
      ),
    ).validated();
    await _persist(state);
  }

  Future<void> updateFocusIntervalMinutes(int value) {
    return _update(state.copyWith(focusIntervalMinutes: value).validated());
  }

  Future<void> updateFinalCountdownSeconds(int value) {
    return _update(state.copyWith(finalCountdownSeconds: value).validated());
  }

  Future<void> maximizeFinalCountdownVisibility() {
    return updateFinalCountdownSeconds(state.maxFinalCountdownSeconds);
  }

  Future<void> updateBreakDurationSeconds(int value) {
    return _update(state.copyWith(breakDurationSeconds: value).validated());
  }

  Future<void> updateSoundEnabled({required bool value}) {
    return _update(state.copyWith(soundEnabled: value));
  }

  Future<void> updateReminderDisplayMode(ReminderDisplayMode value) {
    return _update(state.copyWith(reminderDisplayMode: value));
  }

  Future<void> updateReminderSize(ReminderSize value) {
    return _update(state.copyWith(reminderSize: value));
  }

  Future<void> updateDesktopPosition(DesktopPosition value) {
    return _update(state.copyWith(desktopPosition: value));
  }

  Future<void> updateAndroidOpenReminderScreen({required bool value}) {
    return _update(state.copyWith(androidOpenReminderScreen: value));
  }

  Future<void> updateAndroidPauseWhenScreenOff({required bool value}) {
    return _update(state.copyWith(androidPauseWhenScreenOff: value));
  }

  Future<void> updateLaunchOnStartupEnabled({required bool value}) {
    return _update(state.copyWith(launchOnStartupEnabled: value));
  }

  Future<void> updateThemeMode(ThemeMode value) {
    return _update(state.copyWith(themeMode: value));
  }

  Future<void> updateLanguage(AppLanguage value) {
    return _update(state.copyWith(language: value));
  }

  Future<void> _update(EyeBreakSettings next) async {
    state = next.validated();
    await _persist(state);
  }

  Future<void> _persist(EyeBreakSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_focusIntervalMinutes, settings.focusIntervalMinutes);
    await prefs.setInt(_finalCountdownSeconds, settings.finalCountdownSeconds);
    await prefs.setInt(_breakDurationSeconds, settings.breakDurationSeconds);
    await prefs.setBool(_soundEnabled, settings.soundEnabled);
    await prefs.setString(
      _reminderDisplayMode,
      settings.reminderDisplayMode.name,
    );
    await prefs.setString(_reminderSize, settings.reminderSize.name);
    await prefs.setString(_desktopPosition, settings.desktopPosition.name);
    await prefs.setBool(
      _androidOpenReminderScreen,
      settings.androidOpenReminderScreen,
    );
    await prefs.setBool(
      _androidPauseWhenScreenOff,
      settings.androidPauseWhenScreenOff,
    );
    await prefs.setBool(
      _launchOnStartupEnabled,
      settings.launchOnStartupEnabled,
    );
    await prefs.setString(_themeMode, settings.themeMode.name);
    await prefs.setString(_language, settings.language.name);
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
