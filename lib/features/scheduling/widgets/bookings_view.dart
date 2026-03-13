import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';
import '../../../core/services/services.dart';

/// Vista de agendas/reservas
class BookingsView extends StatefulWidget {
  final bool isAdmin;
  
  const BookingsView({super.key, required this.isAdmin});

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> {
  // Service
  late final BookingService _bookingService;
  
  // Loading state
  bool _isLoading = true;
  String? _errorMessage;
  
  // Filtro de estado
  String _statusFilter = 'all'; // 'all', 'active', 'cancelled'
  
  // Datos cargados desde API (o fallback)
  List<Booking> _bookings = [];
  
  // Datos de fallback si la API no responde
  static final List<Booking> _defaultBookings = [
    Booking(
      id: '1',
      teacherId: '1',
      teacherName: 'Juan Pérez',
      aulaId: '1',
      aulaName: 'Aula VR 1',
      subject: 'PROGRAMACIÓN',
      career: 'SISTEMAS',
      parallel: 'A',
      cycle: '3',
      group: 'Grupo único',
      numStudents: 8,
      schedule: ['Lun-08:00', 'Mié-08:00'],
      date: DateTime.now(),
      startHour: 8,
      endHour: 10,
      status: BookingStatus.active,
      aulaTechnicianName: 'Carlos Mendoza',
      aulaTechnicianEmail: 'cmendoza@ucacue.edu.ec',
      aulaTechnicianPhone: '0998765432',
      aulaLatitude: -2.9001285,
      aulaLongitude: -79.0058965,
    ),
    Booking(
      id: '2',
      teacherId: '2',
      teacherName: 'María García',
      aulaId: '2',
      aulaName: 'Aula VR 2',
      subject: 'ANATOMÍA',
      career: 'MEDICINA',
      parallel: 'B',
      cycle: '2',
      group: 'Grupos 1 y 2',
      numStudents: 20,
      aulaTechnicianName: 'Luis Paredes',
      aulaTechnicianEmail: 'lparedes@ucacue.edu.ec',
      aulaTechnicianPhone: '0991234567',
      aulaLatitude: -2.8997123,
      aulaLongitude: -79.0055432,
      schedule: ['Mar-09:00', 'Jue-09:00'],
      date: DateTime.now(),
      startHour: 9,
      endHour: 11,
      status: BookingStatus.active,
    ),
    Booking(
      id: '3',
      teacherId: '3',
      teacherName: 'Carlos López',
      aulaId: '1',
      aulaName: 'Aula VR 1',
      subject: 'ARQUITECTURA 3D',
      career: 'ARQUITECTURA',
      parallel: 'A',
      cycle: '5',
      group: 'Grupo único',
      numStudents: 12,
      schedule: ['Vie-10:00', 'Vie-11:00'],
      date: DateTime.now().subtract(const Duration(days: 2)),
      startHour: 10,
      endHour: 12,
      status: BookingStatus.cancelled,
      cancellationReason: 'Mantenimiento programado de equipos VR',
      cancelledBy: 'Admin Sistema',
      cancelledAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final Set<String> _selectedBookings = {};
  
  @override
  void initState() {
    super.initState();
    _bookingService = BookingService();
    _loadBookings();
  }
  
  @override
  void dispose() {
    _bookingService.dispose();
    super.dispose();
  }
  
  Future<void> _loadBookings() async {
    try {
      final response = await _bookingService.getBookings();
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response.isSuccess && response.data != null && response.data!.isNotEmpty) {
            _bookings = response.data!;
          } else {
            _bookings = List.from(_defaultBookings);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
          _bookings = List.from(_defaultBookings);
        });
      }
    }
  }
  
  Future<void> _refreshBookings() async {
    setState(() => _isLoading = true);
    await _loadBookings();
  }

