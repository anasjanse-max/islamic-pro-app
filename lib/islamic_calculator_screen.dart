import 'package:flutter/material.dart';
import 'favorites_service.dart';
import 'more_screen.dart'; // Navigates smoothly back to More screen

class IslamicCalculatorScreen extends StatefulWidget {
  const IslamicCalculatorScreen({super.key});

  @override
  State<IslamicCalculatorScreen> createState() =>
      _IslamicCalculatorScreenState();
}

class _IslamicCalculatorScreenState extends State<IslamicCalculatorScreen> {
  static const Color background = Color(0xFF000000);
  static const Color card = Color(0xFF0A0F0C);
  static const Color card2 = Color(0xFF101613);

  static const Color green = Color(0xFF26E17A);
  static const Color greenDark = Color(0xFF0C3323);
  static const Color gold = Color(0xFFE8B63D);

  static const Color whiteText = Color(0xFFF4F6F5);
  static const Color greyText = Color(0xFF98A19D);

  final TextEditingController _wealthController = TextEditingController();
  double _zakatResult = 0.0;

  void _calculateZakat() {
    final double wealth = double.tryParse(_wealthController.text) ?? 0.0;
    setState(() {
      _zakatResult = wealth * 0.025; // 2.5% Zakat calculation formula
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
  void dispose() {
    _wealthController.dispose();
    super.dispose();
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
              _appBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(), // Native smooth scroll
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
  }

  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: _handleBack,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: whiteText, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Islamic Calculator',
              style: TextStyle(
                color: whiteText,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
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
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: greenDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: green, width: 1.2),
                ),
                child: const Icon(Icons.calculate_rounded, color: green, size: 24),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ZAKAT CALCULATOR',
                    style: TextStyle(
                      color: green,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.3,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Calculate 2.5% Zakat',
                    style: TextStyle(
                      color: whiteText,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
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
            style: const TextStyle(color: whiteText, fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Total Savings / Wealth Amount',
              labelStyle: const TextStyle(color: greyText, fontSize: 13),
              filled: true,
              fillColor: card2,
              prefixIcon: const Icon(Icons.monetization_on_rounded, color: gold),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _calculateZakat,
              child: const Text(
                'Calculate Zakat',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: gold.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'TOTAL ZAKAT DUE (2.5%)',
                      style: TextStyle(
                        color: gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
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
                            color: isFav ? Colors.redAccent : greyText,
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
                  style: const TextStyle(
                    color: whiteText,
                    fontSize: 26,
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

  Widget _infoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'زکوٰۃ کے بارے میں',
            style: TextStyle(
              color: whiteText,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'زکوٰۃ اسلام کے بنیادی ارکان میں سے ایک ہے۔ یہ ہر اس مسلمان پر فرض ہے جس کے پاس نصاب کی مقدار کے برابر مال موجود ہو کہ وہ سالانہ اپنے قابلِ زکوٰۃ مال کا 2.5 فیصد ادا کرے۔',
            style: TextStyle(color: greyText, fontSize: 13, height: 1.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}