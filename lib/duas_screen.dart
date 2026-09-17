import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui';

import 'more_screen.dart';

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
  static const Color background = Color(0xFF000000);
  static const Color cardBg = Color(0xFF0A0F0C);
  static const Color green = Color(0xFF26E17A);
  static const Color greenDark = Color(0xFF0C3323);
  static const Color gold = Color(0xFFE8B63D);
  static const Color whiteText = Color(0xFFF4F6F5);
  static const Color greyText = Color(0xFF98A19D);
  static const Color borderColor = Color(0xFF1A221D);

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
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => const MoreScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: background,
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
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: whiteText, size: 15),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Masnoon Duain',
                            style: TextStyle(
                              color: whiteText,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            'Ruhani Sukoon, Har Din Ke Liye',
                            style: TextStyle(color: greyText, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: const Icon(Icons.search_rounded, color: whiteText, size: 18),
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
                        selectedColor: green,
                        backgroundColor: cardBg,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : whiteText,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected ? green : borderColor,
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

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: borderColor, width: 1.2),
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
                                  style: const TextStyle(
                                    color: whiteText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
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
                                      color: greenDark,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.auto_awesome_rounded, color: green, size: 12),
                                        const SizedBox(width: 4),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 110),
                                          child: Text(
                                            dua.category,
                                            style: const TextStyle(
                                              color: green,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.favorite_border_rounded, color: greyText, size: 20),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Arabic Text (Gold) - Fixed alignment & textDirection
                          Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              dua.arabic,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                color: gold,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Translation (Urdu)
                          Text(
                            dua.translation,
                            style: const TextStyle(
                              color: greyText,
                              fontSize: 13,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
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
                                  style: const TextStyle(
                                    color: green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
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
                                          content: Text('Dua copied to clipboard'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF141C18),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.copy_rounded, color: greyText, size: 16),
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
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF141C18),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.share_rounded, color: green, size: 16),
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
  }
}