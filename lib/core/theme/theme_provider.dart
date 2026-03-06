import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gestión de tema (claro/oscuro)
/// Persiste la preferencia del usuario en SharedPreferences
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'ite-vr-theme';
  
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  /// Carga la preferencia de tema guardada
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      if (savedTheme != null) {
        _isDarkMode = savedTheme == 'dark';
      } else {
        // Detectar preferencia del sistema
        _isDarkMode = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }
  
  /// Cambia entre tema claro y oscuro
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, _isDarkMode ? 'dark' : 'light');
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
  
  /// Establece un tema específico
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, _isDarkMode ? 'dark' : 'light');
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}
