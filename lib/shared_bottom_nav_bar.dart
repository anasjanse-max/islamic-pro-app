import 'package:flutter/material.dart';

enum NavScreen { home, quran, qibla, tasbeeh, settings }

class SharedBottomNavBar extends StatelessWidget {
  final NavScreen active;
  final Widget tasbeehIcon;
  final ValueChanged<NavScreen> onTap;

  const SharedBottomNavBar({
    super.key,
    required this.active,
    required this.tasbeehIcon,
    required this.onTap,
  });

  static const Color green = Color(0xFF00E676);
  static const Color greenDark = Color(0xFF0B2E1E);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color greyText = Color(0xFF90A4AE);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 76,
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF080D0A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Row(
          children: [
            _navButton(
              context,
              icon: Icons.home_rounded,
              label: 'Home',
              screen: NavScreen.home,
              isActive: active == NavScreen.home,
            ),
            _navButton(
              context,
              icon: Icons.menu_book_rounded,
              label: 'Quran',
              screen: NavScreen.quran,
              isActive: active == NavScreen.quran,
            ),
            _navButton(
              context,
              icon: Icons.explore_rounded,
              label: 'Qibla',
              screen: NavScreen.qibla,
              isActive: active == NavScreen.qibla,
            ),
            _navButton(
              context,
              label: 'Tasbih',
              screen: NavScreen.tasbeeh,
              isActive: active == NavScreen.tasbeeh,
              customIcon: tasbeehIcon,
            ),
            _navButton(
              context,
              icon: Icons.settings_rounded,
              label: 'Settings',
              screen: NavScreen.settings,
              isActive: active == NavScreen.settings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButton(
      BuildContext context, {
        IconData? icon,
        Widget? customIcon,
        required String label,
        required NavScreen screen,
        required bool isActive,
      }) {
    final Color iconColor = isActive ? green : const Color(0xFFB1B9B5);
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(screen),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive ? greenDark : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isActive ? Border.all(color: green.withOpacity(0.48)) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: customIcon ?? Icon(icon, color: iconColor, size: 23),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 9.5,
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}