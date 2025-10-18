import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Language model to represent available languages
class Language {
  final String code;
  final String name;
  final String flag;

  const Language({required this.code, required this.name, required this.flag});
}

// Available languages
const List<Language> availableLanguages = [
  Language(code: 'en', name: 'English', flag: '🇺🇸'),
  Language(code: 'bn', name: 'বাংলা', flag: '🇧🇩'),
];

// Language state notifier
class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('en')) {
    _loadLanguage();
  }

  static const String _languageKey = 'selected_language';

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'en';
      state = Locale(languageCode);
    } catch (e) {
      // Default to English if loading fails
      state = const Locale('en');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      state = Locale(languageCode);
    } catch (e) {
      // Handle error - could show a snackbar or log
      debugPrint('Error saving language preference: $e');
    }
  }

  Language get currentLanguage {
    return availableLanguages.firstWhere(
      (language) => language.code == state.languageCode,
      orElse: () => availableLanguages.first,
    );
  }
}

// Provider for language selection
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

// Provider for current language object
final currentLanguageProvider = Provider<Language>((ref) {
  final locale = ref.watch(languageProvider);
  return availableLanguages.firstWhere(
    (language) => language.code == locale.languageCode,
    orElse: () => availableLanguages.first,
  );
});
