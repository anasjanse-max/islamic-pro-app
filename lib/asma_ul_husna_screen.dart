import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import 'favorites_service.dart';
import 'more_screen.dart'; // Navigates smoothly back to More screen
import 'settings_screen.dart';

class AsmaItem {
  final int number;
  final String arabic;
  final String transliteration;
  final String urduMeaning;

  const AsmaItem({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.urduMeaning,
  });
}

class AsmaUlHusnaScreen extends StatefulWidget {
  const AsmaUlHusnaScreen({super.key});

  @override
  State<AsmaUlHusnaScreen> createState() => _AsmaUlHusnaScreenState();
}

class _AsmaUlHusnaScreenState extends State<AsmaUlHusnaScreen> {
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

  final List<AsmaItem> _names = const [
    AsmaItem(number: 1, arabic: 'الرَّحْمَنُ', transliteration: 'Ar-Rahman', urduMeaning: 'بڑا مہربان'),
    AsmaItem(number: 2, arabic: 'الرَّحِيمُ', transliteration: 'Ar-Rahim', urduMeaning: 'نہایت رحم کرنے والا'),
    AsmaItem(number: 3, arabic: 'الْمَلِكُ', transliteration: 'Al-Malik', urduMeaning: 'ساری کائنات کا بادشاہ'),
    AsmaItem(number: 4, arabic: 'الْقُدُّوسُ', transliteration: 'Al-Quddus', urduMeaning: 'ہر عیب سے پاک'),
    AsmaItem(number: 5, arabic: 'السَّلَامُ', transliteration: 'As-Salam', urduMeaning: 'سلامتی اور امن دینے والا'),
    AsmaItem(number: 6, arabic: 'الْمُؤْمِنُ', transliteration: 'Al-Mu’min', urduMeaning: 'امن اور امان دینے والا'),
    AsmaItem(number: 7, arabic: 'الْمُهَيْمِنُ', transliteration: 'Al-Muhaymin', urduMeaning: 'نگہبان اور محافظ'),
    AsmaItem(number: 8, arabic: 'الْعَزِيزُ', transliteration: 'Al-Aziz', urduMeaning: 'زبردست اور غالب'),
    AsmaItem(number: 9, arabic: 'الْجَبَّارُ', transliteration: 'Al-Jabbar', urduMeaning: 'اپنے ارادے کو نافذ کرنے والا'),
    AsmaItem(number: 10, arabic: 'الْمُتَكَبِّرُ', transliteration: 'Al-Mutakabbir', urduMeaning: 'بڑائی اور عظمت والا'),
    AsmaItem(number: 11, arabic: 'الْخَالِقُ', transliteration: 'Al-Khaliq', urduMeaning: 'پیدا کرنے والا'),
    AsmaItem(number: 12, arabic: 'الْبَارِئُ', transliteration: 'Al-Bari’', urduMeaning: 'درست بنانے والا'),
    AsmaItem(number: 13, arabic: 'الْمُصَوِّرُ', transliteration: 'Al-Musawwir', urduMeaning: 'صورت گری کرنے والا'),
    AsmaItem(number: 14, arabic: 'الْغَفَّارُ', transliteration: 'Al-Ghaffar', urduMeaning: 'بہت زیادہ بخشنے والا'),
    AsmaItem(number: 15, arabic: 'الْقَهَّارُ', transliteration: 'Al-Qahhar', urduMeaning: 'سب پر غالب'),
    AsmaItem(number: 16, arabic: 'الْوَهَّابُ', transliteration: 'Al-Wahhab', urduMeaning: 'بہت زیادہ عطا کرنے والا'),
    AsmaItem(number: 17, arabic: 'الرَّزَّاقُ', transliteration: 'Ar-Razzaq', urduMeaning: 'روزی دینے والا'),
    AsmaItem(number: 18, arabic: 'الْفَتَّاحُ', transliteration: 'Al-Fattah', urduMeaning: 'مشکلات کھولنے والا'),
    AsmaItem(number: 19, arabic: 'الْعَلِيمُ', transliteration: 'Al-Alim', urduMeaning: 'سب کچھ جاننے والا'),
    AsmaItem(number: 20, arabic: 'الْقَابِضُ', transliteration: 'Al-Qabid', urduMeaning: 'روزی تنگ کرنے والا (حکمت سے)'),
    AsmaItem(number: 21, arabic: 'الْبَاسِطُ', transliteration: 'Al-Basit', urduMeaning: 'روزی کشادہ کرنے والا'),
    AsmaItem(number: 22, arabic: 'الْخَافِضُ', transliteration: 'Al-Khafid', urduMeaning: 'پست کرنے والا'),
    AsmaItem(number: 23, arabic: 'الرَّافِعُ', transliteration: 'Ar-Rafi’', urduMeaning: 'بلند کرنے والا'),
    AsmaItem(number: 24, arabic: 'الْمُعِزُّ', transliteration: 'Al-Mu’izz', urduMeaning: 'عزت دینے والا'),
    AsmaItem(number: 25, arabic: 'الْمُذِلُّ', transliteration: 'Al-Mudhill', urduMeaning: 'ذلیل کرنے والا'),
    AsmaItem(number: 26, arabic: 'السَّمِيعُ', transliteration: 'As-Sami’', urduMeaning: 'سب کچھ سننے والا'),
    AsmaItem(number: 27, arabic: 'الْبَصِيرُ', transliteration: 'Al-Basir', urduMeaning: 'سب کچھ دیکھنے والا'),
    AsmaItem(number: 28, arabic: 'الْحَكَمُ', transliteration: 'Al-Hakam', urduMeaning: 'حاکم اور فیصلہ کرنے والا'),
    AsmaItem(number: 29, arabic: 'الْعَدْلُ', transliteration: 'Al-Adl', urduMeaning: 'بالکل انصاف کرنے والا'),
    AsmaItem(number: 30, arabic: 'اللَّطِيفُ', transliteration: 'Al-Latif', urduMeaning: 'لطف و کرم کرنے والا'),
    AsmaItem(number: 31, arabic: 'الْخَبِيرُ', transliteration: 'Al-Khabir', urduMeaning: 'ہر چیز کی خبر رکھنے والا'),
    AsmaItem(number: 32, arabic: 'الْحَلِيمُ', transliteration: 'Al-Halim', urduMeaning: 'بہت بردبار اور تحمل والا'),
    AsmaItem(number: 33, arabic: 'الْعَظِيمُ', transliteration: 'Al-Azim', urduMeaning: 'بہت عظمت والا'),
    AsmaItem(number: 34, arabic: 'الْغَفُورُ', transliteration: 'Al-Ghafur', urduMeaning: 'بڑا بخشنے والا'),
    AsmaItem(number: 35, arabic: 'الشَّكُورُ', transliteration: 'Ash-Shakur', urduMeaning: 'قدردان اور شکر قبول کرنے والا'),
    AsmaItem(number: 36, arabic: 'الْعَلِيُّ', transliteration: 'Al-Aliyy', urduMeaning: 'سب سے بلند'),
    AsmaItem(number: 37, arabic: 'الْكَبِيرُ', transliteration: 'Al-Kabir', urduMeaning: 'سب سے بڑا'),
    AsmaItem(number: 38, arabic: 'الْحَفِيظُ', transliteration: 'Al-Hafiz', urduMeaning: 'حفاظت کرنے والا'),
    AsmaItem(number: 39, arabic: 'الْمُقِيتُ', transliteration: 'Al-Muqit', urduMeaning: 'قوت اور خوراک دینے والا'),
    AsmaItem(number: 40, arabic: 'الْحَسِيبُ', transliteration: 'Al-Hasib', urduMeaning: 'حساب لینے کے لیے کافی'),
    AsmaItem(number: 41, arabic: 'الْجَلِيلُ', transliteration: 'Al-Jalil', urduMeaning: 'شان و شوکت والا'),
    AsmaItem(number: 42, arabic: 'الْكَرِيمُ', transliteration: 'Al-Karim', urduMeaning: 'بڑا سخی اور کرم کرنے والا'),
    AsmaItem(number: 43, arabic: 'الرَّقِيبُ', transliteration: 'Ar-Raqib', urduMeaning: 'نگران اور محافظ'),
    AsmaItem(number: 44, arabic: 'الْمُجِيبُ', transliteration: 'Al-Mujib', urduMeaning: 'دعائیں قبول کرنے والا'),
    AsmaItem(number: 45, arabic: 'الْوَاسِعُ', transliteration: 'Al-Wasi’', urduMeaning: 'ہر چیز کا احاطہ کرنے والا'),
    AsmaItem(number: 46, arabic: 'الْحَكِيمُ', transliteration: 'Al-Hakim', urduMeaning: 'بڑا حکمت والا'),
    AsmaItem(number: 47, arabic: 'الْوَدُودُ', transliteration: 'Al-Wadud', urduMeaning: 'اپنے بندوں سے محبت کرنے والا'),
    AsmaItem(number: 48, arabic: 'الْمَجِيدُ', transliteration: 'Al-Majid', urduMeaning: 'بزرگی اور عظمت والا'),
    AsmaItem(number: 49, arabic: 'الْبَاعِثُ', transliteration: 'Al-Ba’ith', urduMeaning: 'مردوں کو اٹھانے والا'),
    AsmaItem(number: 50, arabic: 'الشَّهِيدُ', transliteration: 'Ash-Shahid', urduMeaning: 'ہر چیز پر گواہ'),
    AsmaItem(number: 51, arabic: 'الْحَقُّ', transliteration: 'Al-Haqq', urduMeaning: 'سچی ذات'),
    AsmaItem(number: 52, arabic: 'الْوَكِيلُ', transliteration: 'Al-Wakil', urduMeaning: 'کارساز اور بھروسے کے لائق'),
    AsmaItem(number: 53, arabic: 'الْقَوِيُّ', transliteration: 'Al-Qawiyyu', urduMeaning: 'سب سے طاقتور'),
    AsmaItem(number: 54, arabic: 'الْمَتِينُ', transliteration: 'Al-Matin', urduMeaning: 'بہت مضبوط'),
    AsmaItem(number: 55, arabic: 'الْوَلِيُّ', transliteration: 'Al-Waliyy', urduMeaning: 'دوست اور مددگار'),
    AsmaItem(number: 56, arabic: 'الْحَمِيدُ', transliteration: 'Al-Hamid', urduMeaning: 'تعریف کے لائق'),
    AsmaItem(number: 57, arabic: 'الْمُحْصِي', transliteration: 'Al-Muhsi', urduMeaning: 'ہر چیز کا شمار کرنے والا'),
    AsmaItem(number: 58, arabic: 'الْمُبْدِئُ', transliteration: 'Al-Mubdi’', urduMeaning: 'پہلی بار پیدا کرنے والا'),
    AsmaItem(number: 59, arabic: 'الْمُعِيدُ', transliteration: 'Al-Mu’id', urduMeaning: 'دوبارہ زندہ کرنے والا'),
    AsmaItem(number: 60, arabic: 'الْمُحْيِي', transliteration: 'Al-Muhyi', urduMeaning: 'زندگی بخشنے والا'),
    AsmaItem(number: 61, arabic: 'الْمُمِيتُ', transliteration: 'Al-Mumit', urduMeaning: 'موت دینے والا'),
    AsmaItem(number: 62, arabic: 'الْحَيُّ', transliteration: 'Al-Hayy', urduMeaning: 'ہمیشہ زندہ رہنے والا'),
    AsmaItem(number: 63, arabic: 'الْقَيُّومُ', transliteration: 'Al-Qayyum', urduMeaning: 'خود قائم رہنے والا'),
    AsmaItem(number: 64, arabic: 'الْوَاجِدُ', transliteration: 'Al-Wajid', urduMeaning: 'سب کچھ پانے والا'),
    AsmaItem(number: 65, arabic: 'الْمَاجِدُ', transliteration: 'Al-Majid', urduMeaning: 'بزرگی اور عظمت والا'),
    AsmaItem(number: 66, arabic: 'الْوَاحِدُ', transliteration: 'Al-Wahid', urduMeaning: 'اکیلا اور یکتا'),
    AsmaItem(number: 67, arabic: 'الصَّمَدُ', transliteration: 'As-Samad', urduMeaning: 'بے نیاز'),
    AsmaItem(number: 68, arabic: 'الْقَادِرُ', transliteration: 'Al-Qadir', urduMeaning: 'سب پر قدرت رکھنے والا'),
    AsmaItem(number: 69, arabic: 'الْمُقْتَدِرُ', transliteration: 'Al-Muqtadir', urduMeaning: 'كامل اقتدار والا'),
    AsmaItem(number: 70, arabic: 'الْمُقَدِّمُ', transliteration: 'Al-Muqaddim', urduMeaning: 'آگے کرنے والا'),
    AsmaItem(number: 71, arabic: 'الْمُؤَخِّرُ', transliteration: 'Al-Mu’akhkhir', urduMeaning: 'پیچھے کرنے والا'),
    AsmaItem(number: 72, arabic: 'الأَوَّلُ', transliteration: 'Al-Awwal', urduMeaning: 'سب سے پہلا'),
    AsmaItem(number: 73, arabic: 'الآخِرُ', transliteration: 'Al-Akhir', urduMeaning: 'سب سے آخری'),
    AsmaItem(number: 74, arabic: 'الظَّاهِرُ', transliteration: 'Az-Zahir', urduMeaning: 'ظاہر اور آشکار'),
    AsmaItem(number: 75, arabic: 'الْبَاطِنُ', transliteration: 'Al-Batin', urduMeaning: 'پوشیدہ'),
    AsmaItem(number: 76, arabic: 'الْوَالِي', transliteration: 'Al-Wali', urduMeaning: 'مالک اور کارساز'),
    AsmaItem(number: 77, arabic: 'الْمُتَعَالِي', transliteration: 'Al-Muta’ali', urduMeaning: 'بلند و بالا'),
    AsmaItem(number: 78, arabic: 'الْبَرُّ', transliteration: 'Al-Barr', urduMeaning: 'بڑا مہربان اور محسن'),
    AsmaItem(number: 79, arabic: 'التَّوَابُ', transliteration: 'At-Tawwab', urduMeaning: 'توبہ قبول کرنے والا'),
    AsmaItem(number: 80, arabic: 'الْمُنْتَقِمُ', transliteration: 'Al-Muntaqim', urduMeaning: 'بدلہ لینے والا'),
    AsmaItem(number: 81, arabic: 'الْعَفُوُّ', transliteration: 'Al-Afuww', urduMeaning: 'معاف کرنے والا'),
    AsmaItem(number: 82, arabic: 'الرَّؤُوفُ', transliteration: 'Ar-Ra’uf', urduMeaning: 'نہایت شفقت والا'),
    AsmaItem(number: 83, arabic: 'مَالِكُ الْمُلْكِ', transliteration: 'Malik-ul-Mulk', urduMeaning: 'ساری بادشاہی کا مالک'),
    AsmaItem(number: 84, arabic: 'ذُو الجَلَالِ وَالإِكْرَامِ', transliteration: 'Zul-Jalali-wal-Ikram', urduMeaning: 'عظمت اور بزرگی والا'),
    AsmaItem(number: 85, arabic: 'الْمُقْسِطُ', transliteration: 'Al-Muqsit', urduMeaning: 'انصاف کرنے والا'),
    AsmaItem(number: 86, arabic: 'الْجَامِعُ', transliteration: 'Al-Jami’', urduMeaning: 'سب کو اکٹھا کرنے والا'),
    AsmaItem(number: 87, arabic: 'الْغَنِيُّ', transliteration: 'Al-Ghaniyy', urduMeaning: 'بے نیاز اور مالدار'),
    AsmaItem(number: 88, arabic: 'الْمُغْنِي', transliteration: 'Al-Mughni', urduMeaning: 'غنی کرنے والا'),
    AsmaItem(number: 89, arabic: 'الْمَانِعُ', transliteration: 'Al-Mani’', urduMeaning: 'روکنے والا'),
    AsmaItem(number: 90, arabic: 'الضَّارُّ', transliteration: 'Ad-Darr', urduMeaning: 'نقصان پہنچانے والا'),
    AsmaItem(number: 91, arabic: 'النَّافِعُ', transliteration: 'An-Nafi’', urduMeaning: 'نفع دینے والا'),
    AsmaItem(number: 92, arabic: 'النُّورُ', transliteration: 'An-Nur', urduMeaning: 'سراپا نور'),
    AsmaItem(number: 93, arabic: 'الْهَادِي', transliteration: 'Al-Hadi', urduMeaning: 'ہدایت دینے والا'),
    AsmaItem(number: 94, arabic: 'الْبَدِيعُ', transliteration: 'Al-Badi’', urduMeaning: 'خوبصورت پیدا کرنے والا'),
    AsmaItem(number: 95, arabic: 'الْبَاقِي', transliteration: 'Al-Baqi', urduMeaning: 'ہمیشہ رہنے والا'),
    AsmaItem(number: 96, arabic: 'الْوَارِثُ', transliteration: 'Al-Warith', urduMeaning: 'سب کا وارث'),
    AsmaItem(number: 97, arabic: 'الْرَّشِيدُ', transliteration: 'Ar-Rashid', urduMeaning: 'سیدھی راہ دکھانے والا'),
    AsmaItem(number: 98, arabic: 'الصَّبُورُ', transliteration: 'As-Sabur', urduMeaning: 'بڑا صبر کرنے والا'),
    AsmaItem(number: 99, arabic: 'اللَّهُ', transliteration: 'Allah', urduMeaning: 'اللہ (خالقِ مطلق)'),
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
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),

                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _names.length,
                      itemBuilder: (context, index) {
                        return RepaintBoundary(
                          child: _nameCard(_names[index]),
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
                  'أسماء الله الحسنى',
                  style: TextStyle(
                    color: textSecondary, // Secondary Text
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'اللہ تعالیٰ کے 99 نام',
                  style: TextStyle(
                    color: textPrimary, // Dark/Light Heading
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameCard(AsmaItem item) {
    final String id = 'asma_${item.number}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceWhite, // Clean Dynamic Cards
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Very subtle soft shadow
            blurRadius: 8,
            offset: const Offset(0, 4), // Premium downward shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: secondarySurface, // Very Light Sage / Dark Surface
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderSubtle),
            ),
            child: Center(
              child: Text(
                '${item.number}',
                style: const TextStyle(
                  color: richEmerald, // Emerald number highlight
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.transliteration,
                  style: TextStyle(
                    color: textPrimary, // Dynamic Title
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.urduMeaning,
                  style: TextStyle(
                    color: textSecondary, // Secondary text for translation
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.arabic,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: primaryDeepEmerald, // Strong Islamic Emerald Arabic Text
              fontSize: 20,
              fontWeight: FontWeight.w700,
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
                  color: isFav ? Colors.redAccent : textInactive, // Inactive soft color
                  size: 20,
                ),
                onPressed: () async {
                  await FavoritesService.toggleFavorite(
                    id: id,
                    category: 'Names',
                    title: '${item.number}. ${item.transliteration} (${item.arabic})',
                    content: 'Urdu Meaning: ${item.urduMeaning}',
                    subtitle: 'Asma-ul-Husna #${item.number}',
                  );
                  setState(() {});
                },
              );
            },
          ),
        ],
      ),
    );
  }
}