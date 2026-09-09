import 'package:flutter/material.dart';

import '../features/timer/domain/eye_break_settings.dart';
import '../features/timer/domain/timer_status.dart';

class NotificationCopy {
  const NotificationCopy({
    required this.reminderTitle,
    required this.reminderBody,
    required this.countdownTitle,
    required this.countdownBody,
  });

  final String reminderTitle;
  final String reminderBody;
  final String countdownTitle;
  final String countdownBody;
}

class AppStrings {
  const AppStrings._(this.language);

  final AppLanguage language;

  static AppStrings of(AppLanguage language) => AppStrings._(language);

  bool get isPersian => language == AppLanguage.persian;

  Locale get locale => isPersian ? const Locale('fa') : const Locale('en');

  TextDirection get textDirection =>
      isPersian ? TextDirection.rtl : TextDirection.ltr;

  String get appName => 'Reye';

  String get settings => isPersian ? 'تنظیمات' : 'Settings';
  String get timer => isPersian ? 'تایمر' : 'Timer';
  String get reminder => isPersian ? 'یادآور' : 'Reminder';
  String get android => isPersian ? 'اندروید' : 'Android';
  String get startup => isPersian ? 'شروع خودکار' : 'Startup';
  String get appearance => isPersian ? 'ظاهر' : 'Appearance';
  String get languageTitle => isPersian ? 'زبان' : 'Language';
  String get english => isPersian ? 'انگلیسی' : 'English';
  String get persian => isPersian ? 'فارسی' : 'Persian';

  String get focusInterval => isPersian ? 'مدت تمرکز' : 'Focus interval';
  String get focusShort => isPersian ? 'تمرکز' : 'Focus';
  String get finalCountdownVisibility =>
      isPersian ? 'نمایش شمارش پایانی' : 'Final countdown visibility';
  String get finalCountdownShort => isPersian ? 'شمارش' : 'Countdown';
  String get breakDuration => isPersian ? 'مدت استراحت' : 'Break duration';
  String get breakShortLabel => isPersian ? 'استراحت' : 'Break';
  String get soundOnReminder => isPersian ? 'صدای یادآور' : 'Sound on reminder';
  String get reminderDisplayMode =>
      isPersian ? 'حالت نمایش یادآور' : 'Reminder display mode';
  String get reminderSize => isPersian ? 'اندازه یادآور' : 'Reminder size';
  String get windowsMiniWindowPosition =>
      isPersian ? 'جای پنجره کوچک ویندوز' : 'Windows mini window position';
  String get androidOpenReminderScreen => isPersian
      ? 'باز کردن صفحه یادآور'
      : 'Open reminder screen';
  String get androidOpenReminderScreenDescription => isPersian
      ? 'اگر روشن باشد، Reye برای باز کردن صفحه یادآور تلاش می‌کند. در صورت محدودیت اندروید، نوتیفیکیشن نمایش داده می‌شود.'
      : 'When enabled, Reye attempts to open the reminder screen. A notification is used if Android restricts it.';
  String get fullScreenPermissionTitle => isPersian
      ? 'اجازه یادآوری تمام‌صفحه'
      : 'Full-screen reminder permission';
  String get fullScreenPermissionBody => isPersian
      ? 'در اندروید ۱۴ و جدیدتر باید اجازه نمایش اعلان تمام‌صفحه را از تنظیمات سیستم فعال کنید. اگر اجازه ندهید، Reye همچنان نوتیفیکیشن نشان می‌دهد.'
      : 'Android 14 and newer require system permission for full-screen alerts. If you do not allow it, Reye still shows a notification.';
  String get openAndroidSettings =>
      isPersian ? 'باز کردن تنظیمات' : 'Open settings';
  String get notNow => isPersian ? 'فعلاً نه' : 'Not now';
  String get androidPauseWhenScreenOff => isPersian
      ? 'توقف هنگام خاموش بودن صفحه'
      : 'Pause while screen is off';
  String get androidPauseWhenScreenOffDescription => isPersian
      ? 'اگر روشن باشد، با خاموش شدن صفحه گوشی تایمر متوقف می‌شود و با روشن شدن صفحه ادامه پیدا می‌کند.'
      : 'When enabled, the timer pauses while the phone screen is off and resumes when the screen turns on.';
  String get launchOnStartup =>
      isPersian ? 'اجرا هنگام شروع سیستم' : 'Launch on startup';
  String get windowsStartupPlanned => isPersian
      ? 'Reye هنگام ورود به ویندوز برای همان کاربر اجرا می‌شود.'
      : 'Start Reye automatically when this Windows user signs in.';
  String get startupUpdateFailed => isPersian
      ? 'تغییر تنظیم اجرای خودکار انجام نشد.'
      : 'Could not update launch on startup.';
  String get androidStartupRestricted => isPersian
      ? 'اندروید اجرای خودکار را محدود می‌کند؛ Reye آن را اجباری نمی‌کند.'
      : 'Android restricts startup behavior; Reye does not force it.';
  String get theme => isPersian ? 'تم' : 'Theme';
  String get max => isPersian ? 'حداکثر' : 'Max';
  String get maxShort => isPersian ? 'بیشینه' : 'Max';

