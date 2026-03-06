import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../models/booking.dart';
import '../models/aula.dart';
import 'app_button.dart';

/// Modal para bloquear horarios (admin)
class BlockScheduleModal extends StatefulWidget {
  final Aula aula;
  final List<Booking> existingBookings;
  final ValueChanged<Booking> onBlockCreated;

  const BlockScheduleModal({
    super.key,
    required this.aula,
    required this.existingBookings,
    required this.onBlockCreated,
  });

  /// Muestra el modal
  static Future<Booking?> show({
    required BuildContext context,
    required Aula aula,
    required List<Booking> existingBookings,
  }) async {
    Booking? result;
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => BlockScheduleModal(
        aula: aula,
        existingBookings: existingBookings.where((b) => b.aulaId == aula.id).toList(),
        onBlockCreated: (booking) {
          result = booking;
          Navigator.of(context).pop();
        },
      ),
    );
    return result;
  }

  @override
  State<BlockScheduleModal> createState() => _BlockScheduleModalState();
}

class _BlockScheduleModalState extends State<BlockScheduleModal> {
  // Celdas seleccionadas - formato: "YYYY-MM-DD-HH:MM"
  final Set<String> _selectedCells = {};
  int _weekOffset = 0;
  bool _repeatWeekly = false;

  static const List<String> _days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie'];
  static const List<String> _hours = [
    '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'
  ];

  List<DateTime> get _weekDates {
    final today = DateTime.now();
    final currentDay = today.weekday; // 1 = Monday
    final monday = today.subtract(Duration(days: currentDay - 1));
    final targetMonday = monday.add(Duration(days: _weekOffset * 7));
    
    return List.generate(5, (i) => DateTime(
      targetMonday.year,
      targetMonday.month,
      targetMonday.day + i,
    ));
  }

  String get _weekRangeText {
    final dates = _weekDates;
    String formatDate(DateTime d) => '${d.day}/${d.month}';
    return '${formatDate(dates.first)} - ${formatDate(dates.last)}, ${dates.last.year}';
  }

  String get _monthYearText {
    final dates = _weekDates;
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final firstMonth = months[dates.first.month - 1];
    final lastMonth = months[dates.last.month - 1];
    
    if (dates.first.month == dates.last.month) {
      return '$firstMonth ${dates.first.year}';
    }
    return '$firstMonth - $lastMonth ${dates.last.year}';
  }

