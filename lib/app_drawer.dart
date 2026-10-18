import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'asma_ul_husna_screen.dart';
import 'duas_screen.dart';
import 'favorites_screen.dart';
import 'hadith_screen.dart';
import 'hijri_converter_screen.dart';
import 'islamic_articles_screen.dart';
import 'islamic_calculator_screen.dart';
import 'islamic_calendar_screen.dart';
import 'more_screen.dart';
import 'nearby_mosques_screen.dart';
import 'notes_screen.dart';
import 'qibla_screen.dart';
import 'quran_screen.dart';
import 'settings_screen.dart';
import 'live_tasbeeh_icon.dart';
import 'tasbeeh_screen.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback? onClose;
  const AppDrawer({super.key, this.onClose});

  // ==========================================================
  // DYNAMIC PALETTE BASED ON DARK MODE STATE
  // ==========================================================
  static bool get _isDark => ThemeService.isDarkMode.value;

  static Color get appBackground => _isDark ? const Color(0xFF0B1511) : const Color(0xFFF7F6F1);

  // Fully Transparent Glass Surface taake background image clearly show ho
  static Color get glassSurface => _isDark ? const Color(0xFF14221C).withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.45);
  static Color get secondarySurface => _isDark ? const Color(0xFF192B23).withValues(alpha: 0.75) : const Color(0xFFE7F0EB).withValues(alpha: 0.60);

  static const Color primaryDeepEmerald = Color(0xFF164E3B);
  static const Color richEmerald = Color(0xFF1F6B52);
  static const Color softEmerald = Color(0xFF6FAF96);
  static const Color mutedGold = Color(0xFFB5964A);

  static Color get textPrimary => _isDark ? const Color(0xFFF4F6F2) : const Color(0xFF1D2924);
  static Color get textSecondary => _isDark ? const Color(0xFFAAB6AF) : const Color(0xFF4A5A53);
  static Color get textInactive => _isDark ? const Color(0xFF718079) : const Color(0xFF718079);
  static Color get borderSubtle => _isDark ? const Color(0xFF24332B) : const Color(0xFFC5D5CD);

  static Color get bgDark => appBackground;
  static Color get surface => glassSurface;
  static Color get elevatedSurface => secondarySurface;
  static const Color emerald = richEmerald;
  static const Color softMint = softEmerald;
  static Color get textLight => textPrimary;
  static Color get textMuted => textSecondary;

  void _navigateTo(BuildContext context, Widget screen) {
    if (onClose != null) onClose!();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curve,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _openPlayStoreRating(BuildContext context) async {
    if (onClose != null) onClose!();
    const String appPackageName = 'com.prayer.times.app';
    final Uri url = Uri.parse(
        'https://play.google.com/store/apps/details?id=$appPackageName');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showRateModal(context);
      }
    } catch (_) {
      _showRateModal(context);
    }
  }

  void _showRateModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _isDark ? const Color(0xFF14221C).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderSubtle, width: 1.0),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: secondarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, color: mutedGold, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'Enjoying Prayer Times?',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your 5-star rating supports future development and helps reach more Muslims worldwide.',
              style: TextStyle(color: textSecondary, fontSize: 13, height: 1.45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                    (index) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.star_rounded, color: mutedGold, size: 32),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Later',
                      style: TextStyle(color: textInactive, fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: richEmerald,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openPlayStoreRating(context);
                  },
                  child: const Text(
                    'Rate 5 Stars',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    if (onClose != null) onClose!();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _isDark ? const Color(0xFF14221C).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderSubtle),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: secondarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.mosque_rounded, color: richEmerald, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'About App',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prayer Times & Islamic Suite',
              style: TextStyle(
                color: mutedGold,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: secondarySurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderSubtle),
              ),
              child: const Text(
                'v1.0.0 • Stable Release',
                style: TextStyle(color: richEmerald, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'A complete Islamic companion providing accurate prayer notifications, Holy Quran with recitation, real-time Qibla compass, Tasbih counter, Daily Duas, Sahih Hadith, and essential Islamic utilities.',
              style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: richEmerald,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.isDarkMode,
      builder: (context, darkEnabled, child) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double menuWidth = screenWidth * 0.76;

        final List<_DrawerSectionData> sections = [
          _DrawerSectionData(
            title: 'Daily Worship',
            items: [
              _DrawerItemData(
                icon: Icons.menu_book_rounded,
                title: 'Quran Kareem',
                subtitle: 'Read & Listen',
                color: richEmerald,
                screen: const QuranScreen(),
              ),
              _DrawerItemData(
                icon: Icons.fingerprint_rounded,
                customIcon: const LiveTasbeehIcon(
                  size: 20,
                  color: richEmerald,
                  animate: true,
                ),
                title: 'Tasbih',
                subtitle: 'Digital Dhikr Counter',
                color: richEmerald,
                screen: const TasbeehScreen(),
              ),
              _DrawerItemData(
                icon: Icons.explore_rounded,
                title: 'Qibla Finder',
                subtitle: 'Accurate Compass',
                color: richEmerald,
                screen: const QiblaScreen(),
              ),
              _DrawerItemData(
                icon: Icons.calendar_month_rounded,
                title: 'Islamic Calendar',
                subtitle: 'Hijri Dates & Events',
                color: mutedGold,
                screen: const IslamicCalendarScreen(),
              ),
            ],
          ),
          _DrawerSectionData(
            title: 'Knowledge & Dhikr',
            items: [
              _DrawerItemData(
                icon: Icons.favorite_rounded,
                title: 'Daily Duas',
                subtitle: 'Morning & Evening Duas',
                color: richEmerald,
                screen: const DuasScreen(),
              ),
              _DrawerItemData(
                icon: Icons.auto_awesome_rounded,
                title: '99 Names',
                subtitle: 'Asma ul Husna',
                color: mutedGold,
                screen: const AsmaUlHusnaScreen(),
              ),
              _DrawerItemData(
                icon: Icons.auto_stories_rounded,
                title: 'Sahih Hadith',
                subtitle: 'Authentic Collections',
                color: richEmerald,
                screen: const HadithScreen(),
              ),
              _DrawerItemData(
                icon: Icons.article_rounded,
                title: 'Islamic Articles',
                subtitle: 'Read & Learn',
                color: richEmerald,
                screen: const IslamicArticlesScreen(),
              ),
            ],
          ),
          _DrawerSectionData(
            title: 'Utilities & Tools',
            items: [
              _DrawerItemData(
                icon: Icons.calculate_rounded,
                title: 'Islamic Calculator',
                subtitle: 'Zakat, Inheritance & More',
                color: richEmerald,
                screen: const IslamicCalculatorScreen(),
              ),
              _DrawerItemData(
                icon: Icons.mosque_rounded,
                title: 'Nearby Mosques',
                subtitle: 'Locate on Live Map',
                color: richEmerald,
                screen: const NearbyMosquesScreen(),
              ),
              _DrawerItemData(
                icon: Icons.bookmark_rounded,
                title: 'Saved Favorites',
                subtitle: 'Your Bookmarked Ayahs & Duas',
                color: richEmerald,
                screen: const FavoritesScreen(fromMore: false),
              ),
              _DrawerItemData(
                icon: Icons.edit_note_rounded,
                title: 'Islamic Notes',
                subtitle: 'Personal Islamic Journal',
                color: richEmerald,
                screen: const NotesScreen(fromMore: false),
              ),
              _DrawerItemData(
                icon: Icons.swap_horiz_rounded,
                title: 'Date Converter',
                subtitle: 'Hijri ↔ Gregorian',
                color: richEmerald,
                screen: const HijriConverterScreen(),
              ),
              _DrawerItemData(
                icon: Icons.grid_view_rounded,
                title: 'More Features',
                subtitle: 'Explore All Tools',
                color: mutedGold,
                screen: const MoreScreen(),
              ),
            ],
          ),
        ];

        int overallIndex = 0;

        return RepaintBoundary(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: Stack(
              children: [
                // 1. Background Image (Madina 42.jpg) - Ab ye Drawer ke peechhe bilkul saaf dikhegi
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/Madina 42.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: appBackground,
                    ),
                  ),
                ),

                // 2. Main Drawer Container with Frosted Glassmorphism Effect
                SizedBox(
                  width: menuWidth,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0), // Glass blur
                      child: Container(
                        decoration: BoxDecoration(
                          color: glassSurface, // Semi-transparent glass white/dark
                          border: Border(
                            right: BorderSide(
                              color: borderSubtle,
                              width: 1,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 20,
                              offset: const Offset(6, 0),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Executive Header
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: secondarySurface,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: borderSubtle),
                                      ),
                                      child: const Icon(Icons.mosque_rounded, color: richEmerald, size: 24),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Prayer Times',
                                            style: TextStyle(
                                              color: textPrimary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Islamic Suite',
                                            style: TextStyle(
                                              color: textSecondary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.info_outline_rounded,
                                        color: textSecondary,
                                        size: 22,
                                      ),
                                      splashRadius: 20,
                                      onPressed: () => _showAboutDialog(context),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                height: 1,
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                color: borderSubtle,
                              ),

                              // Scrollable Options List
                              Expanded(
                                child: ListView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
                                  children: [
                                    for (final section in sections) ...[
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                        child: Text(
                                          section.title.toUpperCase(),
                                          style: TextStyle(
                                            color: textPrimary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                      for (final item in section.items)
                                        _PremiumMenuItemTile(
                                          index: overallIndex++,
                                          icon: item.icon,
                                          customIcon: item.customIcon,
                                          title: item.title,
                                          subtitle: item.subtitle,
                                          color: item.color,
                                          onTap: () => _navigateTo(context, item.screen),
                                        ),
                                    ],

                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                                      child: Divider(color: borderSubtle, height: 1),
                                    ),

                                    _PremiumMenuItemTile(
                                      index: overallIndex++,
                                      icon: Icons.settings_rounded,
                                      title: 'Settings',
                                      subtitle: 'App Preferences',
                                      color: textSecondary,
                                      onTap: () => _navigateTo(context, const SettingsScreen()),
                                    ),

                                    _PremiumMenuItemTile(
                                      index: overallIndex++,
                                      icon: Icons.star_rounded,
                                      title: 'Rate App',
                                      subtitle: 'Support Us with 5 Stars',
                                      color: mutedGold,
                                      isHighlighted: true,
                                      onTap: () => _openPlayStoreRating(context),
                                    ),

                                    const SizedBox(height: 24),
                                    Center(
                                      child: Text(
                                        'v1.0.0 • Made with ❤️ for Ummah',
                                        style: TextStyle(
                                          color: textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DrawerSectionData {
  final String title;
  final List<_DrawerItemData> items;
  _DrawerSectionData({required this.title, required this.items});
}

class _DrawerItemData {
  final IconData icon;
  final Widget? customIcon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget screen;

  _DrawerItemData({
    required this.icon,
    this.customIcon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.screen,
  });
}

class _PremiumMenuItemTile extends StatefulWidget {
  final int index;
  final IconData icon;
  final Widget? customIcon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _PremiumMenuItemTile({
    required this.index,
    required this.icon,
    this.customIcon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  State<_PremiumMenuItemTile> createState() => _PremiumMenuItemTileState();
}

class _PremiumMenuItemTileState extends State<_PremiumMenuItemTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeService.isDarkMode.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _isPressed
                ? widget.color.withValues(alpha: 0.12)
                : widget.isHighlighted
                ? AppDrawer.secondarySurface
                : (isDark ? const Color(0xFF14221C).withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isPressed
                  ? widget.color.withValues(alpha: 0.3)
                  : widget.isHighlighted
                  ? widget.color.withValues(alpha: 0.3)
                  : AppDrawer.borderSubtle.withValues(alpha: 0.6),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppDrawer.secondarySurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppDrawer.borderSubtle),
                ),
                child: Center(
                  child: widget.customIcon ??
                      Icon(widget.icon, color: widget.color, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: AppDrawer.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: AppDrawer.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: _isPressed ? widget.color : AppDrawer.textSecondary.withValues(alpha: 0.7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}