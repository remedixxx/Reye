import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_strings.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  if (Platform.isAndroid) {
    return AndroidNotificationService();
  }
  return const DesktopNotificationService();
});

abstract class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermissions();
  Future<void> scheduleBreakReminder(
    DateTime scheduledTime,
    NotificationCopy copy, {
    bool openAppOnBreakDue = false,
  });
  Future<void> cancelBreakReminder();
  Future<void> showImmediateBreakReminder(
    NotificationCopy copy, {
    bool openAppOnBreakDue = false,
  });
  Future<void> handleNotificationTap();
}

class AndroidNotificationService implements NotificationService {
  AndroidNotificationService();

  static const MethodChannel _channel = MethodChannel(
    'com.reye.app/android_notifications',
  );

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    await _invoke<void>('initialize');
    _initialized = true;
  }

  @override
  Future<bool> requestPermissions() async {
    return await _invoke<bool>('requestPermissions') ?? false;
  }

  @override
  Future<void> scheduleBreakReminder(
    DateTime scheduledTime,
    NotificationCopy copy, {
    bool openAppOnBreakDue = false,
  }) async {
    await _invoke<void>('scheduleBreakReminder', {
      'scheduledTimeMillis': scheduledTime.millisecondsSinceEpoch,
      'reminderTitle': copy.reminderTitle,
      'reminderBody': copy.reminderBody,
      'countdownTitle': copy.countdownTitle,
      'countdownBody': copy.countdownBody,
      'openAppOnBreakDue': openAppOnBreakDue,
    });
  }

  @override
  Future<void> cancelBreakReminder() async {
    await _invoke<void>('cancelBreakReminder');
  }

  @override
  Future<void> showImmediateBreakReminder(
    NotificationCopy copy, {
    bool openAppOnBreakDue = false,
  }) async {
    await _invoke<void>('showImmediateBreakReminder', {
      'reminderTitle': copy.reminderTitle,
      'reminderBody': copy.reminderBody,
      'openAppOnBreakDue': openAppOnBreakDue,
    });
  }

  @override
  Future<void> handleNotificationTap() async {}

  Future<T?> _invoke<T>(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}

class DesktopNotificationService implements NotificationService {
  const DesktopNotificationService();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleBreakReminder(
    DateTime scheduledTime,
    NotificationCopy copy, {
    bool openAppOnBreakDue = false,
  }) async {}

  @override
  Future<void> cancelBreakReminder() async {}

  @override
  Future<void> showImmediateBreakReminder(
    NotificationCopy copy, {
    bool openAppOnBreakDue = false,
  }) async {}

  @override
  Future<void> handleNotificationTap() async {}
}
