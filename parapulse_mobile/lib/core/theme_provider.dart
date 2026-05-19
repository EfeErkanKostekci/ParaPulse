import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = true;
  Color _accentColor = const Color(0xFF10B981); // Default Green

  bool get isDarkMode => _isDarkMode;
  Color get accentColor => _accentColor;

  static const Color greenAccent = Color(0xFF10B981);
  static const Color blueAccent = Color(0xFF3B82F6);
  static const Color purpleAccent = Color(0xFF8B5CF6);
  
  static const Color coralRed = Color(0xFFF43F5E); // Always red for errors/expenses

  ThemeNotifier() {
    _loadFromPrefs();
  }

  void toggleTheme(bool isDark) {
    _isDarkMode = isDark;
    _saveToPrefs();
    notifyListeners();
  }

  void setAccentColor(Color color) {
    _accentColor = color;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    final colorValue = prefs.getInt('accentColor');
    if (colorValue != null) {
      _accentColor = Color(colorValue);
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setInt('accentColor', _accentColor.value);
  }

  ThemeData get currentTheme {
    final bgColor = _isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = _isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = _isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
    final subTextColor = _isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: _accentColor,
      scaffoldBackgroundColor: bgColor,
      cardColor: cardColor,
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        elevation: 0,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
        bodySmall: TextStyle(color: subTextColor),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accentColor,
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primary: _accentColor,
        surface: cardColor,
        error: coralRed,
      ),
    );
  }
}
