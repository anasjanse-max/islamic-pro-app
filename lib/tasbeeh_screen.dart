import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_screen.dart';
import 'live_tasbeeh_icon.dart';
import 'qibla_screen.dart';
import 'quran_screen.dart';
import 'settings_screen.dart';

class TasbeehItem {
  final String arabic;
  final String title;
  final String meaning;
  final int target;

  const TasbeehItem({
    required this.arabic,
    required this.title,
    required this.meaning,
    required this.target,
  });
}

class _HistoryEntry {
  final String title, arabic;
  final int count, target;
  final DateTime time;

  const _HistoryEntry({
    required this.title,
    required this.arabic,
    required this.count,
    required this.target,
    required this.time,
  });
}

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  // ==========================================================
  // DYNAMIC PALETTE BASED ON DARK MODE STATE
  // ==========================================================
  bool get _isDark => ThemeService.isDarkMode.value;

  Color get appBackground => _isDark ? const Color(0xFF0B1511) : const Color(0xFFF7F6F1);
  Color get surfaceWhite => _isDark ? const Color(0xFF14221C) : const Color(0xFFFFFFFF);
  Color get secondarySurface => _isDark ? const Color(0xFF192B23) : const Color(0xFFE7F0EB);
  Color get selectedSurface => _isDark ? const Color(0xFF192B23) : const Color(0xFFE7F0EB);

  static const Color primaryDeepEmerald = Color(0xFF164E3B);
  static const Color richEmerald = Color(0xFF1F6B52);
  static const Color softEmerald = Color(0xFF6FAF96);
  static const Color mutedGold = Color(0xFFB5964A);

  Color get textPrimary => _isDark ? const Color(0xFFF4F6F2) : const Color(0xFF1D2924);
  Color get textSecondary => _isDark ? const Color(0xFFAAB6AF) : const Color(0xFF66736D);
  Color get textInactive => _isDark ? const Color(0xFF718079) : const Color(0xFF718079);
  Color get borderSubtle => _isDark ? const Color(0xFF24332B) : const Color(0xFFD5DFDA);

  // ==========================================================
  // DATA SOURCES (Preserved 100%)
  // ==========================================================
  static const dhikr = <TasbeehItem>[
    TasbeehItem(
      arabic: 'اللَّهُ أَكْبَرُ',
      title: 'Allahu Akbar',
      meaning: 'Allah is the Greatest.',
      target: 33,
    ),
    TasbeehItem(
      arabic: 'الْحَمْدُ لِلَّهِ',
      title: 'Alhamdulillah',
      meaning: 'All praise is due to Allah.',
      target: 33,
    ),
    TasbeehItem(
      arabic: 'سُبْحَانَ اللَّهِ',
      title: 'SubhanAllah',
      meaning: 'Glory be to Allah.',
      target: 33,
    ),
    TasbeehItem(
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      title: 'Astaghfirullah',
      meaning: 'I seek forgiveness from Allah.',
      target: 100,
    ),
    TasbeehItem(
      arabic: 'لَا إِلٰهَ إِلَّا اللَّهُ',
      title: 'La ilaha illallah',
      meaning: 'There is no god except Allah.',
      target: 100,
    ),
    TasbeehItem(
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      title: 'SubhanAllahi wa bihamdihi',
      meaning: 'Glory be to Allah and praise is for Him.',
      target: 100,
    ),
    TasbeehItem(
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      title: 'La hawla wa la quwwata',
      meaning: 'There is no power and no strength except through Allah.',
      target: 100,
    ),
    TasbeehItem(
      arabic: 'مَا شَاءَ اللَّهُ لَا قُوَّةَ إِلَّا بِاللَّهِ',
      title: 'MashaAllah',
      meaning: 'That which Allah wills. There is no power but Allah.',
      target: 33,
    ),
    TasbeehItem(
      arabic: 'لَا إِلٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      title: 'Dua of Yunus',
      meaning: 'There is no god but You. Glory be to You.',
      target: 100,
    ),
    TasbeehItem(
      arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      title: 'Protection Dua',
      meaning: 'I seek refuge in the Perfect Words of Allah.',
      target: 3,
    ),
    TasbeehItem(
      arabic: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      title: 'Istighfar & Tawbah',
      meaning: 'I ask Allah for forgiveness and repent to Him.',
      target: 100,
    ),
    TasbeehItem(
      arabic: 'لَا إِلٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      title: 'Tawheed Dhikr',
      meaning: 'Allah alone has the dominion and all praise.',
      target: 100,
    ),
    TasbeehItem(
      arabic: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ',
      title: 'Ya Hayyu Ya Qayyum',
      meaning: 'O Ever-Living, by Your mercy I seek help.',
      target: 33,
    ),
    TasbeehItem(
      arabic: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَىٰ نَبِيِّنَا مُحَمَّدٍ',
      title: 'Durood / Salawat',
      meaning: 'O Allah, send blessings and peace upon our Prophet Muhammad.',
      target: 100,
    ),
    TasbeehItem(
      arabic: 'حَسْبِيَ اللَّهُ لَا إِلٰهَ إِلَّا هُوَ',
      title: 'Hasbiyallahu',
      meaning: 'Allah is sufficient for me; upon Him I rely.',
      target: 7,
    ),
    TasbeehItem(
      arabic: 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلٰهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
      title: 'Four Great Dhikr',
      meaning: 'Glory, praise, worship and greatness belong to Allah.',
      target: 100,
    ),
  ];

  final customDhikr = <TasbeehItem>[];
  final history = <_HistoryEntry>[];

  // ==========================================================
  // STATE VARIABLES
  // ==========================================================
  int selected = 0;
  int count = 0;
  int target = 33;
  bool counterOnly = false;
  bool pressed = false;

  TasbeehItem get current => counterOnly
      ? const TasbeehItem(
    arabic: 'عداد',
    title: 'Counter Only',
    meaning: 'Simple counter.',
    target: 33,
  )
      : selected < dhikr.length
      ? dhikr[selected]
      : customDhikr[(selected - dhikr.length).clamp(0, customDhikr.length - 1)];

  double get progress => target == 0 ? 0 : (count / target).clamp(0.0, 1.0);

  // ==========================================================
  // LOGIC & ACTIONS (Preserved 100%)
  // ==========================================================
  void addCount() {
    if (count >= target) return;
    setState(() => count++);
    if (count == target) {
      history.insert(
        0,
        _HistoryEntry(
          title: current.title,
          arabic: current.arabic,
          count: count,
          target: target,
          time: DateTime.now(),
        ),
      );
      message('Target completed — Alhamdulillah 🤲');
    }
  }

  void reset() {
    if (count > 0) {
      history.insert(
        0,
        _HistoryEntry(
          title: current.title,
          arabic: current.arabic,
          count: count,
          target: target,
          time: DateTime.now(),
        ),
      );
    }
    setState(() => count = 0);
  }

  void selectDhikr(int i) {
    final item = i < dhikr.length ? dhikr[i] : customDhikr[i - dhikr.length];
    setState(() {
      counterOnly = false;
      selected = i;
      count = 0;
      target = item.target;
    });
  }

  void deleteCustomDhikr(int index) {
    final actualIndex = dhikr.length + index;
    setState(() {
      customDhikr.removeAt(index);
      if (selected == actualIndex) {
        selected = 0;
        count = 0;
        target = dhikr[0].target;
      } else if (selected > actualIndex) {
        selected--;
      }
    });
    message('Custom Dua deleted');
  }

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

  void createCustom() async {
    final result = await showDialog<TasbeehItem>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => const _CreateDhikrDialog(),
    );

    if (result == null || !mounted) return;

    setState(() {
      customDhikr.add(result);
      selected = dhikr.length + customDhikr.length - 1;
      counterOnly = false;
      count = 0;
      target = result.target;
    });

    message('${result.title} added');
  }

  void setTarget() async {
    final value = await showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => _CustomTargetDialog(currentTarget: target),
    );

    if (value != null && mounted) {
      setState(() {
        target = value;
        count = 0;
      });
    }
  }

  void message(String s) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Text(
            s,
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      );
  }

  // ==========================================================
  // MODAL BOTTOM SHEETS
  // ==========================================================
  void selector() => showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetCtx) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        return Container(
          height: MediaQuery.of(sheetCtx).size.height * .84,
          decoration: BoxDecoration(
            color: surfaceWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: borderSubtle)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textSecondary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Dhikr & Duas',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Choose a Dhikr or create your custom Dua',
                            style: TextStyle(color: textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    iconTopButton(Icons.add_rounded, () async {
                      createCustom();
                      setSheetState(() {});
                    }),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      selectCard(
                        'Counter Only',
                        'عداد',
                        'Simple counter — no Dhikr selected',
                        counterOnly,
                        Icons.touch_app_rounded,
                            () {
                          setState(() {
                            counterOnly = true;
                            count = 0;
                            target = 33;
                          });
                          Navigator.of(sheetCtx).pop();
                        },
                      ),
                      const SizedBox(height: 16),
                      if (customDhikr.isNotEmpty) ...[
                        sectionHeader(
                          'MY CUSTOM DUAS & DHIKR',
                          customDhikr.length,
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(customDhikr.length, (idx) {
                          final x = customDhikr[idx];
                          final sel = !counterOnly &&
                              selected == (dhikr.length + idx);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: selectCard(
                              x.title,
                              x.arabic,
                              '${x.meaning} • Target ${x.target}',
                              sel,
                              Icons.star_rounded,
                                  () {
                                selectDhikr(dhikr.length + idx);
                                Navigator.of(sheetCtx).pop();
                              },
                              isCustom: true,
                              onDelete: () {
                                setSheetState(() {
                                  deleteCustomDhikr(idx);
                                });
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                      sectionHeader('DEFAULT DHIKR & DUAS', dhikr.length),
                      const SizedBox(height: 8),
                      ...List.generate(dhikr.length, (idx) {
                        final x = dhikr[idx];
                        final sel = !counterOnly && selected == idx;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: selectCard(
                            x.title,
                            x.arabic,
                            '${x.meaning} • Target ${x.target}',
                            sel,
                            Icons.auto_awesome_rounded,
                                () {
                              selectDhikr(idx);
                              Navigator.of(sheetCtx).pop();
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  void historySheet() => showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetCtx) => Container(
      height: MediaQuery.of(sheetCtx).size.height * .78,
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: borderSubtle)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: textSecondary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Counter History',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Which Dhikr you counted and how many times',
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (history.isNotEmpty)
                  iconTopButton(Icons.delete_outline_rounded, () {
                    setState(history.clear);
                    Navigator.of(sheetCtx).pop();
                  }),
              ],
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? Center(
              child: Text(
                'No history yet',
                style: TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final h = history[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: secondarySurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: surfaceWhite,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderSubtle),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: richEmerald,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.arabic,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                color: mutedGold,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              h.title,
                              style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Count: ${h.count}  •  Target: ${h.target}',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );

  // ==========================================================
  // WIDGET BUILDERS
  // ==========================================================
  Widget header() => Container(
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
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Digital Tasbih',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Remember Allah, Find Peace',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFFDCEAE4),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        iconTopButton(Icons.auto_awesome_rounded, selector),
        const SizedBox(width: 8),
        iconTopButton(Icons.history_rounded, historySheet),
      ],
    ),
  );

  Widget currentCard() {
    return GestureDetector(
      onTap: selector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: secondarySurface,
                border: Border.all(color: mutedGold.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Text(
                  current.arabic,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: mutedGold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT DHIKR',
                    style: TextStyle(
                      color: richEmerald,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    current.title,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    current.meaning,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget ring() {
    final int totalBeads = target > 0 ? target : 33;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(220, 220),
            painter: _TasbeehBeadsPainter(
              count: count,
              totalBeads: totalBeads,
              activeColor: richEmerald,
              inactiveColor: borderSubtle,
            ),
          ),
          Container(
            width: 135,
            height: 135,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: surfaceWhite,
              border: Border.all(color: richEmerald, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: Text(
                    '$count',
                    key: ValueKey(count),
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: setTarget,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: secondarySurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderSubtle),
                    ),
                    child: Text(
                      '/ $target',
                      style: const TextStyle(
                        color: richEmerald,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget tapButton() {
    return GestureDetector(
      onTapDown: (_) {
        if (count < target) {
          setState(() => pressed = true);
        }
      },
      onTapUp: (_) {
        setState(() => pressed = false);
        addCount();
      },
      onTapCancel: () {
        setState(() => pressed = false);
      },
      child: AnimatedScale(
        scale: pressed ? .94 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: surfaceWhite,
            border: Border.all(color: richEmerald, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: richEmerald,
              ),
              child: const Icon(
                Icons.touch_app_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget tasbeehControls() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _colorfulControlButton(
            title: 'Reset',
            subtitle: 'To Zero',
            icon: Icons.restart_alt_rounded,
            color: mutedGold,
            onTap: reset,
          ),
          _colorfulControlButton(
            title: 'Minus',
            subtitle: 'Decrease',
            icon: Icons.remove_rounded,
            color: Colors.redAccent,
            onTap: () {
              if (count > 0) {
                setState(() => count--);
              }
            },
          ),
          _colorfulControlButton(
            title: 'Count',
            subtitle: 'Increase',
            icon: Icons.add_rounded,
            color: softEmerald,
            onTap: addCount,
          ),
          _colorfulControlButton(
            title: 'Target',
            subtitle: 'Custom',
            icon: Icons.star_outline_rounded,
            color: richEmerald,
            onTap: setTarget,
          ),
          _colorfulControlButton(
            title: 'History',
            subtitle: 'Records',
            icon: Icons.history_rounded,
            color: textSecondary,
            onTap: historySheet,
          ),
        ],
      ),
    );
  }

  Widget _colorfulControlButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 10),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: secondarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionHeader(String title, int itemCount) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: richEmerald,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: secondarySurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderSubtle),
          ),
          child: Text(
            '$itemCount',
            style: const TextStyle(
              color: richEmerald,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget selectCard(
      String title,
      String arabic,
      String sub,
      bool sel,
      IconData icon,
      VoidCallback tap, {
        bool isCustom = false,
        VoidCallback? onDelete,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: sel ? richEmerald : borderSubtle,
          width: sel ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: tap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: secondarySurface,
            shape: BoxShape.circle,
            border: Border.all(color: borderSubtle),
          ),
          child: Icon(icon, color: isCustom ? mutedGold : richEmerald, size: 20),
        ),
        title: Text(
          arabic,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            color: mutedGold,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textSecondary, fontSize: 11),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onDelete != null)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: onDelete,
              ),
            Icon(
              sel ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
              color: sel ? richEmerald : textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget iconTopButton(IconData icon, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: richEmerald,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

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
          _navButton(
            customIcon: const LiveTasbeehIcon(
              size: 20,
              color: richEmerald,
              animate: true,
            ),
            label: 'Tasbih',
            active: true,
            action: () {},
          ),
          _navButton(
            icon: Icons.settings_rounded,
            label: 'Settings',
            active: false,
            action: () => _navigateToScreen(const SettingsScreen()),
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
                      header(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 2, 16, 80),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              currentCard(),
                              ring(),
                              tapButton(),
                              Column(
                                children: [
                                  Text(
                                    'Tap to count',
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Keep your heart focused on Allah',
                                    style: TextStyle(color: textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                              tasbeehControls(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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

// ==========================================================
// CUSTOM PAINTER FOR BEADS MALA (TASBEEH)
// ==========================================================
class _TasbeehBeadsPainter extends CustomPainter {
  final int count;
  final int totalBeads;
  final Color activeColor;
  final Color inactiveColor;

  _TasbeehBeadsPainter({
    required this.count,
    required this.totalBeads,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;

    final linePaint = Paint()
      ..color = const Color(0xFFD5DFDA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, linePaint);

    for (int i = 0; i < totalBeads; i++) {
      final double angle = (i * 2 * math.pi / totalBeads) - (math.pi / 2);
      final Offset beadCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final bool isActive = i < count;

      final paint = Paint()
        ..color = isActive ? activeColor : inactiveColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(beadCenter, 5.0, paint);
    }

    final double topAngle = -math.pi / 2;
    final Offset leaderCenter = Offset(
      center.dx + (radius + 2) * math.cos(topAngle),
      center.dy + (radius + 2) * math.sin(topAngle),
    );

    final leaderPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: leaderCenter, width: 8, height: 14),
        const Radius.circular(3),
      ),
      leaderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TasbeehBeadsPainter oldDelegate) {
    return oldDelegate.count != count || oldDelegate.totalBeads != totalBeads;
  }
}

// ==========================================================
// CREATE DHIKR DIALOG
// ==========================================================
class _CreateDhikrDialog extends StatefulWidget {
  const _CreateDhikrDialog();

  @override
  State<_CreateDhikrDialog> createState() => _CreateDhikrDialogState();
}

class _CreateDhikrDialogState extends State<_CreateDhikrDialog> {
  late TextEditingController _nameController;
  late TextEditingController _arabicController;
  late TextEditingController _meaningController;
  late TextEditingController _targetController;

  bool get _isDark => ThemeService.isDarkMode.value;

  Color get surfaceWhite => _isDark ? const Color(0xFF14221C) : const Color(0xFFFFFFFF);
  Color get secondarySurface => _isDark ? const Color(0xFF192B23) : const Color(0xFFE7F0EB);
  static const Color richEmerald = Color(0xFF1F6B52);
  static const Color softEmerald = Color(0xFF6FAF96);
  Color get textPrimary => _isDark ? const Color(0xFFF4F6F2) : const Color(0xFF1D2924);
  Color get textSecondary => _isDark ? const Color(0xFFAAB6AF) : const Color(0xFF66736D);
  Color get borderSubtle => _isDark ? const Color(0xFF24332B) : const Color(0xFFD5DFDA);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _arabicController = TextEditingController();
    _meaningController = TextEditingController();
    _targetController = TextEditingController(text: '33');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _arabicController.dispose();
    _meaningController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    var arabic = _arabicController.text.trim();
    final meaning = _meaningController.text.trim();
    final target = int.tryParse(_targetController.text.trim()) ?? 33;

    if (name.isEmpty && arabic.isEmpty) return;
    if (arabic.isEmpty) arabic = name;

    final item = TasbeehItem(
      arabic: arabic,
      title: name.isNotEmpty ? name : arabic,
      meaning: meaning.isEmpty ? 'Custom Dhikr' : meaning,
      target: target > 0 ? target : 33,
    );

    Navigator.of(context).pop(item);
  }

  Widget _field(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool rtl = false,
        bool number = false,
      }) {
    return TextField(
      controller: controller,
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      inputFormatters: number
          ? [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(7),
      ]
          : null,
      style: TextStyle(color: textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: richEmerald, size: 20),
        filled: true,
        fillColor: secondarySurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: richEmerald),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: surfaceWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderSubtle),
      ),
      title: Text(
        'Create New Dhikr / Dua',
        style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_nameController, 'Dhikr / Dua Name', Icons.title_rounded),
            const SizedBox(height: 12),
            _field(
              _arabicController,
              'Arabic Text (Optional)',
              Icons.translate_rounded,
              rtl: true,
            ),
            const SizedBox(height: 12),
            _field(_meaningController, 'Meaning / Description',
                Icons.menu_book_rounded),
            const SizedBox(height: 12),
            _field(_targetController, 'Target Count', Icons.flag_rounded,
                number: true),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: borderSubtle),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _cancel,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: richEmerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _submit,
                    child: const Text(
                      'Create',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// CUSTOM TARGET DIALOG
// ==========================================================
class _CustomTargetDialog extends StatefulWidget {
  final int currentTarget;

  const _CustomTargetDialog({required this.currentTarget});

  @override
  State<_CustomTargetDialog> createState() => _CustomTargetDialogState();
}

class _CustomTargetDialogState extends State<_CustomTargetDialog> {
  late TextEditingController _controller;

  bool get _isDark => ThemeService.isDarkMode.value;

  Color get surfaceWhite => _isDark ? const Color(0xFF14221C) : const Color(0xFFFFFFFF);
  Color get secondarySurface => _isDark ? const Color(0xFF192B23) : const Color(0xFFE7F0EB);
  static const Color richEmerald = Color(0xFF1F6B52);
  static const Color softEmerald = Color(0xFF6FAF96);
  Color get textPrimary => _isDark ? const Color(0xFFF4F6F2) : const Color(0xFF1D2924);
  Color get textSecondary => _isDark ? const Color(0xFFAAB6AF) : const Color(0xFF66736D);
  Color get borderSubtle => _isDark ? const Color(0xFF24332B) : const Color(0xFFD5DFDA);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.currentTarget}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final v = int.tryParse(_controller.text.trim());
    if (v != null && v > 0) {
      Navigator.of(context).pop(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: surfaceWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderSubtle),
      ),
      title: Row(
        children: [
          const Icon(Icons.flag_rounded, color: richEmerald),
          const SizedBox(width: 8),
          Text(
            'Set Target Count',
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Presets:',
              style: TextStyle(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [33, 99, 100, 500, 1000].map((num) {
                final isSel = _controller.text == '$num';
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.text = '$num';
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSel ? richEmerald : secondarySurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSel ? richEmerald : borderSubtle,
                      ),
                    ),
                    child: Text(
                      '$num',
                      style: TextStyle(
                        color: isSel ? Colors.white : textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Or Type Custom Target:',
              style: TextStyle(
                color: textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    int curr = int.tryParse(_controller.text) ?? 33;
                    if (curr > 1) {
                      setState(() {
                        _controller.text = '${curr - 1}';
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.remove_circle_outline_rounded,
                    color: richEmerald,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(7),
                    ],
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: secondarySurface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: richEmerald),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    int curr = int.tryParse(_controller.text) ?? 33;
                    setState(() {
                      _controller.text = '${curr + 1}';
                    });
                  },
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: richEmerald,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
          child: Text('Cancel', style: TextStyle(color: textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: richEmerald,
            foregroundColor: Colors.white,
          ),
          onPressed: _submit,
          child: const Text(
            'Save Target',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}