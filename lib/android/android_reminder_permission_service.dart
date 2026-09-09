import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final androidReminderPermissionServiceProvider =
    Provider<AndroidReminderPermissionService>((ref) {
      return const AndroidReminderPermissionService();
    });

class AndroidReminderPermissionService {
  const AndroidReminderPermissionService();

  static const MethodChannel _channel = MethodChannel(
    'com.reye.app/android_notifications',
  );

  Future<bool> isFullScreenIntentPermissionGranted() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>(
            'isFullScreenIntentPermissionGranted',
          ) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> openFullScreenIntentSettings() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>(
            'openFullScreenIntentSettings',
          ) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
