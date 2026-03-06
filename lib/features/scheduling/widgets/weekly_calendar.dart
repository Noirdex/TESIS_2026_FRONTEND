import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

/// Configuración del semestre para límites del calendario
class SemesterConfig {
  final DateTime startDate;
  final DateTime endDate;
  final String name;
  
  const SemesterConfig({
    required this.startDate,
    required this.endDate,
    required this.name,
  });
  
  bool isDateInSemester(DateTime date) {
    return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
           date.isBefore(endDate.add(const Duration(days: 1)));
  }
  
  /// Semestre actual por defecto (ejemplo)
  factory SemesterConfig.current() {
    final now = DateTime.now();
    // Semestre 1: Marzo - Agosto, Semestre 2: Septiembre - Febrero
    if (now.month >= 3 && now.month <= 8) {
      return SemesterConfig(
        startDate: DateTime(now.year, 3, 1),
        endDate: DateTime(now.year, 8, 31),
        name: 'Semestre Marzo - Agosto ${now.year}',
      );
    } else {
      final year = now.month >= 9 ? now.year : now.year - 1;
      return SemesterConfig(
        startDate: DateTime(year, 9, 1),
        endDate: DateTime(year + 1, 2, 28),
        name: 'Semestre Septiembre $year - Febrero ${year + 1}',
      );
    }
  }
}

/// Información de la clase actual que se está agendando
class ClassInfo {
  final String subject;
  final String parallel;
  final String cycle;
  final String group;
  
  const ClassInfo({
    this.subject = '',
    this.parallel = '',
    this.cycle = '',
    this.group = '',
  });
  
  bool get isNotEmpty => subject.isNotEmpty || parallel.isNotEmpty || cycle.isNotEmpty;
  
  String get displayText {
    final parts = <String>[];
    if (subject.isNotEmpty) parts.add(subject);
    if (parallel.isNotEmpty) parts.add('P:$parallel');
    if (cycle.isNotEmpty) parts.add('C:$cycle');
    if (group.isNotEmpty) parts.add(group);
    return parts.join(' · ');
  }
}

/// Calendario semanal interactivo con navegación y límites de semestre
class WeeklyCalendar extends StatefulWidget {
  final Set<String> selectedCells;
  final ValueChanged<String> onCellToggle;
  /// Mapa dinámico de grupos: clave = número de grupo, valor = celdas seleccionadas
  final Map<int, Set<String>> groupCells;
  final bool needsGroups;
  /// Número total de grupos (para generar la leyenda)
  final int totalGroups;
  /// Grupo actualmente activo para selección
  final int activeGroup;
  final Set<String> occupiedCells;
  final Map<String, BookingInfo>? bookingInfo;
  final DateTime? initialWeek;
  final SemesterConfig? semesterConfig;
  final ValueChanged<DateTime>? onWeekChanged;
  final bool showNavigation;
  final bool allowPastDates;
  /// Información de la clase actual para mostrar en celdas seleccionadas
  final ClassInfo? classInfo;

  // Constants - 7 días: Lunes a Domingo
  static const List<String> weekDaysEs = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  static const List<String> weekDaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<int> hours = [7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17];
  
  /// Colores predefinidos para grupos (hasta 10 grupos)
  static const List<Color> groupColors = [
    Color(0xFF4CAF50), // Verde - Grupo 1
    Color(0xFF2196F3), // Azul - Grupo 2
    Color(0xFFFF9800), // Naranja - Grupo 3
    Color(0xFF9C27B0), // Púrpura - Grupo 4
    Color(0xFF00BCD4), // Cyan - Grupo 5
    Color(0xFFE91E63), // Rosa - Grupo 6
    Color(0xFF795548), // Marrón - Grupo 7
    Color(0xFF607D8B), // Gris azulado - Grupo 8
    Color(0xFFCDDC39), // Lima - Grupo 9
    Color(0xFFFF5722), // Naranja profundo - Grupo 10
  ];
  