  bool _isPastDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isBefore(today);
  }

  CalendarCellStatus _getCellStatus(int dayIndex, String hour) {
    final date = _weekDates[dayIndex];
    final dayName = _days[dayIndex];
    final cellId = '${date.toIso8601String().split('T')[0]}-$hour';
    
    // Verificar si está seleccionada
    if (_selectedCells.contains(cellId)) {
      return CalendarCellStatus.selected;
    }
    
    // Verificar si hay una reserva existente
    final existingBooking = widget.existingBookings.firstWhere(
      (b) => b.schedule.contains('$dayName-$hour') && b.isActive,
      orElse: () => Booking(
        id: '', teacherId: '', teacherName: '', aulaId: '', aulaName: '',
        subject: '', career: '', parallel: '', cycle: '', numStudents: 0,
        group: '', schedule: [], date: DateTime.now(),
      ),
    );
    
    if (existingBooking.id.isNotEmpty) {
      if (existingBooking.isLunch) return CalendarCellStatus.lunch;
      if (existingBooking.isBlocked) return CalendarCellStatus.blocked;
      return CalendarCellStatus.occupied;
    }
    
    return CalendarCellStatus.free;
  }

  void _toggleCell(int dayIndex, String hour) {
    final date = _weekDates[dayIndex];
    if (_isPastDate(date)) {
      return;
    }
    
    final status = _getCellStatus(dayIndex, hour);
    if (status == CalendarCellStatus.occupied || 
        status == CalendarCellStatus.lunch) {
      return;
    }
    
    final cellId = '${date.toIso8601String().split('T')[0]}-$hour';
    
    setState(() {
      if (_selectedCells.contains(cellId)) {
        _selectedCells.remove(cellId);
      } else {
        _selectedCells.add(cellId);
      }
    });
  }

  void _handleBlockHours() {
    if (_selectedCells.isEmpty) return;
    
    // Convertir celdas seleccionadas a formato de schedule
    final scheduleItems = <String>[];
    for (final cellId in _selectedCells) {
      final parts = cellId.split('-');
      if (parts.length >= 4) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        final time = parts[3];
        
        final date = DateTime(year, month, day);
        final dayOfWeek = date.weekday; // 1 = Monday
        final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
        final dayName = dayNames[dayOfWeek - 1];
        
        scheduleItems.add('$dayName-$time');
      }
    }
    
    if (scheduleItems.isEmpty) {
      return;
    }
    
    final booking = Booking.blocked(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      aulaId: widget.aula.id,
      aulaName: widget.aula.name,
      schedule: scheduleItems,
      createdBy: 'admin@ucacue.edu.ec', // TODO: obtener del usuario logueado
      repeatWeekly: _repeatWeekly,
    );
    
    widget.onBlockCreated(booking);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(isDark, isSpanish),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildWeekNavigation(isDark, isSpanish),
                    const SizedBox(height: 16),
                    _buildOptionsBar(isDark, isSpanish),
                    const SizedBox(height: 16),
                    _buildCalendarGrid(isDark, isSpanish),
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

  Widget _buildHeader(bool isDark, bool isSpanish) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSpanish ? 'Marcar Horarios No Disponibles' : 'Mark Unavailable Hours',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isSpanish 
                    ? 'Seleccione los horarios en los que el aula no estará disponible'
                    : 'Select the hours when the classroom will not be available',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              LucideIcons.x,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekNavigation(bool isDark, bool isSpanish) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavButton(
            isDark: isDark,
            icon: LucideIcons.chevronLeft,
            label: isSpanish ? 'Semana Anterior' : 'Previous Week',
            onPressed: () => setState(() => _weekOffset--),
            enabled: _weekOffset > -4, // No más de 4 semanas en el pasado
          ),
          
          Column(
            children: [
              Text(
                _monthYearText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _weekRangeText,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          
          _buildNavButton(
            isDark: isDark,
            icon: LucideIcons.chevronRight,
            label: isSpanish ? 'Semana Siguiente' : 'Next Week',
            onPressed: () => setState(() => _weekOffset++),
            enabled: _weekOffset < 26, // Máximo 6 meses adelante
            isReverse: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool enabled,
    bool isReverse = false,
  }) {
    final children = [
      if (!isReverse) Icon(icon, size: 18),
      if (!isReverse) const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 13)),
      if (isReverse) const SizedBox(width: 4),
      if (isReverse) Icon(icon, size: 18),
    ];

    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: enabled 
            ? (isDark ? AppColors.darkText : AppColors.lightText)
            : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _buildOptionsBar(bool isDark, bool isSpanish) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_selectedCells.length} ${isSpanish ? 'horario(s) seleccionado(s)' : 'schedule(s) selected'}',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
          ),
        ),
        
        // Repeat weekly toggle
        Row(
          children: [
            Text(
              isSpanish ? 'Repetir Semanalmente' : 'Repeat Weekly',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: _repeatWeekly,
              onChanged: (v) => setState(() => _repeatWeekly = v),
              activeTrackColor: AppColors.ucRed.withValues(alpha: 0.5),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.ucRed;
                }
                return null;
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(bool isDark, bool isSpanish) {
    final dates = _weekDates;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                // Hora column header
                Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  child: Text(
                    isSpanish ? 'Hora' : 'Hour',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                ),
                // Day headers
                ...List.generate(5, (i) => Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text(
                          _days[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${dates[i].day}/${dates[i].month}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
          
          // Grid
          ...List.generate(_hours.length, (hourIndex) {
            return Row(
              children: [
                // Hour label
                Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 0.5,
                      ),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _hours[hourIndex],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                ),
                // Cells
                ...List.generate(5, (dayIndex) {
                  final status = _getCellStatus(dayIndex, _hours[hourIndex]);
                  final isPast = _isPastDate(_weekDates[dayIndex]);
                  
                  return Expanded(
                    child: _buildCell(
                      isDark: isDark,
                      status: status,
                      isPast: isPast,
                      onTap: () => _toggleCell(dayIndex, _hours[hourIndex]),
                    ),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCell({
    required bool isDark,
    required CalendarCellStatus status,
    required bool isPast,
    required VoidCallback onTap,
  }) {
    Color bgColor;
    Widget? content;
    bool canTap = true;
    
    if (isPast) {
      bgColor = isDark 
          ? Colors.grey.shade900.withValues(alpha: 0.3)
          : Colors.grey.shade200.withValues(alpha: 0.5);
      canTap = false;
    } else {
      switch (status) {
        case CalendarCellStatus.selected:
          bgColor = AppColors.ucRed.withValues(alpha: isDark ? 0.3 : 0.2);
          content = Icon(
            LucideIcons.check,
            size: 18,
            color: AppColors.ucRed,
          );
          break;
        case CalendarCellStatus.occupied:
          bgColor = isDark 
              ? Colors.red.shade900.withValues(alpha: 0.3)
              : Colors.red.shade100;
          content = Text(
            'Ocupado',
            style: TextStyle(
              fontSize: 9,
              color: isDark ? Colors.red.shade200 : Colors.red.shade700,
            ),
          );
          canTap = false;
          break;
        case CalendarCellStatus.lunch:
          bgColor = isDark 
              ? Colors.orange.shade900.withValues(alpha: 0.3)
              : Colors.orange.shade100;
          content = Icon(
            LucideIcons.coffee,
            size: 14,
            color: isDark ? Colors.orange.shade200 : Colors.orange.shade700,
          );
          canTap = false;
          break;
        case CalendarCellStatus.blocked:
          bgColor = isDark 
              ? Colors.grey.shade800
              : Colors.grey.shade300;
          content = Icon(
            LucideIcons.lock,
            size: 14,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          );
          break;
        default:
          bgColor = isDark 
              ? AppColors.darkCard
              : Colors.white;
      }
    }
    
    return GestureDetector(
      onTap: canTap ? onTap : null,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: status == CalendarCellStatus.selected 
                ? AppColors.ucRed
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: status == CalendarCellStatus.selected ? 2 : 0.5,
          ),
        ),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }

  Widget _buildActions(bool isDark, bool isSpanish) {
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
            child: AppSecondaryButton(
              text: isSpanish ? 'Cancelar' : 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              text: isSpanish 
                  ? 'Marcar ${_selectedCells.length} Horario(s)' 
                  : 'Mark ${_selectedCells.length} Schedule(s)',
              icon: LucideIcons.lock,
              onPressed: _selectedCells.isEmpty ? null : _handleBlockHours,
            ),
          ),
        ],
      ),
    );
  }
}
