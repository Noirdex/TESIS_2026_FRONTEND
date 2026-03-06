import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gestión de idioma
/// Persiste la preferencia del usuario en SharedPreferences
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'ite-vr-language';
  
  Locale _locale = const Locale('es');
  Locale get locale => _locale;
  
  String get languageCode => _locale.languageCode;
  bool get isSpanish => _locale.languageCode == 'es';
  bool get isEnglish => _locale.languageCode == 'en';
  
  LocaleProvider() {
    _loadLocale();
  }
  
  /// Carga la preferencia de idioma guardada
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localeKey);
      if (savedLocale != null) {
        _locale = Locale(savedLocale);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading locale: $e');
    }
  }
  
  /// Establece un idioma específico
  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, newLocale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }
  
  /// Alterna entre español e inglés
  Future<void> toggle() async {
    final newLocale = _locale.languageCode == 'es' 
        ? const Locale('en') 
        : const Locale('es');
    await setLocale(newLocale);
  }
}

/// Idiomas soportados
class L10n {
  static const all = [
    Locale('es'),
    Locale('en'),
  ];
}
