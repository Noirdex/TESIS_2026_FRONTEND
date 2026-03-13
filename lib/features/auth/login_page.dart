import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../core/services/auth_service.dart';

/// Página de Login con diseño moderno
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String? _errorMessage;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authService.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final result = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (result.isSuccess && result.user != null) {
      final user = result.user!;
      if (user.role == UserRole.teacher) {
        Navigator.pushReplacementNamed(context, '/teacher-scheduling');
      } else if (user.role == UserRole.admin || user.role == UserRole.superAdmin) {
        Navigator.pushReplacementNamed(context, '/admin-scheduling');
      }
    } else {
      setState(() {
        _errorMessage = result.error ?? AppTranslations.get('invalid_credentials', 
            context.read<LocaleProvider>().languageCode);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final lang = context.watch<LocaleProvider>().languageCode;
    final t = AppTranslations.of(lang);

    return Scaffold(
      backgroundColor: isDark 
          ? AppColors.darkBackground 
          : const Color(0xFFF3F4F6),
      body: Column(
        children: [
          // Header
          _buildHeader(isDark, t),
          
          // Content
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 800;
                      
                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left side - Info
                            Expanded(
                              child: _buildInfoSection(isDark, t),
                            ),
                            const SizedBox(width: 48),
                            // Right side - Login card
                            Expanded(
                              child: _buildLoginCard(isDark, t),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildInfoSection(isDark, t),
                            const SizedBox(height: 32),
                            _buildLoginCard(isDark, t),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, AppStrings t) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
        child: Row(
          children: [
            // Logo - clickeable para volver
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
              child: Row(
                children: [
                  const ThemedLogo(height: 40),
                  const SizedBox(width: 12),
                  Container(
                    height: 30,
                    width: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                        t.vrClassroom,
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
                    DropdownMenuItem(value: 'es', child: Text('🇪🇸 ES')),
                    DropdownMenuItem(value: 'en', child: Text('🇬🇧 EN')),
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
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightInputBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: isDark ? Colors.amber : AppColors.lightTextSecondary,
                ),
                onPressed: () => themeProvider.toggleTheme(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(bool isDark, AppStrings t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ITE VR Logo grande
        const ThemedLogo(height: 80),
        const SizedBox(height: 24),
        
        // Title with gradient
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Text(
            t.welcomeSchedulingSystem,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Features
        AppInfoCard(
          icon: Icons.shield,
          title: t.secureAccess,
          description: t.secureAccessDesc,
          iconGradient: AppColors.primaryGradient,
        ),
        const SizedBox(height: 20),
        AppInfoCard(
          icon: Icons.access_time,
          title: t.realTimeBooking,
          description: t.realTimeBookingDesc,
          iconGradient: AppColors.goldGradient,
        ),
        const SizedBox(height: 20),
        AppInfoCard(
          icon: Icons.flash_on,
          title: t.fastProcess,
          description: t.fastProcessDesc,
          iconGradient: AppColors.primaryGradient,
        ),
      ],
    );
  }

  Widget _buildLoginCard(bool isDark, AppStrings t) {
    return AppCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            t.loginTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.loginSubtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark 
                  ? AppColors.darkTextMuted 
                  : AppColors.lightTextSecondary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Info box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColors.darkBackground 
                  : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark 
                    ? AppColors.darkBorder 
                    : const Color(0xFFBFDBFE),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: isDark 
                      ? AppColors.darkTextSecondary 
                      : const Color(0xFF1E40AF),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ingrese con su correo institucional y contraseña registrados en el sistema.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark 
                          ? AppColors.darkTextSecondary 
                          : const Color(0xFF1E40AF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Form fields
          AppTextField(
            label: t.institutionalEmail,
            hint: 'usuario@ucacue.edu.ec',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          
          const SizedBox(height: 16),
          
          AppTextField(
            label: t.password,
            hint: '••••••••',
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onEditingComplete: _handleLogin,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: isDark 
                    ? AppColors.darkTextMuted 
                    : AppColors.lightTextMuted,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
          
          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.error.withValues(alpha: 0.1) 
                    : AppColors.errorLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark 
                      ? AppColors.error.withValues(alpha: 0.3) 
                      : AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: isDark ? AppColors.error : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.error : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Login button
          AppButton(
            text: t.continueBtn,
            trailingIcon: Icons.arrow_forward,
            onPressed: _handleLogin,
            isLoading: _isLoading,
            isFullWidth: true,
          ),
          
          const SizedBox(height: 16),
          
          // Forgot password
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                t.forgotPassword,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark 
                      ? AppColors.darkTextMuted 
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Help section
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${t.needHelp} ',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark 
                        ? AppColors.darkTextMuted 
                        : AppColors.lightTextSecondary,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    t.contactSupport,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ucRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
