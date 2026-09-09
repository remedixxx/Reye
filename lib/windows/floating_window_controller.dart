import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/timer/domain/eye_break_settings.dart';
import 'windows_window_service.dart';

final floatingWindowControllerProvider = Provider<FloatingWindowController>(
  (ref) => FloatingWindowController(ref.read(windowsWindowServiceProvider)),
);

class FloatingWindowController {
  const FloatingWindowController(this._windowService);

  final WindowsWindowService _windowService;

  Future<void> showCountdown() {
    return _windowService.showMiniWindow();
  }

  Future<void> returnToCountdown() {
    return _windowService.returnToMiniWindow();
  }

  Future<void> showReminder(EyeBreakSettings settings) {
    return _windowService.showReminderWindow(settings.reminderDisplayMode);
  }

  Future<void> hide() {
    return _windowService.hideMiniWindow();
  }

  Future<void> openMainWindowFromMini() {
    return _windowService.openMainWindowFromMini();
  }
}
