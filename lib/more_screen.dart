import 'package:flutter/material.dart';
import 'dart:ui';

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
  static const Color background = Color(0xFF000000);
  static const Color cardBg = Color(0xFF0A0F0C);
  static const Color green = Color(0xFF26E17A);
  static const Color whiteText = Color(0xFFF4F6F5);
  static const Color greyText = Color(0xFF98A19D);
  static const Color borderColor = Color(0xFF1A221D);

  // Smooth custom navigation with fade & scale transition
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                height: 140,
                child: Opacity(
                  opacity: 0.2,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF0C3323), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  // App Bar / Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _handleBack,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: whiteText, size: 15),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'More Features',
                              style: TextStyle(
                                color: whiteText,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              'Explore more Islamic tools',
                              style: TextStyle(color: greyText, fontSize: 11.5),
                            ),
                          ],
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
                                  color: const Color(0xFFF39C12),
                                  onTap: _handleBack,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Quran',
                                  urduSub: 'تلاوت قرآن',
                                  icon: Icons.menu_book_rounded,
                                  color: const Color(0xFF26E17A),
                                  onTap: () => _navigateTo(const QuranScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Tasbih',
                                  urduSub: 'ڈیجیٹل تسبیح',
                                  icon: Icons.radio_button_checked_rounded,
                                  color: const Color(0xFF3498DB),
                                  onTap: () => _navigateTo(const TasbeehScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Qibla',
                                  urduSub: 'قبلہ رخ',
                                  icon: Icons.explore_rounded,
                                  color: const Color(0xFF9B59B6),
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
                                  color: const Color(0xFF26E17A),
                                  onTap: () => _navigateTo(const DuasScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Hadith',
                                  urduSub: 'صحیح احادیث',
                                  icon: Icons.menu_book_rounded,
                                  color: const Color(0xFFF39C12),
                                  onTap: () => _navigateTo(const HadithScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: '99 Names',
                                  urduSub: 'اسماء الحسنیٰ',
                                  icon: Icons.auto_awesome_rounded,
                                  color: const Color(0xFF3498DB),
                                  onTap: () => _navigateTo(const AsmaUlHusnaScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Articles',
                                  urduSub: 'اسلامی مضامین',
                                  icon: Icons.article_rounded,
                                  color: const Color(0xFF9B59B6),
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
                                  color: const Color(0xFFF39C12),
                                  onTap: () => _navigateTo(const IslamicCalendarScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Calculator',
                                  urduSub: 'زکوٰۃ کیلکولیٹر',
                                  icon: Icons.calculate_rounded,
                                  color: const Color(0xFF26E17A),
                                  onTap: () => _navigateTo(const IslamicCalculatorScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Converter',
                                  urduSub: 'ہجری تاریخ تبدیل',
                                  icon: Icons.sync_alt_rounded,
                                  color: const Color(0xFF3498DB),
                                  onTap: () => _navigateTo(const HijriConverterScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Mosques',
                                  urduSub: 'قریبی مساجد',
                                  icon: Icons.mosque_rounded,
                                  color: const Color(0xFF9B59B6),
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
                                  color: const Color(0xFF26E17A),
                                  onTap: () => _navigateTo(const FavoritesScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Notes',
                                  urduSub: 'میرے نوٹس',
                                  icon: Icons.edit_note_rounded,
                                  color: const Color(0xFFF39C12),
                                  onTap: () => _navigateTo(const NotesScreen()),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Reminders',
                                  urduSub: 'خاس یاد دہانی',
                                  icon: Icons.notifications_active_rounded,
                                  color: const Color(0xFF3498DB),
                                  onTap: () => _navigateTo(const SettingsScreen()), // Linked to settings or reminders if available
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFeatureCard(
                                  title: 'Settings',
                                  urduSub: 'ترتیبات',
                                  icon: Icons.settings_rounded,
                                  color: const Color(0xFF9B59B6),
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
            ],
          ),
        ),
      ),
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
                color: green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: whiteText,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        Text(
          badge,
          style: const TextStyle(
            color: green,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String urduSub,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 115,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.22),
              color.withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.35), width: 1.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: whiteText,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              urduSub,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
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