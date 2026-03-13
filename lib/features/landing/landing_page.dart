import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/core.dart';
import '../../core/services/landing_service.dart';

/// Landing Page principal con diseño moderno
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentCarouselIndex = 0;
  
  late final LandingService _landingService;
  bool _isLoading = true;
  String? _errorMessage;

  // Datos del carrusel (cargados desde API)
  List<Map<String, String>> _slides = [];
  
  // Datos de equipos VR (cargados desde API)
  List<Map<String, dynamic>> _vrHeadsets = [];

  // Datos de fallback si la API no responde
  static const List<Map<String, String>> _defaultSlides = [
    {
      'title': 'Aula de Realidad Virtual',
      'description': 'Tecnología de vanguardia para experiencias inmersivas de aprendizaje',
      'image': 'https://images.unsplash.com/photo-1696041758578-db4b9b94a4cf?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1920',
    },
    {
      'title': 'Educación Innovadora',
      'description': 'Aprendizaje práctico con equipos Meta Quest 2, Quest 3 y Apple Vision Pro',
      'image': 'https://images.unsplash.com/photo-1653158861306-e5b3804f6115?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1920',
    },
    {
      'title': 'Acceso para Todos',
      'description': 'Disponible para docentes y estudiantes de todas las facultades',
      'image': 'https://images.unsplash.com/photo-1719159381916-062fa9f435a6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1920',
    },
  ];

  static const List<Map<String, dynamic>> _defaultVrHeadsets = [
    {
      'name': 'Meta Quest 3',
      'description': 'La última generación de VR con gráficos mejorados y realidad mixta',
      'image': 'https://images.unsplash.com/photo-1696041758578-db4b9b94a4cf?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800',
      'specs': ['Resolución 2064x2208 por ojo', 'Realidad Mixta en color', 'Controladores Touch Plus'],
      'count': 5,
    },
    {
      'name': 'Meta Quest 2',
      'description': 'VR accesible y potente para educación inmersiva',
      'image': 'https://images.unsplash.com/photo-1653158861306-e5b3804f6115?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800',
      'specs': ['Resolución 1832x1920 por ojo', 'Seguimiento inside-out', '6GB RAM'],
      'count': 4,
    },
    {
      'name': 'Meta Quest 1',
      'description': 'VR inalámbrico para experiencias educativas básicas',
      'image': 'https://images.unsplash.com/photo-1626387346555-08f186d8c407?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800',
      'specs': ['Resolución 1440x1600 por ojo', 'Totalmente inalámbrico', 'Biblioteca amplia'],
      'count': 3,
    },
    {
      'name': 'Oculus Rift S',
      'description': 'VR conectado a PC para aplicaciones de alto rendimiento',
      'image': 'https://images.unsplash.com/photo-1626387346555-08f186d8c407?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800',
      'specs': ['Resolución 1280x1440 por ojo', 'Conectado a PC', 'Tracking preciso'],
      'count': 2,
    },
    {
      'name': 'Apple Vision Pro',
      'description': 'Computación espacial de nueva generación',
      'image': 'https://images.unsplash.com/photo-1706902734937-53502170bbf1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=800',
      'specs': ['Resolución 4K por ojo', 'Eye tracking avanzado', 'Realidad mixta premium'],
      'count': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _landingService = LandingService();
    _loadLandingContent();
  }

  @override
  void dispose() {
    _landingService.dispose();
    super.dispose();
  }

  Future<void> _loadLandingContent() async {
    try {
      final content = await _landingService.getAllContent();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          
          // Cargar slides desde API o usar defaults
          if (content.hasSlides) {
            _slides = content.slides.map((s) => {
              'title': (s['titulo'] ?? s['title'] ?? '') as String,
              'description': (s['descripcion'] ?? s['description'] ?? '') as String,
              'image': (s['imagen_url'] ?? s['image'] ?? '') as String,
            }).toList();
          } else {
            _slides = List.from(_defaultSlides);
          }
          
          // Cargar equipos VR desde API o usar defaults
          if (content.hasFeatures) {
            _vrHeadsets = content.features.map((f) => {
              'name': f['nombre'] ?? f['name'] ?? '',
              'description': f['descripcion'] ?? f['description'] ?? '',
              'image': f['imagen_url'] ?? f['image'] ?? '',
              'specs': (f['especificaciones'] ?? f['specs'] ?? []) is List 
                  ? List<String>.from(f['especificaciones'] ?? f['specs'] ?? [])
                  : <String>[],
              'count': f['cantidad'] ?? f['count'] ?? 1,
            }).toList();
          } else {
            _vrHeadsets = List.from(_defaultVrHeadsets);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
          // Usar datos por defecto en caso de error
          _slides = List.from(_defaultSlides);
          _vrHeadsets = List.from(_defaultVrHeadsets);
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final lang = context.watch<LocaleProvider>().languageCode;
    final t = AppTranslations.of(lang);
    
    // Si aún está cargando y no hay datos de fallback, mostrar indicador
    if (_isLoading && _slides.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.ucRed),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            _buildHeader(isDark, t),
            
            // Hero Carousel
            _buildHeroCarousel(isDark, t),
            
            // Features Section
            _buildFeaturesSection(isDark, t),
            
            // About Section (Who We Are)
            _buildAboutSection(isDark, t),
            
            // What We Do Section
            _buildWhatWeDoSection(isDark, t),
            
            // VR Equipment Section
            _buildVREquipmentSection(isDark, t),
            
            // CTA Section
            _buildCTASection(isDark, t),
            
            // Footer
            _buildFooter(isDark, t),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, AppStrings t) {
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
            // Logo
            Row(
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
            
            const Spacer(),
            
            // Language selector
            _buildLanguageSelector(isDark),
            
            const SizedBox(width: 12),
            
            // Theme toggle
            _buildThemeToggle(isDark),
            
            const SizedBox(width: 12),
            
            // Login button
            AppButton(
              text: t.login,
              trailingIcon: Icons.arrow_forward,
              onPressed: _navigateToLogin,
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(bool isDark) {
    final localeProvider = context.watch<LocaleProvider>();
    
    return Container(
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
    );
  }

  Widget _buildThemeToggle(bool isDark) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
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
    );
  }

  Widget _buildHeroCarousel(bool isDark, AppStrings t) {
    return Stack(
      children: [
        CarouselSlider.builder(
          itemCount: _slides.length,
          options: CarouselOptions(
            height: 500,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, reason) {
              setState(() => _currentCarouselIndex = index);
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final slide = _slides[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: slide['image']!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.darkCard,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.ucRed),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.darkCard,
                  ),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slide['title']!,
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              slide['description']!,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 32),
                            AppButton(
                              text: t.scheduleNow,
                              trailingIcon: Icons.arrow_forward,
                              onPressed: _navigateToLogin,
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        // Indicators
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _slides.asMap().entries.map((entry) {
              return Container(
                width: _currentCarouselIndex == entry.key ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentCarouselIndex == entry.key
                      ? AppColors.ucRed
                      : Colors.white.withValues(alpha: 0.5),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(bool isDark, AppStrings t) {
    final features = [
      {
        'icon': Icons.calendar_today,
        'title': t.easyBooking,
        'description': t.easyBookingDesc,
      },
      {
        'icon': Icons.people,
        'title': t.trainingIncluded,
        'description': t.trainingIncludedDesc,
      },
      {
        'icon': Icons.emoji_events,
        'title': t.advancedTech,
        'description': t.advancedTechDesc,
      },
    ];

    // Cards pequeñas centradas - estilo cuadros compactos
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildSmallFeatureCard(
              isDark: isDark,
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              description: feature['description'] as String,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSmallFeatureCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon container pequeño
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: isDark 
                  ? AppColors.darkTextMuted 
                  : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(bool isDark, AppStrings t) {
    return Container(
      color: isDark ? AppColors.darkCard : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          
          return isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildAboutContent(isDark, t)),
                    const SizedBox(width: 48),
                    Expanded(child: _buildAboutImage(isDark)),
                  ],
                )
              : Column(
                  children: [
                    _buildAboutContent(isDark, t),
                    const SizedBox(height: 32),
                    _buildAboutImage(isDark),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildAboutContent(bool isDark, AppStrings t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Text(
            t.whoWeAre,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          t.whoWeAreText,
          style: TextStyle(
            fontSize: 16,
            height: 1.7,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            AppStatCard(value: '3', label: t.laboratories),
            const SizedBox(width: 16),
            AppStatCard(value: '15', label: t.vrEquipment),
            const SizedBox(width: 16),
            AppStatCard(value: '50+', label: t.sessionsPerMonth),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutImage(bool isDark) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1593508512255-86ab42a8e620?w=600&h=400&fit=crop',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.darkCard,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -24,
          right: -24,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            // Decorative blur effect
          ),
        ),
      ],
    );
  }

  Widget _buildWhatWeDoSection(bool isDark, AppStrings t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          
          return isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildWhatWeDoImage(isDark)),
                    const SizedBox(width: 48),
                    Expanded(child: _buildWhatWeDoContent(isDark, t)),
                  ],
                )
              : Column(
                  children: [
                    _buildWhatWeDoContent(isDark, t),
                    const SizedBox(height: 32),
                    _buildWhatWeDoImage(isDark),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildWhatWeDoContent(bool isDark, AppStrings t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Text(
            t.whatWeDo,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          t.whatWeDoText,
          style: TextStyle(
            fontSize: 16,
            height: 1.7,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 32),
        AppButton(
          text: t.scheduleNow,
          trailingIcon: Icons.arrow_forward,
          onPressed: _navigateToLogin,
        ),
      ],
    );
  }

  Widget _buildWhatWeDoImage(bool isDark) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: 'https://images.unsplash.com/photo-1535223289827-42f1e9919769?w=600&h=400&fit=crop',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppColors.darkCard,
          ),
        ),
      ),
    );
  }

  Widget _buildVREquipmentSection(bool isDark, AppStrings t) {
    return Container(
      color: isDark ? AppColors.darkCard : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
      child: Column(
        children: [
          // Title
          ShaderMask(
            shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
            child: Text(
              t.ourVrEquipment,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.vrEquipmentDesc,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          
          // Equipment grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1000 ? 3 : 
                                     constraints.maxWidth > 600 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.85,
                ),
                itemCount: _vrHeadsets.length,
                itemBuilder: (context, index) {
                  final headset = _vrHeadsets[index];
                  return _buildVRHeadsetCard(isDark, headset);
                },
              );
            },
          ),
          
          const SizedBox(height: 48),
          
          // Equipment availability summary
          AppCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                  child: Text(
                    t.equipmentAvailability,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: _vrHeadsets.map((headset) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightInputBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${headset['count']}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ucRed,
                            ),
                          ),
                          Text(
                            headset['name'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark 
                                  ? AppColors.darkTextMuted 
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  t.totalDevices,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark 
                        ? AppColors.darkTextMuted 
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVRHeadsetCard(bool isDark, Map<String, dynamic> headset) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: headset['image'] as String,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.darkCard,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                  child: Text(
                    headset['name'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  headset['description'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark 
                        ? AppColors.darkTextMuted 
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ...(headset['specs'] as List<String>).map((spec) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.ucRed,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            spec,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark 
                                  ? AppColors.darkTextSecondary 
                                  : AppColors.lightText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(bool isDark, AppStrings t) {
    // Usar SizedBox.expand y ConstrainedBox para asegurar ancho completo
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDark 
              ? AppColors.darkGradient 
              : AppColors.primaryGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.readyToInnovate,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                t.ctaDescription,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: isDark ? AppColors.darkBackground : AppColors.ucRed,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  t.startNow,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDark, AppStrings t) {
    return Container(
      color: isDark ? Colors.black : const Color(0xFF1F2937),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo & Info
                    Expanded(child: _buildFooterLogo(isDark, t)),
                    const SizedBox(width: 48),
                    // Quick Links
                    Expanded(child: _buildFooterLinks(isDark, t)),
                    const SizedBox(width: 48),
                    // Social
                    Expanded(child: _buildFooterSocial(isDark, t)),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFooterLogo(isDark, t),
                    const SizedBox(height: 32),
                    _buildFooterLinks(isDark, t),
                    const SizedBox(height: 32),
                    _buildFooterSocial(isDark, t),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 32),
          Divider(color: isDark ? AppColors.darkBorder : Colors.white24),
          const SizedBox(height: 24),
          Text(
            '© 2025 ${t.ucName} - ${t.iteVr}. ${t.allRightsReserved}.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextMuted : Colors.white60,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLogo(bool isDark, AppStrings t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ThemedLogo(height: 48),
        const SizedBox(height: 12),
        Text(
          t.iteName,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextMuted : Colors.white60,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${t.innovationDepartment} - Aula ITE VR',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextMuted.withValues(alpha: 0.7) : Colors.white38,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLinks(bool isDark, AppStrings t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.quickLinks,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildFooterLink(t.aboutUs, isDark),
        const SizedBox(height: 8),
        _buildFooterLink(t.services, isDark),
        const SizedBox(height: 8),
        _buildFooterLink(t.contact, isDark),
      ],
    );
  }

  Widget _buildFooterLink(String text, bool isDark) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppColors.darkTextMuted : Colors.white60,
        ),
      ),
    );
  }

  Widget _buildFooterSocial(bool isDark, AppStrings t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.followUs,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSocialButton(FontAwesomeIcons.facebook, isDark),
            const SizedBox(width: 12),
            _buildSocialButton(FontAwesomeIcons.whatsapp, isDark),
            const SizedBox(width: 12),
            _buildSocialButton(FontAwesomeIcons.youtube, isDark),
            const SizedBox(width: 12),
            _buildSocialButton(FontAwesomeIcons.instagram, isDark),
            const SizedBox(width: 12),
            _buildSocialButton(FontAwesomeIcons.linkedin, isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: FaIcon(icon, size: 18, color: Colors.white),
        onPressed: () {},
      ),
    );
  }
}
