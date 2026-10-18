import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui';

import 'favorites_service.dart';
import 'more_screen.dart';
import 'settings_screen.dart';

class DuaItem {
  final String title;
  final String category;
  final String arabic;
  final String translation;
  final String reference;

  const DuaItem({
    required this.title,
    required this.category,
    required this.arabic,
    required this.translation,
    required this.reference,
  });
}

class DuasScreen extends StatefulWidget {
  const DuasScreen({super.key});

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
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

  String selectedCategory = 'Sab';

  final List<String> categories = [
    'Sab',
    'صبح و شام',
    'استغفار و توبہ',
    'حفاظت و پناہ',
    'رزق',
    'نیند و خواب',
  ];

  final List<DuaItem> duasList = [
    const DuaItem(
      title: 'Sayed al-Istighfar',
      category: 'استغفار و توبہ',
      arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ',
      translation: 'اے اللہ! تو میرا رب ہے، تیرے سوا کوئی معبود نہیں، تو نے مجھے پیدا کیا اور میں تیرا بندہ ہوں۔۔۔',
      reference: 'صحیح بخاری',
    ),
    const DuaItem(
      title: 'Subah o Sham ki Dua',
      category: 'حفاظت و پناہ',
      arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ',
      translation: 'اللہ کے نام کے ساتھ جس کی برکت سے زمین اور آسمان کی کوئی چیز نقصان نہیں پہنچا سکتی۔',
      reference: 'ابو داود و ترمذی',
    ),
    const DuaItem(
      title: 'Subah o Sham ke Azkar',
      category: 'صبح و شام',
      arabic: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
      translation: 'میں لعنت شدہ شیطان سے اللہ کی پناہ مانگتا ہوں،',
      reference: 'صحیح مسلم',
    ),
    const DuaItem(
      title: 'Rizq mein Barkat ki Dua',
      category: 'رزق',
      arabic: 'اللَّهُمَّ بَارِكْ لَنَا فِي رِزْقِنَا',
      translation: 'اے اللہ! ہمارے رزق میں برکت عطا فرما۔',
      reference: 'سنن ابن ماجہ',
    ),
    const DuaItem(
      title: 'Nind se Bedar hone ki Dua',
      category: 'نیند و خواب',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      translation: 'تمام تعریفیں اس اللہ کے لیے ہیں جس نے ہمیں زندہ کیا بعد اس کے کہ اس نے ہمیں موت دی تھی، اور اسی کی طرف لوٹ کر جانا ہے۔',
      reference: 'صحیح بخاری',
    ),
    const DuaItem(
      title: 'Ghar se Nikalte waqt ki Dua',
      category: 'حفاظت و پناہ',
      arabic: 'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      translation: 'اللہ کے نام کے ساتھ، میں نے اللہ پر بھروسہ کیا، اور اللہ کی مدد کے بغیر نہ گناہوں سے بچنے کی طاقت ہے اور نہ نیکی کرنے کی قوت۔',
      reference: 'ابو داود و ترمذی',
    ),
    const DuaItem(
      title: 'Khana Khane ke Baad ki Dua',
      category: 'صبح و شام',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
      translation: 'تمام تعریفیں اس اللہ کے لیے ہیں جس نے ہمیں کھلایا اور پلایا اور ہمیں مسلمان بنایا۔',
      reference: 'سنن ترمذی',
    ),
    const DuaItem(
      title: 'Musibat ya Pareshani ki Dua',
      category: 'استغفار و توبہ',
      arabic: 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      translation: 'ترے سوا کوئی معبود نہیں، تو پاک ہے، بےشک میں ہی ظالموں میں سے تھا۔',
      reference: 'جامع ترمذی',
    ),
  ];

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
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.isDarkMode,
      builder: (context, darkEnabled, child) {
        final filteredDuas = selectedCategory == 'Sab'
            ? duasList
            : duasList.where((d) => d.category == selectedCategory).toList();

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
                  // Custom Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _handleBack,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: richEmerald, // Premium Action Color
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
                                'Masnoon Duain',
                                style: TextStyle(
                                  color: textPrimary, // Dark Charcoal
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ruhani Sukoon, Har Din Ke Liye',
                                style: TextStyle(color: textSecondary, fontSize: 12), // Secondary Text
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: surfaceWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderSubtle),
                          ),
                          child: const Icon(Icons.search_rounded, color: richEmerald, size: 20),
                        ),
                      ],
                    ),
                  ),

                  // Horizontal Category Filter Chips
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: richEmerald, // Emerald when active
                            backgroundColor: surfaceWhite, // Clean white when inactive
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: isSelected ? richEmerald : borderSubtle,
                              ),
                            ),
                            onSelected: (bool selected) {
                              setState(() {
                                selectedCategory = cat;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Duas List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: filteredDuas.length,
                      itemBuilder: (context, index) {
                        final dua = filteredDuas[index];
                        final String id = 'dua_${dua.title}';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surfaceWhite, // Clean White Cards
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderSubtle), // Thin borders
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04), // Very subtle shadow
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top row: Title & Category badge + Favorite
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      dua.title,
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: secondarySurface, // Very Light Sage
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: borderSubtle),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.auto_awesome_rounded, color: richEmerald, size: 12),
                                            const SizedBox(width: 4),
                                            ConstrainedBox(
                                              constraints: const BoxConstraints(maxWidth: 110),
                                              child: Text(
                                                dua.category,
                                                style: const TextStyle(
                                                  color: richEmerald,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
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
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              await FavoritesService.toggleFavorite(
                                                id: id,
                                                category: 'Dua',
                                                title: dua.title,
                                                content: '${dua.arabic}\n\n${dua.translation}',
                                                subtitle: dua.reference,
                                              );
                                              setState(() {});
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Arabic Text (Deep Emerald for rich Islamic feel) - Fixed alignment & textDirection
                              Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  dua.arabic,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    color: primaryDeepEmerald, // Strong readable Islamic Typography
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Translation (Urdu)
                              Text(
                                dua.translation,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 13,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Footer: Reference & Action Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      dua.reference,
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Copy Button
                                      GestureDetector(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: '${dua.arabic}\n\n${dua.translation}\n(${dua.reference})'));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              behavior: SnackBarBehavior.floating,
                                              backgroundColor: primaryDeepEmerald,
                                              content: Text('Dua copied to clipboard', style: TextStyle(color: Colors.white)),
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: secondarySurface,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: borderSubtle),
                                          ),
                                          child: const Icon(Icons.copy_rounded, color: richEmerald, size: 16),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Share Button
                                      GestureDetector(
                                        onTap: () {
                                          final shareText = '✨ *${dua.title}* ✨\n\n${dua.arabic}\n\n${dua.translation}\n\n📖 Reference: ${dua.reference}\n(Shared via Prayer Times App)';
                                          Share.share(shareText);
                                        },
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: secondarySurface,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: borderSubtle),
                                          ),
                                          child: const Icon(Icons.share_rounded, color: richEmerald, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
          ),
        );
      },
    );
  }
}