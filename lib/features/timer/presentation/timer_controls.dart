import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/app_shutdown_service.dart';
import '../../../l10n/app_strings.dart';
import '../../../notifications/notification_service.dart';
import '../application/settings_controller.dart';
import '../application/timer_controller.dart';
import '../domain/timer_status.dart';

class TimerControls extends ConsumerWidget {
  const TimerControls({required this.status, super.key});

  final TimerStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(timerControllerProvider.notifier);
    final strings = ref.watch(
      settingsControllerProvider.select(
        (settings) => settings.language.strings,
      ),
    );
    final isPaused = status == TimerStatus.paused;
    const buttonSize = Size(120, 44);
    final colorScheme = Theme.of(context).colorScheme;
    final fixedButtonStyle = ButtonStyle(
      fixedSize: const WidgetStatePropertyAll(buttonSize),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 14),
      ),
      alignment: Alignment.center,
    );
    final exitButtonStyle = fixedButtonStyle.copyWith(
      backgroundColor: WidgetStatePropertyAll(colorScheme.error),
      foregroundColor: WidgetStatePropertyAll(colorScheme.onError),
      iconColor: WidgetStatePropertyAll(colorScheme.onError),
    );

    Future<void> exitApp() async {
      await AppShutdownService.shutdown(
        notificationService: ref.read(notificationServiceProvider),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton.icon(
          style: fixedButtonStyle,
          onPressed: isPaused ? controller.resume : controller.start,
          icon: Icon(isPaused ? Icons.play_arrow_rounded : Icons.refresh),
          label: Text(isPaused ? strings.resume : strings.start),
        ),
        OutlinedButton.icon(
          style: fixedButtonStyle,
          onPressed: status == TimerStatus.paused ? null : controller.pause,
          icon: const Icon(Icons.pause_rounded),
          label: Text(strings.pause),
        ),
        TextButton.icon(
          style: fixedButtonStyle,
          onPressed: controller.reset,
          icon: const Icon(Icons.restart_alt_rounded),
          label: Text(strings.reset),
        ),
        FilledButton.icon(
          style: exitButtonStyle,
          onPressed: exitApp,
          icon: const Icon(Icons.power_settings_new_rounded),
          label: Text(strings.exitApp),
        ),
      ],
    );
  }
}
