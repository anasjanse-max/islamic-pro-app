import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';

import 'home_screen.dart';
import 'quran_screen.dart';
import 'qibla_screen.dart';
import 'tasbeeh_screen.dart';
import 'live_tasbeeh_icon.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Theme Colors
  static const Color background = Color(0xFF000000);
  static const Color cardColor = Color(0xFF0A0F0C);
  static const Color green = Color(0xFF26E17A);
  static const Color greenDark = Color(0xFF0C3323);
  static const Color whiteText = Color(0xFFF4F6F5);
  static const Color greyText = Color(0xFF98A19D);
  static const Color borderColor = Color(0xFF1A221D);

  // States for toggles
  bool prayerNotifications = true;
  bool vibration = true;
  bool azanSound = true;
  bool isPlayingTestAzan = false;

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
          final curve =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
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

  // Helper Widget for Section Headers
  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 24),
      child: Row(
        children: [
          Icon(icon, color: green, size: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: whiteText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Toggle Settings Rows
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: activeColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: whiteText,
                      fontSize: 15,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: greyText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: activeColor,
            trackColor: const Color(0xFF2A302D),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // Helper Widget for Static Info Rows
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: whiteText,
                      fontSize: 15,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: greyText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 68,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF09140F).withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _navButton(
                icon: Icons.home_rounded,
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
              _navButton(
                customIcon: const LiveTasbeehIcon(
                  size: 23,
                  color: Color(0xFFB0BEC5), // Inactive state color
                  animate: false,
                ),
                label: 'Tasbih',
                active: false,
                action: () => _navigateToScreen(const TasbeehScreen()),
              ),
              _navButton(
                icon: Icons.settings_rounded,
                label: 'Settings',
                active: true, // Settings is active here
                action: () {},
              ),
            ],
          ),
        ),
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
    final iconColor = active ? green : const Color(0xFFB0BEC5);

    return Expanded(
      child: GestureDetector(
        onTap: action,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: active ? greenDark : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: active
                ? Border.all(
              color: green.withValues(alpha: 0.55),
              width: 1,
            )
                : null,
            boxShadow: active
                ? [
              BoxShadow(
                color: green.withValues(alpha: 0.2),
                blurRadius: 8,
              )
            ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: customIcon ??
                      Icon(
                        icon,
                        color: iconColor,
                        size: 22,
                      ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 9.5,
                  fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  // App Bar / Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _handleBack,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF101412),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: whiteText, size: 16),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Settings',
                              style: TextStyle(
                                color: whiteText,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40), // Balance for centering title
                      ],
                    ),
                  ),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 100), // Bottom padding for Nav Bar
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SECTION 1: Prayer Notifications
                          _buildSectionHeader(
                              Icons.notifications_active_rounded, 'Prayer Notifications'),
                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              children: [
                                _buildSwitchTile(
                                  title: 'Prayer Notifications',
                                  subtitle: prayerNotifications
                                      ? 'Prayer alerts are ON'
                                      : 'Prayer alerts are OFF',
                                  icon: Icons.notifications_active_rounded,
                                  activeColor: green,
                                  value: prayerNotifications,
                                  onChanged: (val) => setState(() => prayerNotifications = val),
                                ),
                                Divider(
                                    color: Colors.white.withOpacity(0.05),
                                    height: 1,
                                    indent: 70,
                                    endIndent: 16),
                                _buildSwitchTile(
                                  title: 'Vibration',
                                  subtitle: vibration
                                      ? 'Vibration is ON'
                                      : 'Vibration is OFF',
                                  icon: Icons.vibration_rounded,
                                  activeColor: const Color(0xFFF39C12), // Orange
                                  value: vibration,
                                  onChanged: (val) => setState(() => vibration = val),
                                ),
                                Divider(
                                    color: Colors.white.withOpacity(0.05),
                                    height: 1,
                                    indent: 70,
                                    endIndent: 16),
                                _buildSwitchTile(
                                  title: 'Azan Sound',
                                  subtitle: azanSound
                                      ? 'Azan sound is ON'
                                      : 'Azan sound is OFF',
                                  icon: Icons.volume_up_rounded,
                                  activeColor: const Color(0xFF3498DB), // Blue
                                  value: azanSound,
                                  onChanged: (val) => setState(() => azanSound = val),
                                ),
                              ],
                            ),
                          ),

                          // SECTION 2: Azan Test
                          _buildSectionHeader(Icons.volume_up_rounded, 'Azan Test'),
                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                            ),
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: green.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.volume_up_rounded,
                                            color: green, size: 22),
                                      ),
                                      const SizedBox(width: 14),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Test Azan',
                                              style: TextStyle(
                                                  color: whiteText,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Check your Azan notification sound',
                                              style: TextStyle(
                                                color: greyText,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Play Test Azan Button
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isPlayingTestAzan = !isPlayingTestAzan;
                                      });
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: green,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isPlayingTestAzan
                                                ? Icons.stop_rounded
                                                : Icons.play_arrow_rounded,
                                            color: Colors.black,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            isPlayingTestAzan
                                                ? 'Stop Test Azan'
                                                : 'Play Test Azan',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // SECTION 3: App Information
                          _buildSectionHeader(Icons.info_outline_rounded, 'App Information'),
                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              children: [
                                _buildInfoTile(
                                  title: 'Prayer Times',
                                  subtitle: 'Your daily prayer companion',
                                  icon: Icons.mosque_rounded,
                                  iconColor: const Color(0xFF1ABC9C), // Teal/Dark Green
                                ),
                                Divider(
                                    color: Colors.white.withOpacity(0.05),
                                    height: 1,
                                    indent: 70,
                                    endIndent: 16),
                                _buildInfoTile(
                                  title: 'Version',
                                  subtitle: '1.0.0',
                                  icon: Icons.verified_rounded,
                                  iconColor: const Color(0xFF3498DB), // Blue
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
  }
}