import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  double _textScale = 1.0;
  double _cornerRadius = 12.0;

  bool get isDarkMode => _isDarkMode;
  double get textScale => _textScale;
  double get cornerRadius => _cornerRadius;

  ThemeData get theme =>
      _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  void toggleTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }

  void setTextScale(double value) {
    _textScale = value;
    notifyListeners();
  }

  void setCornerRadius(double value) {
    _cornerRadius = value;
    notifyListeners();
  }
}

// A Riverpod provider to manage ThemeMode globally for the app.
// This keeps the Riverpod provider colocated with the theme-related logic.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
