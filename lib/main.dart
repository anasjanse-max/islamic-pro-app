import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'home_screen.dart';
import 'notification_service.dart';
import 'settings_screen.dart'; // ThemeService ke liye import kiya

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // App start hone se pehle saved dark mode state load karein
  await ThemeService.init();

  // Force status bar icons to be white across the entire system UI layer
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // White icons for Android
      statusBarBrightness: Brightness.dark,       // White icons for iOS
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Google Mobile Ads SDK
  try {
    MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('AdMob initialization error: $e');
  }

  try {
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('Notification initialization error: $e');
  }

  runApp(const PrayerTimesApp());
}

class PrayerTimesApp extends StatelessWidget {
  const PrayerTimesApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder puri app ko dynamic tareeqe se Dark/Light mode mein badlega
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.isDarkMode,
      builder: (context, isDark, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Prayer Times',
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: isDark ? const Color(0xFF0B1511) : const Color(0xFFF7F6F1),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1F6B52),
                brightness: isDark ? Brightness.dark : Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
              ),
            ),
            home: const HomeScreen(),
          ),
        );
      },
    );
  }
}