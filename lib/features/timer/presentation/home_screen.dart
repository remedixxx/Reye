import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/duration_format.dart';
import '../../../core/widgets/reye_logo.dart';
import '../../../l10n/app_strings.dart';
import '../../../notifications/notification_service.dart';
import '../../../windows/floating_window_controller.dart';
import '../application/settings_controller.dart';
import '../application/timer_controller.dart';
import '../domain/eye_break_settings.dart';
import '../domain/timer_status.dart';
import 'mini_countdown_widget.dart';
import 'reminder_view.dart';
import 'settings_screen.dart';
import 'timer_controls.dart';

final windowsFloatingCountdownVisibleProvider = StateProvider<bool>((ref) {
  return true;
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final showWindowsFloatingCountdown = ref.watch(
      windowsFloatingCountdownVisibleProvider,
    );

    if (timer.status != TimerStatus.finalCountdown &&
        !showWindowsFloatingCountdown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        ref.read(windowsFloatingCountdownVisibleProvider.notifier).state = true;
      });
    }

    if (Platform.isWindows &&
        timer.status == TimerStatus.finalCountdown &&
        showWindowsFloatingCountdown) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: MiniCountdownWidget(
            label: settings.language.strings.compactSeconds(
              timer.remaining.inSeconds,
            ),
            draggable: true,
            openMainTooltip: settings.language.strings.openMainWindow,
            onOpenMain: () async {
              ref.read(windowsFloatingCountdownVisibleProvider.notifier).state =
                  false;
              await ref
                  .read(floatingWindowControllerProvider)
                  .openMainWindowFromMini();
            },
          ),
        ),
      );
    }

    if (timer.status == TimerStatus.breakDue) {
      final forceFullScreenReminder =
          Platform.isAndroid && settings.androidOpenReminderScreen;
      return Scaffold(
        appBar: forceFullScreenReminder
            ? null
            : AppBar(title: _BrandTitle(strings: settings.language.strings)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ReminderView(
              displayMode: forceFullScreenReminder
                  ? ReminderDisplayMode.fullScreen
                  : settings.reminderDisplayMode,
              size: forceFullScreenReminder
                  ? ReminderSize.large
                  : settings.reminderSize,
            ),
          ),
        ),
      );
    }

    final nextBreak = timer.cycleEndTime;
    return Scaffold(
      appBar: AppBar(
        title: _BrandTitle(strings: settings.language.strings),
        actions: [
          IconButton(
            tooltip: settings.language.strings.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _NotificationWarning(),
            _StatusCard(
              status: timer.status,
              remaining: timer.remaining,
              nextBreak: nextBreak,
              strings: settings.language.strings,
              focusIntervalMinutes: settings.focusIntervalMinutes,
              finalCountdownSeconds: settings.finalCountdownSeconds,
              breakDurationSeconds: settings.breakDurationSeconds,
            ),
            const SizedBox(height: 18),
            TimerControls(status: timer.status),
            const SizedBox(height: 24),
            if (timer.status == TimerStatus.finalCountdown)
              _InlineFinalCountdown(
                label: settings.language.strings.compactSeconds(
                  timer.remaining.inSeconds,
                ),
                strings: settings.language.strings,
                showReturnButton:
                    Platform.isWindows && !showWindowsFloatingCountdown,
                onReturnToFloating: () {
                  ref
                          .read(
                            windowsFloatingCountdownVisibleProvider.notifier,
                          )
                          .state =
                      true;
                  ref
                      .read(floatingWindowControllerProvider)
                      .returnToCountdown();
                },
              ),
            const SizedBox(height: 24),
            _GuidancePanel(strings: settings.language.strings),
            const SizedBox(height: 24),
            _InfoPanel(
              note: Platform.isWindows
                  ? settings.language.strings.windowsBehaviorNote
                  : Platform.isAndroid
                  ? settings.language.strings.androidBehaviorNote
                  : settings.language.strings.unsupportedPlatformNote,
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineFinalCountdown extends StatelessWidget {
  const _InlineFinalCountdown({
    required this.label,
    required this.strings,
    required this.showReturnButton,
    required this.onReturnToFloating,
  });

  final String label;
  final AppStrings strings;
  final bool showReturnButton;
  final VoidCallback onReturnToFloating;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        MiniCountdownWidget(label: label),
        if (showReturnButton)
          OutlinedButton.icon(
            onPressed: onReturnToFloating,
            icon: const Icon(Icons.open_in_full_rounded),
            label: Text(strings.returnToFloatingCountdown),
          ),
      ],
    );
  }
}

class _GuidancePanel extends StatelessWidget {
  const _GuidancePanel({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final paragraphs = strings.eyeCareGuidanceParagraphs;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.visibility_outlined, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    strings.eyeCareGuidanceTitle,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final paragraph in paragraphs) ...[
              Text(
                paragraph,
                style: textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
              if (paragraph != paragraphs.last) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.status,
    required this.remaining,
    required this.nextBreak,
    required this.strings,
    required this.focusIntervalMinutes,
    required this.finalCountdownSeconds,
    required this.breakDurationSeconds,
  });

  final TimerStatus status;
  final Duration remaining;
  final DateTime nextBreak;
  final AppStrings strings;
  final int focusIntervalMinutes;
  final int finalCountdownSeconds;
  final int breakDurationSeconds;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.timerStatus(status), style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              strings.digits(formatDurationClock(remaining)),
              style: textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              strings.nextBreakAt(
                MaterialLocalizations.of(
                  context,
                ).formatTimeOfDay(TimeOfDay.fromDateTime(nextBreak)),
              ),
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            _TimerSummaryChips(
              strings: strings,
              focusIntervalMinutes: focusIntervalMinutes,
              finalCountdownSeconds: finalCountdownSeconds,
              breakDurationSeconds: breakDurationSeconds,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerSummaryChips extends StatelessWidget {
  const _TimerSummaryChips({
    required this.strings,
    required this.focusIntervalMinutes,
    required this.finalCountdownSeconds,
    required this.breakDurationSeconds,
  });

  final AppStrings strings;
  final int focusIntervalMinutes;
  final int finalCountdownSeconds;
  final int breakDurationSeconds;

  @override
  Widget build(BuildContext context) {
    final items = [
      (strings.focusShort, strings.minutes(focusIntervalMinutes)),
      (
        strings.finalCountdownShort,
        strings.countdownDuration(finalCountdownSeconds),
      ),
      (strings.breakShortLabel, strings.seconds(breakDurationSeconds)),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          _TimerSummaryChip(label: item.$1, value: item.$2),
      ],
    );
  }
}

class _TimerSummaryChip extends StatelessWidget {
  const _TimerSummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                note,
                style: Theme.of(context).textTheme.bodyMedium,
                strutStyle: const StrutStyle(
                  forceStrutHeight: true,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationWarning extends ConsumerStatefulWidget {
  @override
  ConsumerState<_NotificationWarning> createState() =>
      _NotificationWarningState();
}

class _NotificationWarningState extends ConsumerState<_NotificationWarning> {
  bool? _granted;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      Future.microtask(() async {
        final granted = await ref
            .read(notificationServiceProvider)
            .requestPermissions();
        if (mounted) {
          setState(() => _granted = granted);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(
      settingsControllerProvider.select(
        (settings) => settings.language.strings,
      ),
    );
    if (!Platform.isAndroid || _granted != false) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(strings.notificationsOff),
        ),
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ReyeLogo(size: 32),
        const SizedBox(width: 10),
        Text(strings.appName),
      ],
    );
  }
}
