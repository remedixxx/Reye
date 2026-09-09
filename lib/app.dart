import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_navigator.dart';
import 'core/theme/app_theme.dart';
import 'features/timer/application/settings_controller.dart';
import 'features/timer/application/timer_controller.dart';
import 'features/timer/presentation/home_screen.dart';
import 'l10n/app_strings.dart';

class ReyeApp extends ConsumerStatefulWidget {
  const ReyeApp({super.key});

  @override
  ConsumerState<ReyeApp> createState() => _ReyeAppState();
}

class _ReyeAppState extends ConsumerState<ReyeApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final timer = ref.read(timerControllerProvider.notifier);
    switch (state) {
      case AppLifecycleState.resumed:
        timer.onAppResumed();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        timer.onAppBackgrounded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final strings = settings.language.strings;

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: strings.appName,
      debugShowCheckedModeBanner: false,
      locale: strings.locale,
      supportedLocales: const [Locale('en'), Locale('fa')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: strings.textDirection,
          child: child ?? const SizedBox.shrink(),
        );
      },
      themeMode: settings.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
