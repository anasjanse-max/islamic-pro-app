import 'package:flutter/material.dart';
import 'favorites_service.dart';
import 'more_screen.dart'; // Smooth navigation ke liye MoreScreen import kiya
import 'settings_screen.dart';

class IslamicCalculatorScreen extends StatefulWidget {
  const IslamicCalculatorScreen({super.key});

  @override
  State<IslamicCalculatorScreen> createState() =>
      _IslamicCalculatorScreenState();
}

class _IslamicCalculatorScreenState extends State<IslamicCalculatorScreen> {
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

  final TextEditingController _wealthController = TextEditingController();
  double _zakatResult = 0.0;

  void _calculateZakat() {
    final double wealth = double.tryParse(_wealthController.text) ?? 0.0;
    setState(() {
      _zakatResult = wealth * 0.025; // 2.5% Zakat calculation formula
    });
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
  void dispose() {
    _wealthController.dispose();
    super.dispose();
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
            backgroundColor: appBackground, // Applied Dynamic Background
            body: SafeArea(
              child: Column(
                children: [
                  _appBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(), // Native smooth scroll
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _zakatCard(),
                          const SizedBox(height: 20),
                          _infoSection(),
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

  Widget _appBar() {
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
                color: richEmerald, // Premium Action Button
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: richEmerald),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Islamic Calculator',
                  style: TextStyle(
                    color: textPrimary, // Dynamic Heading
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Calculate your annual Zakat due',
                  style: TextStyle(color: textSecondary, fontSize: 12), // Secondary Text
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _zakatCard() {
    const String id = 'zakat_calc_result';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceWhite, // Clean Dynamic Cards
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Very subtle soft shadow
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: secondarySurface, // Very Light Sage / Dark Surface
                  shape: BoxShape.circle,
                  border: Border.all(color: borderSubtle),
                ),
                child: const Icon(Icons.calculate_rounded, color: richEmerald, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ZAKAT CALCULATOR',
                    style: TextStyle(
                      color: richEmerald,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Calculate 2.5% Zakat',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _wealthController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: textPrimary, fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Total Savings / Wealth Amount',
              labelStyle: TextStyle(color: textSecondary, fontSize: 13),
              filled: true,
              fillColor: secondarySurface,
              prefixIcon: const Icon(Icons.monetization_on_rounded, color: mutedGold, size: 20),
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: richEmerald,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _calculateZakat,
              child: const Text(
                'Calculate Zakat',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: secondarySurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderSubtle),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'TOTAL ZAKAT DUE (2.5%)',
                      style: TextStyle(
                        color: richEmerald,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
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
                              category: 'Calculator',
                              title: 'Zakat Calculation',
                              content: 'Total Wealth: ${_wealthController.text.isEmpty ? "0" : _wealthController.text}\nCalculated Zakat Due: $_zakatResult',
                              subtitle: '2.5% Rate Calculation',
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
                  '$_zakatResult',
                  style: TextStyle(
                    color: _isDark ? softEmerald : primaryDeepEmerald,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceWhite, // Clean Dynamic Card
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
          Text(
            'زکوٰۃ کے بارے میں',
            style: TextStyle(
              color: textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'زکوٰۃ اسلام کے بنیادی ارکان میں سے ایک ہے۔ یہ ہر اس مسلمان پر فرض ہے جس کے پاس نصاب کی مقدار کے برابر مال موجود ہو کہ وہ سالانہ اپنے قابلِ زکوٰۃ مال کا 2.5 فیصد ادا کرے۔',
            style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}