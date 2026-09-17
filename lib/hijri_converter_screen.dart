import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'favorites_service.dart';
import 'more_screen.dart'; // Navigates smoothly back to More screen

class HijriConverterScreen extends StatefulWidget {
  const HijriConverterScreen({super.key});

  @override
  State<HijriConverterScreen> createState() => _HijriConverterScreenState();
}

class _HijriConverterScreenState extends State<HijriConverterScreen> {
  static const Color background = Color(0xFF000000);
  static const Color card = Color(0xFF0A0F0C);
  static const Color card2 = Color(0xFF101613);

  static const Color green = Color(0xFF26E17A);
  static const Color greenDark = Color(0xFF0C3323);
  static const Color gold = Color(0xFFE8B63D);

  static const Color whiteText = Color(0xFFF4F6F5);
  static const Color greyText = Color(0xFF98A19D);

  int _selectedTab = 0;

  // Hijri Selection Variables (Initialized to 22 Rabi' al-Awwal 1448 for today)
  int _selectedHDay = 22;
  int _selectedHMonth = 3; // Rabi' al-Awwal
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

  // Corrected anchor mapping: 5 September 2026 = 22 Rabi' al-Awwal 1448 AH
  final DateTime anchorGregorian = DateTime(2026, 9, 5);
  final int anchorHDay = 22;
  final int anchorHMonth = 3;
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
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: green,
              onPrimary: Colors.black,
              surface: card,
              onSurface: whiteText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedGregorianDate = picked;
      });
    }
  }

  // Beautiful popup dialog to select Hijri Date easily like a calendar picker
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
              backgroundColor: card2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: const Text(
                'Select Hijri Date',
                style: TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.w900),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Day Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Day:', style: TextStyle(color: greyText, fontWeight: FontWeight.w700)),
                      DropdownButton<int>(
                        value: tempDay,
                        dropdownColor: card,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down_rounded, color: green),
                        items: List.generate(30, (i) => i + 1)
                            .map((d) => DropdownMenuItem(value: d, child: Text('$d', style: const TextStyle(color: whiteText, fontWeight: FontWeight.w800))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => tempDay = val);
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12),
                  // Month Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Month:', style: TextStyle(color: greyText, fontWeight: FontWeight.w700)),
                      DropdownButton<int>(
                        value: tempMonth,
                        dropdownColor: card,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down_rounded, color: green),
                        items: List.generate(12, (i) => i + 1)
                            .map((m) => DropdownMenuItem(value: m, child: Text(hijriMonthNames[m - 1], style: const TextStyle(color: whiteText, fontWeight: FontWeight.w800))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => tempMonth = val);
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12),
                  // Year Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Year:', style: TextStyle(color: greyText, fontWeight: FontWeight.w700)),
                      DropdownButton<int>(
                        value: tempYear,
                        dropdownColor: card,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down_rounded, color: green),
                        items: [1447, 1448, 1449, 1450]
                            .map((y) => DropdownMenuItem(value: y, child: Text('$y AH', style: const TextStyle(color: whiteText, fontWeight: FontWeight.w800))))
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
                  child: const Text('Cancel', style: TextStyle(color: greyText)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.black),
                  onPressed: () {
                    setState(() {
                      _selectedHDay = tempDay;
                      _selectedHMonth = tempMonth;
                      _selectedHYear = tempYear;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            );
          },
        );
      },
    );
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
  void initState() {
    super.initState();
    _convertHijriToGregorian();
    _convertGregorianToHijri();
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
          child: Column(
            children: [
              _headerSection(),
              _tabSelector(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(), // Native smooth scroll
                  ),
                  padding: const EdgeInsets.all(18),
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
  }

  Widget _headerSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: whiteText, size: 20),
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
            child: const Icon(Icons.swap_horiz_rounded, color: gold, size: 26),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DATE CONVERTER',
                  style: TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Hijri ↔ Gregorian',
                  style: TextStyle(
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

  Widget _tabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? greenDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: _selectedTab == 0
                      ? Border.all(color: green.withValues(alpha: 0.5))
                      : null,
                ),
                child: Text(
                  'Hijri → Gregorian',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 0 ? green : greyText,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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
                  color: _selectedTab == 1 ? greenDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: _selectedTab == 1
                      ? Border.all(color: green.withValues(alpha: 0.5))
                      : null,
                ),
                child: Text(
                  'Gregorian → Hijri',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 1 ? green : greyText,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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
            color: card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Hijri Date',
                style: TextStyle(
                    color: gold, fontSize: 14, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              // Interactive Picker Button
              GestureDetector(
                onTap: _showHijriPickerDialog,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: card2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedHijri,
                        style: const TextStyle(
                          color: whiteText,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Icon(Icons.calendar_month_rounded, color: gold, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _convertHijriToGregorian,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Convert to Gregorian',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_gregorianResult.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: green.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Corresponding Gregorian Date',
                      style: TextStyle(color: greyText, fontSize: 11, fontWeight: FontWeight.w700),
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
                            color: isFav ? Colors.redAccent : greyText,
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
                const SizedBox(height: 8),
                Text(
                  _gregorianResult,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: green,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
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
            color: card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Gregorian Date',
                style: TextStyle(
                    color: gold, fontSize: 14, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickGregorianDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: card2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: whiteText,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Icon(Icons.calendar_month_rounded, color: gold, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _convertGregorianToHijri,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Convert to Hijri',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_hijriResult.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: gold.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Corresponding Hijri Date',
                      style: TextStyle(color: greyText, fontSize: 11, fontWeight: FontWeight.w700),
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
                            color: isFav ? Colors.redAccent : greyText,
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
                const SizedBox(height: 8),
                Text(
                  _hijriResult,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: gold,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}