  String get start => isPersian ? 'شروع' : 'Start';
  String get resume => isPersian ? 'ادامه' : 'Resume';
  String get pause => isPersian ? 'مکث' : 'Pause';
  String get reset => isPersian ? 'بازنشانی' : 'Reset';
  String get exitApp => isPersian ? 'خروج' : 'Exit';
  String get openMainWindow => isPersian ? 'باز کردن Reye' : 'Open Reye';
  String get returnToFloatingCountdown =>
      isPersian ? 'برگشت به شمارنده شناور' : 'Return to floating countdown';
  String get eyeCareGuidanceTitle =>
      isPersian ? 'راهنمای راحتی چشم' : 'Eye comfort guidance';

  List<String> get eyeCareGuidanceParagraphs => isPersian
      ? const [
          'استفاده طولانی از مانیتور و گوشی باعث می‌شود چشم‌ها برای مدت زیادی روی فاصله نزدیک متمرکز بمانند.',
          'این وضعیت می‌تواند به خشکی، خستگی چشم، تاری دید، سردرد و کاهش راحتی هنگام کار روزانه منجر شود.',
          'Reye به شما کمک می‌کند یک عادت سالم‌تر برای استفاده از صفحه‌نمایش بسازید.',
          'هر ۲۰ دقیقه، برای ۲۰ ثانیه از صفحه فاصله بگیرید و به نقطه‌ای دور نگاه کنید.',
          'این مکث کوتاه به آرام شدن عضلات تمرکز چشم، پلک‌زدن طبیعی‌تر و بازیابی راحتی چشم کمک می‌کند.',
          'برای نتیجه بهتر، فاصله مناسب از صفحه را حفظ کنید، نور و بازتاب صفحه را تنظیم کنید و بدون وقفه طولانی کار نکنید.',
          'Reye درمان پزشکی نیست، اما یک یادآور ساده و آرام برای مراقبت بهتر از چشم‌ها هنگام استفاده روزانه از صفحه‌نمایش است.',
        ]
      : const [
          'Long screen time can make your eyes work harder, especially when you focus up close without enough breaks.',
          'This may lead to dryness, tired eyes, blurred vision, headaches, and reduced comfort during the day.',
          'Reye helps you build a healthier screen habit based on simple, evidence-informed eye-care guidance.',
          'Every 20 minutes, look away from your screen for 20 seconds and focus on something far away.',
          'This short pause helps relax your focusing muscles, encourages natural blinking, and gives your eyes time to recover.',
          'For better comfort, keep your screen at a proper distance, reduce glare, adjust brightness, and avoid working too long without breaks.',
          'Reye is not a medical treatment, but it is a gentle reminder to protect your eye comfort during daily screen use.',
        ];

  String get reminderTitle =>
      isPersian ? 'وقت استراحت چشم است' : 'Time for an eye break';
  String get reminderBody => isPersian
      ? 'برای ۲۰ ثانیه به چیزی در دوردست نگاه کن. چشم‌هایت را آرام کن و هر وقت آماده بودی برگرد.'
      : 'Look at something far away for 20 seconds. Relax your eyes, then come back when you are ready.';
  String get reminderButton => isPersian
      ? 'برای ۲۰ ثانیه به دور نگاه کردم'
      : 'I looked away for 20 seconds';
  String get snoozeButton =>
      isPersian ? '۵ دقیقه یادآوری بعدی' : 'Snooze 5 minutes';
  String get notificationTitle => reminderTitle;
  String get notificationBody => isPersian
      ? 'برای ۲۰ ثانیه به چیزی در دوردست نگاه کن. یک مکث کوتاه کافی است.'
      : 'Look at something far away for 20 seconds. Your eyes will thank you.';
  String get countdownNotificationBody =>
      isPersian ? 'استراحت بعدی چشم' : 'Next eye break';
  String get breakShort => isPersian ? 'استراحت' : 'Break';
  String get notificationsOff => isPersian
      ? 'نوتیفیکیشن‌ها خاموش هستند. Reye همچنان می‌تواند وقتی برنامه باز است یادآوری کند.'
      : 'Notifications are off. Reye can still remind you while the app is open.';

