import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'l10n/app_strings.dart';
import 'services/ir_platform_service.dart';
import 'splash_screen.dart';
import 'theme/app_colors.dart';

export 'theme/app_colors.dart';
export 'models/device_profile.dart';
export 'screens/main_screen.dart';

// ─────────────────────────────────────────────────────────────
// Entry Point
// ─────────────────────────────────────────────────────────────
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  // Load the saved language before the first frame so the splash and UI
  // open in the user's chosen language.
  try {
    final lang = await IrPlatformService().getLanguage();
    AppStrings.setLang(lang);
    MyApp.langNotifier.value = lang;
  } catch (_) {
    // Falls back to the default language on any channel error.
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final ValueNotifier<String> langNotifier = ValueNotifier('tr');

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    MyApp.langNotifier.addListener(_onLangChange);
  }

  @override
  void dispose() {
    MyApp.langNotifier.removeListener(_onLangChange);
    super.dispose();
  }

  void _onLangChange() {
    AppStrings.setLang(MyApp.langNotifier.value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AC Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        primaryColor: AppColors.accent,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.danger,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.card,
          contentTextStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