  List<Booking> get _filteredBookings {
    if (_statusFilter == 'all') return _bookings;
    if (_statusFilter == 'active') {
      return _bookings.where((b) => b.status == BookingStatus.active).toList();
    }
    if (_statusFilter == 'cancelled') {
      return _bookings.where((b) => b.status == BookingStatus.cancelled).toList();
    }
    if (_statusFilter == 'completed') {
      return _bookings.where((b) => b.status == BookingStatus.completed).toList();
    }
    return _bookings;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;
    
    // Mostrar loading mientras se cargan los datos
    if (_isLoading) {
      return const AppCard(
        padding: EdgeInsets.all(48),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.ucRed),
              SizedBox(height: 16),
              Text('Cargando reservas...'),
            ],
          ),
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isAdmin 
                    ? (isSpanish ? 'Todas las Agendas' : 'All Bookings')
                    : (isSpanish ? 'Mis Agendas' : 'My Bookings'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              if (widget.isAdmin && _selectedBookings.isNotEmpty)
                AppButton(
                  text: isSpanish 
                      ? 'Cancelar Seleccionadas (${_selectedBookings.length})'
                      : 'Cancel Selected (${_selectedBookings.length})',
                  icon: Icons.block,
                  backgroundColor: AppColors.error,
                  onPressed: _handleCancelSelected,
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Filtros de estado
          _buildStatusFilter(isDark, isSpanish),
          
          const SizedBox(height: 24),
          
          // Stats
          _buildStats(isDark, isSpanish),
          
          const SizedBox(height: 24),
          
          // Bookings list
          if (_filteredBookings.isEmpty)
            _buildEmptyState(isDark, isSpanish)
          else
            ..._filteredBookings.map((booking) => _buildBookingCard(booking, isDark, isSpanish)),
        ],
      ),
    );
  }
  
  Widget _buildStatusFilter(bool isDark, bool isSpanish) {
    return Row(
      children: [
        _buildFilterChip(
          label: isSpanish ? 'Todas' : 'All',
          value: 'all',
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          label: isSpanish ? 'Activas' : 'Active',
          value: 'active',
          isDark: isDark,
          color: AppColors.success,
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          label: isSpanish ? 'Finalizadas' : 'Completed',
          value: 'completed',
          isDark: isDark,
          color: AppColors.info,
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          label: isSpanish ? 'Canceladas' : 'Cancelled',
          value: 'cancelled',
          isDark: isDark,
          color: AppColors.error,
        ),
      ],
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool isDark,
    Color? color,
  }) {
    final isSelected = _statusFilter == value;
    
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? (color ?? AppColors.primary).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? (color ?? AppColors.primary)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected 
                ? (color ?? AppColors.primary)
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStats(bool isDark, bool isSpanish) {
    final activeCount = _bookings.where((b) => b.status == BookingStatus.active).length;
    final completedCount = _bookings.where((b) => b.status == BookingStatus.completed).length;
    final cancelledCount = _bookings.where((b) => b.status == BookingStatus.cancelled).length;
    
    return Row(
      children: [
        _buildStatChip(
          icon: LucideIcons.calendarCheck,
          label: isSpanish ? 'Activas' : 'Active',
          count: activeCount,
          color: AppColors.success,
          isDark: isDark,
        ),
        const SizedBox(width: 16),
        _buildStatChip(
          icon: LucideIcons.circleCheck,
          label: isSpanish ? 'Finalizadas' : 'Completed',
          count: completedCount,
          color: AppColors.info,
          isDark: isDark,
        ),
        const SizedBox(width: 16),
        _buildStatChip(
          icon: LucideIcons.calendarX,
          label: isSpanish ? 'Canceladas' : 'Cancelled',
          count: cancelledCount,
          color: AppColors.error,
          isDark: isDark,
        ),
      ],
    );
  }
  
  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isSpanish) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: isDark 
                  ? AppColors.darkTextMuted 
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              isSpanish 
                  ? 'No hay agendas con este filtro'
                  : 'No bookings with this filter',
              style: TextStyle(
                fontSize: 16,
                color: isDark 
                    ? AppColors.darkTextMuted 
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, bool isDark, bool isSpanish) {
    final isSelected = _selectedBookings.contains(booking.id);
    final isCancelled = booking.isCancelled;
    final isCompleted = booking.isCompleted;
    final isInactive = isCancelled || isCompleted; // No editable
    
    // Determinar color según estado
    Color? bgColor;
    Color? borderColor;
    if (isCancelled) {
      bgColor = isDark 
          ? AppColors.error.withValues(alpha: 0.05)
          : AppColors.error.withValues(alpha: 0.03);
      borderColor = AppColors.error.withValues(alpha: 0.3);
    } else if (isCompleted) {
      bgColor = isDark 
          ? AppColors.info.withValues(alpha: 0.05)
          : AppColors.info.withValues(alpha: 0.03);
      borderColor = AppColors.info.withValues(alpha: 0.3);
    } else {
      bgColor = isDark ? AppColors.darkBackground : AppColors.lightInputBg;
      borderColor = isSelected 
          ? AppColors.ucRed 
          : (isDark ? AppColors.darkBorder : AppColors.lightBorder);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox (solo si está activa y es admin)
              if (widget.isAdmin && !isInactive)
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedBookings.add(booking.id);
                      } else {
                        _selectedBookings.remove(booking.id);
                      }
                    });
                  },
                )
              else
                const SizedBox(width: 8),
              
              const SizedBox(width: 8),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge + Subject
                    Row(
                      children: [
                        if (isCancelled)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isSpanish ? 'CANCELADA' : 'CANCELLED',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            booking.subject,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isCancelled
                                  ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary)
                                  : (isDark ? AppColors.darkText : AppColors.lightText),
                              decoration: isCancelled ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${booking.teacherName} • ${booking.career} • '
                      '${isSpanish ? "Ciclo" : "Cycle"} ${booking.cycle} • '
                      '${isSpanish ? "Paralelo" : "Parallel"} ${booking.parallel}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark 
                            ? AppColors.darkTextMuted 
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${booking.aulaName} • ${booking.numStudents} '
                      '${isSpanish ? "estudiantes" : "students"} • ${booking.group}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark 
                            ? AppColors.darkTextMuted 
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    // Información del técnico asignado (solo para docentes)
                    if (!widget.isAdmin && booking.aulaTechnicianName != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.userCog,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isSpanish ? 'Técnico del Aula' : 'Classroom Technician',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Nombre del técnico
                            Text(
                              booking.aulaTechnicianName!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.darkText : AppColors.lightText,
                              ),
                            ),
                            // Email del técnico
                            if (booking.aulaTechnicianEmail != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.mail,
                                    size: 12,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      booking.aulaTechnicianEmail!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            // Teléfono del técnico
                            if (booking.aulaTechnicianPhone != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.phone,
                                    size: 12,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    booking.aulaTechnicianPhone!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    // Botón para ver ubicación del aula (solo para docentes)
                    if (!widget.isAdmin && booking.hasLocation) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _showAulaLocation(booking, isDark, isSpanish),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? AppColors.info.withValues(alpha: 0.1)
                                : AppColors.info.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.info.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.mapPin,
                                size: 14,
                                color: AppColors.info,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isSpanish ? 'Ver ubicación del aula' : 'View classroom location',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.info,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: booking.schedule.map((slot) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? AppColors.darkCardSecondary 
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDark 
                                  ? AppColors.darkBorder 
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark 
                                  ? AppColors.darkText 
                                  : AppColors.lightText,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              
              // Actions
              if (!isCancelled)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Para completadas: solo icono de info (no editable)
                    if (isCompleted)
                      IconButton(
                        icon: Icon(LucideIcons.info, color: AppColors.info),
                        tooltip: isSpanish ? 'Ver detalles' : 'View details',
                        onPressed: () => _showBookingDetails(booking, isDark, isSpanish),
                      )
                    else ...[
                      IconButton(
                        icon: const Icon(LucideIcons.pencil),
                        tooltip: isSpanish ? 'Editar' : 'Edit',
                        onPressed: () => _handleEditBooking(booking),
                      ),
                      if (widget.isAdmin)
                        IconButton(
                          icon: Icon(LucideIcons.ban, color: AppColors.error),
                          tooltip: isSpanish ? 'Cancelar' : 'Cancel',
                          onPressed: () => _handleCancelBooking(booking),
                        ),
                    ],
                  ],
                ),
            ],
          ),
          
          // Mostrar información de cancelación si está cancelada
          if (isCancelled && booking.cancellationReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.circleAlert,
                        size: 16,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isSpanish ? 'Motivo de cancelación:' : 'Cancellation reason:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.cancellationReason!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  if (booking.cancelledBy != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${isSpanish ? "Cancelado por" : "Cancelled by"}: ${booking.cancelledBy}',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: isDark 
                            ? AppColors.darkTextMuted 
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showBookingDetails(Booking booking, bool isDark, bool isSpanish) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.info, color: AppColors.info, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              isSpanish ? 'Clase Finalizada' : 'Completed Class',
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(isSpanish ? 'Materia' : 'Subject', booking.subject, isDark),
              _buildDetailRow(isSpanish ? 'Carrera' : 'Career', booking.career, isDark),
              _buildDetailRow(isSpanish ? 'Aula' : 'Classroom', booking.aulaName, isDark),
              _buildDetailRow(isSpanish ? 'Grupo' : 'Group', booking.group, isDark),
              _buildDetailRow(
                isSpanish ? 'Horarios' : 'Schedule', 
                booking.schedule.join(', '), 
                isDark,
              ),
              if (booking.aulaTechnicianName != null)
                _buildDetailRow(
                  isSpanish ? 'Técnico del Aula' : 'Classroom Technician', 
                  booking.aulaTechnicianName!, 
                  isDark,
                ),
              if (booking.aulaTechnicianEmail != null)
                _buildDetailRow(
                  isSpanish ? 'Email Técnico' : 'Technician Email', 
                  booking.aulaTechnicianEmail!, 
                  isDark,
                ),
              if (booking.aulaTechnicianPhone != null)
                _buildDetailRow(
                  isSpanish ? 'Teléfono Técnico' : 'Technician Phone', 
                  booking.aulaTechnicianPhone!, 
                  isDark,
                ),
              if (booking.notes != null && booking.notes!.isNotEmpty)
                _buildDetailRow(isSpanish ? 'Notas' : 'Notes', booking.notes!, isDark),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isSpanish ? 'Cerrar' : 'Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Muestra la ubicación del aula en un mapa
  void _showAulaLocation(Booking booking, bool isDark, bool isSpanish) {
    if (!booking.hasLocation) return;
    
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          height: 450,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.mapPin, color: AppColors.info, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSpanish ? 'Ubicación del Aula' : 'Classroom Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                        Text(
                          booking.aulaName,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Mapa con la ubicación
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MapPreviewWidget(
                    latitude: booking.aulaLatitude!,
                    longitude: booking.aulaLongitude!,
                    height: double.infinity,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Coordenadas
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.navigation, size: 16, color: AppColors.info),
                    const SizedBox(width: 8),
                    Text(
                      '${booking.aulaLatitude!.toStringAsFixed(6)}, ${booking.aulaLongitude!.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Botón cerrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isSpanish ? 'Cerrar' : 'Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleEditBooking(Booking booking) async {
    // Lista de docentes disponibles (cargar desde servicio si es posible)
    final availableTeachers = [
      {'id': '1', 'firstName': 'Juan', 'lastName': 'Pérez'},
      {'id': '2', 'firstName': 'María', 'lastName': 'García'},
      {'id': '3', 'firstName': 'Carlos', 'lastName': 'López'},
    ];

    // Mostrar modal de edición
    final updatedBooking = await EditBookingModal.show(
      context: context,
      booking: booking,
      availableTeachers: availableTeachers,
      aulaCapacity: 10,
    );

    // Si se guardaron cambios, actualizar en el backend
    if (updatedBooking != null && mounted) {
      final response = await _bookingService.updateBooking(
        id: booking.id,
        subject: updatedBooking.subject,
        career: updatedBooking.career,
        parallel: updatedBooking.parallel,
        cycle: updatedBooking.cycle,
        numStudents: updatedBooking.numStudents,
      );
      
      if (mounted) {
        if (response.isSuccess) {
          // Recargar desde el servidor
          await _refreshBookings();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<LocaleProvider>().isSpanish 
                    ? 'Reserva actualizada exitosamente'
                    : 'Booking updated successfully',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          // Fallback: actualizar localmente
          setState(() {
            final index = _bookings.indexWhere((b) => b.id == booking.id);
            if (index != -1) {
              _bookings[index] = updatedBooking;
            }
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<LocaleProvider>().isSpanish 
                    ? 'Reserva actualizada (modo offline)'
                    : 'Booking updated (offline mode)',
              ),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    }
  }

  void _handleCancelBooking(Booking booking) async {
    final cancelledBooking = await CancelBookingModal.show(
      context: context,
      booking: booking,
      cancelledByName: 'Admin Sistema',
    );
    
    if (cancelledBooking != null && mounted) {
      // Intentar cancelar en el backend
      final response = await _bookingService.cancelBooking(
        booking.id,
        reason: cancelledBooking.cancellationReason,
      );
      
      if (mounted) {
        if (response.isSuccess) {
          // Recargar desde el servidor para tener datos actualizados
          await _refreshBookings();
          _selectedBookings.remove(booking.id);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(LucideIcons.circleCheck, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    context.read<LocaleProvider>().isSpanish 
                        ? 'Reserva cancelada exitosamente'
                        : 'Booking cancelled successfully',
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          // Si falla la API, actualizar localmente como fallback
          setState(() {
            final index = _bookings.indexWhere((b) => b.id == booking.id);
            if (index != -1) {
              _bookings[index] = cancelledBooking;
            }
            _selectedBookings.remove(booking.id);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<LocaleProvider>().isSpanish 
                    ? 'Reserva cancelada (modo offline)'
                    : 'Booking cancelled (offline mode)',
              ),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    }
  }

  void _handleCancelSelected() async {
    final count = _selectedBookings.length;
    final isSpanish = context.read<LocaleProvider>().isSpanish;
    
    final confirmed = await AppConfirmModal.show(
      context: context,
      title: isSpanish 
          ? '¿Cancelar $count agendas?'
          : 'Cancel $count bookings?',
      message: isSpanish 
          ? 'Se solicitará un motivo para cada cancelación.'
          : 'A reason will be requested for each cancellation.',
      confirmText: isSpanish ? 'Continuar' : 'Continue',
      isDanger: true,
    );
    
    if (confirmed == true && mounted) {
      // Cancelar cada booking individualmente
      for (final bookingId in _selectedBookings.toList()) {
        final booking = _bookings.firstWhere((b) => b.id == bookingId);
        if (booking.isActive) {
          final cancelledBooking = await CancelBookingModal.show(
            context: context,
            booking: booking,
            cancelledByName: 'Admin Sistema',
          );
          
          if (cancelledBooking != null && mounted) {
            // Intentar cancelar en el backend
            await _bookingService.cancelBooking(
              bookingId,
              reason: cancelledBooking.cancellationReason,
            );
          }
        }
      }
      
      // Recargar todas las reservas
      await _refreshBookings();
      setState(() => _selectedBookings.clear());
    }
  }
}
