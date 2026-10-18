import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// PRAYER TIMES APP — Shared Theme Constants
// ─────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF040806);
  static const Color card       = Color(0xFF0D1612);
  static const Color card2      = Color(0xFF121E18);

  // Brand Colors
  static const Color green      = Color(0xFF00E676);
  static const Color greenDark  = Color(0xFF0B2E1E);

  // Gold
  static const Color gold       = Color(0xFFFFD700);
  static const Color goldAccent = Color(0xFFE5B53B);

  // Text
  static const Color whiteText  = Color(0xFFFFFFFF);
  static const Color greyText   = Color(0xFF90A4AE);
  static const Color textMuted  = Color(0xFFB0BEC5);
}

// ─────────────────────────────────────────────────────────────
// NAVIGATION SCREEN ENUM
// ─────────────────────────────────────────────────────────────

enum NavScreen { home, quran, qibla, tasbeeh, settings }

// ─────────────────────────────────────────────────────────────
// SHARED PROFESSIONAL BOTTOM NAVIGATION BAR
// ─────────────────────────────────────────────────────────────

class SharedBottomNavBar extends StatelessWidget {
  final NavScreen active;
  final void Function(NavScreen screen) onTap;

  /// Optional: Pass LiveTasbeehIcon widget for the Tasbih tab icon.
  final Widget? tasbeehIcon;

  const SharedBottomNavBar({
    super.key,
    required this.active,
    required this.onTap,
    this.tasbeehIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF09140F),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _navItem(icon: Icons.home_rounded,       label: 'Home',     screen: NavScreen.home),
          _navItem(icon: Icons.menu_book_rounded,  label: 'Quran',    screen: NavScreen.quran),
          _navItem(icon: Icons.explore_rounded,    label: 'Qibla',    screen: NavScreen.qibla),
          _navItem(
            icon: Icons.grain_rounded,
            label: 'Tasbih',
            screen: NavScreen.tasbeeh,
            customIconWidget: tasbeehIcon,
          ),
          _navItem(icon: Icons.settings_rounded,   label: 'Settings', screen: NavScreen.settings),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required NavScreen screen,
    Widget? customIconWidget,
  }) {
    final bool isActive = active == screen;
    final Color iconColor = isActive ? AppColors.green : AppColors.textMuted;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(screen),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.greenDark.withValues(alpha: 0.85)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isActive
                ? Border.all(
                    color: AppColors.green.withValues(alpha: 0.50),
                    width: 1,
                  )
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.20),
                      blurRadius: 10,
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
                  child: customIconWidget ??
                      Icon(icon, color: iconColor, size: 22),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 9.5,
                  fontWeight:
                      isActive ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
