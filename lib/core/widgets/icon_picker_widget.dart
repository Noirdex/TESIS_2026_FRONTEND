import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../providers/locale_provider.dart';

/// Icono disponible para seleccionar
class AvailableIcon {
  final String name;
  final IconData icon;
  final String labelEs;
  final String labelEn;
  
  const AvailableIcon({
    required this.name,
    required this.icon,
    required this.labelEs,
    required this.labelEn,
  });
  
  String getLabel(bool isSpanish) => isSpanish ? labelEs : labelEn;
}

/// Lista de iconos disponibles para features y otras secciones
const List<AvailableIcon> availableIcons = [
  AvailableIcon(name: 'monitor', icon: LucideIcons.monitor, labelEs: 'Monitor', labelEn: 'Monitor'),
  AvailableIcon(name: 'users', icon: LucideIcons.users, labelEs: 'Usuarios', labelEn: 'Users'),
  AvailableIcon(name: 'calendar', icon: LucideIcons.calendar, labelEs: 'Calendario', labelEn: 'Calendar'),
  AvailableIcon(name: 'shield', icon: LucideIcons.shield, labelEs: 'Escudo', labelEn: 'Shield'),
  AvailableIcon(name: 'zap', icon: LucideIcons.zap, labelEs: 'Rayo', labelEn: 'Zap'),
  AvailableIcon(name: 'headphones', icon: LucideIcons.headphones, labelEs: 'Audifonos', labelEn: 'Headphones'),
  AvailableIcon(name: 'glasses', icon: LucideIcons.glasses, labelEs: 'Gafas VR', labelEn: 'VR Glasses'),
  AvailableIcon(name: 'star', icon: LucideIcons.star, labelEs: 'Estrella', labelEn: 'Star'),
  AvailableIcon(name: 'heart', icon: LucideIcons.heart, labelEs: 'Corazon', labelEn: 'Heart'),
  AvailableIcon(name: 'award', icon: LucideIcons.award, labelEs: 'Premio', labelEn: 'Award'),
  AvailableIcon(name: 'book', icon: LucideIcons.bookOpen, labelEs: 'Libro', labelEn: 'Book'),
  AvailableIcon(name: 'clock', icon: LucideIcons.clock, labelEs: 'Reloj', labelEn: 'Clock'),
  AvailableIcon(name: 'globe', icon: LucideIcons.globe, labelEs: 'Globo', labelEn: 'Globe'),
  AvailableIcon(name: 'settings', icon: LucideIcons.settings, labelEs: 'Ajustes', labelEn: 'Settings'),
  AvailableIcon(name: 'target', icon: LucideIcons.target, labelEs: 'Objetivo', labelEn: 'Target'),
  AvailableIcon(name: 'lightbulb', icon: LucideIcons.lightbulb, labelEs: 'Idea', labelEn: 'Lightbulb'),
  AvailableIcon(name: 'rocket', icon: LucideIcons.rocket, labelEs: 'Cohete', labelEn: 'Rocket'),
  AvailableIcon(name: 'cpu', icon: LucideIcons.cpu, labelEs: 'CPU', labelEn: 'CPU'),
  AvailableIcon(name: 'gamepad', icon: LucideIcons.gamepad2, labelEs: 'Control', labelEn: 'Gamepad'),
  AvailableIcon(name: 'wifi', icon: LucideIcons.wifi, labelEs: 'WiFi', labelEn: 'WiFi'),
];

/// Widget para seleccionar un icono de una cuadricula visual
class IconPickerWidget extends StatelessWidget {
  final String? selectedIcon;
  final ValueChanged<String> onIconSelected;
  final int crossAxisCount;
  final double iconSize;
  
  const IconPickerWidget({
    super.key,
    this.selectedIcon,
    required this.onIconSelected,
    this.crossAxisCount = 5,
    this.iconSize = 24,
  });
  
  /// Obtiene el IconData para un nombre de icono
  static IconData getIconData(String name) {
    final icon = availableIcons.firstWhere(
      (i) => i.name == name,
      orElse: () => availableIcons.first,
    );
    return icon.icon;
  }
  
  /// Muestra el selector de iconos en un dialogo
  static Future<String?> show({
    required BuildContext context,
    String? initialIcon,
  }) async {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final isSpanish = context.read<LocaleProvider>().isSpanish;
    String? selected = initialIcon;
    
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.shapes, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                isSpanish ? 'Seleccionar Icono' : 'Select Icon',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 350,
            height: 350,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: availableIcons.length,
              itemBuilder: (ctx, index) {
                final iconItem = availableIcons[index];
                final isSelected = selected == iconItem.name;
                
                return Tooltip(
                  message: iconItem.getLabel(isSpanish),
                  child: InkWell(
                    onTap: () {
                      setDialogState(() => selected = iconItem.name);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : (isDark ? AppColors.darkBackground : AppColors.lightInputBg),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.primary 
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            iconItem.icon,
                            size: 24,
                            color: isSelected 
                                ? AppColors.primary 
                                : (isDark ? AppColors.darkText : AppColors.lightText),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isSpanish ? 'Cancelar' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: selected != null ? () => Navigator.pop(ctx, selected) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(isSpanish ? 'Seleccionar' : 'Select'),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: availableIcons.length,
      itemBuilder: (ctx, index) {
        final iconItem = availableIcons[index];
        final isSelected = selectedIcon == iconItem.name;
        
        return Tooltip(
          message: iconItem.getLabel(isSpanish),
          child: InkWell(
            onTap: () => onIconSelected(iconItem.name),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : (isDark ? AppColors.darkBackground : AppColors.lightInputBg),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected 
                      ? AppColors.primary 
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                iconItem.icon,
                size: iconSize,
                color: isSelected 
                    ? AppColors.primary 
                    : (isDark ? AppColors.darkText : AppColors.lightText),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Boton para abrir el selector de iconos mostrando el icono actual
class IconPickerButton extends StatelessWidget {
  final String? selectedIcon;
  final ValueChanged<String> onIconSelected;
  
  const IconPickerButton({
    super.key,
    this.selectedIcon,
    required this.onIconSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;
    
    final iconData = selectedIcon != null 
        ? IconPickerWidget.getIconData(selectedIcon!)
        : LucideIcons.shapes;
    
    return InkWell(
      onTap: () async {
        final result = await IconPickerWidget.show(
          context: context,
          initialIcon: selectedIcon,
        );
        if (result != null) {
          onIconSelected(result);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(iconData, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              selectedIcon ?? (isSpanish ? 'Seleccionar icono' : 'Select icon'),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevronDown,
              size: 16,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
