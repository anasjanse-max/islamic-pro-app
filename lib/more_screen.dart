import 'dart:ui';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'quran_screen.dart';
import 'qibla_screen.dart';
import 'tasbeeh_screen.dart';
import 'settings_screen.dart';

// Accurate file imports based on your project files
import 'duas_screen.dart';
import 'hadith_screen.dart';
import 'asma_ul_husna_screen.dart';
import 'islamic_articles_screen.dart';
import 'islamic_calendar_screen.dart';
import 'islamic_calculator_screen.dart';
import 'hijri_converter_screen.dart';
import 'nearby_mosques_screen.dart';
import 'favorites_screen.dart';
import 'notes_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
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
  Color get borderSubtle => _isDark ? const Color(0xFF24332B) : const Color(0xFFD5DFDA);

  // Smooth custom navigation with fade & scale transition (Preserved 100%)
  void _navigateTo(Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
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

  void _handleBack() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

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
              child: Column(
                children: [
                  // Header / App Bar (Deep Emerald Theme)
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
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'More Features',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Explore more Islamic tools',
                                style: TextStyle(color: Color(0xFFDCEAE4), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SECTION 1: Prayer & Quran
                          _buildSectionHeader('Prayer & Quran', 'Essential'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Prayer Tim...',
                                  urduSub: 'نماز کے اوقات',
                                  icon: Icons.access_time_rounded,
                                  accentColor: mutedGold,
                                  onTap: _handleBack,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Quran',
                                  urduSub: 'تلاوت قرآن',
                                  icon: Icons.menu_book_rounded,
                                  accentColor: richEmerald,
                                  onTap: () => _navigateTo(const QuranScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Tasbih',
                                  urduSub: 'ڈیجیٹل تسبیح',
                                  icon: Icons.radio_button_checked_rounded,
                                  accentColor: softEmerald,
                                  onTap: () => _navigateTo(const TasbeehScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Qibla',
                                  urduSub: 'قبلہ رخ',
                                  icon: Icons.explore_rounded,
                                  accentColor: richEmerald,
                                  onTap: () => _navigateTo(const QiblaScreen()),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // SECTION 2: Islamic Knowledge
                          _buildSectionHeader('Islamic Knowledge', 'Learn & Grow'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Duas',
                                  urduSub: 'روزانہ دعائیں',
                                  icon: Icons.favorite_rounded,
                                  accentColor: softEmerald,
                                  onTap: () => _navigateTo(const DuasScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Hadith',
                                  urduSub: 'صحیح احادیث',
                                  icon: Icons.menu_book_rounded,
                                  accentColor: mutedGold,
                                  onTap: () => _navigateTo(const HadithScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: '99 Names',
                                  urduSub: 'اسماء الحسنیٰ',
                                  icon: Icons.auto_awesome_rounded,
                                  accentColor: softEmerald,
                                  onTap: () => _navigateTo(const AsmaUlHusnaScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Articles',
                                  urduSub: 'اسلامی مضامین',
                                  icon: Icons.article_rounded,
                                  accentColor: richEmerald,
                                  onTap: () => _navigateTo(const IslamicArticlesScreen()),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // SECTION 3: Tools & Utilities
                          _buildSectionHeader('Tools & Utilities', 'Helpful Tools'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Calendar',
                                  urduSub: 'اسلامی تاریخ',
                                  icon: Icons.calendar_month_rounded,
                                  accentColor: mutedGold,
                                  onTap: () => _navigateTo(const IslamicCalendarScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Calculator',
                                  urduSub: 'زکوٰۃ کیلکولیٹر',
                                  icon: Icons.calculate_rounded,
                                  accentColor: softEmerald,
                                  onTap: () => _navigateTo(const IslamicCalculatorScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Converter',
                                  urduSub: 'ہجری تاریخ تبدیل',
                                  icon: Icons.sync_alt_rounded,
                                  accentColor: richEmerald,
                                  onTap: () => _navigateTo(const HijriConverterScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Mosques',
                                  urduSub: 'قریبی مساجد',
                                  icon: Icons.mosque_rounded,
                                  accentColor: softEmerald,
                                  onTap: () => _navigateTo(const NearbyMosquesScreen()),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // SECTION 4: Personal
                          _buildSectionHeader('Personal', 'Your Space'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Favorites',
                                  urduSub: 'محفوظ کردہ',
                                  icon: Icons.bookmark_rounded,
                                  accentColor: softEmerald,
                                  onTap: () => _navigateTo(const FavoritesScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Notes',
                                  urduSub: 'میرے نوٹس',
                                  icon: Icons.edit_note_rounded,
                                  accentColor: mutedGold,
                                  onTap: () => _navigateTo(const NotesScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Reminders',
                                  urduSub: 'خاس یاد دہانی',
                                  icon: Icons.notifications_active_rounded,
                                  accentColor: richEmerald,
                                  onTap: () => _navigateTo(const SettingsScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Settings',
                                  urduSub: 'ترتیبات',
                                  icon: Icons.settings_rounded,
                                  accentColor: softEmerald,
                                  onTap: () => _navigateTo(const SettingsScreen()),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String badge) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 3.5,
              height: 14,
              decoration: BoxDecoration(
                color: mutedGold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Text(
          badge,
          style: TextStyle(
            color: textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String urduSub,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 115,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(16),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: secondarySurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderSubtle),
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              urduSub,
              style: TextStyle(
                color: textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}