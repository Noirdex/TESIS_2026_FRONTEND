import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core.dart';

/// Editor de contenido de landing page para administradores
/// Permite editar carrusel, sección about, features, etc.
class AdminContentEditor extends StatefulWidget {
  final LandingContent initialContent;
  final Function(LandingContent) onSave;
  
  const AdminContentEditor({
    super.key,
    required this.initialContent,
    required this.onSave,
  });
  
  /// Muestra el editor como página completa
  static Future<LandingContent?> show({
    required BuildContext context,
    required LandingContent initialContent,
  }) async {
    return Navigator.of(context).push<LandingContent>(
      MaterialPageRoute(
        builder: (context) {
          LandingContent? result;
          return AdminContentEditor(
            initialContent: initialContent,
            onSave: (content) {
              result = content;
              Navigator.of(context).pop(result);
            },
          );
        },
      ),
    );
  }

  @override
  State<AdminContentEditor> createState() => _AdminContentEditorState();
}

class _AdminContentEditorState extends State<AdminContentEditor>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LandingContent _content;
  bool _hasChanges = false;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _content = widget.initialContent.copyWith();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;
    
    return Scaffold(
      backgroundColor: isDark 
          ? AppColors.darkBackground 
          : AppColors.lightBackground,
      appBar: _buildAppBar(isDark, isSpanish),
      body: Column(
        children: [
          _buildTabBar(isDark, isSpanish),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _CarouselEditor(
                  slides: _content.carouselSlides,
                  onChanged: (slides) => _updateContent(
                    _content.copyWith(carouselSlides: slides),
                  ),
                ),
                _FeaturesEditor(
                  features: _content.features,
                  onChanged: (features) => _updateContent(
                    _content.copyWith(features: features),
                  ),
                ),
                _AboutEditor(
                  about: _content.aboutSection,
                  onChanged: (about) => _updateContent(
                    _content.copyWith(aboutSection: about),
                  ),
                ),
                _ContactEditor(
                  contact: _content.contactInfo,
                  onChanged: (contact) => _updateContent(
                    _content.copyWith(contactInfo: contact),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(isDark, isSpanish),
    );
  }
  
  AppBar _buildAppBar(bool isDark, bool isSpanish) {
    return AppBar(
      backgroundColor: isDark 
          ? AppColors.darkSurface 
          : AppColors.lightSurface,
      title: Text(
        isSpanish ? 'Editor de Contenido' : 'Content Editor',
        style: TextStyle(
          color: isDark 
              ? AppColors.darkTextPrimary 
              : AppColors.lightTextPrimary,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          LucideIcons.arrowLeft,
          color: isDark 
              ? AppColors.darkTextPrimary 
              : AppColors.lightTextPrimary,
        ),
        onPressed: () => _handleBack(isSpanish),
      ),
      actions: [
        if (_hasChanges)
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.circleAlert,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  isSpanish ? 'Sin guardar' : 'Unsaved',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildTabBar(bool isDark, bool isSpanish) {
    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: isDark 
            ? AppColors.darkTextSecondary 
            : AppColors.lightTextSecondary,
        indicatorColor: AppColors.primary,
        tabs: [
          Tab(
            icon: const Icon(LucideIcons.images, size: 18),
            text: isSpanish ? 'Carrusel' : 'Carousel',
          ),
          Tab(
            icon: const Icon(LucideIcons.layoutGrid, size: 18),
            text: isSpanish ? 'Características' : 'Features',
          ),
          Tab(
            icon: const Icon(LucideIcons.info, size: 18),
            text: isSpanish ? 'Acerca de' : 'About',
          ),
          Tab(
            icon: const Icon(LucideIcons.contact, size: 18),
            text: isSpanish ? 'Contacto' : 'Contact',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomBar(bool isDark, bool isSpanish) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: AppSecondaryButton(
                text: isSpanish ? 'Descartar' : 'Discard',
                onPressed: _hasChanges 
                    ? () => _handleDiscard(isSpanish) 
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: isSpanish ? 'Guardar Cambios' : 'Save Changes',
                icon: LucideIcons.save,
                isLoading: _isSaving,
                onPressed: _hasChanges ? _handleSave : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _updateContent(LandingContent newContent) {
    setState(() {
      _content = newContent;
      _hasChanges = true;
    });
  }
  
  void _handleBack(bool isSpanish) async {
    if (_hasChanges) {
      final confirmed = await AppConfirmModal.show(
        context: context,
        title: isSpanish ? '¿Descartar cambios?' : 'Discard changes?',
        message: isSpanish
            ? 'Tienes cambios sin guardar. ¿Estás seguro de que deseas salir?'
            : 'You have unsaved changes. Are you sure you want to leave?',
        confirmText: isSpanish ? 'Descartar' : 'Discard',
        isDanger: true,
      );
      
      if (confirmed == true && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }
  
  void _handleDiscard(bool isSpanish) async {
    final confirmed = await AppConfirmModal.show(
      context: context,
      title: isSpanish ? '¿Descartar cambios?' : 'Discard changes?',
      message: isSpanish
          ? 'Se perderán todos los cambios realizados.'
          : 'All changes will be lost.',
      confirmText: isSpanish ? 'Descartar' : 'Discard',
      isDanger: true,
    );
    
    if (confirmed == true && mounted) {
      setState(() {
        _content = widget.initialContent.copyWith();
        _hasChanges = false;
      });
    }
  }
  
  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      widget.onSave(_content);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

// ============================================================================
// CAROUSEL EDITOR
// ============================================================================

class _CarouselEditor extends StatelessWidget {
  final List<CarouselSlide> slides;
  final Function(List<CarouselSlide>) onChanged;
  
  const _CarouselEditor({
    required this.slides,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(isDark, isSpanish),
        const SizedBox(height: 16),
        ...slides.asMap().entries.map((entry) => _buildSlideCard(
          context,
          entry.key,
          entry.value,
          isDark,
          isSpanish,
        )),
        const SizedBox(height: 16),
        _buildAddButton(context, isDark, isSpanish),
      ],
    );
  }
  
  Widget _buildHeader(bool isDark, bool isSpanish) {
    return Row(
      children: [
        Icon(
          LucideIcons.images,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          isSpanish 
              ? 'Slides del Carrusel (${slides.length})' 
              : 'Carousel Slides (${slides.length})',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark 
                ? AppColors.darkTextPrimary 
                : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSlideCard(
    BuildContext context,
    int index,
    CarouselSlide slide,
    bool isDark,
    bool isSpanish,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkCardBackground 
            : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  slide.title.isNotEmpty 
                      ? slide.title 
                      : (isSpanish ? 'Sin título' : 'Untitled'),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark 
                        ? AppColors.darkTextPrimary 
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.trash2,
                  size: 18,
                  color: AppColors.error,
                ),
                onPressed: () => _removeSlide(index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SlideEditFields(
            slide: slide,
            onChanged: (updated) => _updateSlide(index, updated),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddButton(BuildContext context, bool isDark, bool isSpanish) {
    return InkWell(
      onTap: _addSlide,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.plus, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              isSpanish ? 'Agregar Slide' : 'Add Slide',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _addSlide() {
    final newSlides = [...slides, CarouselSlide.empty()];
    onChanged(newSlides);
  }
  
  void _updateSlide(int index, CarouselSlide updated) {
    final newSlides = [...slides];
    newSlides[index] = updated;
    onChanged(newSlides);
  }
  
  void _removeSlide(int index) {
    final newSlides = [...slides];
    newSlides.removeAt(index);
    onChanged(newSlides);
  }
}

class _SlideEditFields extends StatelessWidget {
  final CarouselSlide slide;
  final Function(CarouselSlide) onChanged;
  
  const _SlideEditFields({
    required this.slide,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSpanish = context.watch<LocaleProvider>().isSpanish;
    
    return Column(
      children: [
        AppTextField(
          initialValue: slide.title,
          label: isSpanish ? 'Título' : 'Title',
          onChanged: (v) => onChanged(slide.copyWith(title: v)),
        ),
        const SizedBox(height: 12),
        AppTextField(
          initialValue: slide.subtitle,
          label: isSpanish ? 'Subtítulo' : 'Subtitle',
          maxLines: 2,
          onChanged: (v) => onChanged(slide.copyWith(subtitle: v)),
        ),
        const SizedBox(height: 12),
        AppTextField(
          initialValue: slide.imageUrl,
          label: isSpanish ? 'URL de Imagen' : 'Image URL',
          prefixIcon: LucideIcons.image,
          onChanged: (v) => onChanged(slide.copyWith(imageUrl: v)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                initialValue: slide.buttonText,
                label: isSpanish ? 'Texto del Botón' : 'Button Text',
                onChanged: (v) => onChanged(slide.copyWith(buttonText: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                initialValue: slide.buttonLink,
                label: isSpanish ? 'Enlace del Botón' : 'Button Link',
                onChanged: (v) => onChanged(slide.copyWith(buttonLink: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// FEATURES EDITOR
// ============================================================================

class _FeaturesEditor extends StatelessWidget {
  final List<FeatureItem> features;
  final Function(List<FeatureItem>) onChanged;
  
  const _FeaturesEditor({
    required this.features,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(isDark, isSpanish),
        const SizedBox(height: 16),
        ...features.asMap().entries.map((entry) => _buildFeatureCard(
          context,
          entry.key,
          entry.value,
          isDark,
          isSpanish,
        )),
        const SizedBox(height: 16),
        _buildAddButton(context, isDark, isSpanish),
      ],
    );
  }
  
  Widget _buildHeader(bool isDark, bool isSpanish) {
    return Row(
      children: [
        Icon(LucideIcons.layoutGrid, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          isSpanish 
              ? 'Características (${features.length})' 
              : 'Features (${features.length})',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark 
                ? AppColors.darkTextPrimary 
                : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFeatureCard(
    BuildContext context,
    int index,
    FeatureItem feature,
    bool isDark,
    bool isSpanish,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkCardBackground 
            : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _getIconData(feature.icon),
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feature.title.isNotEmpty 
                      ? feature.title 
                      : (isSpanish ? 'Sin título' : 'Untitled'),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark 
                        ? AppColors.darkTextPrimary 
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                onPressed: () => _removeFeature(index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(
            initialValue: feature.title,
            label: isSpanish ? 'Título' : 'Title',
            onChanged: (v) => _updateFeature(
              index,
              feature.copyWith(title: v),
            ),
          ),
          const SizedBox(height: 12),
          AppTextField(
            initialValue: feature.description,
            label: isSpanish ? 'Descripción' : 'Description',
            maxLines: 3,
            onChanged: (v) => _updateFeature(
              index,
              feature.copyWith(description: v),
            ),
          ),
          const SizedBox(height: 12),
          AppTextField(
            initialValue: feature.icon,
            label: isSpanish ? 'Icono (nombre)' : 'Icon (name)',
            hintText: 'e.g., monitor, users, calendar',
            prefixIcon: LucideIcons.shapes,
            onChanged: (v) => _updateFeature(
              index,
              feature.copyWith(icon: v),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddButton(BuildContext context, bool isDark, bool isSpanish) {
    return InkWell(
      onTap: _addFeature,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.plus, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              isSpanish ? 'Agregar Característica' : 'Add Feature',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIconData(String iconName) {
    final icons = {
      'monitor': LucideIcons.monitor,
      'users': LucideIcons.users,
      'calendar': LucideIcons.calendar,
      'shield': LucideIcons.shield,
      'zap': LucideIcons.zap,
      'book': LucideIcons.book,
      'globe': LucideIcons.globe,
      'star': LucideIcons.star,
    };
    return icons[iconName.toLowerCase()] ?? LucideIcons.box;
  }
  
  void _addFeature() {
    final newFeatures = [...features, FeatureItem.empty()];
    onChanged(newFeatures);
  }
  
  void _updateFeature(int index, FeatureItem updated) {
    final newFeatures = [...features];
    newFeatures[index] = updated;
    onChanged(newFeatures);
  }
  
  void _removeFeature(int index) {
    final newFeatures = [...features];
    newFeatures.removeAt(index);
    onChanged(newFeatures);
  }
}

// ============================================================================
// ABOUT EDITOR
// ============================================================================

class _AboutEditor extends StatelessWidget {
  final AboutSection about;
  final Function(AboutSection) onChanged;
  
  const _AboutEditor({
    required this.about,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(isDark, isSpanish),
        const SizedBox(height: 16),
        _buildCard(isDark, isSpanish),
      ],
    );
  }
  
  Widget _buildHeader(bool isDark, bool isSpanish) {
    return Row(
      children: [
        Icon(LucideIcons.info, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          isSpanish ? 'Sección "Acerca de"' : '"About" Section',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark 
                ? AppColors.darkTextPrimary 
                : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCard(bool isDark, bool isSpanish) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkCardBackground 
            : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          AppTextField(
            initialValue: about.title,
            label: isSpanish ? 'Título' : 'Title',
            onChanged: (v) => onChanged(about.copyWith(title: v)),
          ),
          const SizedBox(height: 16),
          AppTextField(
            initialValue: about.description,
            label: isSpanish ? 'Descripción' : 'Description',
            maxLines: 5,
            onChanged: (v) => onChanged(about.copyWith(description: v)),
          ),
          const SizedBox(height: 16),
          AppTextField(
            initialValue: about.imageUrl,
            label: isSpanish ? 'URL de Imagen' : 'Image URL',
            prefixIcon: LucideIcons.image,
            onChanged: (v) => onChanged(about.copyWith(imageUrl: v)),
          ),
          const SizedBox(height: 16),
          AppTextField(
            initialValue: about.videoUrl ?? '',
            label: isSpanish ? 'URL de Video (opcional)' : 'Video URL (optional)',
            prefixIcon: LucideIcons.video,
            onChanged: (v) => onChanged(
              about.copyWith(videoUrl: v.isNotEmpty ? v : null),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CONTACT EDITOR
// ============================================================================

class _ContactEditor extends StatelessWidget {
  final ContactInfo contact;
  final Function(ContactInfo) onChanged;
  
  const _ContactEditor({
    required this.contact,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(isDark, isSpanish),
        const SizedBox(height: 16),
        _buildCard(isDark, isSpanish),
      ],
    );
  }
  
  Widget _buildHeader(bool isDark, bool isSpanish) {
    return Row(
      children: [
        Icon(LucideIcons.contact, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          isSpanish ? 'Información de Contacto' : 'Contact Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark 
                ? AppColors.darkTextPrimary 
                : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCard(bool isDark, bool isSpanish) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkCardBackground 
            : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          AppTextField(
            initialValue: contact.email,
            label: isSpanish ? 'Correo Electrónico' : 'Email',
            prefixIcon: LucideIcons.mail,
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => onChanged(contact.copyWith(email: v)),
          ),
          const SizedBox(height: 16),
          AppTextField(
            initialValue: contact.phone,
            label: isSpanish ? 'Teléfono' : 'Phone',
            prefixIcon: LucideIcons.phone,
            keyboardType: TextInputType.phone,
            onChanged: (v) => onChanged(contact.copyWith(phone: v)),
          ),
          const SizedBox(height: 16),
          AppTextField(
            initialValue: contact.address,
            label: isSpanish ? 'Dirección' : 'Address',
            prefixIcon: LucideIcons.mapPin,
            maxLines: 2,
            onChanged: (v) => onChanged(contact.copyWith(address: v)),
          ),
          const SizedBox(height: 16),
          AppTextField(
            initialValue: contact.schedule,
            label: isSpanish ? 'Horario de Atención' : 'Office Hours',
            prefixIcon: LucideIcons.clock,
            onChanged: (v) => onChanged(contact.copyWith(schedule: v)),
          ),
          const SizedBox(height: 20),
          _buildSocialLinks(isDark, isSpanish),
        ],
      ),
    );
  }
  
  Widget _buildSocialLinks(bool isDark, bool isSpanish) {
    final labelColor = isDark 
        ? AppColors.darkTextSecondary 
        : AppColors.lightTextSecondary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSpanish ? 'Redes Sociales' : 'Social Media',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          initialValue: contact.socialLinks['facebook'] ?? '',
          label: 'Facebook',
          prefixIcon: LucideIcons.facebook,
          onChanged: (v) => onChanged(
            contact.copyWith(
              socialLinks: {...contact.socialLinks, 'facebook': v},
            ),
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          initialValue: contact.socialLinks['instagram'] ?? '',
          label: 'Instagram',
          prefixIcon: LucideIcons.instagram,
          onChanged: (v) => onChanged(
            contact.copyWith(
              socialLinks: {...contact.socialLinks, 'instagram': v},
            ),
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          initialValue: contact.socialLinks['twitter'] ?? '',
          label: 'Twitter / X',
          prefixIcon: LucideIcons.twitter,
          onChanged: (v) => onChanged(
            contact.copyWith(
              socialLinks: {...contact.socialLinks, 'twitter': v},
            ),
          ),
        ),
        const SizedBox(height: 12),
        AppTextField(
          initialValue: contact.socialLinks['youtube'] ?? '',
          label: 'YouTube',
          prefixIcon: LucideIcons.youtube,
          onChanged: (v) => onChanged(
            contact.copyWith(
              socialLinks: {...contact.socialLinks, 'youtube': v},
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// MODELS
// ============================================================================

/// Contenido completo de la landing page
class LandingContent {
  final List<CarouselSlide> carouselSlides;
  final List<FeatureItem> features;
  final AboutSection aboutSection;
  final ContactInfo contactInfo;
  
  const LandingContent({
    required this.carouselSlides,
    required this.features,
    required this.aboutSection,
    required this.contactInfo,
  });
  
  LandingContent copyWith({
    List<CarouselSlide>? carouselSlides,
    List<FeatureItem>? features,
    AboutSection? aboutSection,
    ContactInfo? contactInfo,
  }) {
    return LandingContent(
      carouselSlides: carouselSlides ?? List.from(this.carouselSlides),
      features: features ?? List.from(this.features),
      aboutSection: aboutSection ?? this.aboutSection.copyWith(),
      contactInfo: contactInfo ?? this.contactInfo.copyWith(),
    );
  }
  
  factory LandingContent.empty() {
    return LandingContent(
      carouselSlides: [],
      features: [],
      aboutSection: AboutSection.empty(),
      contactInfo: ContactInfo.empty(),
    );
  }
  
  factory LandingContent.sample() {
    return LandingContent(
      carouselSlides: [
        CarouselSlide(
          title: 'Bienvenido al Aula VR',
          subtitle: 'Experiencias inmersivas para el aprendizaje',
          imageUrl: 'https://example.com/slide1.jpg',
          buttonText: 'Reservar Ahora',
          buttonLink: '/login',
        ),
      ],
      features: [
        FeatureItem(
          icon: 'monitor',
          title: 'Tecnología VR',
          description: 'Equipos de realidad virtual de última generación',
        ),
        FeatureItem(
          icon: 'users',
          title: 'Capacitación',
          description: 'Soporte y capacitación para docentes',
        ),
      ],
      aboutSection: AboutSection(
        title: 'Acerca del Aula VR',
        description: 'El Aula de Realidad Virtual de la Universidad Católica...',
        imageUrl: 'https://example.com/about.jpg',
      ),
      contactInfo: ContactInfo(
        email: 'aulavr@ucacue.edu.ec',
        phone: '+593 7 288 5551',
        address: 'Av. de las Américas y Humboldt',
        schedule: 'Lunes a Viernes: 7:00 - 16:00',
        socialLinks: {},
      ),
    );
  }
}

/// Slide del carrusel
class CarouselSlide {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String buttonText;
  final String buttonLink;
  
  const CarouselSlide({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.buttonText = '',
    this.buttonLink = '',
  });
  
  CarouselSlide copyWith({
    String? title,
    String? subtitle,
    String? imageUrl,
    String? buttonText,
    String? buttonLink,
  }) {
    return CarouselSlide(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      buttonText: buttonText ?? this.buttonText,
      buttonLink: buttonLink ?? this.buttonLink,
    );
  }
  
  factory CarouselSlide.empty() {
    return const CarouselSlide(
      title: '',
      subtitle: '',
      imageUrl: '',
    );
  }
}

/// Item de características
class FeatureItem {
  final String icon;
  final String title;
  final String description;
  
  const FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
  
  FeatureItem copyWith({
    String? icon,
    String? title,
    String? description,
  }) {
    return FeatureItem(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
  
  factory FeatureItem.empty() {
    return const FeatureItem(
      icon: 'star',
      title: '',
      description: '',
    );
  }
}

/// Sección "Acerca de"
class AboutSection {
  final String title;
  final String description;
  final String imageUrl;
  final String? videoUrl;
  
  const AboutSection({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.videoUrl,
  });
  
  AboutSection copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? videoUrl,
  }) {
    return AboutSection(
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
  
  factory AboutSection.empty() {
    return const AboutSection(
      title: '',
      description: '',
      imageUrl: '',
    );
  }
}

/// Información de contacto
class ContactInfo {
  final String email;
  final String phone;
  final String address;
  final String schedule;
  final Map<String, String> socialLinks;
  final double? latitude;
  final double? longitude;
  
  const ContactInfo({
    required this.email,
    required this.phone,
    required this.address,
    required this.schedule,
    required this.socialLinks,
    this.latitude,
    this.longitude,
  });
  
  ContactInfo copyWith({
    String? email,
    String? phone,
    String? address,
    String? schedule,
    Map<String, String>? socialLinks,
    double? latitude,
    double? longitude,
  }) {
    return ContactInfo(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      schedule: schedule ?? this.schedule,
      socialLinks: socialLinks ?? Map.from(this.socialLinks),
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
  
  factory ContactInfo.empty() {
    return const ContactInfo(
      email: '',
      phone: '',
      address: '',
      schedule: '',
      socialLinks: {},
    );
  }
}
