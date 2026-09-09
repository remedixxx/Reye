import 'dart:io';

class PlatformInfo {
  const PlatformInfo._();

  static bool get isAndroid => Platform.isAndroid;
  static bool get isWindows => Platform.isWindows;
}
