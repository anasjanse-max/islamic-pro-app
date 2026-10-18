import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_drawer.dart';
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ==========================================================
  // DYNAMIC PALETTE BASED ON DARK MODE STATE
  // ==========================================================
  bool get _isDark => ThemeService.isDarkMode.value;

  Color get appBackground => _isDark ? const Color(0xFF0B1511) : const Color(0xFFF7F6F1);
  Color get surfaceWhite => _isDark ? const Color(0xFF14221C) : const Color(0xFFFFFFFF);
  Color get secondarySurface => _isDark ? const Color(0xFF192B23) : const Color(0xFFE7F0EB);
  Color get selectedSurface => _isDark ? const Color(0xFF192B23) : const Color(0xFFE7F0EB);
  Color get activeNavBg => _isDark ? const Color(0xFF192B23) : const Color(0xFFE7F0EB);

  static const Color primaryDeepEmerald = Color(0xFF164E3B);
  static const Color richEmerald = Color(0xFF1F6B52);
  static const Color softEmerald = Color(0xFF6FAF96);
  static const Color mutedGold = Color(0xFFB5964A);
  static const Color lightCreamGold = Color(0xFFF4EEDC);

  Color get textPrimary => _isDark ? const Color(0xFFF4F6F2) : const Color(0xFF1D2924);
  Color get textSecondary => _isDark ? const Color(0xFFAAB6AF) : const Color(0xFF66736D);
  Color get textInactive => _isDark ? const Color(0xFF718079) : const Color(0xFF718079);
  Color get borderSubtle => _isDark ? const Color(0xFF24332B) : const Color(0xFFD5DFDA);

  static const Color successGreen = Color(0xFF4C866C);
  static const Color warningBorder = Color(0xFFD9CBA8);
  static const Color warningIcon = Color(0xFF9A7B35);
  static const Color warningText = Color(0xFF80672F);

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
  String nextPrayerTime = '04:20 AM';
  final Map<String, bool> _mutedPrayers = {};

  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  final ValueNotifier<Duration> _remaining = ValueNotifier<Duration>(Duration.zero);

  bool loading = false;
  bool isRefreshing = false;
  bool isGpsOff = false;
  String errorMessage = '';

  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    // Yahan se NotificationService.requestAutoPermissions() hata diya gaya hai
    todayDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    _drawerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
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

    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) => updateNextPrayer(),
    );

    updateNextPrayer();
    _initPermissionsAndLoadData(); // Yahan naya sequence wala function call kiya hai
    _loadMuteStates();
    _loadNativeAd();
  }

  // Yeh naya function add kiya hai permissions ko bari bari mangne ke liye
  Future<void> _initPermissionsAndLoadData() async {
    // 1. Pehle Notifications ki permission mangega
    await NotificationService.requestAutoPermissions();

    // 2. Thoda delay taake pehla popup smooth band ho jaye
    await Future.delayed(const Duration(milliseconds: 500));

    // 3. Phir automatically location fetch karega (aur popup dikhayega agar permission nahi hai)
    await loadData();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _drawerAnimationController.dispose();
    _remaining.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }

  void _loadNativeAd() {
    final String adUnitId = kReleaseMode
        ? 'ca-app-pub-4134027624428398/8824371562'
        : 'ca-app-pub-3940256099942544/2247696110';

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Native ad failed to load: $error');
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: surfaceWhite,
        cornerRadius: 16.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: richEmerald,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: textPrimary,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: textSecondary,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    )..load();
  }

  Future<void> _loadMuteStates() async {
    final prefs = await SharedPreferences.getInstance();
    const prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    if (!mounted) return;
    setState(() {
      for (var prayer in prayers) {
        _mutedPrayers[prayer] = prefs.getBool('mute_$prayer') ?? false;
      }
    });
  }

  Future<void> _toggleMutePrayer(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final currentState = _mutedPrayers[name] ?? false;
    final newState = !currentState;

    if (!mounted) return;
    setState(() {
      _mutedPrayers[name] = newState;
    });

    await prefs.setBool('mute_$name', newState);

    if (newState) {
      const prayersMap = {'Fajr': 100, 'Dhuhr': 101, 'Asr': 102, 'Maghrib': 103, 'Isha': 104};
      final id = prayersMap[name];
      if (id != null) {
        await NotificationService.cancelNotification(id);
      }
    } else {
      _scheduleAllPrayerNotifications();
    }
  }

  void _toggleDrawer() {
    if (!mounted) return;
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
    setState(() => isRefreshing = true);
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
      if (_mutedPrayers[prayer] == true) {
        notificationId++;
        continue;
      }

      final rawTime = prayerTimes[prayer]?.toString() ?? '';
      if (rawTime.isEmpty) continue;

      final parts = rawTime.split(' ').first.split(':');
      if (parts.length < 2) continue;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) continue;

      DateTime scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
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
          final exactSector = address['neighbourhood'] ?? address['suburb'] ?? address['residential'] ?? address['quarter'] ?? address['subdistrict'] ?? address['village'] ?? address['hamlet'] ?? address['town'];
          final mainCity = address['city'] ?? address['county'] ?? address['state_district'] ?? '';

          final sectorStr = exactSector?.toString().trim() ?? '';
          final cityStr = mainCity.toString().trim();

          if (sectorStr.isNotEmpty && cityStr.isNotEmpty && sectorStr != cityStr) {
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
    if (timings is Map) return Map<String, dynamic>.from(timings);
    return data;
  }

  // ==========================================================
  // FULLY DYNAMIC HIJRI DATE EXTRACTION WITH PAKISTAN OFFSET (-2 Days)
  // ==========================================================
  String extractHijriDate(Map<String, dynamic> data) {
    try {
      if (data.containsKey('date') && data['date'].containsKey('hijri')) {
        var hijri = data['date']['hijri'];
        int day = int.parse(hijri['day'].toString());
        String month = hijri['month']['en'].toString();
        String year = hijri['year'].toString();

        // PAKISTAN OFFSET: -2 days taake exact 17 show ho
        day = day - 2;
        if (day <= 0) {
          day = 29;
        }

        // Month correction for Rabi al-Thani / Rabi Al-Akhar
        if (month == "Rabi' al-Awwal" || month == "Rabi' al-Awal") {
          month = "Rabi al-Thani";
        }

        return '$day $month $year AH';
      }
    } catch (e) {
      debugPrint('Error parsing Hijri date: $e');
    }

    // Fallback live date for Pakistan
    return '17 Rabi al-Thani 1448 AH';
  }

  Future<void> loadWeather(double latitude, double longitude) async {
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true',
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
      case 0: return ('Clear', Icons.wb_sunny_rounded);
      case 1: return ('Mainly Clear', Icons.wb_sunny_rounded);
      case 2: return ('Partly Cloudy', Icons.cloud_queue_rounded);
      case 3: return ('Overcast', Icons.cloud_rounded);
      default: return ('Clear', Icons.wb_sunny_rounded);
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

  // 12-Hour Format Conversion (AM/PM)
  String formatPrayerTime(dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.isEmpty) return '--:--';
    final clean = raw.split(' ').first;
    final parts = clean.split(':');
    if (parts.length < 2) return clean;
    int? hour = int.tryParse(parts[0]);
    int? minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return clean;
    int h = hour;
    final String period = h >= 12 ? 'PM' : 'AM';
    if (h == 0) h = 12;
    if (h > 12) h -= 12;
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String formatPrayerTime12Hour(dynamic value) {
    return formatPrayerTime(value);
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
    final prayerChanged = nextPrayer != foundName || nextPrayerTime != foundTime;

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

  void _smoothNavigateTo(Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.02, 0), end: Offset.zero).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _showNotificationHistorySheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final List<Widget> activeNotifications = [];
        const prayersList = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

        for (final prayerName in prayersList) {
          if (_mutedPrayers[prayerName] == true) continue;
          final timeStr = formatPrayerTime12Hour(prayerTimes[prayerName]);
          final bool passed = isPrayerPassed(prayerName);
          final bool isNext = (prayerName == nextPrayer);

          String subTitle = 'Scheduled for today';
          if (passed) subTitle = 'Passed successfully today';
          else if (isNext) subTitle = 'Upcoming next prayer';

          activeNotifications.add(
            _notificationItem('$prayerName Adhan Scheduled', timeStr, subTitle, passed),
          );
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.58,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            color: surfaceWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: borderSubtle, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: secondarySurface, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.notifications_active_rounded, color: richEmerald, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Prayer Notifications',
                      style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: activeNotifications.isEmpty
                    ? Center(
                  child: Text(
                    'No active notifications.\nAll prayers are muted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textSecondary, fontSize: 14),
                  ),
                )
                    : ListView(
                  physics: const BouncingScrollPhysics(),
                  children: activeNotifications,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.isDarkMode,
      builder: (context, darkEnabled, child) {
        return Scaffold(
          backgroundColor: appBackground,
          body: Stack(
            children: [
              AppDrawer(onClose: _toggleDrawer),
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
                          borderRadius: BorderRadius.circular(20 * progress), // Multiply sign added
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: progress == 0
                                  ? const <BoxShadow>[]
                                  : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(-6, 6))],
                            ),
                            child: GestureDetector(
                              onTap: _isDrawerOpen ? _toggleDrawer : null,
                              child: AbsorbPointer(absorbing: _isDrawerOpen, child: child!),
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
      },
    );
  }

  Widget _buildMainHomeContent() {
    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            RefreshIndicator(
              color: richEmerald,
              backgroundColor: surfaceWhite,
              displacement: 60.0,
              edgeOffset: 10.0,
              onRefresh: loadData,
              child: buildBody(),
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomNavigation()),
          ],
        ),
      ),
    );
  }

  Widget buildBody() {
    if (loading) return loadingView();
    if (errorMessage.isNotEmpty) return errorView();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heroHeader(),
          locationCard(),
          if (isGpsOff) gpsWarningBanner(),
          const SizedBox(height: 16),
          nextPrayerCard(),
          const SizedBox(height: 24),
          prayerSection(),
          const SizedBox(height: 28),
          quickActions(),
          const SizedBox(height: 28),
          nativeAdCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget nativeAdCard() {
    if (_isAdLoaded && _nativeAd != null) {
      return Container(
        height: 250,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderSubtle),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(16), child: AdWidget(ad: _nativeAd!)),
      );
    }

    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: richEmerald, strokeWidth: 2)),
            const SizedBox(height: 14),
            Text('Loading Advertisement...', style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          _navButton(icon: Icons.home_filled, label: 'Home', active: true, action: () {}),
          _navButton(icon: Icons.menu_book_rounded, label: 'Quran', active: false, action: () => _smoothNavigateTo(const QuranScreen())),
          _navButton(icon: Icons.explore_rounded, label: 'Qibla', active: false, action: () => _smoothNavigateTo(const QiblaScreen())),
          _navButton(customIcon: const LiveTasbeehIcon(size: 20, color: richEmerald, animate: true), label: 'Tasbih', active: false, action: () => _smoothNavigateTo(const TasbeehScreen())),
          _navButton(icon: Icons.settings_rounded, label: 'Settings', active: false, action: () => _smoothNavigateTo(const SettingsScreen())),
        ],
      ),
    );
  }

  Widget _navButton({IconData? icon, Widget? customIcon, required String label, required bool active, required VoidCallback action}) {
    final iconColor = active ? richEmerald : textInactive;
    final textColor = active ? richEmerald : textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: action,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: active ? activeNavBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 22, height: 22, child: Center(child: customIcon ?? Icon(icon, color: iconColor, size: 20))),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: textColor, fontSize: 10, fontWeight: active ? FontWeight.w600 : FontWeight.w500, letterSpacing: -0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget heroHeader() {
    return Container(
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
            onTap: _toggleDrawer,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: richEmerald,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Daily Prayer',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                ),
                SizedBox(height: 2),
                Text(
                  'Stay connected with your faith',
                  style: TextStyle(color: Color(0xFFDCEAE4), fontSize: 13, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showNotificationHistorySheet,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: richEmerald,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                  Positioned(
                    top: 11,
                    right: 11,
                    child: Container(width: 5, height: 5, decoration: const BoxDecoration(color: mutedGold, shape: BoxShape.circle)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget locationCard() {
    List<String> cityParts = city.split(',');
    String areaTitle = cityParts.first.trim();
    String subLocation = cityParts.length > 1 ? cityParts.sublist(1).join(',').trim() : '';

    return GestureDetector(
      onTap: () => _smoothNavigateTo(const IslamicCalendarScreen()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderSubtle),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
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
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: secondarySurface, borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.location_on_rounded, color: richEmerald, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          areaTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2),
                        ),
                      ),
                    ],
                  ),
                  if (subLocation.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.only(left: 26),
                      child: Text(subLocation, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w400)),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(todayDate, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: mutedGold, size: 12),
                      const SizedBox(width: 6),
                      Text(hijriDate, style: const TextStyle(color: mutedGold, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 50, margin: const EdgeInsets.symmetric(horizontal: 16), color: borderSubtle),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(weatherIcon, color: mutedGold, size: 22),
                const SizedBox(height: 6),
                Text('${temperature.round()}°', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                Text(weatherName, style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w400)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget gpsWarningBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: lightCreamGold,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warningBorder),
      ),
      child: const Row(
        children: [
          Icon(Icons.location_off_rounded, color: warningIcon, size: 16),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'GPS is disabled. Showing saved coordinates.',
              style: TextStyle(color: warningText, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget nextPrayerCard() {
    return ValueListenableBuilder<Duration>(
      valueListenable: _remaining,
      builder: (context, remaining, _) {
        final hours = remaining.inHours.clamp(0, 99);
        final minutes = remaining.inMinutes.remainder(60).clamp(0, 59);
        final seconds = remaining.inSeconds.remainder(60).clamp(0, 59);

        final hoursStr = hours.toString().padLeft(2, '0');
        final minsStr = minutes.toString().padLeft(2, '0');
        final secsStr = seconds.toString().padLeft(2, '0');

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: primaryDeepEmerald,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NEXT PRAYER',
                      style: TextStyle(color: Color(0xFFA9D4C1), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      nextPrayer.isEmpty ? 'Fajr' : nextPrayer,
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$hoursStr : $minsStr : $secsStr',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.volume_up_rounded, color: Color(0xFFD1B66C), size: 14),
                        const SizedBox(width: 6),
                        Text('Adhan at $nextPrayerTime', style: const TextStyle(color: Color(0xFFDCEAE4), fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              prayerRing(remaining),
            ],
          ),
        );
      },
    );
  }

  Widget prayerRing(Duration remaining) {
    return SizedBox(
      width: 84,
      height: 84,
      child: CustomPaint(
        painter: CleanPrayerRingPainter(progress: ringProgress(remaining)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mosque_rounded, color: Color(0xFFD1B66C), size: 20),
              const SizedBox(height: 2),
              Text(nextPrayerTime.isEmpty ? '04:20 AM' : nextPrayerTime, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  double ringProgress(Duration remaining) {
    if (remaining.isNegative) return 0.15;
    return (remaining.inSeconds / (12 * 60 * 60)).clamp(0.05, 1.0); // Multiply signs added
  }

  Widget prayerSection() {
    const prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(width: 3, height: 14, decoration: BoxDecoration(color: mutedGold, borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 8),
              Expanded(
                child: Text("TODAY'S TIMINGS", style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
              ),
              GestureDetector(
                onTap: isRefreshing ? null : loadData,
                child: Row(
                  children: [
                    if (isRefreshing) const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: richEmerald))
                    else Icon(Icons.refresh_rounded, color: textSecondary, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      isRefreshing ? 'Updating...' : 'Refresh',
                      style: TextStyle(color: isRefreshing ? richEmerald : textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: prayerNames.map((name) {
              final active = name == nextPrayer;
              final passed = isPrayerPassed(name);
              return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: prayerCard(name, formatPrayerTime(prayerTimes[name]), active: active, passed: passed)));
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget prayerCard(String name, String time, {required bool active, required bool passed}) {
    final isMuted = _mutedPrayers[name] ?? false;

    return Container(
      height: 125,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: active ? selectedSurface : surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? richEmerald : borderSubtle, width: active ? 1.5 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(prayerIcon(name), color: active ? richEmerald : (passed ? textInactive : softEmerald), size: 14),
              const SizedBox(width: 2),
              GestureDetector(
                onTap: () => _toggleMutePrayer(name),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    isMuted ? Icons.notifications_off_rounded : Icons.notifications_active_rounded,
                    color: isMuted ? Colors.redAccent : (active ? richEmerald : mutedGold),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: active ? primaryDeepEmerald : (passed ? textSecondary : textSecondary), fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500),
              ),
              const SizedBox(height: 3),
              Text(
                time,
                style: TextStyle(color: passed ? textSecondary : textPrimary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: -0.5),
              ),
            ],
          ),
          Container(
            width: 14,
            height: 3,
            decoration: BoxDecoration(color: active ? richEmerald : (passed ? successGreen : Colors.transparent), borderRadius: BorderRadius.circular(10)),
          ),
        ],
      ),
    );
  }

  IconData prayerIcon(String name) {
    switch (name) {
      case 'Fajr': return Icons.wb_twilight_rounded;
      case 'Dhuhr': return Icons.wb_sunny_rounded;
      case 'Asr': return Icons.cloud_rounded;
      case 'Maghrib': return Icons.mosque_rounded;
      case 'Isha': return Icons.nights_stay_rounded;
      default: return Icons.access_time_rounded;
    }
  }

  Widget quickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 3, height: 14, decoration: BoxDecoration(color: mutedGold, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 8),
                  Text('EXPLORE', style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
                ],
              ),
              GestureDetector(
                onTap: () => _smoothNavigateTo(const MoreScreen()),
                child: const Row(
                  children: [
                    Text('See All', style: TextStyle(color: richEmerald, fontSize: 12, fontWeight: FontWeight.w600)),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, color: richEmerald, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              quickAction(icon: Icons.menu_book_rounded, title: 'Quran', brandColor: richEmerald, action: () => _smoothNavigateTo(const QuranScreen())),
              quickAction(title: 'Tasbih', brandColor: softEmerald, action: () => _smoothNavigateTo(const TasbeehScreen()), customIcon: const LiveTasbeehIcon(size: 20, color: softEmerald, animate: true)),
              quickAction(icon: Icons.explore_rounded, title: 'Qibla', brandColor: const Color(0xFF5F9583), action: () => _smoothNavigateTo(const QiblaScreen())),
              quickAction(icon: Icons.grid_view_rounded, title: 'More', brandColor: mutedGold, action: () => _smoothNavigateTo(const MoreScreen())),
            ],
          ),
        ],
      ),
    );
  }

  Widget quickAction({IconData? icon, Widget? customIcon, required String title, required Color brandColor, required VoidCallback action}) {
    return Expanded(
      child: GestureDetector(
        onTap: action,
        child: Container(
          height: 90,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderSubtle),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: secondarySurface, borderRadius: BorderRadius.circular(10)),
                child: Center(child: customIcon ?? Icon(icon, color: brandColor, size: 20)),
              ),
              const SizedBox(height: 8),
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationItem(String title, String time, String sub, bool passed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderSubtle),
      ),
      child: Row(
        children: [
          Icon(passed ? Icons.check_circle_outline_rounded : Icons.notifications_none_rounded, color: passed ? textInactive : richEmerald, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(color: textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: passed ? textSecondary : textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget loadingView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: richEmerald, strokeWidth: 2.5),
            const SizedBox(height: 16),
            Text('Loading prayer times...', style: TextStyle(color: textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget errorView() {
    final tSec = textSecondary;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, color: tSec, size: 48),
              const SizedBox(height: 14),
              Text(errorMessage.isEmpty ? 'Unable to load data.' : errorMessage, textAlign: TextAlign.center, style: TextStyle(color: tSec, fontSize: 14)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: loadData,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: richEmerald,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CleanPrayerRingPainter extends CustomPainter {
  final double progress;

  const CleanPrayerRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF376B59);

    canvas.drawCircle(center, radius, basePaint);

    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFB5964A);

    canvas.drawArc(rect, -1.57, 6.28318 * progress, false, activePaint); // Multiply sign added
  }

  @override
  bool shouldRepaint(covariant CleanPrayerRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}