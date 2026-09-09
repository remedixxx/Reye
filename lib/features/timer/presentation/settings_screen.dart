import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../android/android_reminder_permission_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_strings.dart';
import '../../../windows/windows_startup_service.dart';
import '../application/settings_controller.dart';
import '../domain/eye_break_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final strings = settings.language.strings;

    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Section(
            title: strings.timer,
            children: [
              _IntSetting(
                title: strings.focusInterval,
                subtitle: strings.minutes(settings.focusIntervalMinutes),
                value: settings.focusIntervalMinutes,
                min: AppConstants.minFocusMinutes,
                max: AppConstants.maxFocusMinutes,
                step: 1,
                onChanged: controller.updateFocusIntervalMinutes,
              ),
              _FinalCountdownSetting(
                strings: strings,
                value: settings.finalCountdownSeconds,
                max: settings.maxFinalCountdownSeconds,
                onChanged: controller.updateFinalCountdownSeconds,
                onMaxPressed: controller.maximizeFinalCountdownVisibility,
              ),
              _IntSetting(
                title: strings.breakDuration,
                subtitle: strings.seconds(settings.breakDurationSeconds),
                value: settings.breakDurationSeconds,
                min: AppConstants.minBreakSeconds,
                max: AppConstants.maxBreakSeconds,
                step: 5,
                onChanged: controller.updateBreakDurationSeconds,
              ),
              _SwitchSetting(
                title: strings.soundOnReminder,
                value: settings.soundEnabled,
                onChanged: (value) =>
                    controller.updateSoundEnabled(value: value),
              ),
            ],
          ),
          _Section(
            title: strings.reminder,
            children: [
              _DropdownSetting<ReminderDisplayMode>(
                title: strings.reminderDisplayMode,
                value: settings.reminderDisplayMode,
                values: ReminderDisplayMode.values,
                label: strings.reminderDisplayModeLabel,
                onChanged: controller.updateReminderDisplayMode,
              ),
              _DropdownSetting<ReminderSize>(
                title: strings.reminderSize,
                value: settings.reminderSize,
                values: ReminderSize.values,
                label: strings.reminderSizeLabel,
                onChanged: controller.updateReminderSize,
              ),
              if (Platform.isWindows)
                _DropdownSetting<DesktopPosition>(
                  title: strings.windowsMiniWindowPosition,
                  value: settings.desktopPosition,
                  values: DesktopPosition.values,
                  label: strings.desktopPositionLabel,
                  onChanged: controller.updateDesktopPosition,
                ),
            ],
          ),
          if (Platform.isAndroid)
            _Section(
              title: strings.android,
              children: [
                _SwitchSetting(
                  title: strings.androidOpenReminderScreen,
                  subtitle: strings.androidOpenReminderScreenDescription,
                  value: settings.androidOpenReminderScreen,
                  onChanged: (value) async {
                    await controller.updateAndroidOpenReminderScreen(
                      value: value,
                    );
                    if (!value || !context.mounted) {
                      return;
                    }
                    final permissionService = ref.read(
                      androidReminderPermissionServiceProvider,
                    );
                    final granted = await permissionService
                        .isFullScreenIntentPermissionGranted();
                    if (granted || !context.mounted) {
                      return;
                    }
                    final openSettings = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(strings.fullScreenPermissionTitle),
                        content: Text(strings.fullScreenPermissionBody),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(strings.notNow),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(strings.openAndroidSettings),
                          ),
                        ],
                      ),
                    );
                    if (openSettings == true) {
                      await permissionService.openFullScreenIntentSettings();
                    }
                  },
                ),
                _SwitchSetting(
                  title: strings.androidPauseWhenScreenOff,
                  subtitle: strings.androidPauseWhenScreenOffDescription,
                  value: settings.androidPauseWhenScreenOff,
                  onChanged: (value) =>
                      controller.updateAndroidPauseWhenScreenOff(value: value),
                ),
              ],
            ),
          if (Platform.isWindows)
            _Section(
              title: strings.startup,
              children: [
                _SwitchSetting(
                  title: strings.launchOnStartup,
                  subtitle: strings.windowsStartupPlanned,
                  value: settings.launchOnStartupEnabled,
                  onChanged: (value) async {
                    final updated = await ref
                        .read(windowsStartupServiceProvider)
                        .setEnabled(value);
                    if (updated) {
                      await controller.updateLaunchOnStartupEnabled(
                        value: value,
                      );
                      return;
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(strings.startupUpdateFailed),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          _Section(
            title: strings.appearance,
            children: [
              _DropdownSetting<ThemeMode>(
                title: strings.theme,
                value: settings.themeMode,
                values: ThemeMode.values,
                label: strings.themeModeLabel,
                onChanged: controller.updateThemeMode,
              ),
              _DropdownSetting<AppLanguage>(
                title: strings.languageTitle,
                value: settings.language,
                values: AppLanguage.values,
                label: strings.languageLabel,
                onChanged: controller.updateLanguage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1) const _SettingDivider(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingDivider extends StatelessWidget {
  const _SettingDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 24,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.55),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    this.subtitle,
    required this.control,
    this.controlWidth = 220,
  });

  final String title;
  final String? subtitle;
  final Widget control;
  final double controlWidth;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.bodyLarge),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget,
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: controlWidth),
                  child: control,
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titleWidget),
            const SizedBox(width: 24),
            SizedBox(
              width: controlWidth,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: control,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StepperControl extends StatelessWidget {
  const _StepperControl({
    required this.minusValue,
    required this.plusValue,
    required this.onDelta,
  });

  final int minusValue;
  final int plusValue;
  final ValueChanged<int> onDelta;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      showSelectedIcon: false,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(54, 42)),
        visualDensity: VisualDensity.compact,
      ),
      segments: [
        ButtonSegment(
          value: minusValue,
          icon: const Icon(Icons.remove_rounded),
        ),
        ButtonSegment(value: plusValue, icon: const Icon(Icons.add_rounded)),
      ],
      selected: const <int>{},
      emptySelectionAllowed: true,
      onSelectionChanged: (selection) {
        onDelta(selection.firstOrNull ?? 0);
      },
    );
  }
}

