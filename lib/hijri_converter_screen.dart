import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'favorites_service.dart';
import 'more_screen.dart';
import 'settings_screen.dart';

class HijriConverterScreen extends StatefulWidget {
  const HijriConverterScreen({super.key});

  @override
  State<HijriConverterScreen> createState() => _HijriConverterScreenState();
}

class _HijriConverterScreenState extends State<HijriConverterScreen> {
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

  int _selectedTab = 0;

  int _selectedHDay = 17;
  int _selectedHMonth = 4; // Rabi' al-Thani
  int _selectedHYear = 1448;
  String _gregorianResult = '';

  DateTime _selectedGregorianDate = DateTime.now();
  String _hijriResult = '';

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

  final DateTime anchorGregorian = DateTime(2026, 9, 30);
  final int anchorHDay = 17;
  final int anchorHMonth = 4;
  final int anchorHYear = 1448;

  void _convertHijriToGregorian() {
    int totalDaysOffset = (_selectedHYear - anchorHYear) * 354 +
        ((_selectedHMonth - anchorHMonth) * 29.5).round() +
        (_selectedHDay - anchorHDay);

    DateTime convertedDate = anchorGregorian.add(Duration(days: totalDaysOffset));
    setState(() {
      _gregorianResult = DateFormat('EEEE, d MMMM yyyy').format(convertedDate);
    });
  }

  void _convertGregorianToHijri() {
    int diffDays = _selectedGregorianDate.difference(anchorGregorian).inDays;

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
    String monthName = hijriMonthNames[validMonth - 1];

    setState(() {
      _hijriResult = '$currentHDay $monthName $currentHYear AH';
    });
  }

  Future<void> _pickGregorianDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedGregorianDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: _isDark ? ThemeData.dark() : ThemeData.light(),
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedGregorianDate = picked;
        _convertGregorianToHijri();
      });
    }
  }

  void _showHijriPickerDialog() {
    int tempDay = _selectedHDay;
    int tempMonth = _selectedHMonth;
    int tempYear = _selectedHYear;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: surfaceWhite,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: borderSubtle),
              ),
              title: Text(
                'Select Hijri Date',
                style: TextStyle(color: primaryDeepEmerald, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Day:', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
                      DropdownButton<int>(
                        value: tempDay,
                        dropdownColor: surfaceWhite,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down_rounded, color: richEmerald),
                        items: List.generate(30, (i) => i + 1)
                            .map((d) => DropdownMenuItem(value: d, child: Text('$d', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => tempDay = val);
                        },
                      ),
                    ],
                  ),
                  Divider(color: borderSubtle, height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Month:', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
                      DropdownButton<int>(
                        value: tempMonth,
                        dropdownColor: surfaceWhite,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down_rounded, color: richEmerald),
                        items: List.generate(12, (i) => i + 1)
                            .map((m) => DropdownMenuItem(value: m, child: Text(hijriMonthNames[m - 1], style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => tempMonth = val);
                        },
                      ),
                    ],
                  ),
                  Divider(color: borderSubtle, height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Year:', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600)),
                      DropdownButton<int>(
                        value: tempYear,
                        dropdownColor: surfaceWhite,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down_rounded, color: richEmerald),
                        items: [1447, 1448, 1449, 1450]
                            .map((y) => DropdownMenuItem(value: y, child: Text('$y AH', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => tempYear = val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: textInactive)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: richEmerald,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedHDay = tempDay;
                      _selectedHMonth = tempMonth;
                      _selectedHYear = tempYear;
                      _convertHijriToGregorian();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
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
  void initState() {
    super.initState();
    _selectedGregorianDate = DateTime.now();

    int diffDays = _selectedGregorianDate.difference(anchorGregorian).inDays;
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

    _selectedHDay = currentHDay;
    _selectedHMonth = currentHMonth.clamp(1, 12);
    _selectedHYear = currentHYear;

    _convertHijriToGregorian();
    _convertGregorianToHijri();
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
                  _tabSelector(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: _selectedTab == 0
                          ? _buildHijriToGregorianWidget()
                          : _buildGregorianToHijriWidget(),
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
          // Sleek, Premium Professional Icon Container (Updated)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [richEmerald, primaryDeepEmerald],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: richEmerald.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.sync_alt_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DATE CONVERTER',
                  style: TextStyle(
                    color: richEmerald,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hijri ↔ Gregorian',
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

  Widget _tabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? secondarySurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: _selectedTab == 0
                      ? Border.all(color: richEmerald)
                      : null,
                ),
                child: Text(
                  'Hijri → Gregorian',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 0 ? richEmerald : textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? secondarySurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: _selectedTab == 1
                      ? Border.all(color: richEmerald)
                      : null,
                ),
                child: Text(
                  'Gregorian → Hijri',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 1 ? richEmerald : textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHijriToGregorianWidget() {
    final formattedHijri = '$_selectedHDay ${hijriMonthNames[_selectedHMonth - 1]} $_selectedHYear AH';
    final String id = 'hijri_conv_${_selectedHDay}_${_selectedHMonth}_$_selectedHYear';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
              const Text(
                'Select Hijri Date',
                style: TextStyle(
                    color: richEmerald, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _showHijriPickerDialog,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: secondarySurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderSubtle),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedHijri,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.calendar_month_rounded, color: richEmerald, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _convertHijriToGregorian,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: richEmerald,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Convert to Gregorian',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_gregorianResult.isNotEmpty)
          Container(
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Corresponding Gregorian Date',
                      style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    FutureBuilder<bool>(
                      future: FavoritesService.isFavorite(id),
                      builder: (context, snapshot) {
                        final isFav = snapshot.data ?? false;
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? Colors.redAccent : textInactive,
                            size: 18,
                          ),
                          onPressed: () async {
                            await FavoritesService.toggleFavorite(
                              id: id,
                              category: 'Converter',
                              title: formattedHijri,
                              content: 'Gregorian Date: $_gregorianResult',
                              subtitle: 'Hijri to Gregorian Conversion',
                            );
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _gregorianResult,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: richEmerald,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildGregorianToHijriWidget() {
    final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(_selectedGregorianDate);
    final String id = 'greg_conv_${DateFormat('yyyy_MM_dd').format(_selectedGregorianDate)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
              const Text(
                'Select Gregorian Date',
                style: TextStyle(
                    color: richEmerald, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _pickGregorianDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: secondarySurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderSubtle),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.calendar_month_rounded, color: richEmerald, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _convertGregorianToHijri,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: richEmerald,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Convert to Hijri',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_hijriResult.isNotEmpty)
          Container(
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Corresponding Hijri Date',
                      style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    FutureBuilder<bool>(
                      future: FavoritesService.isFavorite(id),
                      builder: (context, snapshot) {
                        final isFav = snapshot.data ?? false;
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? Colors.redAccent : textInactive,
                            size: 18,
                          ),
                          onPressed: () async {
                            await FavoritesService.toggleFavorite(
                              id: id,
                              category: 'Converter',
                              title: formattedDate,
                              content: 'Hijri Date: $_hijriResult',
                              subtitle: 'Gregorian to Hijri Conversion',
                            );
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _hijriResult,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: richEmerald,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}