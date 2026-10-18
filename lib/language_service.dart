// Dummy file to fix the ghost cache error
class LanguageService {
  static Future<String> getLanguage() async {
    return 'en';
  }
  static Future<void> setLanguage(String langCode) async {}
}