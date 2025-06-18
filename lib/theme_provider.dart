import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Light theme colors
  static const Color primaryColorLight = Color(0xFF00704A);
  static const Color backgroundColorLight = Colors.white;
  static const Color textColorLight = Colors.black;
  static const Color secondaryTextColorLight = Colors.grey;
  static const Color cardColorLight = Colors.white;
  static const Color dividerColorLight = Color(0xFFEEEEEE);
  
  // Dark theme colors
  static const Color primaryColorDark = Color(0xFF2DBC6F);
  static const Color backgroundColorDark = Color(0xFF121212);
  static const Color textColorDark = Colors.white;
  static const Color secondaryTextColorDark = Color(0xFFAAAAAA);
  static const Color cardColorDark = Color(0xFF1E1E1E);
  static const Color dividerColorDark = Color(0xFF2C2C2C);

  ThemeProvider() {
    _loadThemePreference();
  }

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // Save theme preference
  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  // Toggle theme
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemePreference();
    notifyListeners();
  }

  // Get current theme data
  ThemeData getTheme() {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  // Light theme
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColorLight,
    scaffoldBackgroundColor: backgroundColorLight,
    cardColor: cardColorLight,
    dividerColor: dividerColorLight,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColorLight),
      bodyMedium: TextStyle(color: textColorLight),
      titleLarge: TextStyle(color: textColorLight),
      titleMedium: TextStyle(color: textColorLight),
      titleSmall: TextStyle(color: textColorLight),
    ),
    colorScheme: ColorScheme.light(
      primary: primaryColorLight,
      secondary: primaryColorLight,
      surface: cardColorLight,
      background: backgroundColorLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textColorLight,
      onBackground: textColorLight,
    ),
  );

  // Dark theme
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColorDark,
    scaffoldBackgroundColor: backgroundColorDark,
    cardColor: cardColorDark,
    dividerColor: dividerColorDark,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColorDark),
      bodyMedium: TextStyle(color: textColorDark),
      titleLarge: TextStyle(color: textColorDark),
      titleMedium: TextStyle(color: textColorDark),
      titleSmall: TextStyle(color: textColorDark),
    ),
    colorScheme: ColorScheme.dark(
      primary: primaryColorDark,
      secondary: primaryColorDark,
      surface: cardColorDark,
      background: backgroundColorDark,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: textColorDark,
      onBackground: textColorDark,
    ),
  );

  // Get color based on current theme
  Color getPrimaryColor() => _isDarkMode ? primaryColorDark : primaryColorLight;
  Color getBackgroundColor() => _isDarkMode ? backgroundColorDark : backgroundColorLight;
  Color getTextColor() => _isDarkMode ? textColorDark : textColorLight;
  Color getSecondaryTextColor() => _isDarkMode ? secondaryTextColorDark : secondaryTextColorLight;
  Color getCardColor() => _isDarkMode ? cardColorDark : cardColorLight;
  Color getDividerColor() => _isDarkMode ? dividerColorDark : dividerColorLight;
}