class _IntSetting extends StatelessWidget {
  const _IntSetting({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingRow(
      title: title,
      subtitle: subtitle,
      controlWidth: 124,
      control: _StepperControl(
        minusValue: -step,
        plusValue: step,
        onDelta: (delta) => onChanged((value + delta).clamp(min, max).toInt()),
      ),
    );
  }
}

class _FinalCountdownSetting extends StatelessWidget {
  const _FinalCountdownSetting({
    required this.strings,
    required this.value,
    required this.max,
    required this.onChanged,
    required this.onMaxPressed,
  });

  final AppStrings strings;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;
  final VoidCallback onMaxPressed;

  int get _incrementStep {
    if (value < 60) {
      return 5;
    }
    return 60;
  }

  int get _decrementStep {
    if (value <= 60) {
      return 5;
    }
    return 60;
  }

  @override
  Widget build(BuildContext context) {
    return _SettingRow(
      title: strings.finalCountdownVisibility,
      subtitle: strings.finalCountdownSubtitle(value, max),
      controlWidth: 184,
      control: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: strings.maxShort,
            child: SizedBox.square(
              dimension: 42,
              child: OutlinedButton(
                onPressed: value == max ? null : onMaxPressed,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Icon(Icons.keyboard_double_arrow_up_rounded),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _StepperControl(
            minusValue: -_decrementStep,
            plusValue: _incrementStep,
            onDelta: (delta) {
              final next = (value + delta)
                  .clamp(AppConstants.minFinalCountdownSeconds, max)
                  .toInt();
              onChanged(next);
            },
          ),
        ],
      ),
    );
  }
}

class _DropdownSetting<T> extends StatelessWidget {
  const _DropdownSetting({
    required this.title,
    required this.value,
    required this.values,
    required this.label,
    required this.onChanged,
  });

  final String title;
  final T value;
  final List<T> values;
  final String Function(T value) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingRow(
      title: title,
      controlWidth: 260,
      control: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        items: [
          for (final item in values)
            DropdownMenuItem<T>(value: item, child: Text(label(item))),
        ],
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}

class _SwitchSetting extends StatelessWidget {
  const _SwitchSetting({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingRow(
      title: title,
      subtitle: subtitle,
      controlWidth: 92,
      control: Switch(value: value, onChanged: onChanged),
    );
  }
}
