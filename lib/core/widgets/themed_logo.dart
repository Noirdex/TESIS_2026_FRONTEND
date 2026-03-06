import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';
import '../theme/app_colors.dart';

/// Widget para mostrar logo según el tema
/// En modo claro muestra el logo a COLOR (original)
/// En modo oscuro muestra el logo en escala de grises
class ThemedLogo extends StatelessWidget {
  final double height;
  final double? width;
  final BoxFit fit;

  const ThemedLogo({
    super.key,
    required this.height,
    this.width,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    
    Widget logo = Image.asset(
      'assets/logoitevr.png',
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width ?? height,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.ucRed,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.school, color: Colors.white, size: height * 0.6),
      ),
    );

    // MODO CLARO: Logo a color (sin filtro)
    // MODO OSCURO: Logo en escala de grises (con filtro)
    if (isDark) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: logo,
      );
    }

    // Modo claro: devolver logo original (a color)
    return logo;
  }
}
