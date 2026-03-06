import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/core.dart';

/// Widget para seleccionar un aula VR
class AulaSelector extends StatelessWidget {
  final List<Map<String, dynamic>> aulas;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  const AulaSelector({
    super.key,
    required this.aulas,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cards compactas horizontales en un Wrap para mejor adaptabilidad
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: aulas.asMap().entries.map((entry) {
            final index = entry.key;
            final aula = entry.value;
            final isSelected = selectedIndex == index;
            
            // Ancho adaptativo según el espacio disponible
            final cardWidth = constraints.maxWidth > 900 
                ? (constraints.maxWidth - 32) / 3 - 8
                : constraints.maxWidth > 600 
                    ? (constraints.maxWidth - 16) / 2 - 8
                    : constraints.maxWidth;
            
            return SizedBox(
              width: cardWidth,
              child: _buildCompactAulaCard(
                context,
                aula: aula,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () => onSelect(index),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCompactAulaCard(
    BuildContext context, {
    required Map<String, dynamic> aula,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 90, // Altura ajustada para imagen más grande
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected 
                ? AppColors.ucRed 
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.ucRed.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Row(
            children: [
              // Imagen más grande a la izquierda
              SizedBox(
                width: 100, // Imagen más ancha
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: aula['image'] as String,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark ? AppColors.darkBackground : Colors.grey[200],
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.ucRed,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? AppColors.darkBackground : Colors.grey[200],
                        child: Icon(
                          Icons.vrpano,
                          color: isDark 
                              ? AppColors.darkTextMuted 
                              : AppColors.lightTextSecondary,
                          size: 28,
                        ),
                      ),
                    ),
                    // Selection indicator
                    if (isSelected)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Info compacta a la derecha - usando Flexible para evitar overflow
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        aula['name'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        aula['location'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark 
                              ? AppColors.darkTextMuted 
                              : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Row con Flexible para evitar overflow
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people,
                            size: 12,
                            color: isDark 
                                ? AppColors.darkTextMuted 
                                : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${aula['capacity']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark 
                                  ? AppColors.darkText 
                                  : AppColors.lightText,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: isDark 
                                ? AppColors.darkTextMuted 
                                : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              aula['schedule'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark 
                                    ? AppColors.darkText 
                                    : AppColors.lightText,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
