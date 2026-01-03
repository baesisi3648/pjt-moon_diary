import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _themeKey = 'isDarkMode';
  
  late Box _settingsBox;
  bool _isDarkMode = true; // Default to dark mode for night diary

  bool get isDarkMode => _isDarkMode;

  Future<void> init() async {
    _settingsBox = await Hive.openBox(_boxName);
    _isDarkMode = _settingsBox.get(_themeKey, defaultValue: true);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _settingsBox.put(_themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _settingsBox.put(_themeKey, value);
    notifyListeners();
  }
}
