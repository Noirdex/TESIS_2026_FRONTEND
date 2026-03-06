import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';

/// Tipos de vista disponibles en el dashboard
enum DashboardView { schedule, bookings, profile, content, training, classrooms }

/// Layout compartido para páginas de Dashboard (Teacher/Admin)
class DashboardLayout extends StatefulWidget {
  final String pageTitle;
  final Widget child;
  final DashboardView currentView;
  final ValueChanged<DashboardView> onViewChange;
  final bool isAdmin;

  const DashboardLayout({
    super.key,
    required this.pageTitle,
    required this.child,
    required this.currentView,
    required this.onViewChange,
    this.isAdmin = false,
  });

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  bool _sidebarExpanded = false;

  void _toggleSidebar() {
    setState(() => _sidebarExpanded = !_sidebarExpanded);
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final lang = context.watch<LocaleProvider>().languageCode;
    final t = AppTranslations.of(lang);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          // Top Bar - siempre arriba
          _buildTopBar(isDark, t),
          
          // Contenido principal con sidebar
          Expanded(
            child: Stack(
              children: [
                // Main content with offset
                Row(
                  children: [
                    // Sidebar spacer
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isMobile 
                          ? 0 
                          : (_sidebarExpanded ? 240 : 80),
                    ),
                    
                    // Main content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
                
                // Sidebar overlay for mobile
                if (_sidebarExpanded && isMobile)
                  GestureDetector(
                    onTap: _toggleSidebar,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                
                // Sidebar - ahora empieza debajo del header
                _buildSidebar(isDark, t, isMobile),
              ],
            ),
          ),
        ],
      ),
      
      // Mobile bottom navigation
      bottomNavigationBar: isMobile ? _buildMobileNav(isDark, t) : null,
    );
  }

  Widget _buildTopBar(bool isDark, AppStrings t) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkBackground.withValues(alpha: 0.95) 
            : Colors.white.withValues(alpha: 0.95),
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
            // Logo left - con padding adecuado
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: ThemedLogo(height: 64),
            ),
            
            // Title center - expandido para ocupar el espacio restante
            Expanded(
              child: Center(
                child: Text(
                  widget.pageTitle,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ),
            ),
            
            // Spacer derecho para balancear el logo
            const SizedBox(width: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(bool isDark, AppStrings t, bool isMobile) {
    final sidebarWidth = _sidebarExpanded ? 240.0 : 80.0;
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      left: isMobile && !_sidebarExpanded ? -sidebarWidth : 0,
      top: 0,
      bottom: 0,
      width: sidebarWidth,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          border: Border(
            right: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
        ),
        child: Column(
          children: [
            // Menu toggle button
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: InkWell(
                onTap: _toggleSidebar,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.menu,
                        size: 24,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                      if (_sidebarExpanded) ...[
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            t.menu,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark 
                                  ? AppColors.darkText 
                                  : AppColors.lightText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            // Navigation items
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildNavItem(
                      icon: Icons.event_available,
                      label: 'Agendar',
                      view: DashboardView.schedule,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildNavItem(
                      icon: Icons.calendar_month,
                      label: 'Agendas',
                      view: DashboardView.bookings,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildNavItem(
                      icon: Icons.person,
                      label: 'Perfil',
                      view: DashboardView.profile,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    // Capacitaciones disponible para todos (docentes ven solo lectura)
                    _buildNavItem(
                      icon: Icons.school,
                      label: 'Capacitaciones',
                      view: DashboardView.training,
                      isDark: isDark,
                    ),
                    
                    // Admin-only items
                    if (widget.isAdmin) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          color: isDark 
                              ? AppColors.darkBorder 
                              : AppColors.lightBorder,
                        ),
                      ),
                      _buildNavItem(
                        icon: Icons.business,
                        label: 'Gestión de Aulas',
                        view: DashboardView.classrooms,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildNavItem(
                        icon: Icons.article,
                        label: 'Editor Landing',
                        view: DashboardView.content,
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Bottom actions - con scrollable si hay overflow
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Language selector (expanded only)
                  if (_sidebarExpanded) ...[
                    _buildLanguageSelector(isDark),
                    const SizedBox(height: 8),
                  ],
                  
                  // Theme toggle
                  _buildBottomAction(
                    icon: isDark ? Icons.dark_mode : Icons.light_mode,
                    label: isDark ? t.darkMode : t.lightMode,
                    iconColor: isDark ? Colors.amber : null,
                    isDark: isDark,
                    onTap: () {
                      context.read<ThemeProvider>().toggleTheme();
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  // Logout
                  _buildBottomAction(
                    icon: Icons.logout,
                    label: t.logout,
                    iconColor: AppColors.error,
                    isDark: isDark,
                    onTap: _handleLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required DashboardView view,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    final isActive = widget.currentView == view;
    
    return InkWell(
      onTap: onTap ?? () {
        widget.onViewChange(view);
        if (MediaQuery.of(context).size.width < 768) {
          setState(() => _sidebarExpanded = false);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive
                  ? Colors.white
                  : (isDark 
                      ? AppColors.darkTextMuted 
                      : AppColors.lightTextSecondary),
            ),
            if (_sidebarExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isActive
                        ? Colors.white
                        : (isDark 
                            ? AppColors.darkTextMuted 
                            : AppColors.lightTextSecondary),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required bool isDark,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: iconColor ?? (isDark 
                  ? AppColors.darkTextMuted 
                  : AppColors.lightTextSecondary),
            ),
            if (_sidebarExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: iconColor ?? (isDark 
                        ? AppColors.darkTextMuted 
                        : AppColors.lightTextSecondary),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(bool isDark) {
    final localeProvider = context.watch<LocaleProvider>();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: localeProvider.languageCode,
          isExpanded: true,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items: const [
            DropdownMenuItem(value: 'es', child: Text('🇪🇸 Español')),
            DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
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
    );
  }

  Widget? _buildMobileNav(bool isDark, AppStrings t) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMobileNavItem(
              icon: Icons.event_available,
              label: 'Agendar',
              view: DashboardView.schedule,
              isDark: isDark,
            ),
            _buildMobileNavItem(
              icon: Icons.calendar_month,
              label: 'Agendas',
              view: DashboardView.bookings,
              isDark: isDark,
            ),
            _buildMobileNavItem(
              icon: Icons.person,
              label: 'Perfil',
              view: DashboardView.profile,
              isDark: isDark,
            ),
            IconButton(
              icon: Icon(
                Icons.menu,
                color: isDark 
                    ? AppColors.darkTextMuted 
                    : AppColors.lightTextSecondary,
              ),
              onPressed: _toggleSidebar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNavItem({
    required IconData icon,
    required String label,
    required DashboardView view,
    required bool isDark,
  }) {
    final isActive = widget.currentView == view;
    
    return InkWell(
      onTap: () => widget.onViewChange(view),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive
                  ? AppColors.ucRed
                  : (isDark 
                      ? AppColors.darkTextMuted 
                      : AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive
                    ? AppColors.ucRed
                    : (isDark 
                        ? AppColors.darkTextMuted 
                        : AppColors.lightTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
