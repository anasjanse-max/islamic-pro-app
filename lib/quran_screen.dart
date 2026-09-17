import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'favorites_service.dart';
import 'home_screen.dart';
import 'live_tasbeeh_icon.dart';
import 'qibla_screen.dart';
import 'settings_screen.dart';
import 'tasbeeh_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  static const Color bg = Color(0xFF040806);
  static const Color card = Color(0xFF0D1612);
  static const Color card2 = Color(0xFF121E18);

  static const Color green = Color(0xFF00E676);
  static const Color greenDark = Color(0xFF0B2E1E);

  static const Color gold = Color(0xFFFFD700);
  static const Color goldAccent = Color(0xFFE5B53B);

  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color greyText = Color(0xFF90A4AE);

  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  String searchText = '';

  List<Map<String, dynamic>> surahs = const [
    {'number': 1, 'name': 'Al-Fatihah', 'arabic': 'الفاتحة', 'meaning': 'The Opening', 'verses': 7, 'revelation': 'Meccan'},
    {'number': 2, 'name': 'Al-Baqarah', 'arabic': 'البقرة', 'meaning': 'The Cow', 'verses': 286, 'revelation': 'Medinan'},
    {'number': 3, 'name': 'Ali \'Imran', 'arabic': 'آل عمران', 'meaning': 'Family of Imran', 'verses': 200, 'revelation': 'Medinan'},
    {'number': 4, 'name': 'An-Nisa', 'arabic': 'النساء', 'meaning': 'The Women', 'verses': 176, 'revelation': 'Medinan'},
    {'number': 5, 'name': 'Al-Ma\'idah', 'arabic': 'المائدة', 'meaning': 'The Table Spread', 'verses': 120, 'revelation': 'Medinan'},
    {'number': 6, 'name': 'Al-An\'am', 'arabic': 'الأنعام', 'meaning': 'The Cattle', 'verses': 165, 'revelation': 'Meccan'},
    {'number': 7, 'name': 'Al-A\'raf', 'arabic': 'الأعراف', 'meaning': 'The Heights', 'verses': 206, 'revelation': 'Meccan'},
    {'number': 8, 'name': 'Al-Anfal', 'arabic': 'الأنفال', 'meaning': 'The Spoils of War', 'verses': 75, 'revelation': 'Medinan'},
    {'number': 9, 'name': 'At-Tawbah', 'arabic': 'التوبة', 'meaning': 'The Repentance', 'verses': 129, 'revelation': 'Medinan'},
    {'number': 10, 'name': 'Yunus', 'arabic': 'يونس', 'meaning': 'Jonah', 'verses': 109, 'revelation': 'Meccan'},
    {'number': 11, 'name': 'Hud', 'arabic': 'هود', 'meaning': 'Hud', 'verses': 123, 'revelation': 'Meccan'},
    {'number': 12, 'name': 'Yusuf', 'arabic': 'يوسف', 'meaning': 'Joseph', 'verses': 111, 'revelation': 'Meccan'},
    {'number': 13, 'name': 'Ar-Ra\'d', 'arabic': 'الرعد', 'meaning': 'The Thunder', 'verses': 43, 'revelation': 'Medinan'},
    {'number': 14, 'name': 'Ibrahim', 'arabic': 'إبراهيم', 'meaning': 'Abraham', 'verses': 52, 'revelation': 'Meccan'},
    {'number': 15, 'name': 'Al-Hijr', 'arabic': 'الحجر', 'meaning': 'The Rocky Tract', 'verses': 99, 'revelation': 'Meccan'},
    {'number': 16, 'name': 'An-Nahl', 'arabic': 'النحل', 'meaning': 'The Bee', 'verses': 128, 'revelation': 'Meccan'},
    {'number': 17, 'name': 'Al-Isra', 'arabic': 'الإسراء', 'meaning': 'The Night Journey', 'verses': 111, 'revelation': 'Meccan'},
    {'number': 18, 'name': 'Al-Kahf', 'arabic': 'الكهف', 'meaning': 'The Cave', 'verses': 110, 'revelation': 'Meccan'},
    {'number': 19, 'name': 'Maryam', 'arabic': 'مريم', 'meaning': 'Mary', 'verses': 98, 'revelation': 'Meccan'},
    {'number': 20, 'name': 'Taha', 'arabic': 'طه', 'meaning': 'Ta-Ha', 'verses': 135, 'revelation': 'Meccan'},
    {'number': 21, 'name': 'Al-Anbiya', 'arabic': 'الأنبيياء', 'meaning': 'The Prophets', 'verses': 112, 'revelation': 'Meccan'},
    {'number': 22, 'name': 'Al-Hajj', 'arabic': 'الحج', 'meaning': 'The Pilgrimage', 'verses': 78, 'revelation': 'Medinan'},
    {'number': 23, 'name': 'Al-Mu\'minun', 'arabic': 'المؤمنون', 'meaning': 'The Believers', 'verses': 118, 'revelation': 'Meccan'},
    {'number': 24, 'name': 'An-Nur', 'arabic': 'النور', 'meaning': 'The Light', 'verses': 64, 'revelation': 'Medinan'},
    {'number': 25, 'name': 'Al-Furqan', 'arabic': 'الفرقان', 'meaning': 'The Criterion', 'verses': 77, 'revelation': 'Meccan'},
    {'number': 26, 'name': 'Ash-Shu\'ara', 'arabic': 'الشعراء', 'meaning': 'The Poets', 'verses': 227, 'revelation': 'Meccan'},
    {'number': 27, 'name': 'An-Naml', 'arabic': 'النمل', 'meaning': 'The Ant', 'verses': 93, 'revelation': 'Meccan'},
    {'number': 28, 'name': 'Al-Qasas', 'arabic': 'القصص', 'meaning': 'The Stories', 'verses': 88, 'revelation': 'Meccan'},
    {'number': 29, 'name': 'Al-\'Ankabut', 'arabic': 'العنكبوت', 'meaning': 'The Spider', 'verses': 69, 'revelation': 'Meccan'},
    {'number': 30, 'name': 'Ar-Rum', 'arabic': 'الروم', 'meaning': 'The Romans', 'verses': 60, 'revelation': 'Meccan'},
    {'number': 31, 'name': 'Luqman', 'arabic': 'لقمان', 'meaning': 'Luqman', 'verses': 34, 'revelation': 'Meccan'},
    {'number': 32, 'name': 'As-Sajdah', 'arabic': 'السجدة', 'meaning': 'The Prostration', 'verses': 30, 'revelation': 'Meccan'},
    {'number': 33, 'name': 'Al-Ahzab', 'arabic': 'الأحزاب', 'meaning': 'The Combined Forces', 'verses': 73, 'revelation': 'Medinan'},
    {'number': 34, 'name': 'Saba', 'arabic': 'سبإ', 'meaning': 'Sheba', 'verses': 54, 'revelation': 'Meccan'},
    {'number': 35, 'name': 'Fatir', 'arabic': 'فاطر', 'meaning': 'Originator', 'verses': 45, 'revelation': 'Meccan'},
    {'number': 36, 'name': 'Ya-Sin', 'arabic': 'يس', 'meaning': 'Ya Sin', 'verses': 83, 'revelation': 'Meccan'},
    {'number': 37, 'name': 'As-Saffat', 'arabic': 'الصافات', 'meaning': 'Those who set the Ranks', 'verses': 182, 'revelation': 'Meccan'},
    {'number': 38, 'name': 'Sad', 'arabic': 'ص', 'meaning': 'The Letter Sad', 'verses': 88, 'revelation': 'Meccan'},
    {'number': 39, 'name': 'Az-Zumar', 'arabic': 'الزمر', 'meaning': 'The Troops', 'verses': 75, 'revelation': 'Meccan'},
    {'number': 40, 'name': 'Ghafir', 'arabic': 'غافر', 'meaning': 'The Forgiver', 'verses': 85, 'revelation': 'Meccan'},
    {'number': 41, 'name': 'Fussilat', 'arabic': 'فصلت', 'meaning': 'Explained in Detail', 'verses': 54, 'revelation': 'Meccan'},
    {'number': 42, 'name': 'Ash-Shura', 'arabic': 'الشورى', 'meaning': 'The Consultation', 'verses': 53, 'revelation': 'Meccan'},
    {'number': 43, 'name': 'Az-Zukhruf', 'arabic': 'الزخرف', 'meaning': 'The Ornaments of Gold', 'verses': 89, 'revelation': 'Meccan'},
    {'number': 44, 'name': 'Ad-Dukhan', 'arabic': 'الدخان', 'meaning': 'The Smoke', 'verses': 59, 'revelation': 'Meccan'},
    {'number': 45, 'name': 'Al-Jathiyah', 'arabic': 'الجاثية', 'meaning': 'The Crouching', 'verses': 37, 'revelation': 'Meccan'},
    {'number': 46, 'name': 'Al-Ahqaf', 'arabic': 'الأحقاف', 'meaning': 'The Wind-Curved Sandhills', 'verses': 35, 'revelation': 'Meccan'},
    {'number': 47, 'name': 'Muhammad', 'arabic': 'محمد', 'meaning': 'Muhammad', 'verses': 38, 'revelation': 'Medinan'},
    {'number': 48, 'name': 'Al-Fath', 'arabic': 'الفتح', 'meaning': 'The Victory', 'verses': 29, 'revelation': 'Medinan'},
    {'number': 49, 'name': 'Al-Hujurat', 'arabic': 'الحجرات', 'meaning': 'The Dwellings', 'verses': 18, 'revelation': 'Medinan'},
    {'number': 50, 'name': 'Qaf', 'arabic': 'ق', 'meaning': 'The Letter Qaf', 'verses': 45, 'revelation': 'Meccan'},
    {'number': 51, 'name': 'Adh-Dhariyat', 'arabic': 'الذاريات', 'meaning': 'The Winnowing Winds', 'verses': 60, 'revelation': 'Meccan'},
    {'number': 52, 'name': 'At-Tur', 'arabic': 'الطور', 'meaning': 'The Mount', 'verses': 49, 'revelation': 'Meccan'},
    {'number': 53, 'name': 'An-Najm', 'arabic': 'النجم', 'meaning': 'The Star', 'verses': 62, 'revelation': 'Meccan'},
    {'number': 54, 'name': 'Al-Qamar', 'arabic': 'القمر', 'meaning': 'The Moon', 'verses': 55, 'revelation': 'Meccan'},
    {'number': 55, 'name': 'Ar-Rahman', 'arabic': 'الرحمن', 'meaning': 'The Beneficent', 'verses': 78, 'revelation': 'Medinan'},
    {'number': 56, 'name': 'Al-Waqi\'ah', 'arabic': 'الواقعة', 'meaning': 'The Inevitable', 'verses': 96, 'revelation': 'Meccan'},
    {'number': 57, 'name': 'Al-Hadid', 'arabic': 'الحديد', 'meaning': 'The Iron', 'verses': 29, 'revelation': 'Medinan'},
    {'number': 58, 'name': 'Al-Mujadila', 'arabic': 'المجادلة', 'meaning': 'The Pleading Woman', 'verses': 22, 'revelation': 'Medinan'},
    {'number': 59, 'name': 'Al-Hashr', 'arabic': 'الحشر', 'meaning': 'The Exile', 'verses': 24, 'revelation': 'Medinan'},
    {'number': 60, 'name': 'Al-Mumtahanah', 'arabic': 'الممتحنة', 'meaning': 'She that is to be examined', 'verses': 13, 'revelation': 'Medinan'},
    {'number': 61, 'name': 'As-Saff', 'arabic': 'الصف', 'meaning': 'The Ranks', 'verses': 14, 'revelation': 'Medinan'},
    {'number': 62, 'name': 'Al-Jumu\'ah', 'arabic': 'الجمعة', 'meaning': 'The Congregation', 'verses': 11, 'revelation': 'Medinan'},
    {'number': 63, 'name': 'Al-Munafiqun', 'arabic': 'المنافقون', 'meaning': 'The Hypocrites', 'verses': 11, 'revelation': 'Medinan'},
    {'number': 64, 'name': 'At-Taghabun', 'arabic': 'التغابن', 'meaning': 'The Mutual Disillusion', 'verses': 18, 'revelation': 'Medinan'},
    {'number': 65, 'name': 'At-Talaq', 'arabic': 'الطلاق', 'meaning': 'The Divorce', 'verses': 12, 'revelation': 'Medinan'},
    {'number': 66, 'name': 'At-Tahrim', 'arabic': 'التحريم', 'meaning': 'The Prohibition', 'verses': 12, 'revelation': 'Medinan'},
    {'number': 67, 'name': 'Al-Mulk', 'arabic': 'الملك', 'meaning': 'The Sovereignty', 'verses': 30, 'revelation': 'Meccan'},
    {'number': 68, 'name': 'Al-Qalam', 'arabic': 'القلم', 'meaning': 'The Pen', 'verses': 52, 'revelation': 'Meccan'},
    {'number': 69, 'name': 'Al-Haqqah', 'arabic': 'الحاقة', 'meaning': 'The Reality', 'verses': 52, 'revelation': 'Meccan'},
    {'number': 70, 'name': 'Al-Ma\'arij', 'arabic': 'المعارج', 'meaning': 'The Ascending Stairways', 'verses': 44, 'revelation': 'Meccan'},
    {'number': 71, 'name': 'Nuh', 'arabic': 'نوح', 'meaning': 'Noah', 'verses': 28, 'revelation': 'Meccan'},
    {'number': 72, 'name': 'Al-Jinn', 'arabic': 'الجن', 'meaning': 'The Jinn', 'verses': 28, 'revelation': 'Meccan'},
    {'number': 73, 'name': 'Al-Muzzammil', 'arabic': 'المزمل', 'meaning': 'The Enshrouded One', 'verses': 20, 'revelation': 'Meccan'},
    {'number': 74, 'name': 'Al-Muddaththir', 'arabic': 'المدثر', 'meaning': 'The Cloaked One', 'verses': 56, 'revelation': 'Meccan'},
    {'number': 75, 'name': 'Al-Qiyamah', 'arabic': 'القيامة', 'meaning': 'The Resurrection', 'verses': 40, 'revelation': 'Meccan'},
    {'number': 76, 'name': 'Al-Insan', 'arabic': 'الإنسان', 'meaning': 'The Man', 'verses': 31, 'revelation': 'Medinan'},
    {'number': 77, 'name': 'Al-Mursalat', 'arabic': 'المرسلات', 'meaning': 'The Emissaries', 'verses': 50, 'revelation': 'Meccan'},
    {'number': 78, 'name': 'An-Naba', 'arabic': 'النبإ', 'meaning': 'The Tidings', 'verses': 40, 'revelation': 'Meccan'},
    {'number': 79, 'name': 'An-Nazi\'at', 'arabic': 'النازعات', 'meaning': 'Those who drag forth', 'verses': 46, 'revelation': 'Meccan'},
    {'number': 80, 'name': '\'Abasa', 'arabic': 'عبس', 'meaning': 'He Frowned', 'verses': 42, 'revelation': 'Meccan'},
    {'number': 81, 'name': 'At-Takwir', 'arabic': 'التكوير', 'meaning': 'The Overthrowing', 'verses': 29, 'revelation': 'Meccan'},
    {'number': 82, 'name': 'Al-Infitar', 'arabic': 'الإنفطار', 'meaning': 'The Cleaving', 'verses': 19, 'revelation': 'Meccan'},
    {'number': 83, 'name': 'Al-Mutaffifin', 'arabic': 'المطففين', 'meaning': 'The Defrauding', 'verses': 36, 'revelation': 'Meccan'},
    {'number': 84, 'name': 'Al-Inshiqaq', 'arabic': 'الإنشقاق', 'meaning': 'The Sundering', 'verses': 25, 'revelation': 'Meccan'},
    {'number': 85, 'name': 'Al-Buruj', 'arabic': 'البروج', 'meaning': 'The Mansions of the Stars', 'verses': 22, 'revelation': 'Meccan'},
    {'number': 86, 'name': 'At-Tariq', 'arabic': 'الطارق', 'meaning': 'The Nightcomer', 'verses': 17, 'revelation': 'Meccan'},
    {'number': 87, 'name': 'Al-A\'la', 'arabic': 'الأعلى', 'meaning': 'The Most High', 'verses': 19, 'revelation': 'Meccan'},
    {'number': 88, 'name': 'Al-Ghashiyah', 'arabic': 'الغاشية', 'meaning': 'The Overwhelming', 'verses': 26, 'revelation': 'Meccan'},
    {'number': 89, 'name': 'Al-Fajr', 'arabic': 'الفجر', 'meaning': 'The Dawn', 'verses': 30, 'revelation': 'Meccan'},
    {'number': 90, 'name': 'Al-Balad', 'arabic': 'البلد', 'meaning': 'The City', 'verses': 20, 'revelation': 'Meccan'},
    {'number': 91, 'name': 'Ash-Shams', 'arabic': 'الشمس', 'meaning': 'The Sun', 'verses': 15, 'revelation': 'Meccan'},
    {'number': 92, 'name': 'Al-Layl', 'arabic': 'الليل', 'meaning': 'The Night', 'verses': 21, 'revelation': 'Meccan'},
    {'number': 93, 'name': 'Ad-Duhaa', 'arabic': 'الضحى', 'meaning': 'The Morning Hours', 'verses': 11, 'revelation': 'Meccan'},
    {'number': 94, 'name': 'Ash-Sharh', 'arabic': 'الشرح', 'meaning': 'The Relief', 'verses': 8, 'revelation': 'Meccan'},
    {'number': 95, 'name': 'At-Tin', 'arabic': 'التين', 'meaning': 'The Fig', 'verses': 8, 'revelation': 'Meccan'},
    {'number': 96, 'name': 'Al-\'Alaq', 'arabic': 'العلق', 'meaning': 'The Clot', 'verses': 19, 'revelation': 'Meccan'},
    {'number': 97, 'name': 'Al-Qadr', 'arabic': 'القدر', 'meaning': 'The Power', 'verses': 5, 'revelation': 'Meccan'},
    {'number': 98, 'name': 'Al-Bayyinah', 'arabic': 'البينة', 'meaning': 'The Clear Proof', 'verses': 8, 'revelation': 'Medinan'},
    {'number': 99, 'name': 'Az-Zalzalah', 'arabic': 'الزلزلة', 'meaning': 'The Earthquake', 'verses': 8, 'revelation': 'Medinan'},
    {'number': 100, 'name': 'Al-\'Adiyat', 'arabic': 'العاديات', 'meaning': 'The Courser', 'verses': 11, 'revelation': 'Meccan'},
    {'number': 101, 'name': 'Al-Qari\'ah', 'arabic': 'القارعة', 'meaning': 'The Calamity', 'verses': 11, 'revelation': 'Meccan'},
    {'number': 102, 'name': 'At-Takathur', 'arabic': 'التكاثر', 'meaning': 'The Rivalry in world increase', 'verses': 8, 'revelation': 'Meccan'},
    {'number': 103, 'name': 'Al-\'Asr', 'arabic': 'العصر', 'meaning': 'The Declining Day', 'verses': 3, 'revelation': 'Meccan'},
    {'number': 104, 'name': 'Al-Humazah', 'arabic': 'الهمزة', 'meaning': 'The Traducer', 'verses': 9, 'revelation': 'Meccan'},
    {'number': 105, 'name': 'Al-Fil', 'arabic': 'الفيل', 'meaning': 'The Elephant', 'verses': 5, 'revelation': 'Meccan'},
    {'number': 106, 'name': 'Quraysh', 'arabic': 'قريش', 'meaning': 'Quraysh', 'verses': 4, 'revelation': 'Meccan'},
    {'number': 107, 'name': 'Al-Ma\'un', 'arabic': 'الماعون', 'meaning': 'The Small Kindnesses', 'verses': 7, 'revelation': 'Meccan'},
    {'number': 108, 'name': 'Al-Kawthar', 'arabic': 'الكوثر', 'meaning': 'The Abundance', 'verses': 3, 'revelation': 'Meccan'},
    {'number': 109, 'name': 'Al-Kafirun', 'arabic': 'الكافرون', 'meaning': 'The Disbelievers', 'verses': 6, 'revelation': 'Meccan'},
    {'number': 110, 'name': 'An-Nasr', 'arabic': 'النصر', 'meaning': 'The Divine Support', 'verses': 3, 'revelation': 'Medinan'},
    {'number': 111, 'name': 'Al-Masad', 'arabic': 'المسد', 'meaning': 'The Palm Fiber', 'verses': 5, 'revelation': 'Meccan'},
    {'number': 112, 'name': 'Al-Ikhlas', 'arabic': 'الإخلاص', 'meaning': 'The Sincerity', 'verses': 4, 'revelation': 'Meccan'},
    {'number': 113, 'name': 'Al-Falaq', 'arabic': 'الفلق', 'meaning': 'The Daybreak', 'verses': 5, 'revelation': 'Meccan'},
    {'number': 114, 'name': 'An-Nas', 'arabic': 'الناس', 'meaning': 'Mankind', 'verses': 6, 'revelation': 'Meccan'},
  ];

  final List<Map<String, String>> paras = List.generate(30, (index) {
    const names = [
      'Alif Lam Meem', 'Sayaqool', 'Tilkal Rusul', 'Lan Tana Loo', 'Wal Mohsanat',
      'La Yuhibbullah', 'Wa Iza Samiu', 'Wa Lau Annana', 'Qalal Malao', 'Wa A\'lamu',
      'Yatazeroon', 'Wa Mamin Daabbatin', 'Wa Ma Ubarri\'u', 'Rubama', 'Subhanallazi',
      'Qal Alam', 'Aqtarabu', 'Qadd Aflaha', 'Wa Qalallazina', 'A\'man Khalaq',
      'Utlu Ma Oohi', 'Wa Manyaqnut', 'Wa Mali', 'Faman Azlam', 'Elahe Yuraddu',
      'Ha Meem', 'Qala Fama Khatbukum', 'Qad Sami Allah', 'Tabarakallazi', 'Amma',
    ];

    const arabic = [
      'الم', 'سَيَقُولُ', 'تِلْكَ الرُّسُلُ', 'لَنْ تَنَالُوا', 'وَالْمُحْصَنَاتُ',
      'لَا يُحِبُّ اللَّهُ', 'وَإِذَا سَمِعُوا', 'وَلَوْ أَنَّنَا', 'قَالَ الْمَلَأُ', 'وَاعْلَمُوا',
      'يَعْتَذِرُونَ', 'وَمَا مِنْ دَابَّةٍ', 'وَمَا أُبَرِّئُ', 'رُبَمَا', 'سُبْحَانَ الَّذِي',
      'قَالَ أَلَمْ', 'اقْتَرَبَ', 'قَدْ أَفْلَحَ', 'وَقَالَ الَّذِينَ', 'أَمَّنْ خَلَقَ',
      'اتْلُ مَا أُوحِيَ', 'وَمَنْ يَقْنُتْ', 'وَمَا لِيَ', 'فَمَنْ أَظْلَمُ', 'إِلَيْهِ يُرَدُّ',
      'حم', 'قَالَ فَمَا خَطْبُكُمْ', 'قَدْ سَمِعَ اللَّهُ', 'تَبَارَكَ الَّذِي', 'عَمَّ',
    ];

    return {
      'number': '${index + 1}',
      'name': 'Para ${index + 1}',
      'arabic': arabic[index],
      'meaning': names[index],
    };
  });

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _searchController.clear();
        if (mounted) setState(() => searchText = '');
      }
    });

    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.alquran.cloud/v1/surah'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      if (data['code'] != 200) return;

      final List<dynamic> items = data['data'];
      if (!mounted) return;

      setState(() {
        surahs = items.map<Map<String, dynamic>>((s) {
          return {
            'number': s['number'],
            'name': s['englishName'],
            'arabic': s['name'],
            'meaning': s['englishNameTranslation'],
            'verses': s['numberOfAyahs'],
            'revelation': s['revelationType'],
          };
        }).toList();
      });
    } catch (_) {}
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
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
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
        backgroundColor: bg,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Main Scrollable Content
              Column(
                children: [
                  _header(),
                  _selector(),
                  _search(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _surahList(),
                        _paraList(),
                      ],
                    ),
                  ),
                ],
              ),
              // Floating Frosted Navigation Dock (Identical to HomeScreen)
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
  // TOP EXECUTIVE HEADER WITH CALLIGRAPHIC TITLE
  // ==========================================================

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
      child: Column(
        children: [
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: _handleBack,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Quran Emblem Icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      green.withValues(alpha: 0.25),
                      card2,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: green.withValues(alpha: 0.6),
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: green.withValues(alpha: 0.20),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'HOLY QURAN',
                          style: TextStyle(
                            color: goldAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.8,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Read & Reflect',
                      style: TextStyle(
                        color: whiteText,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Calligraphy Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0E1A14),
                  Color(0xFF08120D),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: gold.withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '114 Surahs • 30 Paras',
                      style: TextStyle(
                        color: gold.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Complete Mushaf',
                      style: TextStyle(
                        color: greyText.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'الْقُرْآنُ الْكَرِيمُ',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: gold,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
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
  // SURAHS / PARAS TAB SELECTOR
  // ==========================================================

  Widget _selector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 6, 18, 0),
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: greenDark,
          border: Border.all(color: green.withValues(alpha: 0.55), width: 1.1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: green.withValues(alpha: 0.18),
              blurRadius: 8,
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: green,
        unselectedLabelColor: const Color(0xFF8B918E),
        labelStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Surahs'),
          Tab(text: 'Paras'),
        ],
      ),
    );
  }

  // ==========================================================
  // SEARCH BAR
  // ==========================================================

  Widget _search() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => searchText = value),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
          cursorColor: green,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            prefixIcon:
                const Icon(Icons.search_rounded, color: green, size: 22),
            hintText: _tabController.index == 0
                ? 'Search Surah by name, number...'
                : 'Search Para by name, number...',
            hintStyle: TextStyle(
              color: greyText.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            suffixIcon: searchText.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => searchText = '');
                    },
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white54, size: 18),
                  ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SURAHS LIST
  // ==========================================================

  Widget _surahList() {
    final q = searchText.trim().toLowerCase();
    final filtered = surahs.where((s) {
      return q.isEmpty ||
          s['name'].toString().toLowerCase().contains(q) ||
          s['meaning'].toString().toLowerCase().contains(q) ||
          s['number'].toString().contains(q) ||
          s['arabic'].toString().contains(searchText.trim());
    }).toList();

    if (filtered.isEmpty) return _empty('No Surah Found');

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
      itemCount: filtered.length,
      itemBuilder: (_, index) => _surahCard(filtered[index]),
    );
  }

  // ==========================================================
  // PARAS LIST
  // ==========================================================

  Widget _paraList() {
    final q = searchText.trim().toLowerCase();
    final filtered = paras.where((p) {
      return q.isEmpty ||
          p['name']!.toLowerCase().contains(q) ||
          p['meaning']!.toLowerCase().contains(q) ||
          p['number']!.contains(q) ||
          p['arabic']!.contains(searchText.trim());
    }).toList();

    if (filtered.isEmpty) return _empty('No Para Found');

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
      itemCount: filtered.length,
      itemBuilder: (_, index) => _paraCard(filtered[index]),
    );
  }

  // ==========================================================
  // SURAH CARD (LUXURY GLASSMORPHIC STYLE)
  // ==========================================================

  Widget _surahCard(Map<String, dynamic> s) {
    final String id = 'surah_${s['number']}';
    final bool isMeccan =
        s['revelation'].toString().toLowerCase().contains('meccan');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuranReaderScreen(
              startSurah: s['number'] as int,
              title: s['name'].toString(),
              totalAyahs: s['verses'] as int,
            ),
          ),
        );
      },
      child: Container(
        height: 78,
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F1813),
              Color(0xFF09100C),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Number Emblem
            _numberEmblem(s['number'].toString()),
            const SizedBox(width: 12),
            // Title & Details
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s['name'].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          s['meaning'].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: greyText.withValues(alpha: 0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '• ${s['verses']} Ayahs',
                        style: TextStyle(
                          color: greyText.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Revelation Pill Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isMeccan
                              ? gold.withValues(alpha: 0.14)
                              : green.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isMeccan
                                ? gold.withValues(alpha: 0.4)
                                : green.withValues(alpha: 0.4),
                            width: 0.7,
                          ),
                        ),
                        child: Text(
                          isMeccan ? 'Makki' : 'Madani',
                          style: TextStyle(
                            color: isMeccan ? gold : green,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // Arabic Name
            Text(
              s['arabic'].toString(),
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: gold,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            // Favorite Button
            FutureBuilder<bool>(
              future: FavoritesService.isFavorite(id),
              builder: (context, snapshot) {
                final isFav = snapshot.data ?? false;
                return IconButton(
                  splashRadius: 18,
                  icon: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFav ? Colors.redAccent : const Color(0xFF6F7773),
                    size: 20,
                  ),
                  onPressed: () async {
                    await FavoritesService.toggleFavorite(
                      id: id,
                      category: 'Quran',
                      title: 'Surah ${s['name']} (${s['arabic']})',
                      content:
                          '${s['meaning']} • ${s['verses']} Ayahs • ${s['revelation']} Surah',
                      subtitle: 'Surah #${s['number']}',
                    );
                    setState(() {});
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PARA CARD
  // ==========================================================

  Widget _paraCard(Map<String, String> p) {
    final String id = 'para_${p['number']}';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuranReaderScreen(
              startPara: int.parse(p['number']!),
              title: p['name']!,
            ),
          ),
        );
      },
      child: Container(
        height: 76,
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F1813),
              Color(0xFF09100C),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _numberEmblem(p['number']!),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p['name']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p['meaning']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: greyText.withValues(alpha: 0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              p['arabic']!,
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: gold,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            FutureBuilder<bool>(
              future: FavoritesService.isFavorite(id),
              builder: (context, snapshot) {
                final isFav = snapshot.data ?? false;
                return IconButton(
                  splashRadius: 18,
                  icon: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFav ? Colors.redAccent : const Color(0xFF6F7773),
                    size: 20,
                  ),
                  onPressed: () async {
                    await FavoritesService.toggleFavorite(
                      id: id,
                      category: 'Quran',
                      title: '${p['name']} (${p['arabic']})',
                      content: 'Para Start: ${p['meaning']}',
                      subtitle: 'Para #${p['number']}',
                    );
                    setState(() {});
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // NUMBER EMBLEM BADGE
  // ==========================================================

  Widget _numberEmblem(String number) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gold.withValues(alpha: 0.20),
            greenDark,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gold.withValues(alpha: 0.5),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.12),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // FLOATING FROSTED DOCK NAVIGATION BAR (IDENTICAL TO HOME)
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
                active: true,
                action: () {},
              ),
              _navButton(
                icon: Icons.explore_rounded,
                label: 'Qibla',
                active: false,
                action: () => _navigateToScreen(const QiblaScreen()),
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

  Widget _empty(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ==========================================================
// QURAN READER SCREEN
// ==========================================================

class QuranReaderScreen extends StatefulWidget {
  final int? startSurah;
  final int? startPara;
  final String title;
  final int? totalAyahs;

  const QuranReaderScreen({
    super.key,
    this.startSurah,
    this.startPara,
    required this.title,
    this.totalAyahs,
  });

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  static const int totalPages = 604;
  late PageController _pageController;

  int currentPage = 1;
  String currentTitle = '';

  final Map<int, int> _pageCdnIndex = {};
  final Map<int, List<dynamic>> _pageTextCache = {};

  static const List<int> paraPages = [
    1, 22, 42, 62, 82, 102, 122, 142, 162, 182,
    202, 222, 242, 262, 282, 302, 322, 342, 362, 382,
    402, 422, 442, 462, 482, 502, 522, 542, 562, 582
  ];

  static const List<int> surahPages = [
    1, 2, 50, 77, 106, 128, 151, 177, 187, 208, 221, 235, 249, 255, 262, 267,
    282, 293, 305, 312, 322, 332, 342, 350, 359, 367, 377, 385, 396, 404, 411,
    415, 418, 428, 434, 440, 446, 453, 458, 467, 477, 483, 489, 496, 499, 502,
    507, 511, 515, 518, 520, 523, 526, 528, 531, 534, 537, 542, 545, 549, 551,
    553, 554, 556, 558, 560, 562, 564, 566, 568, 570, 572, 574, 575, 577, 578,
    580, 582, 583, 585, 586, 587, 587, 588, 589, 590, 591, 592, 593, 594, 595,
    595, 596, 596, 597, 597, 598, 598, 599, 599, 600, 600, 601, 601, 602, 602,
    602, 603, 603, 603, 604, 604, 604, 604
  ];

  @override
  void initState() {
    super.initState();
    currentTitle = widget.title;

    int page = 1;
    if (widget.startSurah != null &&
        widget.startSurah! >= 1 &&
        widget.startSurah! <= 114) {
      page = surahPages[widget.startSurah! - 1];
    } else if (widget.startPara != null &&
        widget.startPara! >= 1 &&
        widget.startPara! <= 30) {
      page = paraPages[widget.startPara! - 1];
    }

    currentPage = page.clamp(1, totalPages);
    _pageController = PageController(initialPage: currentPage - 1);
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheNearbyPages(currentPage);
  }

  void _precacheNearbyPages(int page) {
    for (int offset in [-1, 1, 2]) {
      int p = page + offset;
      if (p >= 1 && p <= totalPages) {
        int cdn = _pageCdnIndex[p] ?? 0;
        precacheImage(NetworkImage(_getPageUrl(p, cdn)), context);
      }
    }
  }

  String _getPageUrl(int page, int cdnIndex) {
    final p3 = page.toString().padLeft(3, '0');
    switch (cdnIndex) {
      case 0:
        return 'https://android.quran.com/data/width_1024/page$p3.png';
      case 1:
        return 'https://raw.githubusercontent.com/quran/quran.com-images/master/indopak/page$p3.png';
      default:
        return 'https://images.quran.com/images/pages/mushaf/indopak/page$page.png';
    }
  }

  Future<List<dynamic>> _fetchPageText(int page) async {
    if (_pageTextCache.containsKey(page)) return _pageTextCache[page]!;
    final response = await http
        .get(Uri.parse('https://api.alquran.cloud/v1/page/$page/quran-indopak'))
        .timeout(const Duration(seconds: 4));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 200) {
        final ayahs = data['data']['ayahs'] as List<dynamic>;
        _pageTextCache[page] = ayahs;
        return ayahs;
      }
    }
    throw Exception();
  }

  @override
  void dispose() {
    _pageController.dispose();
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _readerHeader(),
              Expanded(child: _pages()),
              _readerControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readerHeader() {
    final String id = 'quran_page_$currentPage';
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF090D0B),
        border: Border(bottom: BorderSide(color: Color(0xFF202522))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Page $currentPage of $totalPages',
                  style: const TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          FutureBuilder<bool>(
            future: FavoritesService.isFavorite(id),
            builder: (context, snapshot) {
              final isFav = snapshot.data ?? false;
              return IconButton(
                icon: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFav ? Colors.redAccent : const Color(0xFF00E676),
                  size: 22,
                ),
                onPressed: () async {
                  await FavoritesService.toggleFavorite(
                    id: id,
                    category: 'Quran',
                    title: '$currentTitle (Page $currentPage)',
                    content:
                        'Saved Quran Page #$currentPage from $currentTitle.',
                    subtitle: 'Holy Quran Page',
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

  Widget _pages() {
    return PageView.builder(
      controller: _pageController,
      reverse: true,
      itemCount: totalPages,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (idx) {
        int newPage = idx + 1;
        setState(() => currentPage = newPage);
        _precacheNearbyPages(newPage);
      },
      itemBuilder: (_, index) {
        final page = index + 1;
        final cdnIndex = _pageCdnIndex[page] ?? 0;

        if (cdnIndex >= 3) return _textFallbackView(page);

        return Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          child: Image.network(
            _getPageUrl(page, cdnIndex),
            fit: BoxFit.contain,
            gaplessPlayback: true,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Color(0xFF00E676),
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            errorBuilder: (_, _, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _pageCdnIndex[page] = cdnIndex + 1);
              });
              return const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Color(0xFF00E676),
                    strokeWidth: 2,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _textFallbackView(int page) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchPageText(page),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Color(0xFF00E676),
                strokeWidth: 2,
              ),
            ),
          );
        }
        final ayahs = snapshot.data!;

        return Container(
          color: const Color(0xFFFAF6EB),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text.rich(
                TextSpan(
                  children: ayahs.map<InlineSpan>((a) {
                    return TextSpan(
                      text: '${a['text']} ﴿${a['numberInSurah']}﴾ ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        height: 2.0,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }).toList(),
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _readerControls() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF090D0B),
        border: Border(top: BorderSide(color: Color(0xFF202522))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded,
                color: Colors.white, size: 28),
            onPressed: currentPage > 1 ? () => _goTo(currentPage - 1) : null,
          ),
          Text(
            'Page $currentPage / $totalPages',
            style: const TextStyle(
              color: Color(0xFF00E676),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded,
                color: Colors.white, size: 28),
            onPressed:
                currentPage < totalPages ? () => _goTo(currentPage + 1) : null,
          ),
        ],
      ),
    );
  }

  void _goTo(int page) {
    _pageController.animateToPage(
      page - 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }
}
