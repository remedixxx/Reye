import 'package:reye/core/constants/app_constants.dart';
import 'package:reye/features/timer/domain/eye_break_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('settings validation clamps timer ranges', () {
    final settings = EyeBreakSettings.defaults()
        .copyWith(
          focusIntervalMinutes: -10,
          finalCountdownSeconds: 999999,
          breakDurationSeconds: 999,
        )
        .validated();

    expect(settings.focusIntervalMinutes, AppConstants.minFocusMinutes);
    expect(settings.finalCountdownSeconds, settings.focusDuration.inSeconds);
    expect(settings.breakDurationSeconds, AppConstants.maxBreakSeconds);
  });
}
