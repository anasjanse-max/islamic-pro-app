import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'live_tasbeeh_icon.dart';
import 'qibla_screen.dart';
import 'quran_screen.dart';
import 'tasbeeh_screen.dart';

class ThemeService {
  // Global notifier to control Dark Mode across the entire app
  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('app_dark_mode') ?? false;
  }

  static Future<void> toggleDarkMode(bool value) async {
    isDarkMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_dark_mode', value);
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ==========================================================
  // DYNAMIC PALETTE BASED ON DARK MODE STATE
  // ==========================================================
  bool get _isDark => ThemeService.isDarkMode.value;

  Color get appBackground => _isDark ? const Color(0xFF0B1511) : const Color(0xFFF7F6F1);
  Color get surfaceWhite => _isDark ? const Color(0xFF14221C) : const Color(0xFFFFFFFF);
  Color get secondarySurface => _isDark ? const Color(0xFF192B23) : const Color(0xFFE7F0EB);

  static const Color primaryDeepEmerald = Color(0xFF164E3B);
  static const Color richEmerald = Color(0xFF1F6B52);
  static const Color softEmerald = Color(0xFF6FAF96);
  static const Color mutedGold = Color(0xFFB5964A);

  Color get textPrimary => _isDark ? const Color(0xFFF4F6F2) : const Color(0xFF1D2924);
  Color get textSecondary => _isDark ? const Color(0xFFAAB6AF) : const Color(0xFF66736D);
  Color get textInactive => _isDark ? const Color(0xFF718079) : const Color(0xFF718079);
  Color get borderSubtle => _isDark ? const Color(0xFF24332B) : const Color(0xFFD5DFDA);

  // ==========================================================
  // STATE VARIABLES
  // ==========================================================
  bool prayerNotifications = true;
  bool vibration = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prayerNotifications = prefs.getBool('prayer_notifications') ?? true;
      vibration = prefs.getBool('vibration_enabled') ?? true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // ==========================================================
  // NAVIGATION & UI HELPERS
  // ==========================================================
  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _navigateToScreen(Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 160),
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (_, animation, _, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curve,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.985, end: 1.0).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // CUSTOM WIDGET BUILDERS
  // ==========================================================
  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 20),
      child: Row(
        children: [
          Icon(icon, color: richEmerald, size: 18),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color activeColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: secondarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: borderSubtle),
            ),
            child: Icon(icon, color: activeColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: richEmerald,
            trackColor: secondarySurface,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: secondarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: borderSubtle),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FLOATING FROSTED DOCK NAVIGATION BAR
  // ==========================================================
  Widget _buildBottomNavigation() {
    return Container(
      height: 66,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _navButton(
            icon: Icons.home_filled,
            label: 'Home',
            active: false,
            action: () => _navigateToScreen(const HomeScreen()),
          ),
          _navButton(
            icon: Icons.menu_book_rounded,
            label: 'Quran',
            active: false,
            action: () => _navigateToScreen(const QuranScreen()),
          ),
          _navButton(
            icon: Icons.explore_rounded,
            label: 'Qibla',
            active: false,
            action: () => _navigateToScreen(const QiblaScreen()),
          ),
          // Tasbih icon ab yahan bhi colorful aur animated kar diya gaya hai
          _navButton(
            customIcon: const LiveTasbeehIcon(
              size: 20,
              color: richEmerald, // Yahan color ko vibrant richEmerald kar diya hai
              animate: true,
            ),
            label: 'Tasbih',
            active: false,
            action: () => _navigateToScreen(const TasbeehScreen()),
          ),
          _navButton(
            icon: Icons.settings_rounded,
            label: 'Settings',
            active: true,
            action: () {},
          ),
        ],
      ),
    );
  }

  Widget _navButton({
    IconData? icon,
    Widget? customIcon,
    required String label,
    required bool active,
    required VoidCallback action,
  }) {
    final iconColor = active ? richEmerald : textInactive;
    final textColor = active ? richEmerald : textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: action,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: active ? secondarySurface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Center(
                  child: customIcon ??
                      Icon(
                        icon,
                        color: iconColor,
                        size: 20,
                      ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // MAIN BUILD METHOD
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.isDarkMode,
      builder: (context, darkEnabled, child) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _handleBack();
          },
          child: Scaffold(
            backgroundColor: appBackground,
            body: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Column(
                    children: [
                      // App Bar / Header
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryDeepEmerald,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _handleBack,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: richEmerald,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'Settings',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),

                      // Scrollable Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SECTION 0: Appearance / Dark Mode
                              _buildSectionHeader(
                                Icons.palette_rounded,
                                'Appearance',
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: surfaceWhite,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: borderSubtle),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: _buildSwitchTile(
                                  title: 'Dark Mode',
                                  subtitle: darkEnabled ? 'Dark theme is active' : 'Light theme is active',
                                  icon: darkEnabled ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                  activeColor: mutedGold,
                                  value: darkEnabled,
                                  onChanged: (val) {
                                    ThemeService.toggleDarkMode(val);
                                    setState(() {});
                                  },
                                ),
                              ),

                              // SECTION 1: Prayer Notifications
                              _buildSectionHeader(
                                Icons.notifications_active_rounded,
                                'Prayer Notifications',
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: surfaceWhite,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: borderSubtle),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _buildSwitchTile(
                                      title: 'Prayer Notifications',
                                      subtitle: prayerNotifications
                                          ? 'Prayer alerts are ON'
                                          : 'Prayer alerts are OFF',
                                      icon: Icons.notifications_active_rounded,
                                      activeColor: richEmerald,
                                      value: prayerNotifications,
                                      onChanged: (val) {
                                        setState(() => prayerNotifications = val);
                                        _savePreference('prayer_notifications', val);
                                      },
                                    ),
                                    Divider(
                                      color: borderSubtle,
                                      height: 1,
                                      indent: 70,
                                      endIndent: 16,
                                    ),
                                    _buildSwitchTile(
                                      title: 'Vibration',
                                      subtitle: vibration
                                          ? 'Vibration is ON'
                                          : 'Vibration is OFF',
                                      icon: Icons.vibration_rounded,
                                      activeColor: mutedGold,
                                      value: vibration,
                                      onChanged: (val) {
                                        setState(() => vibration = val);
                                        _savePreference('vibration_enabled', val);
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // SECTION 2: App Information
                              _buildSectionHeader(
                                Icons.info_outline_rounded,
                                'App Information',
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: surfaceWhite,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: borderSubtle),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _buildInfoTile(
                                      title: 'Prayer Times',
                                      subtitle: 'Your daily prayer companion',
                                      icon: Icons.mosque_rounded,
                                      iconColor: richEmerald,
                                    ),
                                    Divider(
                                      color: borderSubtle,
                                      height: 1,
                                      indent: 70,
                                      endIndent: 16,
                                    ),
                                    _buildInfoTile(
                                      title: 'Version',
                                      subtitle: '1.0.0',
                                      icon: Icons.verified_rounded,
                                      iconColor: mutedGold,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Floating Bottom Nav
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildBottomNavigation(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}