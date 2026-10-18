import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import 'home_screen.dart';
import 'live_tasbeeh_icon.dart';
import 'quran_screen.dart';
import 'settings_screen.dart';
import 'tasbeeh_screen.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with SingleTickerProviderStateMixin {
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

  static const double _kaabaLatitude = 21.422487;
  static const double _kaabaLongitude = 39.826206;

  // ==========================================================
  // STATE VARIABLES
  // ==========================================================
  StreamSubscription<CompassEvent>? _compassSubscription;

  double _heading = 0;
  double _qiblaBearing = 0;
  bool _loadingLocation = true;
  String? _errorMessage;

  // ==========================================================
  // INITIALIZATION & LIFECYCLE
  // ==========================================================
  @override
  void initState() {
    super.initState();
    _startCompass();
    _loadLocation();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  // ==========================================================
  // CORE LOGIC & SENSORS (Preserved 100%)
  // ==========================================================
  void _startCompass() {
    final Stream<CompassEvent>? stream = FlutterCompass.events;
    if (stream == null) return;

    _compassSubscription = stream.listen((event) {
      final double? value = event.heading;
      if (value == null || !mounted) return;

      final double newHeading = _normalize360(value);
      final double difference = _shortestAngle(newHeading - _heading);
      final double smoothed = _normalize360(_heading + difference * 0.22);

      setState(() => _heading = smoothed);
    });
  }

  Future<void> _loadLocation() async {
    if (mounted) {
      setState(() {
        _loadingLocation = true;
        _errorMessage = null;
      });
    }

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _loadingLocation = false;
          _errorMessage = 'Location service disabled.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _loadingLocation = false;
          _errorMessage = 'Location permission denied.';
        });
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final double bearing = _calculateQiblaBearing(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() {
        _qiblaBearing = bearing;
        _loadingLocation = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingLocation = false;
        _errorMessage = 'Unable to detect location.';
      });
    }
  }

  double _calculateQiblaBearing(double latitude, double longitude) {
    final double lat1 = _toRadians(latitude);
    final double lon1 = _toRadians(longitude);
    final double lat2 = _toRadians(_kaabaLatitude);
    final double lon2 = _toRadians(_kaabaLongitude);

    final double deltaLon = lon2 - lon1;
    final double y = math.sin(deltaLon) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLon);

    return _normalize360(math.atan2(y, x) * 180 / math.pi);
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
  double _normalize360(double value) => (value % 360 + 360) % 360;

  double _shortestAngle(double value) {
    double res = value % 360;
    if (res > 180) res -= 360;
    if (res < -180) res += 360;
    return res;
  }

  double get _relativeQibla => _shortestAngle(_qiblaBearing - _heading);
  double get _turnAmount => _relativeQibla.abs();
  bool get _isAligned => _turnAmount <= 5;

  String get _turnTitle {
    if (_loadingLocation) return 'Finding Qibla direction';
    if (_isAligned) return 'You are facing Qibla';
    return _relativeQibla > 0 ? 'Turn right to Qibla' : 'Turn left to Qibla';
  }

  String get _turnSubtitle {
    if (_loadingLocation) return 'Detecting location...';
    if (_isAligned) return 'Aligned with Kaaba';
    return '${_turnAmount.round()}° ${_relativeQibla > 0 ? 'right' : 'left'} to Qibla';
  }

  String _directionFromDegrees(double degrees) {
    const List<String> directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return directions[((degrees + 22.5) / 45).floor() % 8];
  }

  // ==========================================================
  // NAVIGATION & UI HELPERS
  // ==========================================================
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

  // ==========================================================
  // WIDGET BUILDERS
  // ==========================================================
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
                      _appBar(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 2, 16, 80),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _qiblaBearingCard(),
                              _compassCard(),
                              if (_errorMessage != null)
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 11,
                                  ),
                                ),
                              _turnCard(),
                              _infoRow(),
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

  // ==========================================================
  // EXECUTIVE HEADER (Deep Emerald Theme)
  // ==========================================================
  Widget _appBar() {
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
                  'Qibla Direction',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Find Kaaba',
                  style: TextStyle(
                    color: Color(0xFFDCEAE4),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadLocation,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: richEmerald,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // QIBLA BEARING CARD
  // ==========================================================
  Widget _qiblaBearingCard() {
    return Container(
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: secondarySurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderSubtle),
            ),
            child: const Icon(Icons.mosque_rounded, color: richEmerald, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'QIBLA BEARING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: mutedGold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_qiblaBearing.toStringAsFixed(1)}° ${_directionFromDegrees(_qiblaBearing)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: secondarySurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderSubtle),
            ),
            child: const Icon(Icons.navigation_rounded, color: richEmerald, size: 20),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // COMPASS CARD
  // ==========================================================
  Widget _compassCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
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
        children: [
          const Text(
            'LIVE QIBLA COMPASS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: richEmerald,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Rotate your device to find direction',
            style: TextStyle(
              fontSize: 12,
              color: textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          _compass(),
        ],
      ),
    );
  }

  Widget _compass() {
    const double size = 190;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -_toRadians(_heading),
            child: CustomPaint(
              size: const Size(size, size),
              painter: _CleanCompassPainter(isDark: _isDark),
            ),
          ),
          Transform.rotate(
            angle: _toRadians(_qiblaBearing - _heading),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: richEmerald,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: secondarySurface,
              border: Border.all(color: richEmerald, width: 1.5),
            ),
            child: const Icon(Icons.explore_rounded, color: richEmerald, size: 22),
          ),
          const Positioned(
            top: 2,
            child: Icon(Icons.navigation_rounded, color: richEmerald, size: 18),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TURN DIRECTION STATUS CARD
  // ==========================================================
  Widget _turnCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isAligned ? richEmerald : borderSubtle,
          width: _isAligned ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: secondarySurface,
              border: Border.all(color: _isAligned ? richEmerald : borderSubtle),
            ),
            child: Icon(
              _isAligned ? Icons.check_rounded : Icons.navigation_rounded,
              color: _isAligned ? richEmerald : textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _turnTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _turnSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
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
  // METRICS CARDS
  // ==========================================================
  Widget _infoRow() {
    return Row(
      children: [
        Expanded(
          child: _colorfulInfoCard(
            icon: Icons.mosque_rounded,
            value: '${_qiblaBearing.round()}°',
            label: 'Qibla',
            accentColor: mutedGold,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _colorfulInfoCard(
            icon: Icons.explore_rounded,
            value: '${_heading.round()}°',
            label: 'Heading',
            accentColor: richEmerald,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _colorfulInfoCard(
            icon: Icons.turn_right_rounded,
            value: '${_turnAmount.round()}°',
            label: 'Turn',
            accentColor: softEmerald,
          ),
        ),
      ],
    );
  }

  Widget _colorfulInfoCard({
    required IconData icon,
    required String value,
    required String label,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderSubtle),
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FLOATING FROSTED DOCK NAVIGATION BAR
  // ==========================================================
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
            active: true,
            action: () {},
          ),
          _navButton(
            // Yahan par animated aur colorful icon set kar diya gaya hai
            customIcon: const LiveTasbeehIcon(
              size: 20,
              color: richEmerald,
              animate: true,
            ),
            label: 'Tasbih',
            active: false,
            action: () => _navigateToScreen(const TasbeehScreen()),
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
}

// ==========================================================
// CLEAN COMPASS PAINTER
// ==========================================================
class _CleanCompassPainter extends CustomPainter {
  final bool isDark;
  _CleanCompassPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 4;

    final Paint outerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = isDark ? const Color(0xFF24332B) : const Color(0xFFD5DFDA);

    canvas.drawCircle(center, radius, outerRing);

    final Paint tickPaint = Paint()..strokeCap = StrokeCap.round;

    for (int degree = 0; degree < 360; degree += 6) {
      final double angle = (degree - 90) * math.pi / 180;
      final bool major = degree % 30 == 0;

      final double outer = radius - 4;
      final double inner = major ? radius - 16 : radius - 10;

      final Offset start = Offset(
        center.dx + inner * math.cos(angle),
        center.dy + inner * math.sin(angle),
      );
      final Offset end = Offset(
        center.dx + outer * math.cos(angle),
        center.dy + outer * math.sin(angle),
      );

      tickPaint
        ..strokeWidth = major ? 2.0 : 1.0
        ..color = major
            ? const Color(0xFF1F6B52).withValues(alpha: 0.8)
            : (isDark ? const Color(0xFF24332B) : const Color(0xFFD5DFDA));

      canvas.drawLine(start, end, tickPaint);
    }

    _drawText(canvas, center, radius - 26, 'N', const Color(0xFFB5964A), 14, 0);
    _drawText(canvas, center, radius - 26, 'E', isDark ? const Color(0xFFF4F6F2) : const Color(0xFF1D2924), 12, 90);
    _drawText(canvas, center, radius - 26, 'S', isDark ? const Color(0xFFF4F6F2) : const Color(0xFF1D2924), 12, 180);
    _drawText(canvas, center, radius - 26, 'W', isDark ? const Color(0xFFF4F6F2) : const Color(0xFF1D2924), 12, 270);
  }

  void _drawText(
      Canvas canvas,
      Offset center,
      double radius,
      String label,
      Color color,
      double fontSize,
      double degrees,
      ) {
    final double angle = (degrees - 90) * math.pi / 180;
    final Offset position = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout();
    painter.paint(
      canvas,
      Offset(position.dx - painter.width / 2, position.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _CleanCompassPainter oldDelegate) => oldDelegate.isDark != isDark;
}