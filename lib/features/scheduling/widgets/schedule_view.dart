import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import 'aula_selector.dart';
import 'weekly_calendar.dart';

/// Formateador para convertir texto a mayúsculas
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Vista de agendamiento con pasos colapsables
class ScheduleView extends StatefulWidget {
  final bool isAdmin;
  
  const ScheduleView({super.key, required this.isAdmin});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  // Step states
  bool _step1Collapsed = false;
  bool _step2Collapsed = false;
  bool _step3Collapsed = false;
  
  // Form data
  String _selectedTeacherId = '';
  int? _selectedAula;
  
  // Class data
  final _subjectController = TextEditingController();
  final _careerController = TextEditingController();
  final _parallelController = TextEditingController();
  final _cycleController = TextEditingController();
  final _numStudentsController = TextEditingController();
  
  // Schedule selection
  final Set<String> _selectedCells = {};
  final Map<int, Set<String>> _groupCells = {}; // Mapa de grupo -> celdas seleccionadas
  int _activeGroup = 1; // Grupo activo (1, 2, 3, ...)
  int _totalGroups = 1; // Número total de grupos necesarios
  bool _needsGroups = false;

  // Mock teachers - ahora con hasTraining para indicar si están capacitados
  final List<Map<String, dynamic>> _teachers = [
    {
      'id': '1',
      'firstName': 'Juan',
      'lastName': 'Pérez',
      'email': 'juan.perez@ucacue.edu.ec',
      'faculty': 'Ingeniería',
      'career': 'Sistemas',
      'hasTraining': true, // CAPACITADO - puede agendar
    },
    {
      'id': '2',
      'firstName': 'María',
      'lastName': 'García',
      'email': 'maria.garcia@ucacue.edu.ec',
      'faculty': 'Medicina',
      'career': 'Medicina General',
      'hasTraining': false, // NO CAPACITADO - no puede agendar
    },
    {
      'id': '3',
      'firstName': 'Carlos',
      'lastName': 'López',
      'email': 'carlos.lopez@ucacue.edu.ec',
      'faculty': 'Arquitectura',
      'career': 'Arquitectura',
      'hasTraining': true, // CAPACITADO - puede agendar
    },
  ];
  
  /// Obtiene el docente seleccionado
  Map<String, dynamic>? get _selectedTeacher {
    if (_selectedTeacherId.isEmpty) return null;
    return _teachers.firstWhere(
      (t) => t['id'] == _selectedTeacherId,
      orElse: () => <String, dynamic>{},
    );
  }
  
  /// Verifica si el docente seleccionado está capacitado
  bool get _isSelectedTeacherTrained {
    final teacher = _selectedTeacher;
    if (teacher == null || teacher.isEmpty) return false;
    return teacher['hasTraining'] == true;
  }

  // Mock aulas
  final List<Map<String, dynamic>> _aulas = [
    {
      'name': 'Aula VR 1',
      'location': 'Cuenca · Facultad de Ingenierías',
      'capacity': 10,
      'schedule': '7:00 - 16:00',
      'image': 'https://images.unsplash.com/photo-1617802690658-1173a812650d?w=600&h=400&fit=crop',
    },
    {
      'name': 'Aula VR 2',
      'location': 'Cuenca · Facultad de Medicina',
      'capacity': 15,
      'schedule': '7:00 - 12:00, 13:00 - 18:00',
      'image': 'https://images.unsplash.com/photo-1622979135225-d2ba269cf1ac?w=600&h=400&fit=crop',
    },
    {
      'name': 'Aula VR 3',
      'location': 'Azogues · Campus Norte',
      'capacity': 12,
      'schedule': '8:00 - 17:00',
      'image': 'https://images.unsplash.com/photo-1535223289827-42f1e9919769?w=600&h=400&fit=crop',
    },
  ];

