import 'dart:io';

import 'package:flutter/services.dart';

import '../../notifications/notification_service.dart';
import '../../windows/windows_tray_service.dart';

class AppShutdownService {
  const AppShutdownService._();

  static const MethodChannel _androidChannel = MethodChannel(
    'com.reye.app/app_lifecycle',
  );

  static Future<void> shutdown({
    required NotificationService notificationService,
  }) async {
    await notificationService.cancelBreakReminder();

    if (Platform.isWindows) {
      await WindowsTrayService.instance.hideTrayIcon();
      exit(0);
    }

    if (Platform.isAndroid) {
      await _shutdownAndroid();
      return;
    }

    exit(0);
  }

  static Future<void> _shutdownAndroid() async {
    try {
      await _androidChannel.invokeMethod<void>('shutdownApp');
    } on PlatformException {
      exit(0);
    } on MissingPluginException {
      exit(0);
    }
  }
}
