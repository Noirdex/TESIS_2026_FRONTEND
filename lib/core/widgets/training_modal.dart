import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/translations.dart';
import 'app_button.dart';
import 'app_text_field.dart';

/// Modal de bienvenida y capacitación para docentes (primera vez)
class TrainingModal extends StatefulWidget {
  final VoidCallback onComplete;

  const TrainingModal({
    super.key,
    required this.onComplete,
  });

  @override
  State<TrainingModal> createState() => _TrainingModalState();

  /// Verifica si debe mostrar el modal
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_training') != true;
  }

  /// Marca como visto
  static Future<void> markAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_training', true);
  }

  /// Muestra el modal si es necesario
  static Future<void> showIfNeeded(BuildContext context, VoidCallback onComplete) async {
    if (await shouldShow()) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => TrainingModal(onComplete: onComplete),
        );
      }
    } else {
      onComplete();
    }
  }
}

class _TrainingModalState extends State<TrainingModal> {
  // Estado del formulario
  bool? _hasTraining;
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _careerController = TextEditingController();
  final _subjectController = TextEditingController();
  final _topicsController = TextEditingController();
  DateTime? _tentativeDate;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _positionController.dispose();
    _careerController.dispose();
    _subjectController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.ucRed,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _tentativeDate = picked);
    }
  }

  void _handleSubmit() async {
    if (_hasTraining == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<LocaleProvider>().isSpanish 
                ? 'Por favor seleccione si ha recibido capacitación'
                : 'Please select if you have received training',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_hasTraining == false) {
      if (!_formKey.currentState!.validate() || _tentativeDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<LocaleProvider>().isSpanish 
                  ? 'Por favor complete todos los campos del formulario'
                  : 'Please complete all form fields',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Aquí se enviaría la solicitud de capacitación al backend
      debugPrint('Solicitud de capacitación: ${_firstNameController.text} ${_lastNameController.text}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<LocaleProvider>().isSpanish 
                  ? 'Su solicitud de capacitación ha sido enviada exitosamente'
                  : 'Your training request has been sent successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }

    await TrainingModal.markAsSeen();
    if (mounted) {
      Navigator.of(context).pop();
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final lang = context.watch<LocaleProvider>().languageCode;
    final t = AppTranslations.of(lang);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(isDark, t),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question
                    _buildTrainingQuestion(isDark, t),
                    
                    // Form (if no training)
                    if (_hasTraining == false) ...[
                      const SizedBox(height: 24),
                      _buildTrainingForm(isDark, t),
                    ],
                  ],
                ),
              ),
            ),
            
            // Actions
            _buildActions(isDark, t),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, AppStrings t) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.welcomeSchedulingSystem.contains('Sistema') 
                      ? '¡Bienvenido al Aula ITE VR!'
                      : 'Welcome to ITE VR Classroom!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.read<LocaleProvider>().isSpanish 
                      ? 'Primera vez en el sistema'
                      : 'First time in the system',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingQuestion(bool isDark, AppStrings t) {
    final isSpanish = context.read<LocaleProvider>().isSpanish;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSpanish 
              ? '¿Ha recibido capacitación sobre el uso de los equipos VR?'
              : 'Have you received training on VR equipment use?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        const SizedBox(height: 16),
        
        // Option: Yes
        _buildOptionCard(
          isDark: isDark,
          icon: Icons.check_circle,
          title: isSpanish ? 'Sí, he recibido capacitación' : 'Yes, I have received training',
          isSelected: _hasTraining == true,
          onTap: () => setState(() => _hasTraining = true),
          color: AppColors.success,
        ),
        
        const SizedBox(height: 12),
        
        // Option: No
        _buildOptionCard(
          isDark: isDark,
          icon: Icons.help_outline,
          title: isSpanish ? 'No, necesito capacitación' : 'No, I need training',
          isSelected: _hasTraining == false,
          onTap: () => setState(() => _hasTraining = false),
          color: AppColors.ucGold,
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withValues(alpha: isDark ? 0.2 : 0.1)
              : (isDark ? AppColors.darkBackground : AppColors.lightInputBg),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : (isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected 
                      ? (isDark ? AppColors.darkText : AppColors.lightText)
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingForm(bool isDark, AppStrings t) {
    final isSpanish = context.read<LocaleProvider>().isSpanish;
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider with title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isSpanish ? 'Solicitud de Capacitación' : 'Training Request',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            isSpanish 
                ? 'Complete el formulario para programar su capacitación'
                : 'Complete the form to schedule your training',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Name fields
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: isSpanish ? 'Nombres *' : 'First Name *',
                  hint: isSpanish ? 'Ej: Juan' : 'E.g: John',
                  controller: _firstNameController,
                  validator: (v) => v?.isEmpty == true 
                      ? (isSpanish ? 'Requerido' : 'Required') 
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: isSpanish ? 'Apellidos *' : 'Last Name *',
                  hint: isSpanish ? 'Ej: Pérez' : 'E.g: Smith',
                  controller: _lastNameController,
                  validator: (v) => v?.isEmpty == true 
                      ? (isSpanish ? 'Requerido' : 'Required') 
                      : null,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Position and Career
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: isSpanish ? 'Cargo *' : 'Position *',
                  hint: isSpanish ? 'Ej: Docente Titular' : 'E.g: Professor',
                  controller: _positionController,
                  validator: (v) => v?.isEmpty == true 
                      ? (isSpanish ? 'Requerido' : 'Required') 
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: isSpanish ? 'Carrera *' : 'Program *',
                  hint: isSpanish ? 'Ej: Sistemas' : 'E.g: Computer Science',
                  controller: _careerController,
                  validator: (v) => v?.isEmpty == true 
                      ? (isSpanish ? 'Requerido' : 'Required') 
                      : null,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Subject
          AppTextField(
            label: isSpanish ? 'Materia *' : 'Subject *',
            hint: isSpanish ? 'Ej: Programación' : 'E.g: Programming',
            controller: _subjectController,
            validator: (v) => v?.isEmpty == true 
                ? (isSpanish ? 'Requerido' : 'Required') 
                : null,
          ),
          
          const SizedBox(height: 12),
          
          // Tentative Date
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSpanish ? 'Fecha Tentativa *' : 'Tentative Date *',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _tentativeDate != null
                              ? '${_tentativeDate!.day}/${_tentativeDate!.month}/${_tentativeDate!.year}'
                              : (isSpanish ? 'Seleccionar fecha...' : 'Select date...'),
                          style: TextStyle(
                            fontSize: 15,
                            color: _tentativeDate != null
                                ? (isDark ? AppColors.darkText : AppColors.lightText)
                                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Topics of Interest
          AppTextField(
            label: isSpanish ? 'Temas de Interés *' : 'Topics of Interest *',
            hint: isSpanish 
                ? 'Describa los temas o aspectos específicos en los que necesita capacitación...'
                : 'Describe the specific topics or aspects you need training on...',
            controller: _topicsController,
            maxLines: 3,
            validator: (v) => v?.isEmpty == true 
                ? (isSpanish ? 'Requerido' : 'Required') 
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool isDark, AppStrings t) {
    final isSpanish = context.read<LocaleProvider>().isSpanish;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: _hasTraining == false 
                  ? (isSpanish ? 'Enviar Solicitud' : 'Submit Request')
                  : t.continueBtn,
              trailingIcon: Icons.arrow_forward,
              onPressed: _handleSubmit,
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
