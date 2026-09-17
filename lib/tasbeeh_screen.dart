import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;

import 'home_screen.dart';
import 'qibla_screen.dart';
import 'quran_screen.dart';
import 'settings_screen.dart';
import 'live_tasbeeh_icon.dart';

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
  static const Color background = Color(0xFF000000);
  static const Color card = Color(0xFF0A0F0C);
  static const Color card2 = Color(0xFF101613);

  static const Color green = Color(0xFF26E17A);
  static const Color greenDark = Color(0xFF0C3323);

  static const Color gold = Color(0xFFE8B63D);

  static const Color whiteText = Color(0xFFF4F6F5);
  static const Color greyText = Color(0xFF98A19D);

  static const dhikr = <TasbeehItem>[
    TasbeehItem(
        arabic: 'اللَّهُ أَكْبَرُ',
        title: 'Allahu Akbar',
        meaning: 'Allah is the Greatest.',
        target: 33),
    TasbeehItem(
        arabic: 'الْحَمْدُ لِلَّهِ',
        title: 'Alhamdulillah',
        meaning: 'All praise is due to Allah.',
        target: 33),
    TasbeehItem(
        arabic: 'سُبْحَانَ اللَّهِ',
        title: 'SubhanAllah',
        meaning: 'Glory be to Allah.',
        target: 33),
    TasbeehItem(
        arabic: 'أَسْتَغْفِرُ اللَّهَ',
        title: 'Astaghfirullah',
        meaning: 'I seek forgiveness from Allah.',
        target: 100),
    TasbeehItem(
        arabic: 'لَا إِلٰهَ إِلَّا اللَّهُ',
        title: 'La ilaha illallah',
        meaning: 'There is no god except Allah.',
        target: 100),
    TasbeehItem(
        arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        title: 'SubhanAllahi wa bihamdihi',
        meaning: 'Glory be to Allah and praise is for Him.',
        target: 100),
    TasbeehItem(
        arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
        title: 'La hawla wa la quwwata',
        meaning: 'There is no power and no strength except through Allah.',
        target: 100),
    TasbeehItem(
        arabic: 'مَا شَاءَ اللَّهُ لَا قُوَّةَ إِلَّا بِاللَّهِ',
        title: 'MashaAllah',
        meaning: 'That which Allah wills. There is no power but Allah.',
        target: 33),
    TasbeehItem(
        arabic: 'لَا إِلٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
        title: 'Dua of Yunus',
        meaning: 'There is no god but You. Glory be to You.',
        target: 100),
    TasbeehItem(
        arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
        title: 'Protection Dua',
        meaning: 'I seek refuge in the Perfect Words of Allah.',
        target: 3),
    TasbeehItem(
        arabic: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
        title: 'Istighfar & Tawbah',
        meaning: 'I ask Allah for forgiveness and repent to Him.',
        target: 100),
    TasbeehItem(
        arabic: 'لَا إِلٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
        title: 'Tawheed Dhikr',
        meaning: 'Allah alone has the dominion and all praise.',
        target: 100),
    TasbeehItem(
        arabic: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ',
        title: 'Ya Hayyu Ya Qayyum',
        meaning: 'O Ever-Living, by Your mercy I seek help.',
        target: 33),
    TasbeehItem(
        arabic: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَىٰ نَبِيِّنَا مُحَمَّدٍ',
        title: 'Durood / Salawat',
        meaning: 'O Allah, send blessings and peace upon our Prophet Muhammad.',
        target: 100),
    TasbeehItem(
        arabic: 'حَسْبِيَ اللَّهُ لَا إِلٰهَ إِلَّا هُوَ',
        title: 'Hasbiyallahu',
        meaning: 'Allah is sufficient for me; upon Him I rely.',
        target: 7),
    TasbeehItem(
        arabic:
        'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلٰهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
        title: 'Four Great Dhikr',
        meaning: 'Glory, praise, worship and greatness belong to Allah.',
        target: 100),
  ];

  final customDhikr = <TasbeehItem>[];
  final history = <_HistoryEntry>[];

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
      target: 33)
      : selected < dhikr.length
      ? dhikr[selected]
      : customDhikr[(selected - dhikr.length)
      .clamp(0, customDhikr.length - 1)];

  double get progress => target == 0 ? 0 : (count / target).clamp(0.0, 1.0);

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
          backgroundColor: greenDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Text(s,
              style: const TextStyle(
                  color: whiteText, fontWeight: FontWeight.w700)),
        ),
      );
  }

  void selector() => showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetCtx) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        return Container(
          height: MediaQuery.of(sheetCtx).size.height * .84,
          decoration: const BoxDecoration(
            color: card2,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Dhikr & Duas',
                              style: TextStyle(
                                  color: whiteText,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900)),
                          SizedBox(height: 3),
                          Text('Choose a Dhikr or create your custom Dua',
                              style: TextStyle(
                                  color: greyText, fontSize: 12)),
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
                            'MY CUSTOM DUAS & DHIKR', customDhikr.length),
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

  Widget sectionHeader(String title, int itemCount) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: green,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: greenDark,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$itemCount',
            style: const TextStyle(
                color: green, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget selectCard(String title, String arabic, String sub, bool sel,
      IconData icon, VoidCallback tap,
      {bool isCustom = false, VoidCallback? onDelete}) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: sel ? green : Colors.white.withOpacity(0.08),
          width: sel ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: tap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isCustom ? const Color(0xFF26200A) : greenDark,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isCustom ? gold : green, size: 22),
        ),
        title: Text(arabic,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
                color: gold, fontSize: 17, fontWeight: FontWeight.w800)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: whiteText,
                    fontWeight: FontWeight.w900,
                    fontSize: 13)),
            Text(sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: greyText, fontSize: 10)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 20),
                onPressed: onDelete,
              ),
            Icon(
              sel ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
              color: sel ? green : greyText,
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: green, size: 16),
      ),
    );
  }

  void historySheet() => showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetCtx) => Container(
      height: MediaQuery.of(sheetCtx).size.height * .78,
      decoration: const BoxDecoration(
        color: card2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Counter History',
                          style: TextStyle(
                              color: whiteText,
                              fontSize: 22,
                              fontWeight: FontWeight.w900)),
                      SizedBox(height: 3),
                      Text('Which Dhikr you counted and how many times',
                          style: TextStyle(color: greyText, fontSize: 12)),
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
                ? const Center(
              child: Text('No history yet',
                  style: TextStyle(
                      color: greyText, fontWeight: FontWeight.w700)),
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
                    color: card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                            color: greenDark, shape: BoxShape.circle),
                        child: const Icon(Icons.auto_awesome_rounded,
                            color: green, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(h.arabic,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                    color: gold,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800)),
                            Text(h.title,
                                style: const TextStyle(
                                    color: whiteText,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13)),
                            const SizedBox(height: 3),
                            Text(
                                'Count: ${h.count}  •  Target: ${h.target}',
                                style: const TextStyle(
                                    color: greyText,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
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

  Widget header() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
    child: Row(
      children: [
        GestureDetector(
          onTap: _handleBack,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: whiteText, size: 14),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [green.withValues(alpha: 0.25), card2],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: green.withValues(alpha: 0.6), width: 1.2),
          ),
          child: const Icon(Icons.radio_button_checked_rounded, color: green, size: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DIGITAL TASBEEH',
                  style: TextStyle(
                      color: gold,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.3)),
              const Text(
                'Remember Allah, Find Peace',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: whiteText,
                    fontSize: 13,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        iconTopButton(Icons.auto_awesome_rounded, selector),
        const SizedBox(width: 6),
        iconTopButton(Icons.history_rounded, historySheet),
      ],
    ),
  );

  Widget currentCard() {
    return GestureDetector(
      onTap: selector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F1813), Color(0xFF09100C)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: green.withValues(alpha: 0.35), width: 1.1),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: greenDark,
                border: Border.all(color: gold, width: 1.2),
              ),
              child: Center(
                child: Text(
                  current.arabic,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: gold, fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CURRENT DHIKR',
                      style: TextStyle(
                          color: green,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 1),
                  Text(current.title,
                      style: const TextStyle(
                          color: whiteText,
                          fontSize: 15,
                          fontWeight: FontWeight.w900)),
                  Text(current.meaning,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: greyText, fontSize: 10.5)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: greyText, size: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // EXACT BEADS MALA & DIGITAL COUNTER UI WALA RING
  // ==========================================================

  Widget ring() {
    final int totalBeads = target > 0 ? target : 33;

    return SizedBox(
      width: 230,
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Beads Mala Painter
          CustomPaint(
            size: const Size(230, 230),
            painter: _TasbeehBeadsPainter(
              count: count,
              totalBeads: totalBeads,
              activeColor: green,
              inactiveColor: const Color(0xFF334438),
            ),
          ),
          // Inner Glowing Count Circle Container
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  green.withOpacity(0.35),
                  const Color(0xFF040A07),
                ],
              ),
              border: Border.all(color: green, width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: green.withOpacity(0.25),
                  blurRadius: 16,
                  spreadRadius: 2,
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
                    style: const TextStyle(
                      color: whiteText,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: setTarget,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF040A07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: green.withOpacity(0.4)),
                    ),
                    child: Text(
                      '/ $target',
                      style: const TextStyle(
                        color: green,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
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
        scale: pressed ? .92 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E3D2D), Color(0xFF040A07)],
            ),
            border: Border.all(color: green, width: 2),
            boxShadow: [
              BoxShadow(
                color: green.withOpacity(.35),
                blurRadius: 18,
                spreadRadius: 2,
              )
            ],
          ),
          child: Center(
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [green, green.withValues(alpha: 0.7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: green.withValues(alpha: 0.6),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.touch_app_rounded, color: Colors.black, size: 24),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // NEW COLORFUL PROFESSIONAL CONTROL BUTTONS
  // ==========================================================

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
            color: const Color(0xFFF39C12), // Orange/Gold
            onTap: reset,
          ),
          _colorfulControlButton(
            title: 'Minus',
            subtitle: 'Decrease',
            icon: Icons.remove_rounded,
            color: const Color(0xFFE74C3C), // Red
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
            color: const Color(0xFF26E17A), // Green
            onTap: addCount,
          ),
          _colorfulControlButton(
            title: 'Target',
            subtitle: 'Custom',
            icon: Icons.star_outline_rounded,
            color: const Color(0xFF3498DB), // Blue
            onTap: setTarget,
          ),
          _colorfulControlButton(
            title: 'History',
            subtitle: 'Records',
            icon: Icons.history_rounded,
            color: const Color(0xFF9B59B6), // Purple
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
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.25),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.4), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  color: whiteText,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: color,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
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
                  color: Color(0xFF00E676),
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
              Positioned.fill(
                child: Opacity(
                  opacity: 0.35,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF050D08), Color(0xFF000000)],
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  header(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 2, 16, 78),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          currentCard(),
                          ring(),
                          tapButton(),
                          Column(
                            children: const [
                              Text('Tap to count',
                                  style: TextStyle(
                                      color: whiteText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900)),
                              SizedBox(height: 1),
                              Text(
                                'Keep your heart focused on Allah',
                                style: TextStyle(color: greyText, fontSize: 10),
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
  }
}

// ==========================================================
// CUSTOM PAINTER FOR EXACT BEADS MALA (TASBEEH)
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

    // Draw connecting thin line circle
    final linePaint = Paint()
      ..color = const Color(0xFF223328)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, linePaint);

    // Draw Beads
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

      // Glow effect for active beads
      if (isActive) {
        final glowPaint = Paint()
          ..color = activeColor.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(beadCenter, 7.5, glowPaint);
      }

      canvas.drawCircle(beadCenter, 5.5, paint);
    }

    // Top Imamah / Leader Bead (Top Marker)
    final double topAngle = -math.pi / 2;
    final Offset leaderCenter = Offset(
      center.dx + (radius + 2) * math.cos(topAngle),
      center.dy + (radius + 2) * math.sin(topAngle),
    );

    final leaderPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    // Leader cylinder/bead accent at the top
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: leaderCenter, width: 10, height: 16),
        const Radius.circular(4),
      ),
      leaderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TasbeehBeadsPainter oldDelegate) {
    return oldDelegate.count != count || oldDelegate.totalBeads != totalBeads;
  }
}

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

  static const Color card = Color(0xFF0A0F0C);
  static const Color card2 = Color(0xFF101613);
  static const Color green = Color(0xFF26E17A);
  static const Color whiteText = Color(0xFFF4F6F5);
  static const Color greyText = Color(0xFF98A19D);

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

  Widget _field(TextEditingController controller, String label, IconData icon,
      {bool rtl = false, bool number = false}) {
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
      style: const TextStyle(color: whiteText, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: greyText, fontSize: 13),
        prefixIcon: Icon(icon, color: green, size: 20),
        filled: true,
        fillColor: card,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: card2,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      title: const Text('Create New Dhikr / Dua',
          style: TextStyle(color: whiteText, fontWeight: FontWeight.w900)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_nameController, 'Dhikr / Dua Name', Icons.title_rounded),
            const SizedBox(height: 10),
            _field(_arabicController, 'Arabic Text (Optional)',
                Icons.translate_rounded,
                rtl: true),
            const SizedBox(height: 10),
            _field(_meaningController, 'Meaning / Description',
                Icons.menu_book_rounded),
            const SizedBox(height: 10),
            _field(_targetController, 'Target Count', Icons.flag_rounded,
                number: true),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: greyText,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _cancel,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _submit,
                    child: const Text('Create',
                        style: TextStyle(fontWeight: FontWeight.bold)),
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

class _CustomTargetDialog extends StatefulWidget {
  final int currentTarget;
  const _CustomTargetDialog({required this.currentTarget});

  @override
  State<_CustomTargetDialog> createState() => _CustomTargetDialogState();
}

class _CustomTargetDialogState extends State<_CustomTargetDialog> {
  late TextEditingController _controller;

  static const Color card = Color(0xFF0A0F0C);
  static const Color card2 = Color(0xFF101613);
  static const Color green = Color(0xFF26E17A);
  static const Color whiteText = Color(0xFFF4F6F5);
  static const Color greyText = Color(0xFF98A19D);

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
      backgroundColor: card2,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      title: const Row(
        children: [
          Icon(Icons.flag_rounded, color: green),
          SizedBox(width: 8),
          Text('Set Target Count',
              style: TextStyle(color: whiteText, fontWeight: FontWeight.w900)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick Presets:',
                style: TextStyle(
                    color: greyText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
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
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? green : card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSel
                              ? green
                              : Colors.white.withOpacity(0.12)),
                    ),
                    child: Text(
                      '$num',
                      style: TextStyle(
                        color: isSel ? Colors.black : whiteText,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Or Type Custom Target:',
                style: TextStyle(
                    color: greyText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
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
                  icon: const Icon(Icons.remove_circle_outline_rounded,
                      color: green),
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
                    style: const TextStyle(
                        color: whiteText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: card,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
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
                  icon: const Icon(Icons.add_circle_outline_rounded,
                      color: green),
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
          child: const Text('Cancel', style: TextStyle(color: greyText)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: green, foregroundColor: Colors.black),
          onPressed: _submit,
          child: const Text('Save Target',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}