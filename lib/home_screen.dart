import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_drawer.dart';
import 'favorites_service.dart';
import 'islamic_calendar_screen.dart';
import 'live_tasbeeh_icon.dart';
import 'more_screen.dart';
import 'notification_service.dart';
import 'prayer_service.dart';
import 'qibla_screen.dart';
import 'quran_screen.dart';
import 'settings_screen.dart';
import 'tasbeeh_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  static const Color background = Color(0xFF040806);
  static const Color card = Color(0xFF0D1612);
  static const Color card2 = Color(0xFF121E18);

  static const Color green = Color(0xFF00E676);
  static const Color greenDark = Color(0xFF0B2E1E);

  static const Color gold = Color(0xFFFFD700);
  static const Color goldAccent = Color(0xFFE5B53B);

  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color greyText = Color(0xFF90A4AE);

  // Smooth Drawer Animation Controllers
  late AnimationController _drawerAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  bool _isDrawerOpen = false;

  String city = 'Detecting Location...';
  String hijriDate = 'Loading Hijri Date...';
  String todayDate = '';

  double temperature = 32;
  String weatherName = 'Clear';
  IconData weatherIcon = Icons.wb_sunny_rounded;

  Map<String, dynamic> prayerTimes = {
    'Fajr': '04:20',
    'Dhuhr': '12:07',
    'Asr': '16:39',
    'Maghrib': '18:27',
    'Isha': '19:53',
  };

  String nextPrayer = 'Fajr';
  String nextPrayerTime = '04:20';

  // Isolated countdown state using ValueNotifier
  final ValueNotifier<Duration> _remaining =
  ValueNotifier<Duration>(Duration.zero);

  bool loading = false;
  bool isRefreshing = false;
  bool isGpsOff = false;
  String errorMessage = '';

  Timer? countdownTimer;
  late AnimationController pulseController;

  final PageController _quotePageController = PageController();
  int _currentQuoteIndex = 0;

  final List<Map<String, String>> quotes = [
    {
      'arabic': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'translation': 'Indeed, with hardship [will be] ease.',
      'reference': '— Surah Ash-Sharh (94:6)',
    },
    {
      'arabic': 'فَاذْكُرُونِي أَذْكُرْكُمْ',
      'translation': 'So remember Me; I will remember you.',
      'reference': '— Surah Al-Baqarah (2:152)',
    },
    {
      'arabic': 'رَبِّ إِنِّي لِمَا أَنْزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
      'translation':
      'My Lord, indeed I am, for whatever good You would send down to me, in need.',
      'reference': '— Surah Al-Qasas (28:24)',
    },
  ];

  @override
  void initState() {
    super.initState();

    todayDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    _drawerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.68).animate(
      CurvedAnimation(
        parent: _drawerAnimationController,
        curve: const Cubic(0.22, 1.0, 0.36, 1.0),
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 260.0).animate(
      CurvedAnimation(
        parent: _drawerAnimationController,
        curve: const Cubic(0.22, 1.0, 0.36, 1.0),
        reverseCurve: Curves.easeInCubic,
      ),
    );

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) => updateNextPrayer(),
    );

    updateNextPrayer();
    loadData();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    pulseController.dispose();
    _drawerAnimationController.dispose();
    _quotePageController.dispose();
    _remaining.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      if (_isDrawerOpen) {
        _drawerAnimationController.reverse();
        _isDrawerOpen = false;
      } else {
        _drawerAnimationController.forward();
        _isDrawerOpen = true;
      }
    });
  }

  Future<void> loadData() async {
    if (!mounted) return;

    setState(() {
      isRefreshing = true;
    });

    final prefs = await SharedPreferences.getInstance();

    try {
      double? lat;
      double? lng;
      String detectedCity = '';

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied && serviceEnabled) {
        permission = await Geolocator.requestPermission();
      }

      if (serviceEnabled &&
          (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse)) {
        if (mounted) setState(() => isGpsOff = false);

        Position? position;
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 10),
            ),
          );
        } catch (_) {
          position = await Geolocator.getLastKnownPosition();
        }

        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;

          detectedCity = await _resolveCityViaHttp(lat, lng);

          await prefs.setDouble('last_lat', lat);
          await prefs.setDouble('last_lng', lng);
          if (detectedCity.isNotEmpty) {
            await prefs.setString('last_city', detectedCity);
          }
        } else {
          lat = prefs.getDouble('last_lat');
          lng = prefs.getDouble('last_lng');
          detectedCity = prefs.getString('last_city') ?? 'Saved Location';
        }
      } else {
        if (mounted) setState(() => isGpsOff = true);

        lat = prefs.getDouble('last_lat');
        lng = prefs.getDouble('last_lng');
        detectedCity = prefs.getString('last_city') ?? 'Saved Location';
      }

      lat ??= 34.0151;
      lng ??= 71.5249;

      final result = await PrayerService.getPrayerTimes(lat, lng);
      final timings = extractTimings(result);

      await loadWeather(lat, lng);

      if (!mounted) return;

      setState(() {
        if (detectedCity.isNotEmpty) city = detectedCity;
        if (timings.isNotEmpty) prayerTimes = timings;

        final hDate = extractHijriDate(result);
        if (hDate.isNotEmpty) hijriDate = hDate;

        loading = false;
        isRefreshing = false;
      });

      updateNextPrayer();
      _scheduleAllPrayerNotifications();
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          isRefreshing = false;
        });
      }
      _scheduleAllPrayerNotifications();
    }
  }

  void _scheduleAllPrayerNotifications() {
    if (prayerTimes.isEmpty) return;

    final now = DateTime.now();
    const prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    int notificationId = 100;

    for (final prayer in prayers) {
      final rawTime = prayerTimes[prayer]?.toString() ?? '';
      if (rawTime.isEmpty) continue;

      final parts = rawTime.split(' ').first.split(':');
      if (parts.length < 2) continue;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) continue;

      DateTime scheduledDate =
      DateTime(now.year, now.month, now.day, hour, minute);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      NotificationService.schedulePrayer(
        id: notificationId++,
        prayerName: prayer,
        prayerTime: scheduledDate,
        city: city,
      );
    }
  }

  Future<String> _resolveCityViaHttp(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng&zoom=18&addressdetails=1&accept-language=en',
      );
      final res = await http.get(uri, headers: {
        'User-Agent': 'PrayerTimesApp/1.0 (contact@prayertimes.app)'
      }).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final exactSector = address['neighbourhood'] ??
              address['suburb'] ??
              address['residential'] ??
              address['quarter'] ??
              address['subdistrict'] ??
              address['village'] ??
              address['hamlet'] ??
              address['town'];

          final mainCity = address['city'] ??
              address['county'] ??
              address['state_district'] ??
              '';

          final sectorStr = exactSector?.toString().trim() ?? '';
          final cityStr = mainCity.toString().trim();

          if (sectorStr.isNotEmpty &&
              cityStr.isNotEmpty &&
              sectorStr != cityStr) {
            return '$sectorStr, $cityStr';
          } else if (sectorStr.isNotEmpty) {
            return sectorStr;
          } else if (cityStr.isNotEmpty) {
            return cityStr;
          }
        }
      }
    } catch (_) {}

    return 'Live Location';
  }

  Map<String, dynamic> extractTimings(Map<String, dynamic> data) {
    final dynamic timings = data['timings'];
    if (timings is Map) {
      return Map<String, dynamic>.from(timings);
    }
    return data;
  }

  String extractHijriDate(Map<String, dynamic> data) {
    try {
      final dateMap = data['date'];
      if (dateMap is Map) {
        final hijri = dateMap['hijri'];
        if (hijri is Map) {
          final day = hijri['day']?.toString() ?? '';
          final monthObj = hijri['month'];
          String monthName = '';
          if (monthObj is Map) {
            monthName = monthObj['en']?.toString() ?? '';
          }
          final year = hijri['year']?.toString() ?? '';
          if (day.isNotEmpty && monthName.isNotEmpty && year.isNotEmpty) {
            return '$day $monthName $year';
          }
        }
      }
    } catch (_) {}
    return '25 Rabi\' al-awwal 1448';
  }

  Future<void> loadWeather(double latitude, double longitude) async {
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
            '?latitude=$latitude'
            '&longitude=$longitude'
            '&current_weather=true',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode != 200) return;

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map) return;

      final dynamic currentWeather = decoded['current_weather'];
      if (currentWeather is! Map) return;

      final temp = (currentWeather['temperature'] as num?)?.toDouble() ?? 32.0;
      final code = (currentWeather['weathercode'] as num?)?.toInt() ?? 0;
      final weather = weatherInfo(code);

      if (!mounted) return;

      setState(() {
        temperature = temp;
        weatherName = weather.$1;
        weatherIcon = weather.$2;
      });
    } catch (_) {}
  }

  (String, IconData) weatherInfo(int code) {
    switch (code) {
      case 0:
        return ('Clear', Icons.wb_sunny_rounded);
      case 1:
        return ('Mainly Clear', Icons.wb_sunny_rounded);
      case 2:
        return ('Partly Cloudy', Icons.cloud_queue_rounded);
      case 3:
        return ('Overcast', Icons.cloud_rounded);
      default:
        return ('Clear', Icons.wb_sunny_rounded);
    }
  }

  DateTime? parsePrayerTime(String value, DateTime date) {
    try {
      final clean = value.split(' ').first.trim();
      final parts = clean.split(':');
      if (parts.length < 2) return null;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) return null;

      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  String formatPrayerTime(dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.isEmpty) return '--:--';

    final clean = raw.split(' ').first;
    final parts = clean.split(':');
    if (parts.length < 2) return clean;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return clean;

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  void updateNextPrayer() {
    if (prayerTimes.isEmpty) return;

    final now = DateTime.now();
    const prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    DateTime? nextDate;
    String foundName = '';
    String foundTime = '';

    for (final prayer in prayers) {
      final raw = prayerTimes[prayer]?.toString() ?? '';
      final parsed = parsePrayerTime(raw, now);

      if (parsed != null && parsed.isAfter(now)) {
        nextDate = parsed;
        foundName = prayer;
        foundTime = formatPrayerTime(raw);
        break;
      }
    }

    if (nextDate == null) {
      final fajrRaw = prayerTimes['Fajr']?.toString() ?? '';
      final tomorrow = now.add(const Duration(days: 1));
      final fajr = parsePrayerTime(fajrRaw, tomorrow);

      if (fajr != null) {
        nextDate = fajr;
        foundName = 'Fajr';
        foundTime = formatPrayerTime(fajrRaw);
      }
    }

    if (nextDate == null || !mounted) return;

    final remaining = nextDate.difference(DateTime.now());
    final prayerChanged =
        nextPrayer != foundName || nextPrayerTime != foundTime;

    if (prayerChanged) {
      setState(() {
        nextPrayer = foundName;
        nextPrayerTime = foundTime;
      });
    }

    _remaining.value = remaining;
  }

  bool isPrayerPassed(String name) {
    final raw = prayerTimes[name]?.toString() ?? '';
    final parsed = parsePrayerTime(raw, DateTime.now());
    if (parsed == null) return false;
    return parsed.isBefore(DateTime.now()) && name != nextPrayer;
  }

  void _showNotificationHistorySheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.58,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: BoxDecoration(
          color: const Color(0xFF0A120E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_active_rounded,
                      color: gold, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Prayer Notifications Log',
                    style: TextStyle(
                      color: whiteText,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: greenDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: green.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: green, size: 7),
                      SizedBox(width: 5),
                      Text(
                        'Active',
                        style: TextStyle(
                          color: green,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _notificationItem('Fajr Adhan Scheduled', '04:20 AM',
                      'Passed successfully today', true),
                  _notificationItem('Dhuhr Adhan Scheduled', '12:07 PM',
                      'Passed successfully today', true),
                  _notificationItem('Asr Adhan Scheduled', '04:39 PM',
                      'Upcoming next prayer', false),
                  _notificationItem('Maghrib Adhan Scheduled', '06:27 PM',
                      'Scheduled for today', false),
                  _notificationItem('Isha Adhan Scheduled', '07:53 PM',
                      'Scheduled for today', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationItem(
      String title, String time, String sub, bool passed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: passed
              ? Colors.white.withValues(alpha: 0.06)
              : green.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: passed
                  ? Colors.white.withValues(alpha: 0.05)
                  : green.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              passed
                  ? Icons.check_rounded
                  : Icons.notifications_active_rounded,
              color: passed ? greyText : green,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: whiteText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(color: greyText, fontSize: 10.5),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: passed ? greyText : green,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _smoothNavigateTo(Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AppDrawer(
            onClose: _toggleDrawer,
          ),
          AnimatedBuilder(
            animation: _drawerAnimationController,
            child: _buildMainHomeContent(),
            builder: (context, child) {
              final progress = _drawerAnimationController.value;

              return Transform.translate(
                offset: Offset(_slideAnimation.value, 0),
                child: Transform.scale(
                  alignment: Alignment.centerLeft,
                  scale: _scaleAnimation.value,
                  child: RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30 * progress),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: progress == 0
                              ? const <BoxShadow>[]
                              : [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.75 * progress,
                              ),
                              blurRadius: 30,
                              spreadRadius: 8,
                              offset: const Offset(-12, 10),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: _isDrawerOpen ? _toggleDrawer : null,
                          child: AbsorbPointer(
                            absorbing: _isDrawerOpen,
                            child: child!,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainHomeContent() {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            RefreshIndicator(
              color: green,
              backgroundColor: card2,
              onRefresh: loadData,
              child: buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody() {
    if (loading) return loadingView();
    if (errorMessage.isNotEmpty) return errorView();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heroHeader(),
          locationCard(),
          if (isGpsOff) gpsWarningBanner(),
          const SizedBox(height: 12),
          nextPrayerCard(),
          const SizedBox(height: 18),
          prayerSection(),
          const SizedBox(height: 18),
          quickActions(),
          const SizedBox(height: 18),
          quoteCard(),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // ==========================================================
  // TOP EXECUTIVE HEADER
  // ==========================================================

  Widget heroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      child: Row(
        children: [
          // Drawer Hamburger Button with Gold Glow
          GestureDetector(
            onTap: _toggleDrawer,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    gold.withValues(alpha: 0.18),
                    card2,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: gold.withValues(alpha: 0.55),
                  width: 1.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gold.withValues(alpha: 0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.menu_rounded, color: gold, size: 26),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'PRAYER TIMES',
                      style: TextStyle(
                        color: goldAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: greenDark,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: green.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: green,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Your Daily Prayer',
                  style: TextStyle(
                    color: whiteText,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Stay connected with your faith',
                  style: TextStyle(
                    color: greyText.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Notification Bell with Pulsing Indicator
          GestureDetector(
            onTap: _showNotificationHistorySheet,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.notifications_outlined,
                      color: whiteText, size: 21),
                  Positioned(
                    top: 10,
                    right: 11,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: green.withValues(alpha: 0.8),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LOCATION & WEATHER GLASS CARD
  // ==========================================================

  Widget locationCard() {
    List<String> cityParts = city.split(',');
    String areaTitle = cityParts.first.trim();
    String subLocation =
    cityParts.length > 1 ? cityParts.sublist(1).join(',').trim() : '';

    return GestureDetector(
      onTap: () => _smoothNavigateTo(const IslamicCalendarScreen()),
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 6, 18, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF111C16),
              Color(0xFF0A120E),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: green.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.location_on_rounded,
                            color: green, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          areaTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: whiteText,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (subLocation.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.only(left: 29),
                      child: Text(
                        subLocation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: green,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Gregorian Date
                  Text(
                    todayDate,
                    style: TextStyle(
                      color: greyText.withValues(alpha: 0.9),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Hijri Date Badge
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: gold.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_month_rounded,
                            color: gold, size: 12),
                        const SizedBox(width: 5),
                        Text(
                          hijriDate,
                          style: const TextStyle(
                            color: gold,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 64,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: Colors.white.withValues(alpha: 0.09),
            ),
            // Weather Card
            Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(weatherIcon, color: gold, size: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${temperature.round()}°C',
                    style: const TextStyle(
                      color: whiteText,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    weatherName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: greyText,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget gpsWarningBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF231A05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_off_rounded, color: gold, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'GPS is disabled. Showing saved prayer coordinates.',
              style: TextStyle(
                color: gold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // NEXT PRAYER HERO CARD (DIGITAL COUNTDOWN & GLOWING RING)
  // ==========================================================

  Widget nextPrayerCard() {
    return RepaintBoundary(
      child: ValueListenableBuilder<Duration>(
        valueListenable: _remaining,
        builder: (context, remaining, _) {
          final hours = remaining.inHours.clamp(0, 99);
          final minutes = remaining.inMinutes.remainder(60).clamp(0, 59);
          final seconds = remaining.inSeconds.remainder(60).clamp(0, 59);

          final hoursStr = hours.toString().padLeft(2, '0');
          final minsStr = minutes.toString().padLeft(2, '0');
          final secsStr = seconds.toString().padLeft(2, '0');

          return AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.fromLTRB(18, 6, 18, 0),
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F2B1D),
                      Color(0xFF0A1A12),
                      Color(0xFF06100B),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: green.withValues(
                      alpha: 0.35 + (pulseController.value * 0.25),
                    ),
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: green.withValues(
                        alpha: 0.14 + (pulseController.value * 0.12),
                      ),
                      blurRadius: 18,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: green.withValues(alpha: 0.8),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 7),
                              const Text(
                                'NEXT PRAYER',
                                style: TextStyle(
                                  color: green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            nextPrayer.isEmpty ? 'Fajr' : nextPrayer,
                            style: const TextStyle(
                              color: whiteText,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _timerCapsule(hoursStr, 'H'),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  ':',
                                  style: TextStyle(
                                    color: green,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              _timerCapsule(minsStr, 'M'),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  ':',
                                  style: TextStyle(
                                    color: green,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              _timerCapsule(secsStr, 'S'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.notifications_active_rounded,
                                  color: green,
                                  size: 12,
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Adhan will play at $nextPrayerTime',
                                    style: const TextStyle(
                                      color: Color(0xFFCFD8DC),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    prayerRing(remaining),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _timerCapsule(String number, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: green.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.25),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              number,
              key: ValueKey(number),
              style: const TextStyle(
                color: green,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget prayerRing(Duration remaining) {
    return SizedBox(
      width: 100,
      height: 100,
      child: CustomPaint(
        painter: PrayerRingPainter(
          progress: ringProgress(remaining),
          pulse: pulseController.value,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mosque_rounded, color: gold, size: 17),
              ),
              const SizedBox(height: 3),
              Text(
                nextPrayerTime.isEmpty ? '04:20' : nextPrayerTime,
                style: const TextStyle(
                  color: whiteText,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                nextPrayer,
                style: const TextStyle(
                  color: green,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double ringProgress(Duration remaining) {
    if (remaining.isNegative) return 0.15;
    return (remaining.inSeconds / (12 * 60 * 60)).clamp(0.10, 0.95);
  }

  // ==========================================================
  // TODAY'S PRAYER CARDS (HORIZONTAL STYLED TILES)
  // ==========================================================

  Widget prayerSection() {
    const prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    return Column(
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Container(
                width: 3.5,
                height: 14,
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: green.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "TODAY'S PRAYER TIMES",
                  style: TextStyle(
                    color: whiteText,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Refresh Button
              GestureDetector(
                onTap: isRefreshing ? null : loadData,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: card2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Row(
                    children: [
                      isRefreshing
                          ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: green,
                        ),
                      )
                          : const Icon(Icons.refresh_rounded,
                          color: greyText, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        isRefreshing ? 'Updating...' : 'Refresh',
                        style: TextStyle(
                          color: isRefreshing ? green : greyText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // 5 Prayer Cards Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: prayerNames.map((name) {
              final active = name == nextPrayer;
              final passed = isPrayerPassed(name);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: prayerCard(
                    name,
                    formatPrayerTime(prayerTimes[name]),
                    active: active,
                    passed: passed,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget prayerCard(
      String name,
      String time, {
        required bool active,
        required bool passed,
      }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 136,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: active
              ? [
            const Color(0xFF104028),
            const Color(0xFF092015),
          ]
              : passed
              ? [
            const Color(0xFF0B120E),
            const Color(0xFF070B09),
          ]
              : [
            const Color(0xFF121B16),
            const Color(0xFF0B110E),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active
              ? green
              : passed
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.11),
          width: active ? 1.5 : 1,
        ),
        boxShadow: active
            ? [
          BoxShadow(
            color: green.withValues(alpha: 0.28),
            blurRadius: 12,
            spreadRadius: 0.5,
            offset: const Offset(0, 3),
          )
        ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: active
                  ? green.withValues(alpha: 0.22)
                  : passed
                  ? Colors.white.withValues(alpha: 0.04)
                  : gold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              prayerIcon(name),
              color: active
                  ? green
                  : passed
                  ? greyText.withValues(alpha: 0.6)
                  : gold,
              size: 19,
            ),
          ),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active
                  ? green
                  : passed
                  ? greyText
                  : whiteText,
              fontSize: 11.5,
              fontWeight: active ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: passed ? greyText.withValues(alpha: 0.7) : whiteText,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          if (passed)
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF4CAF50), size: 13)
          else
            Container(
              width: active ? 26 : 18,
              height: 3,
              decoration: BoxDecoration(
                color: active ? green : gold.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                boxShadow: active
                    ? [
                  BoxShadow(
                    color: green.withValues(alpha: 0.8),
                    blurRadius: 4,
                  )
                ]
                    : [],
              ),
            ),
        ],
      ),
    );
  }

  IconData prayerIcon(String name) {
    switch (name) {
      case 'Fajr':
        return Icons.wb_twilight_rounded;
      case 'Dhuhr':
        return Icons.wb_sunny_rounded;
      case 'Asr':
        return Icons.cloud_rounded;
      case 'Maghrib':
        return Icons.mosque_rounded;
      case 'Isha':
        return Icons.nights_stay_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  // ==========================================================
  // QUICK ACCESS BENTO ACTIONS (WITH REAL LIVE TASBEEH ICON)
  // ==========================================================

  Widget quickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3.5,
                    height: 14,
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'QUICK ACCESS',
                    style: TextStyle(
                      color: whiteText,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _smoothNavigateTo(const MoreScreen()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: card2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'See All',
                        style: TextStyle(
                          color: green,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, color: green, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              quickAction(
                icon: Icons.menu_book_rounded,
                title: 'Quran',
                subtitle: 'Read & Listen',
                color: const Color(0xFFFF9E1B),
                action: () => _smoothNavigateTo(const QuranScreen()),
              ),
              quickAction(
                title: 'Tasbih',
                subtitle: 'Live Counter',
                color: const Color(0xFF00E676),
                action: () => _smoothNavigateTo(const TasbeehScreen()),
                customIcon: const LiveTasbeehIcon(
                  size: 22,
                  color: Color(0xFF00E676),
                  animate: true,
                ),
              ),
              quickAction(
                icon: Icons.explore_rounded,
                title: 'Qibla',
                subtitle: 'Find Direction',
                color: const Color(0xFF29B6F6),
                action: () => _smoothNavigateTo(const QiblaScreen()),
              ),
              quickAction(
                icon: Icons.apps_rounded,
                title: 'More',
                subtitle: 'All Features',
                color: const Color(0xFFAB47BC),
                action: () => _smoothNavigateTo(const MoreScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget quickAction({
    IconData? icon,
    Widget? customIcon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback action,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: action,
        child: Container(
          height: 104,
          margin: const EdgeInsets.symmetric(horizontal: 3.5),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.08),
                card,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.3),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: color.withValues(alpha: 0.45),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: customIcon ?? Icon(icon, color: color, size: 20),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: whiteText,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: greyText.withValues(alpha: 0.8),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // DAILY VERSE & DUA CARD
  // ==========================================================

  Widget quoteCard() {
    final currentQuote = quotes[_currentQuoteIndex];
    final String id = 'home_quote_$_currentQuoteIndex';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF131F19),
            Color(0xFF0C1410),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_stories_rounded,
                        color: green, size: 14),
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'DAILY AYAH & DUA',
                    style: TextStyle(
                      color: green,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              FutureBuilder<bool>(
                future: FavoritesService.isFavorite(id),
                builder: (context, snapshot) {
                  final isFav = snapshot.data ?? false;
                  return IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav ? Colors.redAccent : greyText,
                      size: 19,
                    ),
                    onPressed: () async {
                      await FavoritesService.toggleFavorite(
                        id: id,
                        category: 'Quran',
                        title: currentQuote['arabic']!,
                        content: currentQuote['translation']!,
                        subtitle: currentQuote['reference']!,
                      );
                      setState(() {});
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 104,
            child: PageView.builder(
              controller: _quotePageController,
              itemCount: quotes.length,
              onPageChanged: (idx) => setState(() => _currentQuoteIndex = idx),
              itemBuilder: (context, index) {
                final q = quotes[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      q['arabic']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: gold,
                        fontSize: 17.5,
                        height: 1.45,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      q['translation']!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFCFD8DC),
                        fontSize: 11,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      q['reference']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: gold.withValues(alpha: 0.8),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              quotes.length,
                  (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: quoteDot(_currentQuoteIndex == index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget quoteDot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 16 : 6,
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: active ? green : Colors.white.withValues(alpha: 0.2),
      ),
    );
  }

  Widget loadingView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: green, strokeWidth: 3),
            SizedBox(height: 16),
            Text(
              'Loading prayer times...',
              style: TextStyle(
                color: whiteText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget errorView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: Colors.white54,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage.isEmpty ? 'Unable to load data.' : errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: greyText, fontSize: 13),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: loadData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// PRAYER RING CUSTOM PAINTER WITH MULTI-STOP SWEEP GRADIENT
// ==========================================================

class PrayerRingPainter extends CustomPainter {
  final double progress;
  final double pulse;

  const PrayerRingPainter({required this.progress, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    const Color ringGreen = Color(0xFF00E676);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track Background
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.08);

    canvas.drawCircle(center, radius, basePaint);

    // Active Gradient Arc
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF00E676),
          Color(0xFF76FF03),
          Color(0xFF00E676),
        ],
      ).createShader(rect);

    canvas.drawArc(rect, -1.57, 6.28318 * progress, false, activePaint);

    // Pulsing Outer Glow
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = ringGreen.withValues(alpha: 0.10 + pulse * 0.14);
    canvas.drawCircle(center, radius + 5, glowPaint);
  }

  @override
  bool shouldRepaint(covariant PrayerRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulse != pulse;
  }
}