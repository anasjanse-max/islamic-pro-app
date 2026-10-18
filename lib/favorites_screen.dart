import 'package:flutter/material.dart';
import 'favorites_service.dart';
import 'more_screen.dart'; // Navigates smoothly back to More screen
import 'settings_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final bool fromMore;
  const FavoritesScreen({super.key, this.fromMore = false});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
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
            backgroundColor: appBackground,
            body: SafeArea(
              child: Column(
                children: [
                  _headerSection(),
                  _categoryFilterChips(),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                        child: CircularProgressIndicator(color: richEmerald))
                        : _filteredFavorites.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_border_rounded,
                              color: richEmerald.withValues(alpha: 0.4), size: 54),
                          const SizedBox(height: 14),
                          Text(
                            'No Saved Items Yet',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap the heart icon on any item to save it here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),

                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: _filteredFavorites.length,
                      itemBuilder: (context, index) {
                        final item = _filteredFavorites[index];
                        final String cat = item['category'] ?? 'Saved';

                        return RepaintBoundary(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: surfaceWhite,
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
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: secondarySurface,
                                        borderRadius:
                                        BorderRadius.circular(10),
                                        border: Border.all(color: borderSubtle),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getCategoryIcon(cat),
                                            color: richEmerald,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            cat,
                                            style: const TextStyle(
                                              color: richEmerald,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.favorite_rounded,
                                        color: Colors.redAccent,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _removeItem(item['id']),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  item['title'] ?? '',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if ((item['subtitle'] ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    item['subtitle'],
                                    style: const TextStyle(
                                        color: richEmerald,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                                if ((item['content'] ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    item['content'],
                                    style: TextStyle(
                                      color: textSecondary,
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
      },
    );
  }

  Widget _categoryFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final bool isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = cat);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? richEmerald : surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? richEmerald : borderSubtle,
                  ),
                ),
                child: Center(
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : textSecondary,
                      fontSize: 12.5,
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
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

  Widget _headerSection() {
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
                color: richEmerald,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: richEmerald),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: secondarySurface,
              border: Border.all(color: borderSubtle),
            ),
            child: const Icon(Icons.favorite_rounded, color: richEmerald, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SAVED COLLECTION',
                  style: TextStyle(
                    color: richEmerald,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Favorite Items',
                  style: TextStyle(
                    color: textPrimary,
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
}