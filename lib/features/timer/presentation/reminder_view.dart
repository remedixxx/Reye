import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_strings.dart';
import '../application/settings_controller.dart';
import '../application/timer_controller.dart';
import '../domain/eye_break_settings.dart';

class ReminderView extends ConsumerWidget {
  const ReminderView({
    required this.displayMode,
    required this.size,
    super.key,
  });

  final ReminderDisplayMode displayMode;
  final ReminderSize size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(
      settingsControllerProvider.select(
        (settings) => settings.language.strings,
      ),
    );
    final padding = switch (size) {
      ReminderSize.small => const EdgeInsets.all(18),
      ReminderSize.medium => const EdgeInsets.all(24),
      ReminderSize.large => const EdgeInsets.all(32),
    };
    final titleStyle = switch (size) {
      ReminderSize.small => Theme.of(context).textTheme.titleLarge,
      ReminderSize.medium => Theme.of(context).textTheme.headlineSmall,
      ReminderSize.large => Theme.of(context).textTheme.headlineMedium,
    };

    final content = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.visibility_outlined,
            size: size == ReminderSize.large ? 44 : 34,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            strings.reminderTitle,
            style: titleStyle?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            strings.reminderBody,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: () => ref
                    .read(timerControllerProvider.notifier)
                    .confirmBreakCompleted(),
                child: Text(strings.reminderButton),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(timerControllerProvider.notifier).snooze(),
                child: Text(strings.snoozeButton),
              ),
            ],
          ),
        ],
      ),
    );

    if (displayMode == ReminderDisplayMode.compactBanner) {
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Card(child: content),
        ),
      );
    }

    if (displayMode == ReminderDisplayMode.fullScreen) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: content,
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(child: content),
      ),
    );
  }
}
