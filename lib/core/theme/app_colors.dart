import 'package:flutter/material.dart';

/// Colores de la marca UC (Universidad Católica de Cuenca)
/// Actualizados para el rediseño 2025
class AppColors {
  AppColors._();

  // ============== COLORES PRIMARIOS UC ==============
  static const Color ucRed = Color(0xFFB31B34);
  static const Color ucRedDark = Color(0xFF8B1428);
  static const Color ucRedLight = Color(0xFFD32F3F);
  
  static const Color ucGold = Color(0xFFD4A017);
  static const Color ucGoldLight = Color(0xFFF5D547);
  
  static const Color ucBlue = Color(0xFF1565C0);
  static const Color ucBlueLight = Color(0xFF2196F3);
  
  // ============== ALIASES PRINCIPALES ==============
  static const Color primary = ucRed;
  static const Color primaryDark = ucRedDark;
  static const Color primaryLight = ucRedLight;
  static const Color secondary = ucGold;
  static const Color accent = ucBlue;
  
  // ============== TEMA CLARO ==============
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF111827);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextMuted = Color(0xFF9CA3AF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightInputBg = Color(0xFFF3F4F6);
  
  // ============== TEMA OSCURO (Escala de grises pura, sin tonos azules) ==============
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color darkCardBackground = Color(0xFF1A1A1A);
  static const Color darkCardSecondary = Color(0xFF2A2A2A);
  static const Color darkText = Color(0xFFFAFAFA);
  static const Color darkTextPrimary = Color(0xFFFAFAFA);
  static const Color darkTextSecondary = Color(0xFFCCCCCC);
  static const Color darkTextMuted = Color(0xFFA0A0A0);
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color darkInputBg = Color(0xFF0F0F0F);
  static const Color darkHover = Color(0xFF404040);
  
  // ============== COLORES DE ESTADO ==============
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  
  // ============== COLORES DE CALENDARIO ==============
  static const Color calendarFree = Colors.white;
  static const Color calendarAvailable = Color(0xFFF0FDF4); // Green 50 - Disponible
  static const Color calendarOccupied = Color(0xFFFEE2E2); // Light red
  static const Color calendarOccupiedDark = Color(0xFF7F1D1D); // Dark red
  static const Color calendarSelected = Color(0xFFD1FAE5); // Light green
  static const Color calendarSelectedDark = Color(0xFF065F46); // Dark green
  static const Color calendarGroup1 = Color(0xFFBBF7D0); // Green 200
  static const Color calendarGroup2 = Color(0xFFBFDBFE); // Blue 200
  static const Color calendarConflict = Color(0xFFFECACA); // Red 200 - Conflicto entre grupos
  static const Color calendarBlocked = Color(0xFFD1D5DB); // Gray 300
  static const Color calendarLunch = Color(0xFFF97316); // Orange 500
  
  // ============== GRADIENTES ==============
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [ucRed, ucRedLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [ucGold, ucGoldLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkCard, darkBackground],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