  String get windowsBehaviorNote => isPersian
      ? 'شمارش شناور نزدیک پایان تایمر نمایش داده می‌شود.'
      : 'Floating countdown appears near the end.';
  String get androidBehaviorNote => isPersian
      ? 'وقتی برنامه در پس‌زمینه است، نوتیفیکیشن‌ها یادآوری می‌کنند.'
      : 'Notifications remind you when the app is in background.';
  String get unsupportedPlatformNote => isPersian
      ? 'این نسخه برای ویندوز و اندروید ساخته شده است.'
      : 'This build is intended for Windows and Android.';

  String get systemTheme => isPersian ? 'سیستم' : 'System';
  String get lightTheme => isPersian ? 'روشن' : 'Light';
  String get darkTheme => isPersian ? 'تاریک' : 'Dark';

  String nextBreakAt(String time) =>
      isPersian ? 'استراحت بعدی در $time' : 'Next break at $time';

  String minutes(int value) {
    final unit = isPersian
        ? 'دقیقه'
        : value == 1
        ? 'minute'
        : 'minutes';
    return '${number(value)} $unit';
  }

  String seconds(int value) {
    final unit = isPersian
        ? 'ثانیه'
        : value == 1
        ? 'second'
        : 'seconds';
    return '${number(value)} $unit';
  }

  String countdownDuration(int totalSeconds) {
    if (totalSeconds < 60) {
      return seconds(totalSeconds);
    }
    final wholeMinutes = totalSeconds ~/ 60;
    final remainingSeconds = totalSeconds.remainder(60);
    if (remainingSeconds == 0) {
      return minutes(wholeMinutes);
    }
    return '${minutes(wholeMinutes)} ${seconds(remainingSeconds)}';
  }

  String finalCountdownSubtitle(int value, int maxValue) {
    return isPersian
        ? '${countdownDuration(value)} - حداکثر ${countdownDuration(maxValue)}'
        : '${countdownDuration(value)} - max ${countdownDuration(maxValue)}';
  }

  String compactSeconds(int value) =>
      isPersian ? '${number(value.clamp(0, 999))}ث' : '${value.clamp(0, 999)}s';

  String number(num value) {
    return digits(value.toString());
  }

  String digits(String text) {
    if (!isPersian) {
      return text;
    }
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var result = text;
    for (var i = 0; i < western.length; i++) {
      result = result.replaceAll(western[i], eastern[i]);
    }
    return result;
  }

  String timerStatus(TimerStatus status) {
    switch (status) {
      case TimerStatus.idle:
        return isPersian ? 'آماده' : 'Ready';
      case TimerStatus.running:
        return isPersian ? 'زمان تمرکز' : 'Focus time';
      case TimerStatus.paused:
        return isPersian ? 'متوقف' : 'Paused';
      case TimerStatus.finalCountdown:
        return isPersian ? 'استراحت نزدیک است' : 'Break soon';
      case TimerStatus.breakDue:
        return isPersian ? 'زمان استراحت' : 'Break due';
      case TimerStatus.breakInProgress:
        return isPersian ? 'استراحت در جریان است' : 'Break in progress';
    }
  }

  String reminderDisplayModeLabel(ReminderDisplayMode mode) {
    switch (mode) {
      case ReminderDisplayMode.compactBanner:
        return isPersian ? 'بنر کوچک بالا' : 'Compact top banner';
      case ReminderDisplayMode.mediumCard:
        return isPersian ? 'کارت شناور متوسط' : 'Medium floating card';
      case ReminderDisplayMode.fullScreen:
        return isPersian ? 'یادآور تمام‌صفحه' : 'Full-screen reminder';
    }
  }

  String reminderSizeLabel(ReminderSize size) {
    switch (size) {
      case ReminderSize.small:
        return isPersian ? 'کوچک' : 'Small';
      case ReminderSize.medium:
        return isPersian ? 'متوسط' : 'Medium';
      case ReminderSize.large:
        return isPersian ? 'بزرگ' : 'Large';
    }
  }

  String desktopPositionLabel(DesktopPosition position) {
    switch (position) {
      case DesktopPosition.topLeft:
        return isPersian ? 'بالا چپ' : 'Top-left';
      case DesktopPosition.topRight:
        return isPersian ? 'بالا راست' : 'Top-right';
      case DesktopPosition.bottomLeft:
        return isPersian ? 'پایین چپ' : 'Bottom-left';
      case DesktopPosition.bottomRight:
        return isPersian ? 'پایین راست' : 'Bottom-right';
    }
  }

  String themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return systemTheme;
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
    }
  }

  String languageLabel(AppLanguage value) {
    switch (value) {
      case AppLanguage.english:
        return english;
      case AppLanguage.persian:
        return persian;
    }
  }

  NotificationCopy get notificationCopy => NotificationCopy(
    reminderTitle: notificationTitle,
    reminderBody: notificationBody,
    countdownTitle: appName,
    countdownBody: countdownNotificationBody,
  );
}

extension AppLanguageStrings on AppLanguage {
  AppStrings get strings => AppStrings.of(this);
}