  /// Obtiene el color para un grupo específico (1-indexed)
  static Color getGroupColor(int groupNumber) {
    if (groupNumber < 1) return groupColors[0];
    return groupColors[(groupNumber - 1) % groupColors.length];
  }

  const WeeklyCalendar({
    super.key,
    required this.selectedCells,
    required this.onCellToggle,
    this.groupCells = const {},
    this.needsGroups = false,
    this.totalGroups = 1,
    this.activeGroup = 1,
    this.occupiedCells = const {},
    this.bookingInfo,
    this.initialWeek,
    this.semesterConfig,
    this.onWeekChanged,
    this.showNavigation = true,
    this.allowPastDates = false,
    this.classInfo,
  });

  @override
  State<WeeklyCalendar> createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  late DateTime _currentWeekStart;
  late SemesterConfig _semester;
  
  @override
  void initState() {
    super.initState();
    _semester = widget.semesterConfig ?? SemesterConfig.current();
    _currentWeekStart = _getWeekStart(widget.initialWeek ?? DateTime.now());
    
    // Asegurar que la semana inicial esté dentro del semestre
    if (!_semester.isDateInSemester(_currentWeekStart)) {
      _currentWeekStart = _getWeekStart(_semester.startDate);
    }
  }
  
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - weekday + 1);
  }
  
  DateTime _getDateForDay(int dayIndex) {
    return _currentWeekStart.add(Duration(days: dayIndex));
  }
  
  bool get _canGoBack {
    final previousWeek = _currentWeekStart.subtract(const Duration(days: 7));
    if (!widget.allowPastDates) {
      final now = DateTime.now();
      final currentWeekStart = _getWeekStart(now);
      if (previousWeek.isBefore(currentWeekStart)) return false;
    }
    return _semester.isDateInSemester(previousWeek);
  }
  
  bool get _canGoForward {
    final nextWeek = _currentWeekStart.add(const Duration(days: 7));
    return _semester.isDateInSemester(nextWeek);
  }
  
  void _goToPreviousWeek() {
    if (!_canGoBack) return;
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
    widget.onWeekChanged?.call(_currentWeekStart);
  }
  
  void _goToNextWeek() {
    if (!_canGoForward) return;
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
    widget.onWeekChanged?.call(_currentWeekStart);
  }
  
  void _goToToday() {
    final today = DateTime.now();
    final todayWeekStart = _getWeekStart(today);
    if (_semester.isDateInSemester(todayWeekStart)) {
      setState(() {
        _currentWeekStart = todayWeekStart;
      });
      widget.onWeekChanged?.call(_currentWeekStart);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;
    final weekDays = isSpanish 
        ? WeeklyCalendar.weekDaysEs 
        : WeeklyCalendar.weekDaysEn;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showNavigation) ...[
          _buildNavigationHeader(isDark, isSpanish),
          const SizedBox(height: 12),
        ],
        _buildLegend(isDark, isSpanish),
        const SizedBox(height: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calcular anchos dinámicamente para ocupar todo el espacio
              const timeColumnWidth = 70.0;
              const minDayWidth = 80.0; // Reducido para 7 días
              const dayCount = 7; // Lunes a Domingo
              
              // Ancho disponible para los días
              final availableWidth = constraints.maxWidth - timeColumnWidth;
              // Ancho de cada día (al menos minDayWidth)
              final dayWidth = (availableWidth / dayCount).clamp(minDayWidth, double.infinity);
              
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Column(
                    children: [
                      // Header FIJO - no se mueve con el scroll
                      _buildHeaderRow(isDark, weekDays, dayWidth: dayWidth),
                      // Body con SCROLL - solo las horas hacen scroll
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: WeeklyCalendar.hours.map(
                              (hour) => _buildTimeRow(hour, isDark, weekDays, dayWidth: dayWidth),
                            ).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationHeader(bool isDark, bool isSpanish) {
    final textColor = isDark 
        ? AppColors.darkTextPrimary 
        : AppColors.lightTextPrimary;
    final mutedColor = isDark 
        ? AppColors.darkTextSecondary 
        : AppColors.lightTextSecondary;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          // Semester indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _semester.name,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Week navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  LucideIcons.chevronLeft,
                  color: _canGoBack ? textColor : mutedColor,
                ),
                onPressed: _canGoBack ? _goToPreviousWeek : null,
                tooltip: isSpanish ? 'Semana anterior' : 'Previous week',
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _formatWeekRange(isSpanish),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _goToToday,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, 
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _isCurrentWeek() 
                              ? AppColors.success.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isCurrentWeek() 
                                ? AppColors.success.withValues(alpha: 0.3)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 14,
                              color: _isCurrentWeek() 
                                  ? AppColors.success 
                                  : mutedColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isCurrentWeek()
                                  ? (isSpanish ? 'Semana actual' : 'Current week')
                                  : (isSpanish ? 'Ir a hoy' : 'Go to today'),
                              style: TextStyle(
                                fontSize: 12,
                                color: _isCurrentWeek() 
                                    ? AppColors.success 
                                    : mutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.chevronRight,
                  color: _canGoForward ? textColor : mutedColor,
                ),
                onPressed: _canGoForward ? _goToNextWeek : null,
                tooltip: isSpanish ? 'Semana siguiente' : 'Next week',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isDark, bool isSpanish) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem(
          isDark,
          color: AppColors.calendarAvailable,
          label: isSpanish ? 'Disponible' : 'Available',
        ),
        _buildLegendItem(
          isDark,
          color: AppColors.calendarSelected,
          label: isSpanish ? 'Seleccionado' : 'Selected',
        ),
        _buildLegendItem(
          isDark,
          color: AppColors.calendarOccupied,
          label: isSpanish ? 'Ocupado' : 'Occupied',
        ),
        _buildLegendItem(
          isDark,
          color: AppColors.calendarLunch,
          label: isSpanish ? 'Almuerzo' : 'Lunch',
        ),
        // Generar leyenda dinámica para todos los grupos
        if (widget.needsGroups) 
          ...List.generate(widget.totalGroups, (index) {
            final groupNum = index + 1;
            return _buildLegendItem(
              isDark,
              color: WeeklyCalendar.getGroupColor(groupNum),
              label: isSpanish ? 'Grupo $groupNum' : 'Group $groupNum',
            );
          }),
      ],
    );
  }

  Widget _buildLegendItem(bool isDark, {required Color color, required String label}) {
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
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark 
                ? AppColors.darkTextSecondary 
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(bool isDark, List<String> weekDays, {double dayWidth = 90}) {
    final isSpanish = context.watch<LocaleProvider>().isSpanish;
    
    return Container(
      color: isDark ? AppColors.darkCardBackground : AppColors.lightInputBg,
      child: Row(
        children: [
          // Empty corner cell
          Container(
            width: 70,
            height: 56,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: Center(
              child: Text(
                isSpanish ? 'Hora' : 'Time',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark 
                      ? AppColors.darkTextSecondary 
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ),
          // Day headers with dates (7 días: Lun-Dom)
          ...List.generate(7, (index) {
            final date = _getDateForDay(index);
            final isToday = _isToday(date);
            final isPast = _isPastDate(date);
            
            return Expanded(
              child: Container(
                constraints: BoxConstraints(minWidth: dayWidth),
                height: 56,
                decoration: BoxDecoration(
                  color: isToday 
                      ? AppColors.primary.withValues(alpha: 0.1) 
                      : null,
                  border: Border(
                    right: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    bottom: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weekDays[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isPast 
                            ? (isDark 
                                ? AppColors.darkTextMuted 
                                : AppColors.lightTextSecondary)
                            : (isToday 
                                ? AppColors.primary 
                                : (isDark 
                                    ? AppColors.darkTextPrimary 
                                    : AppColors.lightTextPrimary)),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, 
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                          color: isToday 
                              ? Colors.white 
                              : (isPast 
                                  ? (isDark 
                                      ? AppColors.darkTextMuted 
                                      : AppColors.lightTextSecondary)
                                  : (isDark 
                                      ? AppColors.darkTextSecondary 
                                      : AppColors.lightTextSecondary)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeRow(int hour, bool isDark, List<String> weekDays, {double dayWidth = 90}) {
    final isLunchHour = hour == 12;
    
    return Row(
      children: [
        // Time label
        Container(
          width: 70,
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBackground : AppColors.lightInputBg,
            border: Border(
              right: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              bottom: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
          child: Center(
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark 
                    ? AppColors.darkTextSecondary 
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ),
        // Day cells - 7 días expandibles
        ...List.generate(7, (dayIndex) {
          final date = _getDateForDay(dayIndex);
          final cellId = '${date.toIso8601String().split('T')[0]}-$hour';
          return Expanded(
            child: _buildCell(cellId, hour, dayIndex, isDark, isLunchHour, dayWidth: dayWidth),
          );
        }),
      ],
    );
  }

  Widget _buildCell(
    String cellId, 
    int hour, 
    int dayIndex, 
    bool isDark, 
    bool isLunchHour,
    {double dayWidth = 90}
  ) {
    final date = _getDateForDay(dayIndex);
    final isPast = _isPastDate(date);
    final isOccupied = widget.occupiedCells.contains(cellId);
    final isSelected = widget.selectedCells.contains(cellId);
    final bookingData = widget.bookingInfo?[cellId];
    
    final isDisabled = isPast || (isLunchHour && !isOccupied);
    
    // Determinar en qué grupos está esta celda y su etiqueta
    String? currentGroupLabel;
    List<int> cellGroups = [];
    if (widget.needsGroups) {
      for (int groupNum = 1; groupNum <= widget.totalGroups; groupNum++) {
        if (widget.groupCells[groupNum]?.contains(cellId) == true) {
          cellGroups.add(groupNum);
        }
      }
      if (cellGroups.isNotEmpty) {
        currentGroupLabel = cellGroups.map((g) => 'G$g').join('/');
      }
    }
    
    Color cellColor;
    if (isLunchHour) {
      cellColor = AppColors.calendarLunch;
    } else if (isPast) {
      cellColor = isDark 
          ? AppColors.darkCardBackground.withValues(alpha: 0.5)
          : Colors.grey.shade100;
    } else if (isOccupied) {
      cellColor = AppColors.calendarOccupied;
    } else if (widget.needsGroups && cellGroups.isNotEmpty) {
      // Si la celda pertenece a múltiples grupos, mostrar color de conflicto
      if (cellGroups.length > 1) {
        cellColor = AppColors.calendarConflict;
      } else {
        // Usar el color del grupo correspondiente
        cellColor = WeeklyCalendar.getGroupColor(cellGroups.first);
      }
    } else if (isSelected) {
      cellColor = AppColors.calendarSelected;
    } else {
      // Celdas disponibles en BLANCO (o fondo del card en dark mode)
      cellColor = isDark ? AppColors.darkCard : Colors.white;
    }
    
    return GestureDetector(
      onTap: isDisabled || isOccupied 
          ? null 
          : () => widget.onCellToggle(cellId),
      onLongPress: isOccupied && bookingData != null
          ? () => _showBookingTooltip(context, bookingData)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: BoxConstraints(minWidth: dayWidth),
        height: 52,
        decoration: BoxDecoration(
          color: cellColor,
          border: Border(
            right: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            bottom: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
        ),
        child: _buildCellContent(
          isLunchHour, 
          isOccupied, 
          isPast, 
          bookingData,
          isDark,
          isSelected: isSelected,
          groupLabel: currentGroupLabel,
        ),
      ),
    );
  }

  Widget? _buildCellContent(
    bool isLunchHour,
    bool isOccupied,
    bool isPast,
    BookingInfo? bookingData,
    bool isDark, {
    bool isSelected = false,
    String? groupLabel,
  }) {
    final isSpanish = context.read<LocaleProvider>().isSpanish;
    
    if (isLunchHour) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.utensils,
              size: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 4),
            Text(
              isSpanish ? 'Almuerzo' : 'Lunch',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      );
    }
    
    if (isPast) {
      return Center(
        child: Icon(
          LucideIcons.minus,
          size: 14,
          color: isDark 
              ? AppColors.darkTextMuted 
              : AppColors.lightTextSecondary.withValues(alpha: 0.5),
        ),
      );
    }
    
    if (isOccupied && bookingData != null) {
      return Tooltip(
        message: '${bookingData.teacherName}\n${bookingData.subject}',
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                bookingData.type == BookingType.blocked 
                    ? LucideIcons.lock 
                    : LucideIcons.user,
                size: 14,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              if (bookingData.subject.isNotEmpty)
                Text(
                  bookingData.subject.length > 8 
                      ? '${bookingData.subject.substring(0, 8)}...' 
                      : bookingData.subject,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      );
    }
    
    if (isOccupied) {
      return Center(
        child: Icon(
          LucideIcons.ban,
          size: 16,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      );
    }
    
    // Mostrar información de la clase cuando la celda está seleccionada
    if (isSelected && widget.classInfo != null && widget.classInfo!.isNotEmpty) {
      final classInfo = widget.classInfo!;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (groupLabel != null)
              Text(
                groupLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            if (classInfo.subject.isNotEmpty)
              Text(
                classInfo.subject.length > 10 
                    ? '${classInfo.subject.substring(0, 10)}...'
                    : classInfo.subject,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              'P:${classInfo.parallel} C:${classInfo.cycle}',
              style: TextStyle(
                fontSize: 8,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      );
    }
    
    // Celda seleccionada sin info de clase, solo mostrar grupo si aplica
    if (isSelected && groupLabel != null) {
      return Center(
        child: Text(
          groupLabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      );
    }
    
    return null;
  }

  void _showBookingTooltip(BuildContext context, BookingInfo booking) {
    final isSpanish = context.read<LocaleProvider>().isSpanish;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.subject,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(booking.teacherName),
            if (booking.career.isNotEmpty)
              Text(
                '${isSpanish ? 'Carrera' : 'Career'}: ${booking.career}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatWeekRange(bool isSpanish) {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6)); // Lunes a Domingo
    
    final months = isSpanish
        ? ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic']
        : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    if (_currentWeekStart.month == weekEnd.month) {
      return '${_currentWeekStart.day} - ${weekEnd.day} ${months[weekEnd.month - 1]} ${weekEnd.year}';
    } else {
      return '${_currentWeekStart.day} ${months[_currentWeekStart.month - 1]} - ${weekEnd.day} ${months[weekEnd.month - 1]} ${weekEnd.year}';
    }
  }

  bool _isCurrentWeek() {
    final now = DateTime.now();
    final currentWeekStart = _getWeekStart(now);
    return _currentWeekStart.year == currentWeekStart.year &&
           _currentWeekStart.month == currentWeekStart.month &&
           _currentWeekStart.day == currentWeekStart.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  bool _isPastDate(DateTime date) {
    if (widget.allowPastDates) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today);
  }
}

/// Información de una reserva para mostrar en el calendario
class BookingInfo {
  final String id;
  final String teacherName;
  final String subject;
  final String career;
  final BookingType type;
  
  const BookingInfo({
    required this.id,
    required this.teacherName,
    required this.subject,
    this.career = '',
    this.type = BookingType.regular,
  });
}
