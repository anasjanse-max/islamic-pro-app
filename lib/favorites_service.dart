import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'user_saved_favorites';

  // All Saved Favorites
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null || data.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(data);
      return List<Map<String, dynamic>>.from(decoded);
    } catch (_) {
      return [];
    }
  }

  // Check if an item is already favorited by ID
  static Future<bool> isFavorite(String id) async {
    final favorites = await getFavorites();
    return favorites.any((item) => item['id'] == id);
  }

  // Toggle Favorite (Add if not present, Remove if present)
  static Future<bool> toggleFavorite({
    required String id,
    required String category,
    required String title,
    required String content,
    String? subtitle,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    final int existingIndex = favorites.indexWhere((item) => item['id'] == id);

    bool isNowFavorite = false;
    if (existingIndex >= 0) {
      favorites.removeAt(existingIndex);
      isNowFavorite = false;
    } else {
      favorites.insert(0, {
        'id': id,
        'category': category,
        'title': title,
        'content': content,
        'subtitle': subtitle ?? '',
        'date': DateTime.now().toIso8601String(),
      });
      isNowFavorite = true;
    }

    await prefs.setString(_key, jsonEncode(favorites));
    return isNowFavorite;
  }

  // Remove Favorite
  static Future<void> removeFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.removeWhere((item) => item['id'] == id);
    await prefs.setString(_key, jsonEncode(favorites));
  }
}