import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core.dart';
import '../../features/scheduling/widgets/weekly_calendar.dart';

/// Formateador para convertir texto a mayúsculas
class _UpperCaseTextFormatter extends TextInputFormatter {
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

/// Modal para editar una reserva existente
class EditBookingModal extends StatefulWidget {
  final Booking booking;
  final List<Map<String, String>> availableTeachers;
  final Function(Booking updatedBooking) onSave;
  /// Capacidad del aula para determinar si se necesitan grupos
  final int aulaCapacity;
  
  const EditBookingModal({
    super.key,
    required this.booking,
    required this.availableTeachers,
    required this.onSave,
    this.aulaCapacity = 10, // Capacidad por defecto
  });
  
  /// Muestra el modal de edición de reserva
  static Future<Booking?> show({
    required BuildContext context,
    required Booking booking,
    required List<Map<String, String>> availableTeachers,
    int aulaCapacity = 10,
  }) async {
    Booking? result;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditBookingModal(
        booking: booking,
        availableTeachers: availableTeachers,
        aulaCapacity: aulaCapacity,
        onSave: (updatedBooking) {
          result = updatedBooking;
          Navigator.of(context).pop();
        },
      ),
    );
    
    return result;
  }

  @override
  State<EditBookingModal> createState() => _EditBookingModalState();
}

class _EditBookingModalState extends State<EditBookingModal> {
  late TextEditingController _subjectController;
  late TextEditingController _careerController;
  late TextEditingController _parallelController;
  late TextEditingController _cycleController;
  late TextEditingController _numStudentsController;
  late TextEditingController _notesController;
  
  late String _selectedTeacherId;
  
  // Celdas seleccionadas para el calendario (sin grupos)
  final Set<String> _selectedCells = {};
  
