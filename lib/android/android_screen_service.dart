import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final androidScreenServiceProvider = Provider<AndroidScreenService>((ref) {
  return const AndroidScreenService();
});

enum AndroidScreenEvent { screenOff, screenOn }

class AndroidScreenService {
  const AndroidScreenService();

  static const EventChannel _events = EventChannel(
    'com.reye.app/android_screen_events',
  );

  Stream<AndroidScreenEvent> get events {
    if (!Platform.isAndroid) {
      return const Stream.empty();
    }
    return _events.receiveBroadcastStream().map((event) {
      return switch (event) {
        'screenOff' => AndroidScreenEvent.screenOff,
        'screenOn' => AndroidScreenEvent.screenOn,
        _ => AndroidScreenEvent.screenOn,
      };
    });
  }
}
