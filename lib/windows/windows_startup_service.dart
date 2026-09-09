import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final windowsStartupServiceProvider = Provider<WindowsStartupService>((ref) {
  return const WindowsStartupService();
});

class WindowsStartupService {
  const WindowsStartupService();

  static const _runKey = r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run';
  static const _valueName = 'Reye';

  bool get isSupported => Platform.isWindows;

  Future<bool> setEnabled(bool enabled) async {
    if (!isSupported) {
      return false;
    }
    if (!enabled) {
      await _disable();
      return true;
    }
    final result = await _enable();
    return result.exitCode == 0;
  }

  Future<ProcessResult> _enable() {
    final executable = '"${Platform.resolvedExecutable}"';
    return Process.run('reg', [
      'add',
      _runKey,
      '/v',
      _valueName,
      '/t',
      'REG_SZ',
      '/d',
      executable,
      '/f',
    ]);
  }

  Future<ProcessResult> _disable() {
    return Process.run('reg', ['delete', _runKey, '/v', _valueName, '/f']);
  }
}