  // Soporte para grupos dinámicos
  final Map<int, Set<String>> _groupCells = {};
  int _activeGroup = 1;
  int _totalGroups = 1;
  bool _needsGroups = false;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initializeFields();
  }
  
  void _initializeFields() {
    final booking = widget.booking;
    
    _subjectController = TextEditingController(text: booking.subject);
    _careerController = TextEditingController(text: booking.career);
    _parallelController = TextEditingController(text: booking.parallel ?? '');
    _cycleController = TextEditingController(text: booking.cycle ?? '');
    _numStudentsController = TextEditingController(
      text: booking.numStudents?.toString() ?? '',
    );
    _notesController = TextEditingController(text: booking.notes ?? '');
    
    _selectedTeacherId = booking.teacherId;
    
    // Agregar listener para verificar grupos cuando cambie el número de estudiantes
    _numStudentsController.addListener(_checkGroupsNeeded);
    
    // Inicializar celdas seleccionadas desde la reserva original
    _initializeSelectedCells();
    
    // Verificar si se necesitan grupos
    _checkGroupsNeeded();
  }
  
  void _initializeSelectedCells() {
    final booking = widget.booking;
    // Convertir la fecha y horas a celdas seleccionadas
    for (int hour = booking.startHour; hour < booking.endHour; hour++) {
      final cellId = '${booking.date.toIso8601String().split('T')[0]}-$hour';
      _selectedCells.add(cellId);
    }
    
    // Si la reserva tiene grupo, inicializar las celdas del grupo
    if (booking.group.isNotEmpty && booking.group != 'Grupo único') {
      // Extraer número de grupo del string
      final groupMatch = RegExp(r'Grupo (\d+)').firstMatch(booking.group);
      if (groupMatch != null) {
        final groupNum = int.tryParse(groupMatch.group(1) ?? '1') ?? 1;
        _groupCells[groupNum] = Set.from(_selectedCells);
        _activeGroup = groupNum;
      }
    }
  }
  
  /// Verifica si se necesitan grupos basándose en el número de estudiantes y capacidad del aula
  void _checkGroupsNeeded() {
    final numStudents = int.tryParse(_numStudentsController.text) ?? 0;
    final capacity = widget.aulaCapacity;
    
    setState(() {
      if (numStudents > capacity) {
        _totalGroups = (numStudents / capacity).ceil();
        _needsGroups = true;
        
        // Inicializar sets para cada grupo si no existen
        for (int i = 1; i <= _totalGroups; i++) {
          _groupCells.putIfAbsent(i, () => <String>{});
        }
        
        // Si había celdas en _selectedCells, moverlas al grupo 1
        if (_selectedCells.isNotEmpty && _groupCells[1]!.isEmpty) {
          _groupCells[1]!.addAll(_selectedCells);
          _selectedCells.clear();
        }
      } else {
        _needsGroups = false;
        _totalGroups = 1;
        _activeGroup = 1;
        
        // Si había celdas en grupos, moverlas a _selectedCells
        if (_groupCells.isNotEmpty) {
          for (final cells in _groupCells.values) {
            _selectedCells.addAll(cells);
          }
          _groupCells.clear();
        }
      }
    });
  }
  
  /// Calcula los estudiantes por grupo
  List<int> get _studentsPerGroup {
    final numStudents = int.tryParse(_numStudentsController.text) ?? 0;
    final capacity = widget.aulaCapacity;
    
    if (!_needsGroups || _totalGroups <= 1) return [numStudents];
    
    final studentsPerGroup = <int>[];
    int remaining = numStudents;
    
    for (int i = 0; i < _totalGroups; i++) {
      final students = remaining > capacity ? capacity : remaining;
      studentsPerGroup.add(students);
      remaining -= students;
    }
    
    return studentsPerGroup;
  }
  
  @override
  void dispose() {
    _subjectController.dispose();
    _careerController.dispose();
    _parallelController.dispose();
    _cycleController.dispose();
    _numStudentsController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  bool get _canSave {
    final hasCells = _needsGroups 
        ? _groupCells.values.any((cells) => cells.isNotEmpty)
        : _selectedCells.isNotEmpty;
    
    return _subjectController.text.isNotEmpty &&
           _careerController.text.isNotEmpty &&
           _selectedTeacherId.isNotEmpty &&
           hasCells;
  }
  
  bool get _hasChanges {
    final booking = widget.booking;
    
    // Verificar cambios en campos de texto
    if (_subjectController.text != booking.subject ||
        _careerController.text != booking.career ||
        _parallelController.text != (booking.parallel ?? '') ||
        _cycleController.text != (booking.cycle ?? '') ||
        _numStudentsController.text != (booking.numStudents?.toString() ?? '') ||
        _notesController.text != (booking.notes ?? '') ||
        _selectedTeacherId != booking.teacherId) {
      return true;
    }
    
    // Verificar cambios en celdas seleccionadas
    final originalCells = <String>{};
    for (int hour = booking.startHour; hour < booking.endHour; hour++) {
      final cellId = '${booking.date.toIso8601String().split('T')[0]}-$hour';
      originalCells.add(cellId);
    }
    
    // Si se necesitan grupos, verificar las celdas de los grupos
    if (_needsGroups) {
      final allGroupCells = <String>{};
      for (final cells in _groupCells.values) {
        allGroupCells.addAll(cells);
      }
      return !allGroupCells.containsAll(originalCells) || 
             !originalCells.containsAll(allGroupCells);
    }
    
    return !_selectedCells.containsAll(originalCells) || 
           !originalCells.containsAll(_selectedCells);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;
    
    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 900),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isDark, isSpanish),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      _buildErrorBanner(isDark),
                    
                    // Sección de datos de la clase
                    _buildSectionTitle(
                      isDark, 
                      isSpanish ? 'Datos de la Clase' : 'Class Data',
                      LucideIcons.bookOpen,
                    ),
                    const SizedBox(height: 12),
                    _buildTeacherSelector(isDark, isSpanish),
                    const SizedBox(height: 16),
                    _buildSubjectField(isDark, isSpanish),
                    const SizedBox(height: 16),
                    _buildCareerField(isDark, isSpanish),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildParallelField(isDark, isSpanish)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildCycleField(isDark, isSpanish)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildNumStudentsField(isDark, isSpanish)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Sección de horarios con tabla
                    _buildSectionTitle(
                      isDark, 
                      isSpanish ? 'Horarios Seleccionados' : 'Selected Schedule',
                      LucideIcons.calendar,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSpanish 
                          ? 'Haz clic en las celdas para agregar o quitar horarios'
                          : 'Click on cells to add or remove time slots',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark 
                            ? AppColors.darkTextSecondary 
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Selector de grupos si se necesitan
                    if (_needsGroups) ...[
                      _buildGroupSelector(isDark, isSpanish),
                      const SizedBox(height: 16),
                    ],
                    
                    // Tabla del calendario
                    SizedBox(
                      height: 400,
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
                        showNavigation: true,
                        classInfo: ClassInfo(
                          subject: _subjectController.text,
                          parallel: _parallelController.text,
                          cycle: _cycleController.text,
                          group: _needsGroups ? 'G$_activeGroup' : '',
                        ),
                      ),
                    ),
                    
                    // Resumen de horarios seleccionados
                    if (_selectedCells.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSelectedSlotsChips(isDark, isSpanish),
                    ],
                    
                    const SizedBox(height: 16),
                    _buildNotesField(isDark, isSpanish),
                  ],
                ),
              ),
            ),
            _buildActions(isDark, isSpanish),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(bool isDark, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSelectedSlotsChips(bool isDark, bool isSpanish) {
    // Organizar celdas por fecha
    final slotsByDate = <String, List<int>>{};
    for (final cellId in _selectedCells) {
      final parts = cellId.split('-');
      if (parts.length >= 4) {
        final dateKey = '${parts[0]}-${parts[1]}-${parts[2]}';
        final hour = int.tryParse(parts[3]) ?? 0;
        slotsByDate.putIfAbsent(dateKey, () => []).add(hour);
      }
    }
    
    // Ordenar horas
    for (final hours in slotsByDate.values) {
      hours.sort();
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSpanish 
                ? '${_selectedCells.length} hora(s) seleccionada(s):'
                : '${_selectedCells.length} hour(s) selected:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: slotsByDate.entries.map((entry) {
              final date = DateTime.parse(entry.key);
              final hours = entry.value;
              final daysEs = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
              final daysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              final days = isSpanish ? daysEs : daysEn;
              
              return Chip(
                label: Text(
                  '${days[date.weekday - 1]} ${date.day}: ${hours.map((h) => '${h.toString().padLeft(2, '0')}:00').join(', ')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader(bool isDark, bool isSpanish) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkCardBackground 
            : AppColors.lightCardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              LucideIcons.pencil,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSpanish ? 'Editar Reserva' : 'Edit Booking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark 
                        ? AppColors.darkTextPrimary 
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  'ID: ${widget.booking.id}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark 
                        ? AppColors.darkTextSecondary 
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              LucideIcons.x,
              color: isDark 
                  ? AppColors.darkTextSecondary 
                  : AppColors.lightTextSecondary,
            ),
            onPressed: () => _handleClose(isSpanish),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.triangleAlert, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: AppColors.error, fontSize: 14),
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.x, color: AppColors.error, size: 16),
            onPressed: () => setState(() => _errorMessage = null),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTeacherSelector(bool isDark, bool isSpanish) {
    final textColor = isDark 
        ? AppColors.darkTextPrimary 
        : AppColors.lightTextPrimary;
    final labelColor = isDark 
        ? AppColors.darkTextSecondary 
        : AppColors.lightTextSecondary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSpanish ? 'Docente *' : 'Teacher *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.darkCardBackground 
                : AppColors.lightCardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark 
                  ? AppColors.darkBorder 
                  : AppColors.lightBorder,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedTeacherId.isNotEmpty ? _selectedTeacherId : null,
              hint: Text(
                isSpanish ? 'Seleccionar docente' : 'Select teacher',
                style: TextStyle(color: labelColor),
              ),
              dropdownColor: isDark 
                  ? AppColors.darkCardBackground 
                  : AppColors.lightCardBackground,
              items: widget.availableTeachers.map((teacher) {
                return DropdownMenuItem(
                  value: teacher['id'],
                  child: Text(
                    '${teacher['firstName']} ${teacher['lastName']}',
                    style: TextStyle(color: textColor),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedTeacherId = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSubjectField(bool isDark, bool isSpanish) {
    return AppTextField(
      controller: _subjectController,
      label: isSpanish ? 'Materia *' : 'Subject *',
      hintText: isSpanish ? 'Nombre de la materia' : 'Subject name',
      prefixIcon: LucideIcons.bookOpen,
      onChanged: (_) => setState(() {}),
    );
  }
  
  Widget _buildCareerField(bool isDark, bool isSpanish) {
    return AppTextField(
      controller: _careerController,
      label: isSpanish ? 'Carrera *' : 'Career *',
      hintText: isSpanish ? 'Nombre de la carrera' : 'Career name',
      prefixIcon: LucideIcons.graduationCap,
      onChanged: (_) => setState(() {}),
    );
  }
  
  Widget _buildParallelField(bool isDark, bool isSpanish) {
    return AppTextField(
      controller: _parallelController,
      label: isSpanish ? 'Paralelo' : 'Parallel',
      hintText: 'A',
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
        LengthLimitingTextInputFormatter(1),
        _UpperCaseTextFormatter(),
      ],
      onChanged: (_) => setState(() {}),
    );
  }
  
  Widget _buildCycleField(bool isDark, bool isSpanish) {
    return AppTextField(
      controller: _cycleController,
      label: isSpanish ? 'Ciclo' : 'Cycle',
      hintText: '1',
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
      onChanged: (_) => setState(() {}),
    );
  }
  
  Widget _buildNumStudentsField(bool isDark, bool isSpanish) {
    return AppTextField(
      controller: _numStudentsController,
      label: isSpanish ? 'Estudiantes' : 'Students',
      hintText: '10',
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      onChanged: (_) => setState(() {}),
    );
  }
  
  Widget _buildNotesField(bool isDark, bool isSpanish) {
    return AppTextField(
      controller: _notesController,
      label: isSpanish ? 'Notas adicionales' : 'Additional notes',
      hintText: isSpanish 
          ? 'Información adicional sobre la reserva...' 
          : 'Additional booking information...',
      maxLines: 3,
      onChanged: (_) => setState(() {}),
    );
  }
  
  /// Construye el selector de grupos
  Widget _buildGroupSelector(bool isDark, bool isSpanish) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info de grupos
          Row(
            children: [
              Icon(LucideIcons.users, color: AppColors.info, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSpanish
                      ? 'Se requieren $_totalGroups grupos: ${_studentsPerGroup.asMap().entries.map((e) => "G${e.key + 1}(${e.value} est.)").join(", ")}'
                      : '$_totalGroups groups required: ${_studentsPerGroup.asMap().entries.map((e) => "G${e.key + 1}(${e.value} stud.)").join(", ")}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Selector de grupo activo
          Text(
            isSpanish 
                ? 'Seleccione el grupo a editar:'
                : 'Select group to edit:',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_totalGroups, (index) {
                final groupNum = index + 1;
                final color = WeeklyCalendar.getGroupColor(groupNum);
                final isActive = _activeGroup == groupNum;
                final cellCount = _groupCells[groupNum]?.length ?? 0;
                
                return GestureDetector(
                  onTap: () => setState(() => _activeGroup = groupNum),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isActive 
                          ? LinearGradient(colors: [color, color.withValues(alpha: 0.8)])
                          : null,
                      color: isActive ? null : (isDark ? AppColors.darkCard : Colors.white),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive ? color : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isSpanish ? 'Grupo $groupNum' : 'Group $groupNum',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isActive 
                                ? Colors.white 
                                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary),
                          ),
                        ),
                        if (cellCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isActive 
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$cellCount',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.white : color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActions(bool isDark, bool isSpanish) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkCardBackground 
            : AppColors.lightCardBackground,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(
            color: isDark 
                ? AppColors.darkBorder 
                : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppSecondaryButton(
              text: isSpanish ? 'Cancelar' : 'Cancel',
              onPressed: () => _handleClose(isSpanish),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              text: isSpanish ? 'Guardar Cambios' : 'Save Changes',
              isLoading: _isLoading,
              onPressed: _canSave && _hasChanges ? _handleSave : null,
              icon: LucideIcons.save,
            ),
          ),
        ],
      ),
    );
  }
  
  void _handleClose(bool isSpanish) async {
    if (_hasChanges) {
      final confirmed = await AppConfirmModal.show(
        context: context,
        title: isSpanish ? '¿Descartar cambios?' : 'Discard changes?',
        message: isSpanish
            ? 'Tienes cambios sin guardar. ¿Estás seguro de que deseas salir?'
            : 'You have unsaved changes. Are you sure you want to leave?',
        confirmText: isSpanish ? 'Descartar' : 'Discard',
        cancelText: isSpanish ? 'Continuar editando' : 'Keep editing',
        isDanger: true,
      );
      
      if (confirmed == true && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }
  
  Future<void> _handleSave() async {
    if (!_canSave) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Obtener las celdas según si hay grupos o no
      final cellsToUse = _needsGroups 
          ? (_groupCells[_activeGroup] ?? {})
          : _selectedCells;
      
      // Extraer la fecha y horas de las celdas seleccionadas
      DateTime? selectedDate;
      int? startHour;
      int? endHour;
      
      final sortedCells = cellsToUse.toList()..sort();
      if (sortedCells.isNotEmpty) {
        // Parse first cell to get date
        final firstCellParts = sortedCells.first.split('-');
        if (firstCellParts.length >= 4) {
          selectedDate = DateTime.parse('${firstCellParts[0]}-${firstCellParts[1]}-${firstCellParts[2]}');
          
          // Get all hours for this date and find range
          final hours = <int>[];
          for (final cell in sortedCells) {
            final parts = cell.split('-');
            if (parts.length >= 4) {
              hours.add(int.tryParse(parts[3]) ?? 0);
            }
          }
          hours.sort();
          startHour = hours.first;
          endHour = hours.last + 1; // endHour es exclusivo
        }
      }
      
      // Determinar el string del grupo
      String groupString;
      if (_needsGroups) {
        groupString = 'Grupo $_activeGroup';
      } else {
        groupString = 'Grupo único';
      }
      
      final updatedBooking = widget.booking.copyWith(
        teacherId: _selectedTeacherId,
        date: selectedDate ?? widget.booking.date,
        startHour: startHour ?? widget.booking.startHour,
        endHour: endHour ?? widget.booking.endHour,
        subject: _subjectController.text,
        career: _careerController.text,
        parallel: _parallelController.text.isNotEmpty 
            ? _parallelController.text 
            : null,
        cycle: _cycleController.text.isNotEmpty 
            ? _cycleController.text 
            : null,
        numStudents: _numStudentsController.text.isNotEmpty 
            ? int.tryParse(_numStudentsController.text) 
            : null,
        notes: _notesController.text.isNotEmpty 
            ? _notesController.text 
            : null,
        group: groupString,
      );
      
      widget.onSave(updatedBooking);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al guardar: $e';
          _isLoading = false;
        });
      }
    }
  }
}
