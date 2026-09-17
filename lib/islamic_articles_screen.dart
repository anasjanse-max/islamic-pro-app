import 'package:flutter/material.dart';
import 'favorites_service.dart';
import 'more_screen.dart'; // Smooth navigation ke liye MoreScreen import kiya

class IslamicArticlesScreen extends StatefulWidget {
  const IslamicArticlesScreen({super.key});

  @override
  State<IslamicArticlesScreen> createState() => _IslamicArticlesScreenState();
}

class _IslamicArticlesScreenState extends State<IslamicArticlesScreen> {
  static const Color background = Color(0xFF000000);
  static const Color card = Color(0xFF0A0F0C);
  static const Color green = Color(0xFF26E17A);
  static const Color greenDark = Color(0xFF0C3323);
  static const Color gold = Color(0xFFE8B63D);
  static const Color whiteText = Color(0xFFF4F6F5);
  static const Color greyText = Color(0xFF98A19D);

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
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
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
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: whiteText, size: 16),
                      ),
                    ),
                    const Expanded(
                      child: Column(
                        children: [
                          Text('اسلامی مضامین', style: TextStyle(color: green, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                          SizedBox(height: 2),
                          Text('پڑھیں اور سیکھیں', style: TextStyle(color: whiteText, fontSize: 18, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 42), // Balance alignment
                  ],
                ),
              ),

              // Articles List (Optimized for Pro Smoothness)
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(), // Native smooth bounce
                  ),
                  cacheExtent: 2000, // Pre-loads content for zero lag
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                  children: [
                    _articleCategory(
                      '🕌 نماز (الصلوة)',
                      'اسلام کا ستون اور اللہ سے تعلق',
                      [
                        _articleItem('🕌 نماز (الصلوة)', 'نماز کی اہمیت', 'نماز اسلام کا دوسرا رکن ہے اور قیامت کے دن سب سے پہلا سوال نماز کا ہوگا۔'),
                        _articleItem('🕌 نماز (الصلوة)', 'نماز کے فرائض', 'نماز شروع کرنے سے پہلے اور اندر 13 فرائض ہیں (جیسے وضو، قیام، رکوع، سجدہ، وغیرہ)۔'),
                        _articleItem('🕌 نماز (الصلوة)', 'نماز میں عام غلطیاں', 'رکوع اور سجدہ میں جلدی کرنا، تکبیرِ تحریمہ صحیح ادا نہ کرنا۔'),
                        _articleItem('🕌 نماز (الصلوة)', 'خشوع کیسے حاصل کریں', 'نماز میں دھیان رکھنے کے لیے اللہ کی عظمت کو سمجھیں اور یہ سوچیں کہ ہم اللہ کے سامنے کھڑے ہیں۔'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _articleCategory(
                      '📖 قرآن کریم (القرآن الكريم)',
                      'پوری انسانیت کے لیے روشن ہدایت',
                      [
                        _articleItem('📖 قرآن کریم (القرآن الكريم)', 'قرآن کی فضیلت', 'قرآن پڑھنے پر ہر حرف پر نیکی ملتی ہے اور یہ دنیا و آخرت میں شفاعت کرے گا۔'),
                        _articleItem('📖 قرآن کریم (القرآن الكريم)', 'منتخب آیات کی تشریح', 'سورہ الفاتحہ اور آیت الكرسی کی آسان تفسیر جو دل کو سکون دیتی ہے۔'),
                        _articleItem('📖 قرآن کریم (القرآن الكريم)', 'قرآن سے ملنے والے اسباق', 'صبر، شکر، اور دوسروں کے ساتھ بھلائی کرنے کے خوبصورت پیغامات۔'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _articleCategory(
                      '🤲 دعائیں اور اذکار (دعاء وأذكار)',
                      'اللہ تعالیٰ کی یاد اور حفاظت',
                      [
                        _articleItem('🤲 دعائیں اور اذکار (دعاء وأذكار)', 'صبح اور شام کے اذکار', 'آیت الكرسی، تینوں قل اور مسنون دعائیں جو دن بھر کی حفاظت کا ذریعہ ہیں۔'),
                        _articleItem('🤲 دعائیں اور اذکار (دعاء وأذكار)', 'سونے کی دعا', '“بِسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا” (اے اللہ! میں تیرے ہی نام کے ساتھ مرتا اور جیتا ہوں)۔'),
                        _articleItem('🤲 دعائیں اور اذکار (دعاء وأذكار)', 'سفر کی دعا', '“سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا...” جو سفر کو باحفاظت بناتی ہے۔'),
                        _articleItem('🤲 دعائیں اور اذکار (دعاء وأذكار)', 'پریشانی کے وقت کی دعا', '“لا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ”۔'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _articleCategory(
                      '🌙 ماہِ رمضان المبارک (شهر رمضان)',
                      'برکتوں اور رحمتوں کا مہینہ',
                      [
                        _articleItem('🌙 ماہِ رمضان المبارک (شهر رمضان)', 'روزے کی اہمیت', 'روزہ صرف بھوکا رہنے کا نام نہیں بلکہ نفس پر قابو پانے اور تقویٰ حاصل کرنے کا ذریعہ ہے۔'),
                        _articleItem('🌙 ماہِ رمضان المبارک (شهر رمضان)', 'رمضان کے آداب', 'بری باتوں، جھوٹ اور غیبت سے بچنا اور زیادہ سے زیادہ قرآن کی تلاوت کرنا۔'),
                        _articleItem('🌙 ماہِ رمضان المبارک (شهر رمضان)', 'لیلۃ القدر', 'ہزار مہینوں سے بہتر رات، جس کی تلاش طاق راتوں میں کی جاتی ہے۔'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _articleCategory(
                      '❤️ اسلامی اخلاق و کردار (الأخلاق الإسلامية)',
                      'اپنے کردار کو سنواریں',
                      [
                        _articleItem('❤️ اسلامی اخلاق و کردار (الأخلاق الإسلامية)', 'صبر اور شکر', 'مصیبت پر صبر کرنا اور اللہ کی نعمتوں پر شکر ادا کرنا مومن کے دو بازو ہیں۔'),
                        _articleItem('❤️ اسلامی اخلاق و کردار (الأخلاق الإسلامية)', 'سچ بولنا', 'سچ ہمیشہ انسان کو نجات دیتا ہے اور جھوٹ سے رزق اور زندگی کی برکت ختم ہو جاتی ہے۔'),
                        _articleItem('❤️ اسلامی اخلاق و کردار (الأخلاق الإسلامية)', 'والدین کے ساتھ حسنِ سلوک', 'ماں باپ کی خدمت اور ان کے ساتھ نرمی سے پیش آنا جنت کا سب سے آسان راستہ ہے۔'),
                        _articleItem('❤️ اسلامی اخلاق و کردار (الأخلاق الإسلامية)', 'معاف کرنا اور اچھا اخلاق', 'دوسروں کی غلطیوں کو معاف کرنا اللہ تعالیٰ کو بے حد پسند ہے۔'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _articleCategory(
                      '📜 سیرت طیبہ اور اسلامی تاریخ (السيرة والتاريخ)',
                      'اسلام کا روشن ماضی',
                      [
                        _articleItem('📜 سیرت طیبہ اور اسلامی تاریخ (السيرة والتاريخ)', 'نبی کریم ﷺ کی سیرت', 'آپ ﷺ کی مبارک زندگی ہمارے لیے دنیا اور آخرت میں بہترین نمونہ ہے۔'),
                        _articleItem('📜 سیرت طیبہ اور اسلامی تاریخ (السيرة والتاريخ)', 'صحابہ کرام کے واقعات', 'حضرت ابو بکر، عمر، عثمان اور علی (رضوان اللہ علیہم) کی ایمانداری اور بہادری کے ایمان افروز واقعات۔'),
                        _articleItem('📜 سیرت طیبہ اور اسلامی تاریخ (السيرة والتاريخ)', 'اسلامی تاریخ کے اہم واقعات', 'غزوہ بدر، فتح مکہ اور میثاقِ مدینہ کے سنہری اسباق۔'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _articleCategory(
                      '⚖️ روزمرہ کی اسلامی رہنمائی (التوجيه اليومي)',
                      'زندگی گزارنے کے اصول',
                      [
                        _articleItem('⚖️ روزمرہ کی اسلامی رہنمائی (التوجيه اليومي)', 'حلال اور حرام کا تصور', 'حلال روزی کمانا فرض ہے اور حرام چیزوں اور طریقوں سے سختی سے بچنا ضروری ہے۔'),
                        _articleItem('⚖️ روزمرہ کی اسلامی رہنمائی (التوجيه اليومي)', 'پڑوسیوں کے حقوق', 'پڑوسی کا یہ حق ہے کہ اس کے ساتھ اچھا سلوک کیا جائے چاہے وہ کسی بھی مذہب کا ہو۔'),
                        _articleItem('⚖️ روزمرہ کی اسلامی رہنمائی (التوجيه اليومي)', 'وقت کی اہمیت', 'وقت ایک قیمتی نعمت ہے، اس کی قدر کریں کیونکہ گزرا ہوا وقت کبھی واپس نہیں آتا۔'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _articleCategory(String title, String subtitle, List<Widget> items) {
    return RepaintBoundary( // Optimizes GPU rendering for static list cards
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: gold, fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: greyText, fontSize: 11)),
            const SizedBox(height: 12),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _articleItem(String categoryTitle, String heading, String desc) {
    final String id = 'article_${categoryTitle}_$heading';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.brightness_1, color: green, size: 6),
              const SizedBox(width: 8),
              Expanded(
                child: Text(heading, style: const TextStyle(color: whiteText, fontSize: 13.5, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 6),
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
                        category: 'Article',
                        title: heading,
                        content: desc,
                        subtitle: categoryTitle,
                      );
                      setState(() {});
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(desc, style: const TextStyle(color: greyText, fontSize: 12, height: 1.4)),
          ),
        ],
      ),
    );
  }
}