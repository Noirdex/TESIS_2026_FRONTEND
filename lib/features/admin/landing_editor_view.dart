import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/core.dart';

/// Vista para editar el contenido de la Landing Page
/// Usa el modelo LandingContent de admin_content_editor.dart
class LandingEditorView extends StatefulWidget {
  const LandingEditorView({super.key});

  @override
  State<LandingEditorView> createState() => _LandingEditorViewState();
}

class _LandingEditorViewState extends State<LandingEditorView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late LandingContent _content;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _content = LandingContent.sample();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;

    return Column(
      children: [
        // Header
        AppCard(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.pencilLine, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSpanish ? 'Editor de Landing Page' : 'Landing Page Editor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    Text(
                      isSpanish 
                          ? 'Edita el contenido visible en la página de inicio.'
                          : 'Edit the content visible on the home page.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_hasChanges) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.circleAlert, size: 16, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Text(
                        isSpanish ? 'Cambios sin guardar' : 'Unsaved changes',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
              AppSecondaryButton(
                text: isSpanish ? 'Previsualizar' : 'Preview',
                onPressed: () => _handlePreview(isSpanish),
              ),
              const SizedBox(width: 12),
              AppButton(
                text: isSpanish ? 'Guardar Cambios' : 'Save Changes',
                icon: LucideIcons.save,
                isLoading: _isSaving,
                onPressed: _hasChanges ? _handleSave : null,
              ),
            ],
          ),
        ),
        
        // Tabs
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightInputBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: isDark 
                ? AppColors.darkTextSecondary 
                : AppColors.lightTextSecondary,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.all(4),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.images, size: 16),
                    const SizedBox(width: 6),
                    Text(isSpanish ? 'Carrusel' : 'Carousel'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.layoutGrid, size: 16),
                    const SizedBox(width: 6),
                    Text(isSpanish ? 'Características' : 'Features'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.info, size: 16),
                    const SizedBox(width: 6),
                    Text(isSpanish ? 'Acerca de' : 'About'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.contact, size: 16),
                    const SizedBox(width: 6),
                    Text(isSpanish ? 'Contacto' : 'Contact'),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Content - Usar SizedBox en lugar de Expanded para evitar conflicto con SingleChildScrollView
        SizedBox(
          height: MediaQuery.of(context).size.height - 280,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCarouselEditor(isDark, isSpanish),
              _buildFeaturesEditor(isDark, isSpanish),
              _buildAboutEditor(isDark, isSpanish),
              _buildContactEditor(isDark, isSpanish),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCarouselEditor(bool isDark, bool isSpanish) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isSpanish ? 'Slides del Carrusel' : 'Carousel Slides',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              AppButton(
                text: isSpanish ? 'Agregar Slide' : 'Add Slide',
                icon: LucideIcons.plus,
                onPressed: () => _handleAddSlide(isDark, isSpanish),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_content.carouselSlides.isEmpty)
            _buildEmptyState(
              isDark, 
              isSpanish, 
              LucideIcons.images,
              isSpanish ? 'No hay slides' : 'No slides',
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _content.carouselSlides.length,
              itemBuilder: (context, index) {
                final slide = _content.carouselSlides[index];
                return _buildSlideCard(slide, index, isDark, isSpanish);
              },
            ),
        ],
      ),
    );
  }
  
  Widget _buildSlideCard(CarouselSlide slide, int index, bool isDark, bool isSpanish) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview
          Container(
            width: 120,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
              borderRadius: BorderRadius.circular(8),
              image: slide.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(slide.imageUrl),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    )
                  : null,
            ),
            child: slide.imageUrl.isEmpty
                ? Icon(
                    LucideIcons.image,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  slide.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (slide.buttonText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      slide.buttonText,
                      style: TextStyle(fontSize: 10, color: AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(LucideIcons.pencil, size: 18, color: AppColors.info),
                tooltip: isSpanish ? 'Editar' : 'Edit',
                onPressed: () => _handleEditSlide(slide, index, isDark, isSpanish),
              ),
              IconButton(
                icon: Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                tooltip: isSpanish ? 'Eliminar' : 'Delete',
                onPressed: () => _handleDeleteSlide(index, isSpanish),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeaturesEditor(bool isDark, bool isSpanish) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isSpanish ? 'Características' : 'Features',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              AppButton(
                text: isSpanish ? 'Agregar' : 'Add',
                icon: LucideIcons.plus,
                onPressed: () => _handleAddFeature(isDark, isSpanish),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isSpanish 
                ? 'Estas características se muestran en la sección de funcionalidades.'
                : 'These features are displayed in the functionalities section.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_content.features.isEmpty)
            _buildEmptyState(
              isDark, 
              isSpanish, 
              LucideIcons.layoutGrid,
              isSpanish ? 'No hay características' : 'No features',
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _content.features.asMap().entries.map((entry) => 
                _buildFeatureCard(entry.value, entry.key, isDark, isSpanish),
              ).toList(),
            ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard(FeatureItem feature, int index, bool isDark, bool isSpanish) {
    return SizedBox(
      width: 280,
      height: 200, // Altura fija para uniformidad
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    IconPickerWidget.getIconData(feature.icon),
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                feature.description,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(LucideIcons.pencil, size: 18, color: AppColors.info),
                  onPressed: () => _handleEditFeature(feature, index, isDark, isSpanish),
                ),
                IconButton(
                  icon: Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                  onPressed: () => _handleDeleteFeature(index, isSpanish),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAboutEditor(bool isDark, bool isSpanish) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSpanish ? 'Sección "Acerca de"' : '"About" Section',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            TextField(
              controller: TextEditingController(text: _content.aboutSection.title),
              decoration: InputDecoration(
                labelText: isSpanish ? 'Título' : 'Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(LucideIcons.type, size: 18),
              ),
              onChanged: (v) {
                setState(() {
                  _content = _content.copyWith(
                    aboutSection: _content.aboutSection.copyWith(title: v),
                  );
                  _markAsChanged();
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Description
            TextField(
              controller: TextEditingController(text: _content.aboutSection.description),
              maxLines: 5,
              decoration: InputDecoration(
                labelText: isSpanish ? 'Descripción' : 'Description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                alignLabelWithHint: true,
              ),
              onChanged: (v) {
                setState(() {
                  _content = _content.copyWith(
                    aboutSection: _content.aboutSection.copyWith(description: v),
                  );
                  _markAsChanged();
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Image
            Text(
              isSpanish ? 'Imagen de la sección' : 'Section Image',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'JPG • 400x400px • 1:1',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  // Preview de imagen
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      image: _content.aboutSection.imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(_content.aboutSection.imageUrl),
                              fit: BoxFit.cover,
                              onError: (_, __) {},
                            )
                          : null,
                    ),
                    child: _content.aboutSection.imageUrl.isEmpty
                        ? Center(
                            child: Icon(
                              LucideIcons.image,
                              size: 32,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_content.aboutSection.imageUrl.isNotEmpty)
                          Text(
                            isSpanish ? 'Imagen actual' : 'Current image',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          )
                        else
                          Text(
                            isSpanish ? 'Sin imagen' : 'No image',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                final picker = ImagePicker();
                                final image = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 400,
                                  maxHeight: 400,
                                  imageQuality: 85,
                                );
                                if (image != null) {
                                  // TODO: En producción, subir a Firebase
                                  // Por ahora usar URL mock
                                  setState(() {
                                    _content = _content.copyWith(
                                      aboutSection: _content.aboutSection.copyWith(
                                        imageUrl: 'local://about/${DateTime.now().millisecondsSinceEpoch}.jpg',
                                      ),
                                    );
                                    _markAsChanged();
                                  });
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isSpanish ? 'Imagen seleccionada' : 'Image selected'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(LucideIcons.upload, size: 16),
                              label: Text(
                                isSpanish ? 'Seleccionar' : 'Select',
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                            if (_content.aboutSection.imageUrl.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _content = _content.copyWith(
                                      aboutSection: _content.aboutSection.copyWith(imageUrl: ''),
                                    );
                                    _markAsChanged();
                                  });
                                },
                                child: Text(
                                  isSpanish ? 'Quitar' : 'Remove',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactEditor(bool isDark, bool isSpanish) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppCard(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSpanish ? 'Información de Contacto' : 'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildContactField(isDark, isSpanish ? 'Correo' : 'Email', 
                        _content.contactInfo.email, LucideIcons.mail, (v) {
                      setState(() {
                        _content = _content.copyWith(
                          contactInfo: _content.contactInfo.copyWith(email: v),
                        );
                        _markAsChanged();
                      });
                    }),
                    _buildContactField(isDark, isSpanish ? 'Teléfono' : 'Phone', 
                        _content.contactInfo.phone, LucideIcons.phone, (v) {
                      setState(() {
                        _content = _content.copyWith(
                          contactInfo: _content.contactInfo.copyWith(phone: v),
                        );
                        _markAsChanged();
                      });
                    }),
                    _buildContactField(isDark, isSpanish ? 'Dirección' : 'Address', 
                        _content.contactInfo.address, LucideIcons.mapPin, (v) {
                      setState(() {
                        _content = _content.copyWith(
                          contactInfo: _content.contactInfo.copyWith(address: v),
                        );
                        _markAsChanged();
                      });
                    }, width: 400),
                    _buildContactField(isDark, isSpanish ? 'Horario' : 'Schedule', 
                        _content.contactInfo.schedule, LucideIcons.clock, (v) {
                      setState(() {
                        _content = _content.copyWith(
                          contactInfo: _content.contactInfo.copyWith(schedule: v),
                        );
                        _markAsChanged();
                      });
                    }),
                  ],
                ),
              ],
            ),
          ),
          
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSpanish ? 'Redes Sociales' : 'Social Media',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSpanish 
                      ? 'URLs de redes sociales que se mostrarán en el pie de página.'
                      : 'Social media URLs that will be displayed in the footer.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildContactField(isDark, 'Facebook', 
                        _content.contactInfo.socialLinks['facebook'] ?? '', 
                        LucideIcons.facebook, (v) {
                      setState(() {
                        final links = Map<String, String>.from(_content.contactInfo.socialLinks);
                        links['facebook'] = v;
                        _content = _content.copyWith(
                          contactInfo: _content.contactInfo.copyWith(socialLinks: links),
                        );
                        _markAsChanged();
                      });
                    }),
                    _buildContactField(isDark, 'Instagram', 
                        _content.contactInfo.socialLinks['instagram'] ?? '', 
                        LucideIcons.instagram, (v) {
                      setState(() {
                        final links = Map<String, String>.from(_content.contactInfo.socialLinks);
                        links['instagram'] = v;
                        _content = _content.copyWith(
                          contactInfo: _content.contactInfo.copyWith(socialLinks: links),
                        );
                        _markAsChanged();
                      });
                    }),
                    _buildContactField(isDark, 'Twitter/X', 
                        _content.contactInfo.socialLinks['twitter'] ?? '', 
                        LucideIcons.twitter, (v) {
                      setState(() {
                        final links = Map<String, String>.from(_content.contactInfo.socialLinks);
                        links['twitter'] = v;
                        _content = _content.copyWith(
                          contactInfo: _content.contactInfo.copyWith(socialLinks: links),
                        );
                        _markAsChanged();
                      });
                    }),
                    _buildContactField(isDark, 'LinkedIn', 
                        _content.contactInfo.socialLinks['linkedin'] ?? '', 
                        LucideIcons.linkedin, (v) {
                      setState(() {
                        final links = Map<String, String>.from(_content.contactInfo.socialLinks);
                        links['linkedin'] = v;
                        _content = _content.copyWith(
                          contactInfo: _content.contactInfo.copyWith(socialLinks: links),
                        );
                        _markAsChanged();
                      });
                    }),
                    _buildContactField(isDark, 'YouTube', 
                        _content.contactInfo.socialLinks['youtube'] ?? '', 
                        LucideIcons.youtube, (v) {
                      setState(() {
                        final links = Map<String, String>.from(_content.contactInfo.socialLinks);
                        links['youtube'] = v;
                        _content = _content.copyWith(
                          contactInfo: _content.contactInfo.copyWith(socialLinks: links),
                        );
                        _markAsChanged();
                      });
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isSpanish 
                      ? 'Si una red social está vacía, no se mostrará en la página.'
                      : 'If a social media field is empty, it won\'t be displayed on the page.',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Ubicación con mapa
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.mapPin, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isSpanish ? 'Ubicación en el Mapa' : 'Map Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isSpanish 
                      ? 'Selecciona la ubicación que se mostrará en el mapa de contacto.'
                      : 'Select the location that will be displayed on the contact map.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Preview del mapa
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                        child: SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: _content.contactInfo.latitude != null && 
                                 _content.contactInfo.longitude != null
                              ? MapPreviewWidget(
                                  latitude: _content.contactInfo.latitude!,
                                  longitude: _content.contactInfo.longitude!,
                                  height: 200,
                                )
                              : Container(
                                  color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          LucideIcons.map,
                                          size: 40,
                                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          isSpanish ? 'Sin ubicación configurada' : 'No location set',
                                          style: TextStyle(
                                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      // Controles
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
                        ),
                        child: Row(
                          children: [
                            if (_content.contactInfo.latitude != null) ...[
                              Icon(LucideIcons.navigation, size: 14, color: AppColors.success),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${_content.contactInfo.latitude!.toStringAsFixed(4)}, ${_content.contactInfo.longitude!.toStringAsFixed(4)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: isDark ? AppColors.darkText : AppColors.lightText,
                                  ),
                                ),
                              ),
                            ] else
                              Expanded(
                                child: Text(
                                  isSpanish ? 'Haz clic para seleccionar ubicación' : 'Click to select location',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final result = await MapPickerWidget.show(
                                  context: context,
                                  initialLatitude: _content.contactInfo.latitude,
                                  initialLongitude: _content.contactInfo.longitude,
                                );
                                if (result != null) {
                                  setState(() {
                                    _content = _content.copyWith(
                                      contactInfo: _content.contactInfo.copyWith(
                                        latitude: result['latitude'],
                                        longitude: result['longitude'],
                                      ),
                                    );
                                    _markAsChanged();
                                  });
                                }
                              },
                              icon: Icon(
                                _content.contactInfo.latitude != null 
                                    ? LucideIcons.pencil 
                                    : LucideIcons.mapPin,
                                size: 14,
                              ),
                              label: Text(
                                _content.contactInfo.latitude != null 
                                    ? (isSpanish ? 'Cambiar' : 'Change')
                                    : (isSpanish ? 'Seleccionar' : 'Select'),
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactField(
    bool isDark,
    String label,
    String value,
    IconData icon,
    ValueChanged<String> onChanged, {
    double width = 250,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: onChanged,
      ),
    );
  }
  
  Widget _buildEmptyState(bool isDark, bool isSpanish, IconData icon, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              icon,
              size: 64,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Handlers
  void _handlePreview(bool isSpanish) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSpanish 
              ? 'Previsualización próximamente disponible'
              : 'Preview coming soon',
        ),
      ),
    );
  }
  
  void _handleSave() async {
    setState(() => _isSaving = true);
    
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasChanges = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<LocaleProvider>().isSpanish 
                  ? 'Cambios guardados exitosamente'
                  : 'Changes saved successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  void _handleAddSlide(bool isDark, bool isSpanish) async {
    final titleCtrl = TextEditingController();
    final subtitleCtrl = TextEditingController();
    final buttonTextCtrl = TextEditingController();
    final buttonLinkCtrl = TextEditingController();
    XFile? selectedImage;
    Uint8List? imagePreviewBytes;
    String? imageUrl;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isSpanish ? 'Nuevo Slide' : 'New Slide'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'Título *' : 'Title *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: subtitleCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'Subtítulo *' : 'Subtitle *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Imagen con selector
                  Text(
                    isSpanish ? 'Imagen del slide' : 'Slide image',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG • 400x400px • 1:1',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: imagePreviewBytes != null
                                ? Image.memory(imagePreviewBytes!, fit: BoxFit.cover)
                                : Icon(
                                    LucideIcons.image,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selectedImage != null)
                                Text(
                                  selectedImage!.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkText : AppColors.lightText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 6),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxWidth: 400,
                                    maxHeight: 400,
                                    imageQuality: 85,
                                  );
                                  if (image != null) {
                                    final bytes = await image.readAsBytes();
                                    setDialogState(() {
                                      selectedImage = image;
                                      imagePreviewBytes = bytes;
                                    });
                                  }
                                },
                                icon: const Icon(LucideIcons.upload, size: 14),
                                label: Text(
                                  isSpanish ? 'Seleccionar' : 'Select',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  TextField(
                    controller: buttonTextCtrl,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'Texto del botón' : 'Button text',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: buttonLinkCtrl,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'Enlace del botón (opcional)' : 'Button link (optional)',
                      hintText: '/login',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(isSpanish ? 'Cancelar' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(isSpanish ? 'Agregar' : 'Add'),
            ),
          ],
        ),
      ),
    );
    
    if (result == true && titleCtrl.text.isNotEmpty && subtitleCtrl.text.isNotEmpty && mounted) {
      // TODO: En producción, subir la imagen a Firebase y obtener URL
      setState(() {
        _content = _content.copyWith(
          carouselSlides: [
            ..._content.carouselSlides,
            CarouselSlide(
              title: titleCtrl.text,
              subtitle: subtitleCtrl.text,
              imageUrl: imageUrl ?? '', // Se llenaría con URL de Firebase
              buttonText: buttonTextCtrl.text,
              buttonLink: buttonLinkCtrl.text,
            ),
          ],
        );
        _markAsChanged();
      });
    }
  }
  
  void _handleEditSlide(CarouselSlide slide, int index, bool isDark, bool isSpanish) async {
    final titleCtrl = TextEditingController(text: slide.title);
    final subtitleCtrl = TextEditingController(text: slide.subtitle);
    final buttonTextCtrl = TextEditingController(text: slide.buttonText);
    final buttonLinkCtrl = TextEditingController(text: slide.buttonLink);
    
    String? imageUrl = slide.imageUrl;
    Uint8List? imagePreviewBytes;
    XFile? selectedImage;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isSpanish ? 'Editar Slide' : 'Edit Slide'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'Título *' : 'Title *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: subtitleCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'Subtítulo *' : 'Subtitle *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Imagen con selector
                  Text(
                    isSpanish ? 'Imagen del slide' : 'Slide image',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'JPG/PNG • 1920x1080px',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: imagePreviewBytes != null
                                ? Image.memory(imagePreviewBytes!, fit: BoxFit.cover)
                                : (imageUrl != null && imageUrl!.isNotEmpty && !imageUrl!.startsWith('local://'))
                                    ? Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(LucideIcons.image, color: AppColors.darkTextMuted))
                                    : Icon(
                                        LucideIcons.image,
                                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                      ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selectedImage != null)
                                Text(
                                  selectedImage!.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkText : AppColors.lightText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              else if (imageUrl != null && imageUrl!.isNotEmpty)
                                Text(
                                  isSpanish ? 'Imagen actual' : 'Current image',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.success,
                                  ),
                                ),
                              const SizedBox(height: 6),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxWidth: 1920,
                                    maxHeight: 1080,
                                    imageQuality: 85,
                                  );
                                  if (image != null) {
                                    final bytes = await image.readAsBytes();
                                    setDialogState(() {
                                      selectedImage = image;
                                      imagePreviewBytes = bytes;
                                      imageUrl = 'local://carousel/${DateTime.now().millisecondsSinceEpoch}.jpg';
                                    });
                                  }
                                },
                                icon: const Icon(LucideIcons.upload, size: 14),
                                label: Text(
                                  isSpanish ? 'Cambiar imagen' : 'Change image',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  TextField(
                    controller: buttonTextCtrl,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'Texto del botón' : 'Button text',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: buttonLinkCtrl,
                    decoration: InputDecoration(
                      labelText: isSpanish ? 'Enlace del botón (opcional)' : 'Button link (optional)',
                      hintText: '/login',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(isSpanish ? 'Cancelar' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(isSpanish ? 'Guardar' : 'Save'),
            ),
          ],
        ),
      ),
    );
    
    if (result == true && titleCtrl.text.isNotEmpty && subtitleCtrl.text.isNotEmpty && mounted) {
      setState(() {
        final slides = List<CarouselSlide>.from(_content.carouselSlides);
        slides[index] = CarouselSlide(
          title: titleCtrl.text,
          subtitle: subtitleCtrl.text,
          imageUrl: imageUrl ?? '',
          buttonText: buttonTextCtrl.text,
          buttonLink: buttonLinkCtrl.text,
        );
        _content = _content.copyWith(carouselSlides: slides);
        _markAsChanged();
      });
    }
  }
  
  void _handleDeleteSlide(int index, bool isSpanish) async {
    final confirmed = await AppConfirmModal.show(
      context: context,
      title: isSpanish ? '¿Eliminar slide?' : 'Delete slide?',
      message: isSpanish 
          ? '¿Está seguro de eliminar este slide?'
          : 'Are you sure you want to delete this slide?',
      confirmText: isSpanish ? 'Eliminar' : 'Delete',
      isDanger: true,
    );
    
    if (confirmed == true && mounted) {
      setState(() {
        final slides = List<CarouselSlide>.from(_content.carouselSlides);
        slides.removeAt(index);
        _content = _content.copyWith(carouselSlides: slides);
        _markAsChanged();
      });
    }
  }
  
  void _handleAddFeature(bool isDark, bool isSpanish) async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedIcon = 'monitor';
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isSpanish ? 'Nueva Característica' : 'New Feature'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: isSpanish ? 'Título *' : 'Title *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: isSpanish ? 'Descripción *' : 'Description *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                // Selector visual de iconos
                Text(
                  isSpanish ? 'Seleccionar icono' : 'Select icon',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: IconPickerWidget(
                    selectedIcon: selectedIcon,
                    crossAxisCount: 5,
                    onIconSelected: (icon) {
                      setDialogState(() => selectedIcon = icon);
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(isSpanish ? 'Cancelar' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(isSpanish ? 'Agregar' : 'Add'),
            ),
          ],
        ),
      ),
    );
    
    if (result == true && titleCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty && mounted) {
      setState(() {
        _content = _content.copyWith(
          features: [
            ..._content.features,
            FeatureItem(
              icon: selectedIcon,
              title: titleCtrl.text,
              description: descCtrl.text,
            ),
          ],
        );
        _markAsChanged();
      });
    }
  }
  
  void _handleEditFeature(FeatureItem feature, int index, bool isDark, bool isSpanish) async {
    final titleCtrl = TextEditingController(text: feature.title);
    final descCtrl = TextEditingController(text: feature.description);
    String selectedIcon = feature.icon;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isSpanish ? 'Editar Característica' : 'Edit Feature'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: isSpanish ? 'Título *' : 'Title *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: isSpanish ? 'Descripción *' : 'Description *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                // Selector visual de iconos
                Text(
                  isSpanish ? 'Seleccionar icono' : 'Select icon',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: IconPickerWidget(
                    selectedIcon: selectedIcon,
                    crossAxisCount: 5,
                    onIconSelected: (icon) {
                      setDialogState(() => selectedIcon = icon);
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(isSpanish ? 'Cancelar' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(isSpanish ? 'Guardar' : 'Save'),
            ),
          ],
        ),
      ),
    );
    
    if (result == true && titleCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty && mounted) {
      setState(() {
        final features = List<FeatureItem>.from(_content.features);
        features[index] = FeatureItem(
          icon: selectedIcon,
          title: titleCtrl.text,
          description: descCtrl.text,
        );
        _content = _content.copyWith(features: features);
        _markAsChanged();
      });
    }
  }
  
  void _handleDeleteFeature(int index, bool isSpanish) async {
    final confirmed = await AppConfirmModal.show(
      context: context,
      title: isSpanish ? '¿Eliminar característica?' : 'Delete feature?',
      message: isSpanish 
          ? '¿Está seguro de eliminar esta característica?'
          : 'Are you sure you want to delete this feature?',
      confirmText: isSpanish ? 'Eliminar' : 'Delete',
      isDanger: true,
    );
    
    if (confirmed == true && mounted) {
      setState(() {
        final features = List<FeatureItem>.from(_content.features);
        features.removeAt(index);
        _content = _content.copyWith(features: features);
        _markAsChanged();
      });
    }
  }
}
