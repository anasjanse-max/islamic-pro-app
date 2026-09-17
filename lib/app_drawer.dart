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

  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color greyText = Color(0xFFCFD8DC);
  static const Color green = Color(0xFF00E676);
  static const Color gold = Color(0xFFFFD700);

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
        backgroundColor: const Color(0xFF0E1612),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: gold.withOpacity(0.35), width: 1.2),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: gold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, color: gold, size: 36),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enjoying Prayer Times?',
              style: TextStyle(
                color: whiteText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your 5-star rating supports future development and helps reach more Muslims worldwide.',
              style: TextStyle(color: greyText, fontSize: 13, height: 1.45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                    (index) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(Icons.star_rounded, color: gold, size: 28),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Later',
                      style: TextStyle(color: greyText, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openPlayStoreRating(context);
                  },
                  child: const Text(
                    'Rate 5 Stars',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
        backgroundColor: const Color(0xFF0E1612),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF29B6F6).withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.mosque_rounded,
                  color: Color(0xFF29B6F6), size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'About App',
              style: TextStyle(
                color: whiteText,
                fontSize: 18,
                fontWeight: FontWeight.w800,
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
                color: gold,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              margin: const EdgeInsets.only(top: 4, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'v1.0.0 • Stable Release',
                style: TextStyle(color: greyText, fontSize: 11),
              ),
            ),
            const Text(
              'A complete Islamic companion providing accurate prayer notifications, Holy Quran with recitation, real-time Qibla compass, Tasbih counter, Daily Duas, Sahih Hadith, and essential Islamic utilities.',
              style: TextStyle(color: whiteText, fontSize: 12.5, height: 1.45),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double menuWidth = screenWidth * 0.74;

    // Structured into clean, intuitive sections
    final List<_DrawerSectionData> sections = [
      _DrawerSectionData(
        title: 'Daily Worship',
        items: [
          _DrawerItemData(
            icon: Icons.menu_book_rounded,
            title: 'Quran Kareem',
            subtitle: 'Read & Listen',
            color: const Color(0xFFFF9E1B),
            screen: const QuranScreen(),
          ),
          _DrawerItemData(
            icon: Icons.fingerprint_rounded,
            customIcon: const LiveTasbeehIcon(
              size: 21,
              color: Color(0xFF00E676),
              animate: true,
            ),
            title: 'Tasbih',
            subtitle: 'Digital Dhikr Counter',
            color: const Color(0xFF00E676),
            screen: const TasbeehScreen(),
          ),
          _DrawerItemData(
            icon: Icons.explore_rounded,
            title: 'Qibla Finder',
            subtitle: 'Accurate Compass',
            color: const Color(0xFF29B6F6),
            screen: const QiblaScreen(),
          ),
          _DrawerItemData(
            icon: Icons.calendar_month_rounded,
            title: 'Islamic Calendar',
            subtitle: 'Hijri Dates & Events',
            color: const Color(0xFFFFB300),
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
            color: const Color(0xFFFF4081),
            screen: const DuasScreen(),
          ),
          _DrawerItemData(
            icon: Icons.auto_awesome_rounded,
            title: '99 Names',
            subtitle: 'Asma ul Husna',
            color: const Color(0xFFFFD700),
            screen: const AsmaUlHusnaScreen(),
          ),
          _DrawerItemData(
            icon: Icons.auto_stories_rounded,
            title: 'Sahih Hadith',
            subtitle: 'Authentic Collections',
            color: const Color(0xFFFF7043),
            screen: const HadithScreen(),
          ),
          _DrawerItemData(
            icon: Icons.article_rounded,
            title: 'Islamic Articles',
            subtitle: 'Read & Learn',
            color: const Color(0xFF26A69A),
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
            color: const Color(0xFF00E5FF),
            screen: const IslamicCalculatorScreen(),
          ),
          _DrawerItemData(
            icon: Icons.mosque_rounded,
            title: 'Nearby Mosques',
            subtitle: 'Locate on Live Map',
            color: const Color(0xFF43A047),
            screen: const NearbyMosquesScreen(),
          ),
          _DrawerItemData(
            icon: Icons.bookmark_rounded,
            title: 'Saved Favorites',
            subtitle: 'Your Bookmarked Ayahs & Duas',
            color: const Color(0xFFFF5252),
            screen: const FavoritesScreen(fromMore: false),
          ),
          _DrawerItemData(
            icon: Icons.edit_note_rounded,
            title: 'Islamic Notes',
            subtitle: 'Personal Islamic Journal',
            color: const Color(0xFFFFCA28),
            screen: const NotesScreen(fromMore: false),
          ),
          _DrawerItemData(
            icon: Icons.swap_horiz_rounded,
            title: 'Date Converter',
            subtitle: 'Hijri ↔ Gregorian',
            color: const Color(0xFFAB47BC),
            screen: const HijriConverterScreen(),
          ),
          _DrawerItemData(
            icon: Icons.apps_rounded,
            title: 'More Features',
            subtitle: 'Explore All Tools',
            color: const Color(0xFF26E17A),
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
        color: const Color(0xFF060B08),
        child: Stack(
          children: [
            // 1. Background Image (Masjid Nabawi)
            Positioned.fill(
              child: Image.asset(
                'assets/images/Madina 42.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF0A0F0C),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mosque_rounded, color: gold, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Ensure image is assets/images/Madina 42.jpg',
                          style: TextStyle(color: greyText, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. High-Contrast Directional Overlay
            // Darkens the menu side for readability while preserving right side transparency
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: const [0.0, 0.65, 1.0],
                    colors: [
                      const Color(0xFF050A07).withOpacity(0.95),
                      const Color(0xFF09120D).withOpacity(0.82),
                      Colors.black.withOpacity(0.35),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Frosted Glass Drawer Container
            SizedBox(
              width: menuWidth,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Colors.white.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Executive Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        gold.withOpacity(0.3),
                                        green.withOpacity(0.12),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: gold.withOpacity(0.75),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: gold.withOpacity(0.35),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.mosque_rounded,
                                      color: gold, size: 22),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Prayer Times',
                                        style: TextStyle(
                                          color: whiteText,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.3,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black,
                                              blurRadius: 6,
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration: const BoxDecoration(
                                              color: green,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'ISLAMIC SUITE',
                                            style: TextStyle(
                                              color: gold.withOpacity(0.9),
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.white.withOpacity(0.55),
                                    size: 20,
                                  ),
                                  splashRadius: 18,
                                  onPressed: () => _showAboutDialog(context),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  gold.withOpacity(0.4),
                                  Colors.white.withOpacity(0.08),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          // Scrollable Options List
                          Expanded(
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
                              children: [
                                for (final section in sections) ...[
                                  // Category Section Header
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        14, 12, 14, 6),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 3,
                                          height: 11,
                                          decoration: BoxDecoration(
                                            color: gold,
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: gold.withOpacity(0.5),
                                                blurRadius: 4,
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 7),
                                        Text(
                                          section.title.toUpperCase(),
                                          style: TextStyle(
                                            color:
                                            Colors.white.withOpacity(0.65),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Section Items
                                  for (final item in section.items)
                                    _AnimatedMenuItemTile(
                                      index: overallIndex++,
                                      icon: item.icon,
                                      customIcon: item.customIcon,
                                      title: item.title,
                                      subtitle: item.subtitle,
                                      color: item.color,
                                      onTap: () =>
                                          _navigateTo(context, item.screen),
                                    ),
                                ],

                                // Bottom Actions Divider
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      14, 14, 14, 10),
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.12),
                                    height: 1,
                                  ),
                                ),

                                // Settings Tile
                                _AnimatedMenuItemTile(
                                  index: overallIndex++,
                                  icon: Icons.settings_rounded,
                                  title: 'Settings',
                                  subtitle: 'App Preferences & Notifications',
                                  color: const Color(0xFF90A4AE),
                                  onTap: () => _navigateTo(
                                      context, const SettingsScreen()),
                                ),

                                // Rate App Golden Tile
                                _AnimatedMenuItemTile(
                                  index: overallIndex++,
                                  icon: Icons.star_rounded,
                                  title: 'Rate App',
                                  subtitle: 'Support Us with 5 Stars',
                                  color: const Color(0xFFFFD700),
                                  isHighlighted: true,
                                  onTap: () => _openPlayStoreRating(context),
                                ),

                                const SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    'v1.0.0 • Made with ❤️ for Ummah',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.35),
                                      fontSize: 10,
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
  }
}

// ==========================================================
// DATA MODELS
// ==========================================================

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

// ==========================================================
// ULTRA-PREMIUM ANIMATED GLASS TILE
// ==========================================================

class _AnimatedMenuItemTile extends StatefulWidget {
  final int index;
  final IconData icon;
  final Widget? customIcon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _AnimatedMenuItemTile({
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
  State<_AnimatedMenuItemTile> createState() => _AnimatedMenuItemTileState();
}

class _AnimatedMenuItemTileState extends State<_AnimatedMenuItemTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(
          milliseconds: (180 + (widget.index * 22)).clamp(180, 420)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(-18 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isPressed ? 0.965 : 1.0,
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isPressed
                      ? [
                    widget.color.withOpacity(0.32),
                    widget.color.withOpacity(0.12),
                  ]
                      : widget.isHighlighted
                      ? [
                    widget.color.withOpacity(0.16),
                    Colors.white.withOpacity(0.03),
                  ]
                      : [
                    Colors.white.withOpacity(0.075),
                    Colors.white.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _isPressed
                      ? widget.color.withOpacity(0.85)
                      : widget.isHighlighted
                      ? widget.color.withOpacity(0.4)
                      : Colors.white.withOpacity(0.10),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                  if (_isPressed || widget.isHighlighted)
                    BoxShadow(
                      color: widget.color.withOpacity(widget.isHighlighted ? 0.15 : 0.32),
                      blurRadius: 12,
                      spreadRadius: 0.5,
                    ),
                ],
              ),
              child: Row(
                children: [
                  // High-End Glowing Squircle Icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color.withOpacity(0.28),
                          widget.color.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: widget.color.withOpacity(0.50),
                        width: 1.1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(0.30),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: widget.customIcon ??
                          Icon(widget.icon, color: widget.color, size: 20),
                    ),
                  ),
                  const SizedBox(width: 11),

                  // Title + Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.15,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              )
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.68),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Sleek Circular Arrow Pill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _isPressed
                          ? widget.color.withOpacity(0.22)
                          : Colors.white.withOpacity(0.06),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isPressed
                            ? widget.color.withOpacity(0.6)
                            : Colors.white.withOpacity(0.08),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: _isPressed
                          ? widget.color
                          : Colors.white.withOpacity(0.55),
                      size: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}