import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'favorites_service.dart';
import 'more_screen.dart'; // Navigates back to More screen smoothly

class IslamicCalendarScreen extends StatefulWidget {
  const IslamicCalendarScreen({super.key});

  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> {
  static const Color background = Color(0xFF000000);
  static const Color card = Color(0xFF0A0F0C);
  static const Color card2 = Color(0xFF101613);

  static const Color green = Color(0xFF26E17A);
  static const Color greenDark = Color(0xFF0C3323);
  static const Color gold = Color(0xFFE8B63D);

  static const Color whiteText = Color(0xFFF4F6F5);
  static const Color greyText = Color(0xFF98A19D);

  DateTime _selectedMonth = DateTime.now();
  final DateTime _today = DateTime.now();

  static const List<String> hijriMonthNames = [
    'Muharram',
    'Safar',
    'Rabi\' al-Awwal',
    'Rabi\' al-Thani',
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qi\'dah',
    'Dhu al-Hijjah'
  ];

  static const Map<String, String> islamicEvents = {
    '1-1': '🕌 Islamic New Year (1st Muharram)',
    '10-1': '🖤 Day of Ashura (10th Muharram)',
    '12-3': '💚 Mawlid al-Nabi (12th Rabi\' al-Awwal)',
    '27-7': '✨ Isra and Mi\'raj (27th Rajab)',
    '15-8': '🌕 Shab-e-Barat (15th Sha\'ban)',
    '1-9': '🌙 First Day of Ramadan',
    '27-9': '📖 Laylat al-Qadr (27th Ramadan)',
    '1-10': '🎉 Eid al-Fitr (1st Shawwal)',
    '9-12': '🕋 Day of Arafah (9th Dhu al-Hijjah)',
    '10-12': '🐑 Eid al-Adha (10th Dhu al-Hijjah)',
  };

  Map<String, dynamic> getHijriDetails(DateTime gDate) {
    final anchorGregorian = DateTime(2026, 9, 5);
    const anchorHDay = 22;
    const anchorHMonth = 3;
    const anchorHYear = 1448;

    int diffDays = gDate.difference(anchorGregorian).inDays;

    int currentHDay = anchorHDay + diffDays;
    int currentHMonth = anchorHMonth;
    int currentHYear = anchorHYear;

    while (currentHDay > 30 || currentHDay < 1) {
      if (currentHDay > 30) {
        int monthLength = (currentHMonth % 2 != 0) ? 30 : 29;
        if (currentHDay > monthLength) {
          currentHDay -= monthLength;
          currentHMonth++;
          if (currentHMonth > 12) {
            currentHMonth = 1;
            currentHYear++;
          }
        } else {
          break;
        }
      } else if (currentHDay < 1) {
        currentHMonth--;
        if (currentHMonth < 1) {
          currentHMonth = 12;
          currentHYear--;
        }
        int prevMonthLength = (currentHMonth % 2 != 0) ? 30 : 29;
        currentHDay += prevMonthLength;
      }
    }

    int validMonth = currentHMonth.clamp(1, 12);

    return {
      'day': currentHDay,
      'month': validMonth,
      'monthName': hijriMonthNames[validMonth - 1],
      'year': currentHYear,
    };
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
          _selectedMonth.year, _selectedMonth.month + offset, 1);
    });
  }

  void _handleBack() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, __, ___) => const MoreScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final midMonthDate = DateTime(_selectedMonth.year, _selectedMonth.month, 15);
    final currentHijri = getHijriDetails(midMonthDate);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Column(
            children: [
              _headerSection(currentHijri),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(), // Native smooth bounce
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Column(
                    children: [
                      _monthSelector(currentHijri),
                      const SizedBox(height: 14),
                      _weekDaysHeader(),
                      const SizedBox(height: 8),
                      _calendarGrid(),
                      const SizedBox(height: 20),
                      _upcomingEventsSection(currentHijri),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerSection(Map<String, dynamic> currentHijri) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: whiteText, size: 20),
          ),
          const SizedBox(width: 2),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold.withValues(alpha: 0.08),
              border: Border.all(color: gold.withValues(alpha: 0.6), width: 1.5),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: gold, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ISLAMIC CALENDAR',
                  style: TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${currentHijri['monthName']} ${currentHijri['year']} AH',
                  style: const TextStyle(
                    color: whiteText,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthSelector(Map<String, dynamic> currentHijri) {
    final gregMonthStr = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left_rounded, color: green, size: 28),
          ),
          Column(
            children: [
              Text(
                '${currentHijri['monthName']} ${currentHijri['year']}',
                style: const TextStyle(
                  color: green,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                gregMonthStr,
                style: const TextStyle(
                  color: greyText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right_rounded, color: green, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _weekDaysHeader() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: days
          .map(
            (day) => Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                color: day == 'Fri' ? gold : greyText,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  Widget _calendarGrid() {
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday % 7;

    final totalCells = daysInMonth + firstWeekday;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.85,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < firstWeekday) {
          return const SizedBox.shrink();
        }

        final dayNum = index - firstWeekday + 1;
        final currentDate = DateTime(_selectedMonth.year, _selectedMonth.month, dayNum);
        final hijri = getHijriDetails(currentDate);

        final isToday = currentDate.year == _today.year &&
            currentDate.month == _today.month &&
            currentDate.day == _today.day;

        final eventKey = '${hijri['day']}-${hijri['month']}';
        final hasEvent = islamicEvents.containsKey(eventKey);

        return Container(
          decoration: BoxDecoration(
            color: isToday ? greenDark : card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isToday
                  ? green
                  : (hasEvent ? gold : Colors.white.withValues(alpha: 0.08)),
              width: isToday || hasEvent ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$dayNum',
                style: TextStyle(
                  color: isToday ? green : whiteText,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${hijri['day']}',
                style: TextStyle(
                  color: hasEvent ? gold : greyText,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hasEvent) ...[
                const SizedBox(height: 2),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _upcomingEventsSection(Map<String, dynamic> currentHijri) {
    List<Widget> eventWidgets = [];

    islamicEvents.forEach((key, title) {
      final parts = key.split('-');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      if (month == currentHijri['month']) {
        final String id = 'event_${month}_$day';
        eventWidgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: card2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: gold.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: gold, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: whiteText,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '$day ${hijriMonthNames[month - 1]}',
                  style: const TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                FutureBuilder<bool>(
                  future: FavoritesService.isFavorite(id),
                  builder: (context, snapshot) {
                    final isFav = snapshot.data ?? false;
                    return IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? Colors.redAccent : greyText,
                        size: 18,
                      ),
                      onPressed: () async {
                        await FavoritesService.toggleFavorite(
                          id: id,
                          category: 'Calendar',
                          title: title,
                          content: 'Event Date: $day ${hijriMonthNames[month - 1]}',
                          subtitle: 'Islamic Event',
                        );
                        setState(() {});
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ISLAMIC EVENTS THIS MONTH',
          style: TextStyle(
            color: whiteText,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        if (eventWidgets.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'No major Islamic event recorded in this Hijri month.',
              textAlign: TextAlign.center,
              style: TextStyle(color: greyText, fontSize: 11.5),
            ),
          )
        else
          ...eventWidgets,
      ],
    );
  }
}