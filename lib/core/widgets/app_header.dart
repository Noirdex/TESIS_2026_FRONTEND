import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../providers/locale_provider.dart';
import 'app_button.dart';

/// Header moderno con logo, selector de idioma y tema
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onLogoTap;
  final VoidCallback? onLoginTap;
  final bool showLoginButton;
  final bool isTransparent;
  final String? loginText;

  const AppHeader({
    super.key,
    this.onLogoTap,
    this.onLoginTap,
    this.showLoginButton = true,
    this.isTransparent = false,
    this.loginText,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isTransparent 
            ? Colors.transparent 
            : (isDark 
                ? AppColors.darkBackground.withValues(alpha: 0.9) 
                : Colors.white.withValues(alpha: 0.9)),
        border: isTransparent 
            ? null 
            : Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Logo section
              GestureDetector(
                onTap: onLogoTap,
                child: Row(
                  children: [
                    // UC Logo
                    Image.asset(
                      'assets/logoitevr.png',
                      height: 40,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.ucRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 30,
                      width: 1,
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => 
                              AppColors.primaryGradient.createShader(bounds),
                          child: const Text(
                            'Aula ITE VR',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          'Aula Virtual',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark 
                                ? AppColors.darkTextMuted 
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Language selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: localeProvider.languageCode,
                    isDense: true,
                    icon: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(
                        value: 'es',
                        child: Text('🇪🇸 ES'),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text('🇬🇧 EN'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        localeProvider.setLocale(Locale(value));
                      }
                    },
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                    dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Theme toggle
              AppIconButton(
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                iconColor: isDark ? Colors.amber : AppColors.lightTextSecondary,
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: isDark ? 'Modo Claro' : 'Modo Oscuro',
              ),
              
              if (showLoginButton) ...[
                const SizedBox(width: 12),
                AppButton(
                  text: loginText ?? 'Iniciar Sesión',
                  trailingIcon: Icons.arrow_forward,
                  onPressed: onLoginTap,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Header simple con título centrado (para páginas internas)
class AppSimpleHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const AppSimpleHeader({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkBackground.withValues(alpha: 0.9) 
            : Colors.white.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (onBack != null)
                AppIconButton(
                  icon: Icons.arrow_back,
                  onPressed: onBack,
                ),
              if (onBack != null) const SizedBox(width: 12),
              
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                  textAlign: onBack == null ? TextAlign.center : TextAlign.start,
                ),
              ),
              
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}
