import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import 'weekly_calendar.dart';

/// Vista para que el admin bloquee horarios como "No Disponible"
/// El admin NO reserva clases, solo bloquea horarios
class AdminBlockScheduleView extends StatefulWidget {
  const AdminBlockScheduleView({super.key});

  @override
  State<AdminBlockScheduleView> createState() => _AdminBlockScheduleViewState();
}

class _AdminBlockScheduleViewState extends State<AdminBlockScheduleView> {
  int? _selectedAula;
  final Set<String> _selectedCells = {};
  bool _repeatWeekly = false;
  int _repeatWeeks = 4;
  
  // Mock aulas
  final List<Map<String, dynamic>> _aulas = [
    {
      'id': '1',
      'name': 'Aula VR 1',
      'location': 'Edificio A - Piso 2',
      'capacity': 10,
      'schedule': '07:00 - 16:00',
    },
    {
      'id': '2',
      'name': 'Aula VR 2',
      'location': 'Edificio B - Piso 1',
      'capacity': 15,
      'schedule': '08:00 - 17:00',
    },
    {
      'id': '3',
      'name': 'Aula VR Principal',
      'location': 'Edificio Central',
      'capacity': 25,
      'schedule': '07:00 - 18:00',
    },
  ];

  // Horarios bloqueados POR AULA - Map<aulaIndex, Map<cellId, BookingInfo>>
  final Map<int, Map<String, BookingInfo>> _blockedSlotsByAula = {
    0: {
      '2026-01-27-12': BookingInfo(
        id: 'lunch-1',
        teacherName: 'Sistema',
        subject: 'Almuerzo',
        type: BookingType.lunch,
      ),
      '2026-01-28-12': BookingInfo(
        id: 'lunch-2',
        teacherName: 'Sistema',
        subject: 'Almuerzo',
        type: BookingType.lunch,
      ),
    },
    1: {
      '2026-01-27-12': BookingInfo(
        id: 'lunch-3',
        teacherName: 'Sistema',
        subject: 'Almuerzo',
        type: BookingType.lunch,
      ),
    },
    2: {
      '2026-01-27-12': BookingInfo(
        id: 'lunch-4',
        teacherName: 'Sistema',
        subject: 'Almuerzo',
        type: BookingType.lunch,
      ),
    },
  };
  
  /// Obtiene los bloqueos del aula seleccionada
  Map<String, BookingInfo> get _currentAulaBlockedSlots {
    if (_selectedAula == null) return {};
    return _blockedSlotsByAula.putIfAbsent(_selectedAula!, () => {});
  }
  
  /// Desplaza un cellId por N semanas
  String _offsetCellByWeeks(String cellId, int weeks) {
    // cellId formato: '2026-01-27-12' (YYYY-MM-DD-HH)
    final parts = cellId.split('-');
    if (parts.length < 4) return cellId;
    
    final date = DateTime.parse('${parts[0]}-${parts[1]}-${parts[2]}');
    final newDate = date.add(Duration(days: 7 * weeks));
    final hour = parts[3];
    
    return '${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}-$hour';
  }

  void _handleSelectAula(int index) {
    setState(() {
      _selectedAula = index;
      _selectedCells.clear(); // Limpiar selección al cambiar de aula
    });
  }

  void _handleBlockSchedules() async {
    if (_selectedAula == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un aula primero')),
      );
      return;
    }

    if (_selectedCells.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione al menos un horario')),
      );
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aula = _aulas[_selectedAula!];
    final totalSlots = _repeatWeekly 
        ? _selectedCells.length * _repeatWeeks
        : _selectedCells.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.lock, color: AppColors.warning, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Confirmar Bloqueo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Bloquear $totalSlots horario(s) en ${aula['name']}?',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            if (_repeatWeekly) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.repeat, size: 16, color: AppColors.info),
                        const SizedBox(width: 8),
                        Text(
                          'Repetición semanal activada',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedCells.length} horario(s) × $_repeatWeeks semanas = $totalSlots bloqueos totales',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Los docentes no podrán reservar estos horarios.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        // Obtener o crear el mapa de bloqueos para el aula actual
        final aulaBlocks = _blockedSlotsByAula.putIfAbsent(_selectedAula!, () => {});
        
        // Determinar cuántas semanas bloquear
        final weeksToBlock = _repeatWeekly ? _repeatWeeks : 1;
        
