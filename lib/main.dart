import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'notifications/notification_service.dart';
import 'windows/windows_window_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = Platform.isAndroid
      ? AndroidNotificationService()
      : const DesktopNotificationService();
  await notificationService.initialize();

  final windowsWindowService = WindowsWindowService();
  if (Platform.isWindows) {
    await windowsWindowService.initialize();
    await windowsWindowService.configureMainWindow();
  }

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
        windowsWindowServiceProvider.overrideWithValue(windowsWindowService),
      ],
      child: const ReyeApp(),
    ),
  );
}
