import 'package:flutter/material.dart';
import 'favorites_service.dart';
import 'more_screen.dart'; // Navigates smoothly back to More screen

class FavoritesScreen extends StatefulWidget {
  final bool fromMore;
  const FavoritesScreen({super.key, this.fromMore = false});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static const Color background = Color(0xFF000000);
  static const Color card = Color(0xFF0A0F0C);
  static const Color green = Color(0xFF26E17A);
  static const Color gold = Color(0xFFE8B63D);
  static const Color whiteText = Color(0xFFF4F6F5);
  static const Color greyText = Color(0xFF98A19D);

  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Quran',
    'Dua',
    'Hadith',
    'Names',
    'Article',
    'Calendar'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final list = await FavoritesService.getFavorites();
    setState(() {
      _favorites = list;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredFavorites {
    if (_selectedCategory == 'All') return _favorites;
    return _favorites
        .where((item) => item['category'] == _selectedCategory)
        .toList();
  }

  Future<void> _removeItem(String id) async {
    await FavoritesService.removeFavorite(id);
    _loadData();
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Quran':
        return Icons.menu_book_rounded;
      case 'Dua':
        return Icons.volunteer_activism_rounded;
      case 'Hadith':
        return Icons.menu_book_sharp;
      case 'Names':
        return Icons.auto_awesome_rounded;
      case 'Article':
        return Icons.article_rounded;
      case 'Calendar':
        return Icons.calendar_month_rounded;
      default:
        return Icons.bookmark_rounded;
    }
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
              _headerSection(),
              _categoryFilterChips(),
              Expanded(
                child: _isLoading
                    ? const Center(
                    child: CircularProgressIndicator(color: green))
                    : _filteredFavorites.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border_rounded,
                          color: gold.withValues(alpha: 0.5), size: 60),
                      const SizedBox(height: 14),
                      const Text(
                        'No Saved Items Yet',
                        style: TextStyle(
                          color: whiteText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap the heart icon on any item to save it here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: greyText, fontSize: 12),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  cacheExtent: 2000,
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredFavorites.length,
                  itemBuilder: (context, index) {
                    final item = _filteredFavorites[index];
                    final String cat = item['category'] ?? 'Saved';

                    return RepaintBoundary(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: gold.withValues(alpha: 0.12),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getCategoryIcon(cat),
                                        color: gold,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        cat,
                                        style: const TextStyle(
                                          color: gold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(
                                    Icons.favorite_rounded,
                                    color: Colors.redAccent,
                                    size: 22,
                                  ),
                                  onPressed: () =>
                                      _removeItem(item['id']),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['title'] ?? '',
                              style: const TextStyle(
                                color: whiteText,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if ((item['subtitle'] ?? '').isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                item['subtitle'],
                                style: const TextStyle(
                                    color: green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                            if ((item['content'] ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                item['content'],
                                style: const TextStyle(
                                  color: whiteText,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
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

  Widget _categoryFilterChips() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final bool isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = cat);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? green : card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? green
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.black : whiteText,
                  fontSize: 12,
                  fontWeight:
                  isSelected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _headerSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 20, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: whiteText, size: 20),
          ),
          const SizedBox(width: 2),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold.withValues(alpha: 0.08),
              border: Border.all(color: gold.withValues(alpha: 0.6), width: 1.5),
            ),
            child: const Icon(Icons.favorite_rounded, color: gold, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SAVED COLLECTION',
                  style: TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Favorite Items',
                  style: TextStyle(
                    color: whiteText,
                    fontSize: 17,
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
}