        // Agregar los bloqueos para cada semana
        for (int week = 0; week < weeksToBlock; week++) {
          for (final cellId in _selectedCells) {
            final newCellId = week == 0 ? cellId : _offsetCellByWeeks(cellId, week);
            aulaBlocks[newCellId] = BookingInfo(
              id: 'block-${DateTime.now().millisecondsSinceEpoch}-$newCellId',
              teacherName: 'Administrador',
              subject: 'No Disponible',
              type: BookingType.blocked,
            );
          }
        }
        
        _selectedCells.clear();
      });

      if (mounted) {
        final message = _repeatWeekly 
            ? 'Se bloquearon ${_selectedCells.length * _repeatWeeks} horarios ($_repeatWeeks semanas)'
            : 'Horarios bloqueados exitosamente';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(LucideIcons.circleCheck, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(message),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
  
  void _handleUnblockSlot(String cellId) async {
    if (_selectedAula == null) return;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '¿Desbloquear horario?',
          style: TextStyle(
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        content: Text(
          'Este horario volverá a estar disponible para que los docentes puedan reservarlo.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Desbloquear'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      setState(() {
        _blockedSlotsByAula[_selectedAula!]?.remove(cellId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Horario desbloqueado'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
  
  void _showUnblockDialog(bool isDark, bool isSpanish) async {
    if (_selectedAula == null || _currentAulaBlockedSlots.isEmpty) return;
    
    final slotsToUnblock = <String>{};
    
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final blockedEntries = _currentAulaBlockedSlots.entries.toList();
          
          return AlertDialog(
            backgroundColor: isDark ? AppColors.darkCard : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(LucideIcons.lockOpen, color: AppColors.warning, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  isSpanish ? 'Desbloquear Horarios' : 'Unblock Schedules',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 400,
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSpanish 
                        ? 'Selecciona los horarios que deseas desbloquear:'
                        : 'Select the schedules you want to unblock:',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setDialogState(() {
                            slotsToUnblock.addAll(blockedEntries.map((e) => e.key));
                          });
                        },
                        child: Text(isSpanish ? 'Seleccionar todos' : 'Select all'),
                      ),
                      TextButton(
                        onPressed: () {
                          setDialogState(() {
                            slotsToUnblock.clear();
                          });
                        },
                        child: Text(isSpanish ? 'Limpiar' : 'Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: blockedEntries.length,
                      itemBuilder: (ctx, index) {
                        final entry = blockedEntries[index];
                        final cellId = entry.key;
                        final bookingInfo = entry.value;
                        final isSelected = slotsToUnblock.contains(cellId);
                        
                        // Parsear cellId (ej: "Lun-08:00")
                        final parts = cellId.split('-');
                        final day = parts[0];
                        final hour = parts.length > 1 ? parts[1] : '';
                        
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) {
                            setDialogState(() {
                              if (value == true) {
                                slotsToUnblock.add(cellId);
                              } else {
                                slotsToUnblock.remove(cellId);
                              }
                            });
                          },
                          title: Text(
                            '$day - $hour',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          ),
                          subtitle: Text(
                            bookingInfo.subject.isNotEmpty ? bookingInfo.subject : (isSpanish ? 'Bloqueado' : 'Blocked'),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                            ),
                          ),
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(isSpanish ? 'Cancelar' : 'Cancel'),
              ),
              ElevatedButton(
                onPressed: slotsToUnblock.isEmpty 
                    ? null 
                    : () {
                        Navigator.pop(ctx);
                        _unblockSelectedSlots(slotsToUnblock, isSpanish);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  '${isSpanish ? "Desbloquear" : "Unblock"} (${slotsToUnblock.length})',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _unblockSelectedSlots(Set<String> cellIds, bool isSpanish) {
    if (_selectedAula == null) return;
    
    setState(() {
      for (final cellId in cellIds) {
        _blockedSlotsByAula[_selectedAula!]?.remove(cellId);
      }
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSpanish 
                ? '${cellIds.length} horarios desbloqueados'
                : '${cellIds.length} schedules unblocked',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con instrucciones
          AppCard(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.lock, color: AppColors.warning, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSpanish ? 'Bloquear Horarios' : 'Block Schedules',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSpanish 
                            ? 'Marca horarios como "No Disponible" para que los docentes no puedan reservarlos. Cada aula tiene sus propios bloqueos.'
                            : 'Mark schedules as "Not Available" so teachers cannot book them. Each classroom has its own blocks.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Selector de aula
          AppCard(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isSpanish ? 'Seleccionar Aula' : 'Select Classroom',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    if (_selectedAula != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.circleCheck, size: 14, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              '${_currentAulaBlockedSlots.length} ${isSpanish ? "bloqueados" : "blocked"}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botón para desbloquear horarios
                      if (_currentAulaBlockedSlots.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _showUnblockDialog(isDark, isSpanish),
                          icon: Icon(LucideIcons.lockOpen, size: 16, color: AppColors.warning),
                          label: Text(
                            isSpanish ? 'Desbloquear' : 'Unblock',
                            style: TextStyle(color: AppColors.warning),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.warning),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _aulas.asMap().entries.map((entry) {
                    final index = entry.key;
                    final aula = entry.value;
                    final isSelected = _selectedAula == index;
                    final blockedCount = (_blockedSlotsByAula[index]?.length ?? 0);

                    return GestureDetector(
                      onTap: () => _handleSelectAula(index),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 14),
                              ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      aula['name'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.darkText : AppColors.lightText,
                                      ),
                                    ),
                                    if (blockedCount > 0) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.warning.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '$blockedCount',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.warning,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  aula['location'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Calendario para seleccionar horarios a bloquear
          if (_selectedAula != null) ...[
            AppCard(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isSpanish ? 'Seleccionar Horarios a Bloquear' : 'Select Schedules to Block',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                      if (_selectedCells.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_selectedCells.length} ${isSpanish ? 'seleccionados' : 'selected'}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSpanish 
                        ? 'Haz clic en las celdas ocupadas (naranjas) para desbloquearlas.'
                        : 'Click on occupied cells (orange) to unblock them.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Calendario
                  SizedBox(
                    height: 500,
                    child: WeeklyCalendar(
                      selectedCells: _selectedCells,
                      onCellToggle: (cellId) {
                        // Si la celda está bloqueada, preguntar si desea desbloquear
                        if (_currentAulaBlockedSlots.containsKey(cellId)) {
                          _handleUnblockSlot(cellId);
                        } else {
                          setState(() {
                            if (_selectedCells.contains(cellId)) {
                              _selectedCells.remove(cellId);
                            } else {
                              _selectedCells.add(cellId);
                            }
                          });
                        }
                      },
                      occupiedCells: _currentAulaBlockedSlots.keys.toSet(),
                      bookingInfo: _currentAulaBlockedSlots,
                    ),
                  ),
                ],
              ),
            ),

            // Opciones de repetición
            AppCard(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.repeat, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSpanish ? 'Repetir Semanalmente' : 'Repeat Weekly',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkText : AppColors.lightText,
                              ),
                            ),
                            Text(
                              isSpanish 
                                  ? 'Bloquea los mismos horarios por varias semanas'
                                  : 'Block the same slots for multiple weeks',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _repeatWeekly,
                        onChanged: (value) => setState(() => _repeatWeekly = value),
                        activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                        thumbColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.primary;
                          }
                          return null;
                        }),
                      ),
                    ],
                  ),
                  if (_repeatWeekly) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            isSpanish ? 'Número de semanas:' : 'Number of weeks:',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBackground : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: _repeatWeeks > 1 
                                      ? () => setState(() => _repeatWeeks--) 
                                      : null,
                                  iconSize: 18,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    '$_repeatWeeks',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.darkText : AppColors.lightText,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: _repeatWeeks < 24 
                                      ? () => setState(() => _repeatWeeks++) 
                                      : null,
                                  iconSize: 18,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (_selectedCells.isNotEmpty)
                            Text(
                              '= ${_selectedCells.length * _repeatWeeks} ${isSpanish ? "bloqueos" : "blocks"}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.info,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Botón de bloquear
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedCells.isNotEmpty ? _handleBlockSchedules : null,
                  icon: const Icon(LucideIcons.lock),
                  label: Text(
                    _selectedCells.isEmpty 
                        ? (isSpanish ? 'Seleccione horarios para bloquear' : 'Select schedules to block')
                        : (isSpanish 
                            ? 'Bloquear ${_repeatWeekly ? "${_selectedCells.length * _repeatWeeks}" : "${_selectedCells.length}"} Horario(s)'
                            : 'Block ${_repeatWeekly ? "${_selectedCells.length * _repeatWeeks}" : "${_selectedCells.length}"} Schedule(s)'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCells.isEmpty ? Colors.grey : AppColors.warning,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
