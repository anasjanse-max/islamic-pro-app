import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import 'home_screen.dart';
import 'quran_screen.dart';
import 'settings_screen.dart';
import 'tasbeeh_screen.dart';
import 'live_tasbeeh_icon.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  static const Color background = Color(0xFF000000);
  static const Color card = Color(0xFF0A0F0C);
  static const Color card2 = Color(0xFF0D1612);
  static const Color green = Color(0xFF26E17A);
  static const Color greenDark = Color(0xFF0C3323);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldAccent = Color(0xFFE5B53B);
  static const Color whiteText = Color(0xFFF4F6F5);
  static const Color greyText = Color(0xFF98A19D);

  static const double _kaabaLatitude = 21.422487;
  static const double _kaabaLongitude = 39.826206;

  StreamSubscription<CompassEvent>? _compassSubscription;

  double _heading = 0;
  double _qiblaBearing = 0;
  bool _loadingLocation = true;
  String? _errorMessage;

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
    if (mounted) setState(() { _loadingLocation = true; _errorMessage = null; });

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() { _loadingLocation = false; _errorMessage = 'Location service disabled.'; });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() { _loadingLocation = false; _errorMessage = 'Location permission denied.'; });
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      final double bearing = _calculateQiblaBearing(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() { _qiblaBearing = bearing; _loadingLocation = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loadingLocation = false; _errorMessage = 'Unable to detect location.'; });
    }
  }

  double _calculateQiblaBearing(double latitude, double longitude) {
    final double lat1 = _toRadians(latitude);
    final double lon1 = _toRadians(longitude);
    final double lat2 = _toRadians(_kaabaLatitude);
    final double lon2 = _toRadians(_kaabaLongitude);

    final double deltaLon = lon2 - lon1;
    final double y = math.sin(deltaLon) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(deltaLon);

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
                            Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
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
  }

  // ==========================================================
  // EXECUTIVE HEADER
  // ==========================================================

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: _handleBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 15),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [green.withValues(alpha: 0.25), card2],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: green.withValues(alpha: 0.6), width: 1.2),
            ),
            child: const Icon(Icons.explore_rounded, color: green, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'QIBLA DIRECTION',
                      style: TextStyle(
                        color: goldAccent,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(width: 4, height: 4, decoration: const BoxDecoration(color: green, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 1),
                const Text(
                  'Find Kaaba',
                  style: TextStyle(
                    color: whiteText,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
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
                color: card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: green.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.refresh_rounded, color: green, size: 18),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F1813), Color(0xFF09100C)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: green.withValues(alpha: 0.35), width: 1.1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: greenDark,
              border: Border.all(color: green, width: 1.1),
            ),
            child: const Icon(Icons.mosque_rounded, color: green, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'QIBLA BEARING',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: green),
                ),
                const SizedBox(height: 1),
                Text(
                  '${_qiblaBearing.toStringAsFixed(1)}° ${_directionFromDegrees(_qiblaBearing)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: whiteText),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: greenDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: green.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.navigation_rounded, color: green, size: 18),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PERFECTLY FIT COMPASS CARD (NO SCROLL NEEDED)
  // ==========================================================

  Widget _compassCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F1813), Color(0xFF09100C)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09), width: 1.1),
      ),
      child: Column(
        children: [
          const Text(
            'LIVE QIBLA COMPASS',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 1.3, color: green),
          ),
          const SizedBox(height: 2),
          const Text(
            'Rotate your device to find direction',
            style: TextStyle(fontSize: 10.5, color: greyText, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _compass(),
        ],
      ),
    );
  }

  Widget _compass() {
    const double size = 210; // Optimized size to fit screen perfectly

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
              painter: _DarkCompassPainter(),
            ),
          ),
          Transform.rotate(
            angle: _toRadians(_qiblaBearing - _heading),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: green,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(color: green.withValues(alpha: 0.5), blurRadius: 8),
                    ],
                  ),
                  child: const Icon(Icons.mosque_rounded, color: Colors.black, size: 14),
                ),
              ),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF040806),
              border: Border.all(color: green, width: 1.5),
            ),
            child: const Icon(Icons.explore_rounded, color: green, size: 24),
          ),
          const Positioned(
            top: 4,
            child: Icon(Icons.navigation_rounded, color: green, size: 18),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F1813), Color(0xFF09100C)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isAligned ? green.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.09),
          width: 1.1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isAligned ? green : greenDark,
            ),
            child: Icon(
              _isAligned ? Icons.check_rounded : Icons.navigation_rounded,
              color: _isAligned ? Colors.black : green,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _turnTitle,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: whiteText),
                ),
                const SizedBox(height: 1),
                Text(
                  _turnSubtitle,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: greyText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // COLORFUL METRICS CARDS
  // ==========================================================

  Widget _infoRow() {
    return Row(
      children: [
        Expanded(
          child: _colorfulInfoCard(
            icon: Icons.mosque_rounded,
            value: '${_qiblaBearing.round()}°',
            label: 'Qibla',
            startColor: const Color(0xFF261A05),
            endColor: const Color(0xFF140D02),
            accentColor: gold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _colorfulInfoCard(
            icon: Icons.explore_rounded,
            value: '${_heading.round()}°',
            label: 'Heading',
            startColor: const Color(0xFF051C12),
            endColor: const Color(0xFF030D08),
            accentColor: green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _colorfulInfoCard(
            icon: Icons.turn_right_rounded,
            value: '${_turnAmount.round()}°',
            label: 'Turn',
            startColor: const Color(0xFF0D1626),
            endColor: const Color(0xFF060B12),
            accentColor: Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  Widget _colorfulInfoCard({
    required IconData icon,
    required String value,
    required String label,
    required Color startColor,
    required Color endColor,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.1),
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: whiteText),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: accentColor),
          ),
        ],
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
                active: true,
                action: () {},
              ),
              _navButton(
                customIcon: const LiveTasbeehIcon(
                  size: 23,
                  color: Color(0xFFB0BEC5),
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
}

class _DarkCompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 4;

    final Paint outerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = const Color(0xFF26E17A).withOpacity(0.6);

    canvas.drawCircle(center, radius, outerRing);

    final Paint tickPaint = Paint()..strokeCap = StrokeCap.round;

    for (int degree = 0; degree < 360; degree += 6) {
      final double angle = (degree - 90) * math.pi / 180;
      final bool major = degree % 30 == 0;

      final double outer = radius - 4;
      final double inner = major ? radius - 16 : radius - 10;

      final Offset start = Offset(center.dx + inner * math.cos(angle), center.dy + inner * math.sin(angle));
      final Offset end = Offset(center.dx + outer * math.cos(angle), center.dy + outer * math.sin(angle));

      tickPaint
        ..strokeWidth = major ? 2.0 : 1.0
        ..color = major ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.3);

      canvas.drawLine(start, end, tickPaint);
    }

    _drawText(canvas, center, radius - 28, 'N', Colors.redAccent, 15, 0);
    _drawText(canvas, center, radius - 28, 'E', Colors.white, 13, 90);
    _drawText(canvas, center, radius - 28, 'S', Colors.white, 13, 180);
    _drawText(canvas, center, radius - 28, 'W', Colors.white, 13, 270);
  }

  void _drawText(Canvas canvas, Offset center, double radius, String label, Color color, double fontSize, double degrees) {
    final double angle = (degrees - 90) * math.pi / 180;
    final Offset position = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));

    final TextPainter painter = TextPainter(
      text: TextSpan(text: label, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    );

    painter.layout();
    painter.paint(canvas, Offset(position.dx - painter.width / 2, position.dy - painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}