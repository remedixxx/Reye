import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

import '../core/navigation/app_navigator.dart';
import '../features/timer/domain/eye_break_settings.dart';
import 'windows_tray_service.dart';

final windowsWindowServiceProvider = Provider<WindowsWindowService>((ref) {
  return WindowsWindowService();
});

class WindowsWindowService with WindowListener {
  static const _mainWindowSize = Size(920, 680);
  static const _mainWindowMinimumSize = Size(720, 560);
  static const _miniWindowSize = Size(124, 36);

  bool _isMiniWindowVisible = false;
  bool _miniSuppressedUntilNextCycle = false;
  bool _restoringFromTray = false;

  bool get _supported => Platform.isWindows;

  Future<void> initialize() async {
    if (!_supported) {
      return;
    }
    await windowManager.ensureInitialized();
    windowManager.addListener(this);
  }

  Future<void> configureMainWindow() async {
    if (!_supported) {
      return;
    }
    const options = WindowOptions(
      size: _mainWindowSize,
      minimumSize: _mainWindowMinimumSize,
      center: true,
      title: 'Reye',
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  Future<void> showMiniWindow() async {
    if (!_supported) {
      return;
    }
    if (_miniSuppressedUntilNextCycle) {
      return;
    }
    popToRootRoute();
    final shouldPlaceInCorner = !_isMiniWindowVisible;
    await windowManager.setAsFrameless();
    await windowManager.setBackgroundColor(const Color(0x00000000));
    await windowManager.setHasShadow(false);
    await windowManager.setSkipTaskbar(true);
    await windowManager.setMinimumSize(const Size(1, 1));
    await windowManager.setSize(_miniWindowSize);
    if (shouldPlaceInCorner) {
      await setWindowPosition(DesktopPosition.topRight);
    }
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setResizable(false);
    await windowManager.show();
    await WindowsTrayService.instance.showCountdownTrayIcon(
      onOpenRequested: openMainWindowFromMini,
    );
    _isMiniWindowVisible = true;
  }

  Future<void> returnToMiniWindow() async {
    if (!_supported) {
      return;
    }
    _miniSuppressedUntilNextCycle = false;
    await showMiniWindow();
  }

  Future<void> hideMiniWindow() async {
    if (!_supported) {
      return;
    }
    _miniSuppressedUntilNextCycle = false;
    await restoreMainWindow();
  }

  Future<void> openMainWindowFromMini() async {
    if (!_supported) {
      return;
    }
    _miniSuppressedUntilNextCycle = true;
    await restoreMainWindow();
    await windowManager.focus();
  }

  Future<void> restoreMainWindow() async {
    if (!_supported) {
      return;
    }
    _isMiniWindowVisible = false;
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setBackgroundColor(const Color(0xFFFFFFFF));
    await WindowsTrayService.instance.hideTrayIcon();
    await windowManager.setHasShadow(true);
    await windowManager.setSkipTaskbar(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    await windowManager.setResizable(true);
    await windowManager.setMinimumSize(_mainWindowMinimumSize);
    await windowManager.setSize(_mainWindowSize);
    await windowManager.center();
    await windowManager.show();
  }

  Future<void> minimizeToTray() async {
    if (!_supported || _isMiniWindowVisible || _restoringFromTray) {
      return;
    }
    await windowManager.setSkipTaskbar(true);
    await windowManager.hide();
    await WindowsTrayService.instance.showMinimizedTrayIcon(
      onOpenRequested: restoreFromTray,
    );
  }

  Future<void> restoreFromTray() async {
    if (!_supported) {
      return;
    }
    _restoringFromTray = true;
    try {
      await WindowsTrayService.instance.hideTrayIcon();
      await windowManager.setSkipTaskbar(false);
      await windowManager.show();
      await windowManager.restore();
      await windowManager.focus();
    } finally {
      _restoringFromTray = false;
    }
  }

  @override
  void onWindowMinimize() {
    unawaited(minimizeToTray());
  }

  Future<void> setAlwaysOnTop(bool value) async {
    if (_supported) {
      await windowManager.setAlwaysOnTop(value);
    }
  }

  Future<void> setWindowPosition(DesktopPosition position) async {
    if (!_supported) {
      return;
    }
    final display = await screenRetriever.getPrimaryDisplay();
    final visible = display.visiblePosition ?? const Offset(0, 0);
    final size = await windowManager.getSize();
    final area = display.visibleSize ?? display.size;
    const margin = 24.0;

    final left = switch (position) {
      DesktopPosition.topLeft ||
      DesktopPosition.bottomLeft => visible.dx + margin,
      DesktopPosition.topRight || DesktopPosition.bottomRight =>
        visible.dx + area.width - size.width - margin,
    };
    final top = switch (position) {
      DesktopPosition.topLeft ||
      DesktopPosition.topRight => visible.dy + margin,
      DesktopPosition.bottomLeft || DesktopPosition.bottomRight =>
        visible.dy + area.height - size.height - margin,
    };
    await windowManager.setPosition(Offset(left, top));
  }

  Future<void> setCompactSize(ReminderSize size) async {
    if (!_supported) {
      return;
    }
    final windowSize = switch (size) {
      ReminderSize.small => const Size(132, 84),
      ReminderSize.medium => const Size(220, 132),
      ReminderSize.large => const Size(320, 188),
    };
    await windowManager.setSize(windowSize);
  }

  Future<void> showReminderWindow(ReminderDisplayMode mode) async {
    if (!_supported) {
      return;
    }
    _isMiniWindowVisible = false;
    _miniSuppressedUntilNextCycle = false;
    await windowManager.setMinimumSize(const Size(1, 1));
    await WindowsTrayService.instance.hideTrayIcon();
    await windowManager.setBackgroundColor(const Color(0xFFFFFFFF));
    await windowManager.setHasShadow(true);
    await windowManager.setSkipTaskbar(false);
    final windowSize = switch (mode) {
      ReminderDisplayMode.compactBanner => const Size(640, 320),
      ReminderDisplayMode.mediumCard => const Size(560, 440),
      ReminderDisplayMode.fullScreen => _mainWindowSize,
    };
    await windowManager.setMinimumSize(const Size(420, 300));
    await windowManager.setSize(windowSize);
    await _placeReminderWindow(mode, windowSize);
    await windowManager.setAlwaysOnTop(true);
    await windowManager.show();
  }

  Future<void> _placeReminderWindow(
    ReminderDisplayMode mode,
    Size windowSize,
  ) async {
    final display = await screenRetriever.getPrimaryDisplay();
    final visible = display.visiblePosition ?? const Offset(0, 0);
    final area = display.visibleSize ?? display.size;

    final left = visible.dx + (area.width - windowSize.width) / 2;
    final top = switch (mode) {
      ReminderDisplayMode.compactBanner => visible.dy + 32,
      ReminderDisplayMode.mediumCard || ReminderDisplayMode.fullScreen =>
        visible.dy + (area.height - windowSize.height) / 2,
    };

    await windowManager.setPosition(Offset(left, top));
  }
}
