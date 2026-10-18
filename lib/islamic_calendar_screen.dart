import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'more_screen.dart';
import 'settings_screen.dart';

class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});

  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> {
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

  // Navigation variables for Hijri Month & Year
  int _currentHMonth = 4; // Start with Rabi' al-Thani 1448
  int _currentHYear = 1448;

  static const List<String> hijriMonthNames = [
    'Muharram al-Haram',
    'Safar al-Muzaffar',
    'Rabi\' al-Awwal',
    'Rabi\' al-Thani',
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab al-Murajjab',
    'Sha\'ban al-Muazzam',
    'Ramadan al-Mubarak',
    'Shawwal al-Mukarram',
    'Dhu al-Qi\'dah',
    'Dhu al-Hijjah'
  ];

  final DateTime anchorGregorian = DateTime(2026, 9, 30);
  final int anchorHDay = 17;
  final int anchorHMonth = 4;
  final int anchorHYear = 1448;

  // Function to convert Hijri date to Gregorian Date for exact grid alignment
  DateTime _getGregorianDateForHijri(int hDay, int hMonth, int hYear) {
    int totalDaysOffset = (hYear - anchorHYear) * 354 +
        ((hMonth - anchorHMonth) * 29.5).round() +
        (hDay - anchorHDay);
    return anchorGregorian.add(Duration(days: totalDaysOffset));
  }

  // Professional Islamic Events mapped for specific Hijri months
  List<String> _getBlessedOccasionsForCurrentMonth() {
    List<String> occasions = [];
    if (_currentHMonth == 9 && _currentHYear == 1448) {
      occasions.add('🌙 1st Ramadan al-Mubarak (Expected Moonlight Sighting)');
    } else if (_currentHMonth == 10 && _currentHYear == 1448) {
      occasions.add('🎉 Eid-ul-Fitr (1st Shawwal al-Mukarram)');
    } else if (_currentHMonth == 12 && _currentHYear == 1448) {
      occasions.add('🕋 Eid-ul-Adha & Ayyam-ut-Tashreeq (10th Dhu al-Hijjah)');
    } else if (_currentHMonth == 1 && _currentHYear == 1449) {
      occasions.add('⭐ Youm-e-Ashura (10th Muharram al-Haram)');
    } else if (_currentHMonth == 3 && _currentHYear == 1448) {
      occasions.add('✨ 12 Rabi\' al-Awwal: Jashn-e-Eid Milad-un-Nabi (PBUH)');
    }
    return occasions;
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 180),
          pageBuilder: (_, __, ___) => const MoreScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    }
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
                  _headerSection(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildMonthlyCalendarView(),
                          const SizedBox(height: 16),
                          _buildIslamicEventsCard(),
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

  Widget _headerSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _handleBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: richEmerald,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: richEmerald),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: secondarySurface,
              border: Border.all(color: borderSubtle),
            ),
            child: const Icon(Icons.mosque_rounded, color: richEmerald, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ISLAMIC CALENDAR',
                  style: TextStyle(
                    color: richEmerald,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hijri Monthly View',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
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
  // PROFESSIONAL ISLAMIC HIJRI MONTHLY CALENDAR GRID
  // ==========================================================
  Widget _buildMonthlyCalendarView() {
    // Determine month length (alternate 30 and 29 days)
    final int daysInHijriMonth = (_currentHMonth % 2 != 0) ? 30 : 29;

    // Get starting weekday based on the 1st of this Hijri month's Gregorian equivalent
    final DateTime firstDayGregorian = _getGregorianDateForHijri(1, _currentHMonth, _currentHYear);
    int startingWeekday = firstDayGregorian.weekday % 7;

    // Corresponding Gregorian Month/Year text for header subtitle
    final DateTime midMonthGregorian = _getGregorianDateForHijri(15, _currentHMonth, _currentHYear);
    final String gregorianSubtitle = DateFormat('MMMM yyyy').format(midMonthGregorian);
    final String islamicHeaderTitle = '${hijriMonthNames[_currentHMonth - 1]} $_currentHYear AH';

    List<Widget> dayWidgets = [];

    const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    for (var day in weekDays) {
      dayWidgets.add(
        Center(
          child: Text(
            day,
            style: TextStyle(color: richEmerald, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }

    for (int hDay = 1; hDay <= daysInHijriMonth; hDay++) {
      final DateTime correspondingGregorian = _getGregorianDateForHijri(hDay, _currentHMonth, _currentHYear);
      final bool isToday = correspondingGregorian.year == DateTime.now().year &&
          correspondingGregorian.month == DateTime.now().month &&
          correspondingGregorian.day == DateTime.now().day;

      dayWidgets.add(
        Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isToday ? richEmerald : secondarySurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isToday ? richEmerald : borderSubtle),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$hDay', // Main prominent number is now Hijri Date (Starts from 1!)
                style: TextStyle(
                  color: isToday ? Colors.white : textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${correspondingGregorian.day} ${DateFormat('MMM').format(correspondingGregorian)}', // Subordinate Gregorian date
                style: TextStyle(
                  color: isToday ? Colors.white70 : mutedGold,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Hijri Month Navigation Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: richEmerald),
                onPressed: () {
                  setState(() {
                    _currentHMonth--;
                    if (_currentHMonth < 1) {
                      _currentHMonth = 12;
                      _currentHYear--;
                    }
                  });
                },
              ),
              Column(
                children: [
                  Text(
                    islamicHeaderTitle,
                    style: TextStyle(
                      color: primaryDeepEmerald,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    gregorianSubtitle,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: richEmerald),
                onPressed: () {
                  setState(() {
                    _currentHMonth++;
                    if (_currentHMonth > 12) {
                      _currentHMonth = 1;
                      _currentHYear++;
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.85,
            children: dayWidgets,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BLESSED OCCASIONS CARD
  // ==========================================================
  Widget _buildIslamicEventsCard() {
    final occasions = _getBlessedOccasionsForCurrentMonth();

    if (occasions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: secondarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: richEmerald, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Blessed Occasions This Month',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: borderSubtle, height: 1),
          const SizedBox(height: 12),
          ...occasions.map((occasion) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              occasion,
              style: TextStyle(
                color: primaryDeepEmerald,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          )),
        ],
      ),
    );
  }
}