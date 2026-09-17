import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'favorites_service.dart';
import 'more_screen.dart'; // Navigates smoothly back to More screen

class HadithItem {
  final String category;
  final String title;
  final String arabic;
  final String urduTranslation;
  final String reference;

  const HadithItem({
    required this.category,
    required this.title,
    required this.arabic,
    required this.urduTranslation,
    required this.reference,
  });
}

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  static const Color background = Color(0xFF000000);
  static const Color card = Color(0xFF0A0F0C);
  static const Color card2 = Color(0xFF101613);

  static const Color green = Color(0xFF26E17A);
  static const Color greenDark = Color(0xFF0C3323);
  static const Color gold = Color(0xFFE8B63D);

  static const Color whiteText = Color(0xFFF4F6F5);
  static const Color greyText = Color(0xFF98A19D);

  String _selectedCategory = 'سب';

  final List<String> _categories = [
    'سب',
    'ایمان و عقیدہ',
    'اخلاق و آداب',
    'علم و فضائل',
    'عبادت و نماز',
    'ذکر و دعا',
    'نیکی اور صدقہ',
    'صبر و سکون',
  ];

  final List<HadithItem> _hadiths = const [
    // ایمان و عقیدہ
    HadithItem(
      category: 'ایمان و عقیدہ',
      title: 'اعمال کا دارومدار نیتوں پر ہے',
      arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
      urduTranslation: 'تمام اعمال کا دارومدار نیتوں پر ہے، اور ہر انسان کو وہی ملے گا جس کی اس نے نیت کی تھی۔',
      reference: 'صحیح بخاری (۱)',
    ),
    HadithItem(
      category: 'ایمان و عقیدہ',
      title: 'کامل مومن کون ہے؟',
      arabic: 'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
      urduTranslation: 'تم میں سے کوئی اس وقت تک کامل مومن نہیں ہو سکتا جب تک وہ اپنے بھائی کے لیے بھی وہی پسند نہ کرے جو اپنے لیے پسند کرتا ہے۔',
      reference: 'صحیح بخاری (۱۳)',
    ),
    HadithItem(
      category: 'ایمان و عقیدہ',
      title: 'ایمان کی شاخیں',
      arabic: 'الْإِيمَانُ بِضْعٌ وَسَبْعُونَ أَوْ بِضْعٌ وَسِتُّونَ شُعْبَةً، فَأَفْضَلُهَا قَوْلُ لَا إِلَهَ إِلَّا اللَّهُ، وَأَدْنَاهَا إِمَاطَةُ الْأَذَى عَنِ الطَّرِيقِ',
      urduTranslation: 'ایمان کے ستر سے کچھ اوپر یا ساٹھ سے کچھ اوپر شعبے ہیں، جن میں سب سے افضل کلمہ "لا إله إلا الله" کہنا ہے اور سب سے ادنیٰ راستے سے تکلیف دہ چیز کا ہٹانا ہے۔',
      reference: 'صحیح مسلم (۳۵)',
    ),
    HadithItem(
      category: 'ایمان و عقیدہ',
      title: 'مومن کی شان',
      arabic: 'عَجَبًا لِأَمْرِ الْمُؤْمِنِ، إِنَّ أَمْرَهُ كُلَّهُ خَيْرٌ',
      urduTranslation: 'مومن کا معاملہ بھی عجیب ہے، اس کے ہر کام میں اس کے لیے بھلائی ہے (اگر تکلیف پہنچے تو صبر کرتا ہے اور راحت ملے تو شکر کرتا ہے)۔',
      reference: 'صحیح مسلم (۲۹۹۹)',
    ),
    HadithItem(
      category: 'ایمان و عقیدہ',
      title: 'اللہ تعالیٰ کے نزدیک پسندیدہ عمل',
      arabic: 'أَحَبُّ الأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ',
      urduTranslation: 'اللہ تعالیٰ کے نزدیک سب سے پسندیدہ عمل وہ ہے جو ہمیشہ کیا جائے، خواہ وہ تھوڑا ہی کیوں نہ ہو۔',
      reference: 'صحیح بخاری (۶۴۶۵)',
    ),
    HadithItem(
      category: 'ایمان و عقیدہ',
      title: 'حياء ایمان کا حصہ ہے',
      arabic: 'الْحَيَاءُ مِنَ الْإِيمَانِ',
      urduTranslation: 'حیا ایمان کا ایک اہم حصہ ہے۔',
      reference: 'صحیح بخاری (۹)',
    ),
    HadithItem(
      category: 'ایمان و عقیدہ',
      title: 'دنیا مومن کے لیے قید خانہ ہے',
      arabic: 'الدُّنْيَا سِجْنُ الْمُؤْمِنِ وَجَنَّةُ الْكَافِرِ',
      urduTranslation: 'دنیا مومن کے لیے قید خانہ اور کافر کے لیے جنت ہے۔',
      reference: 'صحیح مسلم (۲۹۵۶)',
    ),
    HadithItem(
      category: 'ایمان و عقیدہ',
      title: 'دلوں کا زنگ اور استغفار',
      arabic: 'إِنَّهُ لَيُغَانُ عَلَى قَلْبِي، وَإِنِّي لَأَسْتَغْفِرُ اللَّهَ فِي الْيَوْمِ مِائَةَ مَرَّةٍ',
      urduTranslation: 'بے شک میرے دل پر بھی کبھی کبھی غفلت سی چھا جاتی ہے، اس لیے میں دن میں سو بار اللہ سے استغفار کرتا ہوں۔',
      reference: 'صحیح مسلم (۲۷۰۲)',
    ),

    // اخلاق و آداب
    HadithItem(
      category: 'اخلاق و آداب',
      title: 'بہترین انسان',
      arabic: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
      urduTranslation: 'تم میں سے بہترین وہ لوگ ہیں جو قرآن سیکھیں اور دوسروں کو سکھائیں۔',
      reference: 'صحیح بخاری (۵۰۲۷)',
    ),
    HadithItem(
      category: 'اخلاق و آداب',
      title: 'اچھے اخلاق والے بہترین لوگ',
      arabic: 'إِنَّ مِنْ خِيَارِكُمْ أَحْسَنَكُمْ أَخْلَاقاً',
      urduTranslation: 'بے شک تم میں سے بہترین وہ ہیں جن کے اخلاق سب سے اچھے ہیں۔',
      reference: 'صحیح بخاری (۶۰۳۵)',
    ),
    HadithItem(
      category: 'اخلاق و آداب',
      title: 'مسکرانا بھی صدقہ ہے',
      arabic: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ',
      urduTranslation: 'اپنے بھائی کے سامنے مسکرانا بھی تمہارے لیے صدقہ ہے۔',
      reference: 'جامع ترمذی (۱۹۵۶)',
    ),
    HadithItem(
      category: 'اخلاق و آداب',
      title: 'گالی دینا فسق ہے',
      arabic: 'سِبَابُ الْمُسْلِمِ فُسُوقٌ، وَقِتَالُهُ كُفْرٌ',
      urduTranslation: 'مسلمان کو گالی دینا گناہ (فسق) ہے اور اس سے جنگ کرنا کفر ہے۔',
      reference: 'صحیح بخاری (۴۸)',
    ),
    HadithItem(
      category: 'اخلاق و آداب',
      title: 'پڑوسی کے حقوق',
      arabic: 'مَا زَالَ جِبْرِيلُ يُوصِينِي بِالْجَارِ حَتَّى ظَنَنْتُ أَنَّهُ سَيُوَرِّثُهُ',
      urduTranslation: 'فرشتہ جبرئیل علیہ السلام مجھے پڑوسی کے بارے میں اتنی بار تاکید کرتے رہے کہ مجھے گمان ہونے لگا کہ وہ اسے وارث بنا دیں گے۔',
      reference: 'صحیح بخاری (۶۰۱۵)',
    ),
    HadithItem(
      category: 'اخلاق و آداب',
      title: 'والدین کی نافرمانی بڑا گناہ',
      arabic: 'أَلَا أُنَبِّئُكُمْ بِأَكْبَرِ الْكَبَائِرِ؟ الإِشْرَاكُ بِاللَّهِ، وَعُقُوقُ الْوَالِدَيْنِ',
      urduTranslation: 'کیا میں تمہیں سب سے بڑے گناہوں کے بارے میں نہ بتاؤں؟ اللہ کے ساتھ شرک کرنا اور والدین کی نافرمانی کرنا۔',
      reference: 'صحیح بخاری (۲۶۵۴)',
    ),
    HadithItem(
      category: 'اخلاق و آداب',
      title: 'صلہ رحمی (رشتہ داروں سے اچھا سلوک)',
      arabic: 'مَنْ أَحَبَّ أَنْ يُبْسَطَ لَهُ فِي رِزْقِهِ، وَيُنْسَأَ لَهُ فِي أثَرِهِ، فَلْيَصِلْ رَحِمَهُ',
      urduTranslation: 'جو شخص یہ پسند کرتا ہے کہ اس کے رزق میں وسعت دی جائے اور اس کی عمر دراز کی جائے، تو اسے چاہیے کہ صلہ رحمی کرے (رشتہ داروں سے اچھے تعلقات رکھے)۔',
      reference: 'صحیح بخاری (۲۰۶۷)',
    ),
    HadithItem(
      category: 'اخلاق و آداب',
      title: 'غصے پر قابو پانا',
      arabic: 'لَيْسَ الشَّدِيدُ بِالصُّرَعَةِ، إِنَّمَا الشَّدِيدُ الَّذِي يَمْلِكُ نَفْسَهُ عِنْدَ الْغَضَبِ',
      urduTranslation: 'پہلوان وہ نہیں جو اچھے اچھوں کو پچھاڑ دے، بلکہ اصل طاقتور وہ ہے جو غصے کے وقت اپنے آپ پر قابو رکھے۔',
      reference: 'صحیح بخاری (۶۱۱۴)',
    ),
    HadithItem(
      category: 'اخلاق و آداب',
      title: 'سچی بات کہنا',
      arabic: 'عَلَيْكُمْ بِالصِّدْقِ، فَإِنَّ الصِّدْقَ يَهْدِي إِلَى الْبِرِّ',
      urduTranslation: 'سچ کو لازم پکڑو، کیونکہ سچائی نیکی کی طرف رہنمائی کرتی ہے۔',
      reference: 'صحیح بخاری (۶۰۹۴)',
    ),
    HadithItem(
      category: 'اخلاق و آداب',
      title: 'مہمان نوازی',
      arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيُكْرِمْ ضَيْفَهُ',
      urduTranslation: 'جو شخص اللہ اور آخرت کے دن پر ایمان رکھتا ہے، اسے چاہیے کہ اپنے مہمان کی عزت کرے۔',
      reference: 'صحیح بخاری (۶۰۱۸)',
    ),

    // علم و فضائل
    HadithItem(
      category: 'علم و فضائل',
      title: 'علم حاصل کرنا فرض ہے',
      arabic: 'طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ',
      urduTranslation: 'علم حاصل کرنا ہر مسلمان پر فرض ہے۔',
      reference: 'سنن ابن ماجه (۲۲۴)',
    ),
    HadithItem(
      category: 'علم و فضائل',
      title: 'جنت کا راستہ',
      arabic: 'مَنْ سَلَكَ طَرِيقاً يَلْتَمِسُ فِيهِ عِلْماً سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقاً إِلَى الْجَنَّةِ',
      urduTranslation: 'جو شخص علم کی تلاش میں کسی راستے پر چلے، اللہ تعالیٰ اس کے لیے جنت کا راستہ آسان کر دیتا ہے۔',
      reference: 'صحیح مسلم (۲۶۹۹)',
    ),
    HadithItem(
      category: 'علم و فضائل',
      title: 'بہترین صدقہ جاریہ',
      arabic: 'إِذَا مَاتَ الإِنْسَانُ انْقَطَعَ عَنْهُ عَمَلُهُ إِلَّا مِنْ ثَلَاثٍ: صَدَقَةٍ جَارِيَةٍ، أَوْ عِلْمٍ يُنْتَفَعُ بِهِ، أَوْ وَلَدٍ صَالِحٍ يَدْعُو لَهُ',
      urduTranslation: 'جب انسان مر جاتا ہے تو اس کے اعمال کا سلسلہ منقطع ہو جاتا ہے سوائے تین چیزوں کے: صدقہ جاریہ، ایسا علم جس سے فائدہ اٹھایا جائے، یا نیک بیٹا جو اس کے لیے دعا کرے۔',
      reference: 'صحیح مسلم (۱۶۳۱)',
    ),
    HadithItem(
      category: 'علم و فضائل',
      title: 'بھلائی سکھانے والے کی فضیلت',
      arabic: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
      urduTranslation: 'تم میں بہتر وہ ہے جو خود قرآن سیکھے اور دوسروں کو سکھائے۔',
      reference: 'صحیح بخاری (۵۰۲۷)',
    ),
    HadithItem(
      category: 'علم و فضائل',
      title: 'مفید بات حکمت ہے',
      arabic: 'الْكَلِمَةُ الْحِكْمَةُ ضَالَّةُ الْمُؤْمِنِ، فَحَيْثُ وَجَدَهَا فَهُوَ أَحَقُّ بِهَا',
      urduTranslation: 'اچھی بات (حکمت) مومن کی گمشدہ چیز ہے، جہاں بھی وہ اسے پائے، وہ اس کا سب سے زیادہ حقدار ہے۔',
      reference: 'جامع ترمذی (۲۶۸۷)',
    ),

    // عبادت و نماز
    HadithItem(
      category: 'عبادت و نماز',
      title: 'نماز مومن اور کافر میں فرق',
      arabic: 'إِنَّ بَيْنَ الرَّجُلِ وَبَيْنَ الشِّرْكِ وَالْكُفْرِ تَرْكَ الصَّلَاةِ',
      urduTranslation: 'بندے اور کفر و شرک کے درمیان فرق صرف نماز کو چھوڑنا ہے۔',
      reference: 'صحیح مسلم (۸۲)',
    ),
    HadithItem(
      category: 'عبادت و نماز',
      title: 'نماز کی پابندی',
      arabic: 'بُنِيَ الْإِسْلَامُ عَلَى خَمْسٍ...',
      urduTranslation: 'اسلام کی بنیاد پانچ چیزوں پر ہے: گواہی دینا کہ اللہ کے سوا کوئی معبود نہیں... اور نماز قائم کرنا۔',
      reference: 'صحیح بخاری (۸)',
    ),
    HadithItem(
      category: 'عبادت و نماز',
      title: 'باجماعت نماز کا ثواب',
      arabic: 'صَلَاةُ الْجَمَاعَةِ تَفْضُلُ صَلَاةَ الْفَذِّ بِسَبْعٍ وَعِشْرِينَ دَرَجَةً',
      urduTranslation: 'باجماعت نماز اکیلے نماز پڑھنے سے ستائیس درجے فضیلت رکھتی ہے۔',
      reference: 'صحیح بخاری (۶۴۵)',
    ),
    HadithItem(
      category: 'عبادت و نماز',
      title: 'آنکھوں کی ٹھنڈک',
      arabic: 'وَجُعِلَتْ قُرَّةُ عَيْنِي فِي الصَّلَاةِ',
      urduTranslation: 'اور میری آنکھوں کی ٹھنڈک نماز میں رکھی گئی ہے۔',
      reference: 'سنن نسائی (۳۹۳۹)',
    ),
    HadithItem(
      category: 'عبادت و نماز',
      title: 'سجدے کی حالت میں دعا',
      arabic: 'أَقْرَبُ مَا يَكُونُ الْعَبْدُ مِنْ رَبِّهِ وَهُوَ سَاجِدٌ، فَأَكْثِرُوا الدُّعَاءَ',
      urduTranslation: 'بندہ اپنے رب کے سب سے زیادہ قریب سجدے کی حالت میں ہوتا ہے، لہٰذا اس میں کثرت سے دعا کیا کرو۔',
      reference: 'صحیح مسلم (۴۸۲)',
    ),
    HadithItem(
      category: 'عبادت و نماز',
      title: 'تہجد کی نماز',
      arabic: 'أَفْضَلُ الصِّيَامِ بَعْدَ رَمَضَانَ شَهْرُ اللَّهِ الْمُحَرَّمُ، وَأَفْضَلُ الصَّلَاةِ بَعْدَ الْفَرِيسَةِ صَلَاةُ اللَّيْلِ',
      urduTranslation: 'فرض نماز کے بعد سب سے افضل نماز رات کی نماز (تہجد) ہے۔',
      reference: 'صحیح مسلم (۱۱۶۳)',
    ),

    // ذکر و دعا
    HadithItem(
      category: 'ذکر و دعا',
      title: 'سب سے پیارا کلام',
      arabic: 'أَحَبُّ الْكَلَامِ إِلَى اللَّهِ أَرْبَعٌ: سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ',
      urduTranslation: 'اللہ تعالیٰ کو سب سے پیارے چار کلمات ہیں: سبحان اللہ، الحمد لله، لا إله إلا الله، واللہ أكبر۔',
      reference: 'صحیح مسلم (۲۱۳۵)',
    ),
    HadithItem(
      category: 'ذکر و دعا',
      title: 'وزن میں بھاری کلمات',
      arabic: 'كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِسَانِ، ثَقِيلَتَانِ فِي الْمِيزَانِ، حَبِيبَتَانِ إِلَى الرَّحْمَنِ: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      urduTranslation: 'دو کلمے زبان پر ہلکے، میزان میں بہت بھاری اور رحمان کو بہت محبوب ہیں: "سبحان الله وبحمده، سبحان الله العظيم"۔',
      reference: 'صحیح بخاری (۶۶۸۲)',
    ),
    HadithItem(
      category: 'ذکر و دعا',
      title: 'دعا عبادت کا مغز ہے',
      arabic: 'الدُّعَاءُ هُوَ الْعِبَادَةُ',
      urduTranslation: 'دعا ہی اصل عبادت ہے۔',
      reference: 'جامع ترمذی (۳۳۷۲)',
    ),
    HadithItem(
      category: 'ذکر و دعا',
      title: 'استغفار کی فضیلت',
      arabic: 'مَنْ لَزِمَ الِاسْتِغْفَارَ جَعَلَ اللَّهُ لَهُ مِنْ كُلِّ ضِيقٍ مَخْرَجًا، وَمِنْ كُلِّ هَمٍّ فَرَجًا',
      urduTranslation: 'جو شخص استغفار کو لازم پکڑ لے، اللہ تعالیٰ اس کے لیے ہر تنگی سے نکلنے کا راستہ بنا دیتا ہے اور ہر غم سے نجات دیتا ہے۔',
      reference: 'سنن ابی داود (۱۵۱۸)',
    ),

    // نیکی اور صدقہ
    HadithItem(
      category: 'نیکی اور صدقہ',
      title: 'صدقہ مال کو کم نہیں کرتا',
      arabic: 'مَا نَقَصَ مَالٌ مِنْ صَدَقَةٍ',
      urduTranslation: 'صدقہ کرنے سے مال کبھی کم نہیں ہوتا۔',
      reference: 'صحیح مسلم (۲۵۸۸)',
    ),
    HadithItem(
      category: 'نیکی اور صدقہ',
      title: 'جہنم کی آگ سے بچاؤ',
      arabic: 'اتَّقُوا النَّارَ وَلَوْ بِشِقِّ تَمْرَةٍ',
      urduTranslation: 'جہنم کی آگ سے بچو خواہ کھجور کے ایک ٹکڑے (صدقے) ہی کے ذریعے۔',
      reference: 'صحیح بخاری (۱۴۱۷)',
    ),
    HadithItem(
      category: 'نیکی اور صدقہ',
      title: 'ہر نیکی صدقہ ہے',
      arabic: 'كُلُّ مَعْرُوفٍ صَدَقَةٌ',
      urduTranslation: 'ہر نیکی کا کام صدقہ ہے۔',
      reference: 'صحیح بخاری (۶۰۲۱)',
    ),
    HadithItem(
      category: 'نیکی اور صدقہ',
      title: 'یتیم کی کفالت',
      arabic: 'أَنَا وَكَافِلُ الْيَتِيمِ فِي الْجَنَّةِ هَكَذَا',
      urduTranslation: 'میں اور یتیم کی کفالت کرنے والا جنت میں اس طرح ہوں گے (آپ ﷺ نے اپنی شہادت اور درمیانی انگلی سے اشارہ کیا)۔',
      reference: 'صحیح بخاری (۶۰۰۵)',
    ),

    // صبر و سکون
    HadithItem(
      category: 'صبر و سکون',
      title: 'صبر پہلی چوٹ پر ہے',
      arabic: 'إِنَّمَا الصَّبْرُ عِنْدَ الصَّدْمَةِ الْأُولَى',
      urduTranslation: 'صبر تو اصل میں صدمے کے شروع ہوتے ہی (پہلی چوٹ پر) کرنا ہے۔',
      reference: 'صحیح بخاری (۱۲۸۳)',
    ),
    HadithItem(
      category: 'صبر و سکون',
      title: 'مومن کی آزمائش',
      arabic: 'مَا يُصِيبُ الْمُسْلِمَ مِنْ نَصَبٍ وَلَا وَصَبٍ وَلَا هَمٍّ وَلَا حُزْنٍ وَلَا أَذًى وَلَا غَمٍّ حَتَّى الشَّوْكَةِ يُشَاكُهَا إِلَّا كَفَّرَ اللَّهُ بِهَا مِنْ خَطَايَاهُ',
      urduTranslation: 'مسلمان کو جو بھی تکلیف، بیماری، غم، رنج یا پریشانی پہنچتی ہے، یہاں تک کہ اگر اسے کانٹا بھی چبھ جائے، تو اللہ تعالیٰ اس کے بدلے اس کے گناہ معاف فرما دیتا ہے۔',
      reference: 'صحیح بخاری (۵۶۴۱)',
    ),
    HadithItem(
      category: 'صبر و سکون',
      title: 'بڑے صبر کا بدلہ بڑا اجر',
      arabic: 'إِذَا أَحَبَّ اللَّهُ قَوْمًا ابْتَلَاهُمْ',
      urduTranslation: 'جب اللہ تعالیٰ کسی قوم سے محبت کرتا ہے تو انہیں آزمائش میں مبتلا کرتا ہے۔',
      reference: 'جامع ترمذی (۲۳۹۶)',
    ),
  ];

  void _handleBack() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => const MoreScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredHadiths = _selectedCategory == 'سب'
        ? _hadiths
        : _hadiths.where((h) => h.category == _selectedCategory).toList();

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
              _categorySelector(),
              Expanded(
                child: filteredHadiths.isEmpty
                    ? const Center(
                  child: Text(
                    'اس زمرے میں کوئی حدیث نہیں ملی',
                    style: TextStyle(color: greyText, fontSize: 14),
                  ),
                )
                    : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  itemCount: filteredHadiths.length,
                  itemBuilder: (context, index) {
                    return _hadithCard(filteredHadiths[index]);
                  },
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'صحیح احادیث مبارکہ',
                  style: TextStyle(
                    color: green,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'فرامینِ نبی کریم ﷺ',
                  style: TextStyle(
                    color: whiteText,
                    fontSize: 18,
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

  Widget _categorySelector() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? greenDark : card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? green : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Center(
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? green : whiteText,
                      fontSize: 12,
                      fontWeight:
                      isSelected ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _hadithCard(HadithItem hadith) {
    final String id = 'hadith_${hadith.title}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  hadith.title,
                  style: const TextStyle(
                    color: whiteText,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: card2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hadith.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: gold,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
                      size: 20,
                    ),
                    onPressed: () async {
                      await FavoritesService.toggleFavorite(
                        id: id,
                        category: 'Hadith',
                        title: hadith.title,
                        content: '${hadith.arabic}\n\n${hadith.urduTranslation}',
                        subtitle: hadith.reference,
                      );
                      setState(() {});
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            hadith.arabic,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: gold,
              fontSize: 20,
              height: 1.6,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hadith.urduTranslation,
            style: const TextStyle(
              color: greyText,
              fontSize: 13.5,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                hadith.reference,
                style: const TextStyle(
                  color: green,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}