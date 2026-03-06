import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../../features/scheduling/widgets/weekly_calendar.dart';

/// Modelo para representar un horario seleccionado
class ScheduleSlot {
  final DateTime date;
  final int hour;
  final String? group;
  
  const ScheduleSlot({
    required this.date,
    required this.hour,
    this.group,
  });
  
  String get dayName {
    const daysEs = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return daysEs[date.weekday - 1];
  }
  
  String get dayNameEn {
    const daysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return daysEn[date.weekday - 1];
  }
  
  String get dateFormatted {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String get timeRange => '${hour.toString().padLeft(2, '0')}:00 - ${(hour + 1).toString().padLeft(2, '0')}:00';
}

/// Información completa del agendamiento para mostrar en el resumen
class BookingSummary {
  final String teacherName;
  final String aulaName;
  final String subject;
  final String career;
  final String parallel;
  final String cycle;
  final int numStudents;
  final List<ScheduleSlot> slots;
  final bool needsGroups;
  
  const BookingSummary({
    required this.teacherName,
    required this.aulaName,
    required this.subject,
    required this.career,
    required this.parallel,
    required this.cycle,
    required this.numStudents,
    required this.slots,
    this.needsGroups = false,
  });
  
  /// Agrupa los slots por grupo dinámicamente (G1, G2, G3, etc.)
  Map<String, List<ScheduleSlot>> get slotsByGroup {
    final groups = <String, List<ScheduleSlot>>{};
    for (final slot in slots) {
      final groupKey = slot.group ?? 'G1';
      groups.putIfAbsent(groupKey, () => []).add(slot);
    }
    // Ordenar por nombre de grupo (G1, G2, G3...)
    final sortedKeys = groups.keys.toList()..sort();
    return {for (final key in sortedKeys) key: groups[key]!};
  }
  
  /// Extrae el número del grupo (G1 -> 1, G2 -> 2, etc.)
  static int getGroupNumber(String groupKey) {
    final match = RegExp(r'G(\d+)').firstMatch(groupKey);
    return match != null ? int.parse(match.group(1)!) : 1;
  }
}

/// Modal de confirmación con tabla resumen de horarios
class BookingSummaryModal extends StatelessWidget {
  final BookingSummary summary;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  
  const BookingSummaryModal({
    super.key,
    required this.summary,
    this.onConfirm,
    this.onCancel,
  });
  
  /// Muestra el modal y retorna true si se confirma
  static Future<bool> show({
    required BuildContext context,
    required BookingSummary summary,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BookingSummaryModal(summary: summary),
    );
    return result ?? false;
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(isDark, isSpanish),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking Info
                    _buildInfoSection(isDark, isSpanish),
                    
                    const SizedBox(height: 24),
                    
                    // Schedule Table
                    _buildScheduleTable(isDark, isSpanish),
                  ],
                ),
              ),
            ),
            
            // Actions
            _buildActions(context, isDark, isSpanish),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(bool isDark, bool isSpanish) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(19),
          topRight: Radius.circular(19),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.calendarCheck,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSpanish ? 'Confirmar Reserva' : 'Confirm Booking',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  isSpanish 
                      ? 'Revise los detalles antes de confirmar'
                      : 'Review details before confirming',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoSection(bool isDark, bool isSpanish) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkBackground 
            : AppColors.lightInputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            isDark,
            icon: LucideIcons.user,
            label: isSpanish ? 'Docente' : 'Teacher',
            value: summary.teacherName,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            isDark,
            icon: LucideIcons.building,
            label: isSpanish ? 'Aula' : 'Classroom',
            value: summary.aulaName,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            isDark,
            icon: LucideIcons.bookOpen,
            label: isSpanish ? 'Materia' : 'Subject',
            value: summary.subject,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            isDark,
            icon: LucideIcons.graduationCap,
            label: isSpanish ? 'Carrera' : 'Career',
            value: summary.career,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  isDark,
                  icon: LucideIcons.hash,
                  label: isSpanish ? 'Paralelo' : 'Parallel',
                  value: summary.parallel,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoRow(
                  isDark,
                  icon: LucideIcons.refreshCw,
                  label: isSpanish ? 'Ciclo' : 'Cycle',
                  value: summary.cycle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoRow(
                  isDark,
                  icon: LucideIcons.users,
                  label: isSpanish ? 'Estudiantes' : 'Students',
                  value: '${summary.numStudents}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildScheduleTable(bool isDark, bool isSpanish) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.clock,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              isSpanish ? 'Horarios Seleccionados' : 'Selected Schedules',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${summary.slots.length} ${isSpanish ? 'horarios' : 'slots'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (summary.needsGroups) ...[
          // Renderizar dinámicamente todos los grupos (G1, G2, G3, etc.)
          for (final entry in summary.slotsByGroup.entries) ...[
            if (entry.value.isNotEmpty) ...[
              _buildGroupHeader(
                isDark, 
                'Grupo ${BookingSummary.getGroupNumber(entry.key)}',
                WeeklyCalendar.getGroupColor(BookingSummary.getGroupNumber(entry.key)),
                entry.value.length,
              ),
              const SizedBox(height: 8),
              _buildSlotsTable(isDark, isSpanish, entry.value),
              const SizedBox(height: 16),
            ],
          ],
        ] else ...[
          _buildSlotsTable(isDark, isSpanish, summary.slots),
        ],
      ],
    );
  }
  
  Widget _buildGroupHeader(bool isDark, String groupName, Color color, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            groupName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const Spacer(),
          Text(
            '$count horarios',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSlotsTable(bool isDark, bool isSpanish, List<ScheduleSlot> slots) {
    // Ordenar por fecha y hora
    final sortedSlots = List<ScheduleSlot>.from(slots)
      ..sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;
        return a.hour.compareTo(b.hour);
      });
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      isSpanish ? 'Día' : 'Day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      isSpanish ? 'Fecha' : 'Date',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      isSpanish ? 'Horario' : 'Time',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Rows
            ...sortedSlots.asMap().entries.map((entry) {
              final index = entry.key;
              final slot = entry.value;
              final isEven = index % 2 == 0;
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isEven 
                      ? (isDark ? AppColors.darkCard : Colors.white)
                      : (isDark ? AppColors.darkBackground.withValues(alpha: 0.5) : AppColors.lightInputBg.withValues(alpha: 0.5)),
                  border: Border(
                    bottom: index < sortedSlots.length - 1
                        ? BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          )
                        : BorderSide.none,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        isSpanish ? slot.dayName : slot.dayNameEn,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        slot.dateFormatted,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        slot.timeRange,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
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
    );
  }
  
  Widget _buildActions(BuildContext context, bool isDark, bool isSpanish) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(false),
              icon: const Icon(LucideIcons.x, size: 18),
              label: Text(isSpanish ? 'Cancelar' : 'Cancel'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(LucideIcons.check, size: 18),
              label: Text(isSpanish ? 'Confirmar' : 'Confirm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
