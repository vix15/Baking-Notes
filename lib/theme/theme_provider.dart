import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:baking_notes/theme/theme_constants.dart';
 
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  final Box _settingsBox = Hive.box('settings');
 
  ThemeProvider() {
    _loadTheme();
  }
 
  void _loadTheme() {
    try {
      _isDarkMode = _settingsBox?.get('isDarkMode', defaultValue: false) ?? false;
    } catch (e) {
      _isDarkMode = false;
    }
  }
 
  bool get isDarkMode => _isDarkMode;
 
  ThemeData get themeData {
    return _isDarkMode ? darkTheme : lightTheme;
  }
 
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }
 
  void setTheme(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      _saveTheme();
      notifyListeners();
    }
  }
 
  void _saveTheme() {
    try {
      _settingsBox?.put('isDarkMode', _isDarkMode);
    } catch (e) {
      // Handle error silently
    }
  }
}