  // Solo puede continuar si el docente seleccionado está capacitado
  bool get _canProceedToStep2 => _selectedTeacherId.isNotEmpty && _isSelectedTeacherTrained;
  bool get _canProceedToStep3 => _selectedAula != null;
  bool get _canProceedToStep4 => 
      _subjectController.text.isNotEmpty &&
      _careerController.text.isNotEmpty &&
      _parallelController.text.isNotEmpty &&
      _cycleController.text.isNotEmpty &&
      _numStudentsController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _numStudentsController.addListener(_checkGroupsNeeded);
  }

  void _checkGroupsNeeded() {
    if (_selectedAula != null && _numStudentsController.text.isNotEmpty) {
      final numStudents = int.tryParse(_numStudentsController.text) ?? 0;
      final capacity = _aulas[_selectedAula!]['capacity'] as int;
      
      setState(() {
        if (numStudents > capacity) {
          // Calcular cuántos grupos se necesitan
          // Ejemplo: 15 estudiantes, capacidad 10 = 2 grupos (10 + 5)
          // Ejemplo: 30 estudiantes, capacidad 10 = 3 grupos (10 + 10 + 10)
          _totalGroups = (numStudents / capacity).ceil();
          _needsGroups = true;
          _activeGroup = 1;
          
          // Inicializar sets para cada grupo si no existen
          for (int i = 1; i <= _totalGroups; i++) {
            _groupCells.putIfAbsent(i, () => <String>{});
          }
        } else {
          _needsGroups = false;
          _totalGroups = 1;
          _activeGroup = 1;
          _groupCells.clear();
        }
      });
    }
  }
  
  /// Obtiene la cantidad de estudiantes por grupo
  List<int> get _studentsPerGroup {
    if (!_needsGroups || _selectedAula == null) return [];
    
    final numStudents = int.tryParse(_numStudentsController.text) ?? 0;
    final capacity = _aulas[_selectedAula!]['capacity'] as int;
    
    final groups = <int>[];
    int remaining = numStudents;
    
    for (int i = 0; i < _totalGroups; i++) {
      if (remaining >= capacity) {
        groups.add(capacity);
        remaining -= capacity;
      } else {
        groups.add(remaining);
        remaining = 0;
      }
    }
    
    return groups;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _careerController.dispose();
    _parallelController.dispose();
    _cycleController.dispose();
    _numStudentsController.dispose();
    super.dispose();
  }

  void _handleAddNewTeacher() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final facultyController = TextEditingController();
    final careerController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
              child: Icon(Icons.person_add, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Nuevo Docente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nombre y Apellido en fila
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Nombre *',
                        hint: 'Juan',
                        controller: firstNameController,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Apellido *',
                        hint: 'Pérez',
                        controller: lastNameController,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Correo Institucional *',
                  hint: 'juan.perez@ucacue.edu.ec',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Teléfono *',
                  hint: '0999999999',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Facultad *',
                  hint: 'Ej: Ingeniería',
                  controller: facultyController,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Carrera *',
                  hint: 'Ej: Sistemas',
                  controller: careerController,
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (firstNameController.text.isEmpty ||
                  lastNameController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  phoneController.text.isEmpty ||
                  facultyController.text.isEmpty ||
                  careerController.text.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Complete todos los campos')),
                );
                return;
              }
              
              final newId = DateTime.now().millisecondsSinceEpoch.toString();
              setState(() {
                _teachers.add({
                  'id': newId,
                  'firstName': firstNameController.text,
                  'lastName': lastNameController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'faculty': facultyController.text,
                  'career': careerController.text,
                });
                _selectedTeacherId = newId;
              });
              
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Docente agregado exitosamente'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConfirmBooking() async {
    // Validate
    if (!_canProceedToStep4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }

    if (!_needsGroups && _selectedCells.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione al menos un horario')),
      );
      return;
    }

    if (_needsGroups) {
      // Verificar que todos los grupos tengan horarios seleccionados
      for (int i = 1; i <= _totalGroups; i++) {
        if (_groupCells[i]?.isEmpty ?? true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Por favor seleccione horarios para el Grupo $i')),
          );
          return;
        }
      }
    }

    // Convertir celdas seleccionadas a ScheduleSlots
    final slots = <ScheduleSlot>[];
    
    if (_needsGroups) {
      // Agregar slots de todos los grupos
      for (int i = 1; i <= _totalGroups; i++) {
        final groupCells = _groupCells[i] ?? {};
        for (final cellId in groupCells) {
          final slot = _cellIdToSlot(cellId, 'G$i');
          if (slot != null) slots.add(slot);
        }
      }
    } else {
      for (final cellId in _selectedCells) {
        final slot = _cellIdToSlot(cellId, null);
        if (slot != null) slots.add(slot);
      }
    }

    // Obtener nombre del docente
    final teacher = _teachers.firstWhere(
      (t) => t['id'] == _selectedTeacherId,
      orElse: () => {'firstName': '', 'lastName': ''},
    );
    final teacherName = '${teacher['firstName']} ${teacher['lastName']}'.trim();

    // Crear resumen
    final summary = BookingSummary(
      teacherName: teacherName,
      aulaName: _selectedAula != null ? _aulas[_selectedAula!]['name'] as String : '',
      subject: _subjectController.text,
      career: _careerController.text,
      parallel: _parallelController.text,
      cycle: _cycleController.text,
      numStudents: int.tryParse(_numStudentsController.text) ?? 0,
      slots: slots,
      needsGroups: _needsGroups,
    );

    // Mostrar modal de confirmación con tabla resumen
    final confirmed = await BookingSummaryModal.show(
      context: context,
      summary: summary,
    );
    
    if (confirmed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva confirmada exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
      // Reset form
      _resetForm();
    }
  }

  ScheduleSlot? _cellIdToSlot(String cellId, String? group) {
    // El formato del cellId es: "2024-01-15-7" (fecha ISO - hora)
    try {
      final parts = cellId.split('-');
      if (parts.length < 4) return null;
      
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final hour = int.parse(parts[3]);
      
      return ScheduleSlot(
        date: DateTime(year, month, day),
        hour: hour,
        group: group,
      );
    } catch (e) {
      return null;
    }
  }

  void _resetForm() {
    setState(() {
      _step1Collapsed = false;
      _step2Collapsed = false;
      _step3Collapsed = false;
      _selectedTeacherId = '';
      _selectedAula = null;
      _subjectController.clear();
      _careerController.clear();
      _parallelController.clear();
      _cycleController.clear();
      _numStudentsController.clear();
      _selectedCells.clear();
      _groupCells.clear();
      _activeGroup = 1;
      _totalGroups = 1;
      _needsGroups = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final lang = context.watch<LocaleProvider>().languageCode;
    final t = AppTranslations.of(lang);

    return Column(
      children: [
        // Step 1: Teacher Selection
        _buildStep1(isDark, t),
        
        // Step 2: Classroom Selection (solo si docente capacitado)
        if (_canProceedToStep2 && _step1Collapsed)
          _buildStep2(isDark, t),
        
        // Step 3: Class Details
        if (_canProceedToStep3 && _selectedAula != null && _step2Collapsed)
          _buildStep3(isDark, t),
        
        // Step 4: Schedule Selection
        if (_canProceedToStep4 && _step3Collapsed)
          _buildStep4(isDark, t),
      ],
    );
  }
  
  Widget _buildStep1(bool isDark, AppStrings t) {
    if (_step1Collapsed && _canProceedToStep2) {
      final teacher = _selectedTeacher;
      return _buildCollapsedStep(
        isDark: isDark,
        stepNumber: '1',
        title: t.teacherInfo,
        subtitle: teacher != null 
            ? '${teacher['firstName']} ${teacher['lastName']}' 
            : '',
        onTap: () => setState(() => _step1Collapsed = false),
      );
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step header
          _buildStepHeader('1', t.teacherInfo),
          
          const SizedBox(height: 16),
          
          // Teacher selector
          Row(
            children: [
              Expanded(
                child: AppDropdown<String>(
                  label: 'Seleccionar Docente',
                  hint: 'Seleccione un docente...',
                  value: _selectedTeacherId.isEmpty ? null : _selectedTeacherId,
                  items: _teachers.map((teacher) {
                    final isTrained = teacher['hasTraining'] == true;
                    return DropdownMenuItem(
                      value: teacher['id'] as String,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('${teacher['firstName']} ${teacher['lastName']}'),
                          ),
                          // Badge de estado
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isTrained 
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isTrained ? 'Capacitado' : 'Sin capacitar',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isTrained ? AppColors.success : AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedTeacherId = value ?? ''),
                ),
              ),
              const SizedBox(width: 16),
              AppButton(
                text: 'Nuevo Docente',
                icon: Icons.add,
                onPressed: _handleAddNewTeacher,
              ),
            ],
          ),
          
          // Mostrar estado del docente seleccionado
          if (_selectedTeacherId.isNotEmpty) ...[
            const SizedBox(height: 16),
            
            if (_isSelectedTeacherTrained)
              // Docente capacitado - puede continuar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Este docente ha completado la capacitación y puede realizar reservas.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              // Docente NO capacitado - NO puede continuar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Este docente aún no ha sido capacitado',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'El Técnico del Aula VR debe aprobar que el docente ha recibido la capacitación correspondiente antes de poder realizar reservas.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Por favor, contacte al administrador para coordinar la capacitación.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          
          const SizedBox(height: 24),
          
          // Confirm button - solo habilitado si docente está capacitado
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                text: t.confirmTeacher,
                onPressed: _canProceedToStep2 
                    ? () => setState(() => _step1Collapsed = true)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Muestra modal para solicitar capacitación
  Widget _buildStep2(bool isDark, AppStrings t) {
    if (_step2Collapsed && _selectedAula != null) {
      return _buildCollapsedStep(
        isDark: isDark,
        stepNumber: '2',
        title: t.selectLab,
        subtitle: '${_aulas[_selectedAula!]['name']} - ${_aulas[_selectedAula!]['location']}',
        onTap: () => setState(() => _step2Collapsed = false),
      );
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('2', t.selectLab),
          
          const SizedBox(height: 24),
          
          AulaSelector(
            aulas: _aulas,
            selectedIndex: _selectedAula,
            onSelect: (index) => setState(() => _selectedAula = index),
          ),
          
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                text: t.confirmClassroom,
                onPressed: _canProceedToStep3
                    ? () => setState(() => _step2Collapsed = true)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(bool isDark, AppStrings t) {
    if (_step3Collapsed && _canProceedToStep4) {
      return _buildCollapsedStep(
        isDark: isDark,
        stepNumber: '3',
        title: t.classDetails,
        subtitle: '${_subjectController.text} - ${_careerController.text} - Paralelo ${_parallelController.text} - Ciclo ${_cycleController.text} - ${_numStudentsController.text} estudiantes',
        onTap: () => setState(() => _step3Collapsed = false),
      );
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('3', t.classDetails),
          
          const SizedBox(height: 24),
          
          // Form fields
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: '${t.subject} *',
                  hint: t.subjectPlaceholder,
                  controller: _subjectController,
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  label: '${t.career} *',
                  hint: 'Ej: MEDICINA',
                  controller: _careerController,
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: '${t.parallel} *',
                  hint: 'A',
                  controller: _parallelController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 1,
                  inputFormatters: [
                    // Solo letras mayúsculas (A-Z)
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                    LengthLimitingTextInputFormatter(1),
                    UpperCaseTextFormatter(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  label: '${t.cycle} *',
                  hint: '01',
                  controller: _cycleController,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  label: '${t.numStudents} *',
                  hint: '10',
                  controller: _numStudentsController,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                ),
              ),
            ],
          ),
          
          // Group warning
          if (_needsGroups) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.ucGold.withValues(alpha: 0.1) 
                    : AppColors.warningLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.ucGold.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: AppColors.ucGold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.groupDivisionRequired,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.ucGold : Colors.orange[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.groupDivisionMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark 
                                ? AppColors.ucGold.withValues(alpha: 0.8) 
                                : Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                text: t.confirmData,
                onPressed: _canProceedToStep4
                    ? () => setState(() => _step3Collapsed = true)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep4(bool isDark, AppStrings t) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('4', t.selectSchedule),
          
          const SizedBox(height: 24),
          
          // Group toggle if needed - dinámico según número de grupos
          if (_needsGroups) ...[
            // Info de grupos
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.groups, color: AppColors.info, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Se requieren $_totalGroups grupos: ${_studentsPerGroup.asMap().entries.map((e) => "G${e.key + 1}(${e.value} est.)").join(", ")}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Selector de grupos
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                  spacing: 8,
                  children: List.generate(_totalGroups, (index) {
                    final groupNum = index + 1;
                    final color = _getGroupColor(groupNum);
                    return _buildGroupToggle('Grupo $groupNum', groupNum, color, isDark);
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Legend
          _buildCalendarLegend(isDark),
          
          const SizedBox(height: 16),
          
          // Calendar - envuelto en SizedBox para evitar unbounded height
          SizedBox(
            height: 520, // Altura fija para el calendario (11 horas * ~45px + header)
            child: WeeklyCalendar(
              selectedCells: _needsGroups 
                  ? (_groupCells[_activeGroup] ?? {})
                  : _selectedCells,
              onCellToggle: (cellId) {
                setState(() {
                  if (_needsGroups) {
                    final currentSet = _groupCells.putIfAbsent(_activeGroup, () => <String>{});
                    if (currentSet.contains(cellId)) {
                      currentSet.remove(cellId);
                    } else {
                      currentSet.add(cellId);
                    }
                  } else {
                    if (_selectedCells.contains(cellId)) {
                      _selectedCells.remove(cellId);
                    } else {
                      _selectedCells.add(cellId);
                    }
                  }
                });
              },
              groupCells: _groupCells,
              needsGroups: _needsGroups,
              totalGroups: _totalGroups,
              activeGroup: _activeGroup,
              classInfo: ClassInfo(
                subject: _subjectController.text,
                parallel: _parallelController.text,
                cycle: _cycleController.text,
                group: _needsGroups ? 'G$_activeGroup' : '',
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Center(
            child: AppButton(
              text: t.confirmBooking,
              onPressed: _handleConfirmBooking,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String number, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedStep({
    required bool isDark,
    required String stepNumber,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
          Icon(
            Icons.edit,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
          ),
        ],
      ),
    );
  }

  /// Obtiene un color para cada grupo (usa los mismos colores que WeeklyCalendar)
  Color _getGroupColor(int groupNum) {
    return WeeklyCalendar.getGroupColor(groupNum);
  }

  Widget _buildGroupToggle(String label, int group, Color color, bool isDark) {
    final isActive = _activeGroup == group;
    
    return GestureDetector(
      onTap: () => setState(() => _activeGroup = group),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: isActive 
              ? LinearGradient(colors: [color, color.withValues(alpha: 0.8)])
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive 
                ? Colors.white 
                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarLegend(bool isDark) {
    return Wrap(
      spacing: 24,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem('Disponible', isDark ? AppColors.darkCard : Colors.white, isDark),
        _buildLegendItem('Ocupado', AppColors.calendarOccupied, isDark),
        if (_needsGroups) 
          // Generar leyenda dinámica para todos los grupos
          ...List.generate(_totalGroups, (index) {
            final groupNum = index + 1;
            return _buildLegendItem(
              'Grupo $groupNum', 
              WeeklyCalendar.getGroupColor(groupNum), 
              isDark,
            );
          })
        else
          _buildLegendItem('Seleccionado', AppColors.calendarSelected, isDark),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ],
    );
  }
}
