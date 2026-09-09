import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

final windowsTrayServiceProvider = Provider<WindowsTrayService>((ref) {
  return WindowsTrayService.instance;
});

class WindowsTrayService with TrayListener {
  WindowsTrayService._();

  static final WindowsTrayService instance = WindowsTrayService._();

  bool _initialized = false;
  bool _visible = false;
  Future<void> Function()? _onOpenRequested;

  Future<void> showCountdownTrayIcon({
    Future<void> Function()? onOpenRequested,
  }) async {
    return showTrayIcon(
      tooltip: 'Reye countdown',
      onOpenRequested: onOpenRequested,
    );
  }

  Future<void> showMinimizedTrayIcon({
    Future<void> Function()? onOpenRequested,
  }) async {
    return showTrayIcon(tooltip: 'Reye', onOpenRequested: onOpenRequested);
  }

  Future<void> showTrayIcon({
    required String tooltip,
    Future<void> Function()? onOpenRequested,
  }) async {
    if (!Platform.isWindows) {
      return;
    }
    _onOpenRequested = onOpenRequested;
    await _initialize();
    await trayManager.setToolTip(tooltip);
    if (_visible) {
      return;
    }
    await trayManager.setIcon('assets/icons/reye.ico');
    _visible = true;
  }

  Future<void> hideTrayIcon() async {
    if (!Platform.isWindows || !_initialized || !_visible) {
      return;
    }
    await trayManager.destroy();
    _onOpenRequested = null;
    _visible = false;
  }

  Future<void> _initialize() async {
    if (_initialized) {
      return;
    }
    trayManager.addListener(this);
    final menu = Menu(
      items: [
        MenuItem(key: 'open', label: 'Open Reye'),
        MenuItem.separator(),
        MenuItem(key: 'exit', label: 'Exit'),
      ],
    );
    await trayManager.setContextMenu(menu);
    _initialized = true;
  }

  @override
  void onTrayIconMouseDown() {
    _openMainWindow();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'open':
        _openMainWindow();
        break;
      case 'exit':
        exit(0);
      default:
        break;
    }
  }

  Future<void> _openMainWindow() async {
    if (!Platform.isWindows) {
      return;
    }
    final onOpenRequested = _onOpenRequested;
    if (onOpenRequested != null) {
      await onOpenRequested();
      return;
    }
    await windowManager.setSkipTaskbar(false);
    await windowManager.show();
    await windowManager.focus();
  }
}
