import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/core.dart';

/// Estado de capacitación de un docente
enum TrainingStatus {
  pending,      // Solicitud enviada, pendiente de agendar
  scheduled,    // Capacitación agendada
  completed,    // Capacitado - puede agendar
  rejected,     // Rechazado
  needsRefresh, // Necesita refuerzo/actualización
  rescheduled,  // Reagendada
}

/// Modelo de solicitud de capacitación
class TrainingRequest {
  final String id;
  final String teacherId;
  final String teacherName;
  final String teacherEmail;
  final String faculty;
  final String career;
  final DateTime requestDate;
  final String? preferredDate;
  String? notes;  // Mutable para permitir agregar anotaciones
  TrainingStatus status;
  DateTime? scheduledDate;
  DateTime? completedDate;

  TrainingRequest({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.teacherEmail,
    required this.faculty,
    required this.career,
    required this.requestDate,
    this.preferredDate,
    this.notes,
    this.status = TrainingStatus.pending,
    this.scheduledDate,
    this.completedDate,
  });
}

/// Vista para administrar solicitudes de capacitación
/// Si isAdmin es true, muestra acciones de admin (agendar, aprobar, rechazar)
/// Si isAdmin es false, muestra vista de solo lectura para docentes
class TrainingRequestsView extends StatefulWidget {
  final bool isAdmin;
  
  const TrainingRequestsView({
    super.key, 
    this.isAdmin = true,
  });

  @override
  State<TrainingRequestsView> createState() => _TrainingRequestsViewState();
}

class _TrainingRequestsViewState extends State<TrainingRequestsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  // Mock de solicitudes de capacitación con más datos
  final List<TrainingRequest> _requests = [
    TrainingRequest(
      id: 'tr1',
      teacherId: 't1',
      teacherName: 'María García',
      teacherEmail: 'maria.garcia@ucacue.edu.ec',
      faculty: 'Medicina',
      career: 'Medicina General',
      requestDate: DateTime.now().subtract(const Duration(days: 3)),
      preferredDate: '2026-02-15',
      notes: 'Disponible por las tardes',
      status: TrainingStatus.pending,
    ),
    TrainingRequest(
      id: 'tr2',
      teacherId: 't2',
      teacherName: 'Carlos Mendoza',
      teacherEmail: 'carlos.mendoza@ucacue.edu.ec',
      faculty: 'Ingeniería',
      career: 'Sistemas',
      requestDate: DateTime.now().subtract(const Duration(days: 5)),
      preferredDate: '2026-02-20',
      status: TrainingStatus.scheduled,
      scheduledDate: DateTime.now().add(const Duration(days: 2)),
    ),
    TrainingRequest(
      id: 'tr3',
      teacherId: 't3',
      teacherName: 'Ana Torres',
      teacherEmail: 'ana.torres@ucacue.edu.ec',
      faculty: 'Arquitectura',
      career: 'Arquitectura',
      requestDate: DateTime.now().subtract(const Duration(days: 10)),
      status: TrainingStatus.completed,
      completedDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TrainingRequest(
      id: 'tr4',
      teacherId: 't4',
      teacherName: 'Roberto Sánchez',
      teacherEmail: 'roberto.sanchez@ucacue.edu.ec',
      faculty: 'Derecho',
      career: 'Jurisprudencia',
      requestDate: DateTime.now().subtract(const Duration(days: 1)),
      preferredDate: '2026-02-10',
      notes: 'Horarios de mañana preferiblemente',
      status: TrainingStatus.pending,
    ),
    TrainingRequest(
      id: 'tr5',
      teacherId: 't5',
      teacherName: 'Laura Pérez',
      teacherEmail: 'laura.perez@ucacue.edu.ec',
      faculty: 'Odontología',
      career: 'Odontología',
      requestDate: DateTime.now().subtract(const Duration(days: 60)),
      status: TrainingStatus.needsRefresh,
      completedDate: DateTime.now().subtract(const Duration(days: 180)),
      notes: 'Requiere actualización sobre nuevos equipos VR',
    ),
    TrainingRequest(
      id: 'tr6',
      teacherId: 't6',
      teacherName: 'Fernando López',
      teacherEmail: 'fernando.lopez@ucacue.edu.ec',
      faculty: 'Ingeniería',
      career: 'Civil',
      requestDate: DateTime.now().subtract(const Duration(days: 7)),
      status: TrainingStatus.rescheduled,
      scheduledDate: DateTime.now().add(const Duration(days: 5)),
      notes: 'Reagendado por conflicto de horario',
    ),
    TrainingRequest(
      id: 'tr7',
      teacherId: 't7',
      teacherName: 'Patricia Vega',
      teacherEmail: 'patricia.vega@ucacue.edu.ec',
      faculty: 'Psicología',
      career: 'Psicología Clínica',
      requestDate: DateTime.now().subtract(const Duration(days: 15)),
      status: TrainingStatus.completed,
      completedDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  List<TrainingRequest> get _pendingRequests =>
      _requests.where((r) => r.status == TrainingStatus.pending).toList();

  List<TrainingRequest> get _scheduledRequests =>
      _requests.where((r) => 
          r.status == TrainingStatus.scheduled ||
          r.status == TrainingStatus.rescheduled).toList();

  List<TrainingRequest> get _completedRequests =>
      _requests.where((r) => r.status == TrainingStatus.completed).toList();

  List<TrainingRequest> _filterBySearch(List<TrainingRequest> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((r) =>
        r.teacherName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        r.teacherEmail.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        r.faculty.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

    return Column(
      children: [
        // Header con búsqueda
        _buildHeader(isDark, isSpanish),
        const SizedBox(height: 16),
        
        // Tabs
        _buildTabs(isDark, isSpanish),
        
        // Content - Usar SizedBox en lugar de Expanded para evitar conflicto con SingleChildScrollView
        SizedBox(
          height: MediaQuery.of(context).size.height - 320,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRequestsList(
                _filterBySearch(_pendingRequests),
                isDark,
                isSpanish,
                emptyMessage: isSpanish 
                    ? 'No hay solicitudes pendientes'
                    : 'No pending requests',
              ),
              _buildRequestsList(
                _filterBySearch(_scheduledRequests),
                isDark,
                isSpanish,
                emptyMessage: isSpanish 
                    ? 'No hay capacitaciones agendadas'
                    : 'No scheduled trainings',
              ),
              _buildRequestsList(
                _filterBySearch(_completedRequests),
                isDark,
                isSpanish,
                emptyMessage: isSpanish 
                    ? 'No hay docentes capacitados'
                    : 'No trained teachers',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark, bool isSpanish) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              hint: isSpanish ? 'Buscar docente...' : 'Search teacher...',
              prefixIcon: LucideIcons.search,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          // Stats
          _buildStatChip(
            '${_pendingRequests.length}',
            isSpanish ? 'Pendientes' : 'Pending',
            AppColors.warning,
            isDark,
          ),
          const SizedBox(width: 8),
          _buildStatChip(
            '${_scheduledRequests.length}',
            isSpanish ? 'Agendadas' : 'Scheduled',
            AppColors.info,
            isDark,
          ),
          const SizedBox(width: 8),
          _buildStatChip(
            '${_completedRequests.length}',
            isSpanish ? 'Capacitados' : 'Trained',
            AppColors.success,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String count, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDark, bool isSpanish) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                const Icon(LucideIcons.clock, size: 16),
                const SizedBox(width: 6),
                Text(isSpanish ? 'Pendientes' : 'Pending'),
                if (_pendingRequests.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_pendingRequests.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.calendar, size: 16),
                const SizedBox(width: 6),
                Text(isSpanish ? 'Agendadas' : 'Scheduled'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.circleCheck, size: 16),
                const SizedBox(width: 6),
                Text(isSpanish ? 'Capacitados' : 'Trained'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(
    List<TrainingRequest> requests,
    bool isDark,
    bool isSpanish, {
    required String emptyMessage,
  }) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.inbox,
              size: 48,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(requests[index], isDark, isSpanish);
      },
    );
  }

  Widget _buildRequestCard(TrainingRequest request, bool isDark, bool isSpanish) {
    final statusColor = switch (request.status) {
      TrainingStatus.pending => AppColors.warning,
      TrainingStatus.scheduled => AppColors.info,
      TrainingStatus.completed => AppColors.success,
      TrainingStatus.rejected => AppColors.error,
      TrainingStatus.needsRefresh => Colors.orange,
      TrainingStatus.rescheduled => Colors.purple,
    };

    final statusText = switch (request.status) {
      TrainingStatus.pending => isSpanish ? 'Pendiente' : 'Pending',
      TrainingStatus.scheduled => isSpanish ? 'Agendada' : 'Scheduled',
      TrainingStatus.completed => isSpanish ? 'Capacitado' : 'Trained',
      TrainingStatus.rejected => isSpanish ? 'Rechazado' : 'Rejected',
      TrainingStatus.needsRefresh => isSpanish ? 'Necesita Refuerzo' : 'Needs Refresh',
      TrainingStatus.rescheduled => isSpanish ? 'Reagendada' : 'Rescheduled',
    };

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  request.teacherName.split(' ').map((n) => n[0]).take(2).join(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.teacherName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    Text(
                      request.teacherEmail,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      request.status == TrainingStatus.completed 
                          ? LucideIcons.circleCheck 
                          : (request.status == TrainingStatus.scheduled 
                              ? LucideIcons.calendar 
                              : LucideIcons.clock),
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Details
          Row(
            children: [
              _buildDetailChip(
                LucideIcons.building,
                request.faculty,
                isDark,
              ),
              const SizedBox(width: 8),
              _buildDetailChip(
                LucideIcons.graduationCap,
                request.career,
                isDark,
              ),
              const SizedBox(width: 8),
              _buildDetailChip(
                LucideIcons.calendarDays,
                _formatDate(request.requestDate, isSpanish),
                isDark,
              ),
            ],
          ),
          
          // Preferred date / Notes
          if (request.preferredDate != null || request.notes != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (request.preferredDate != null)
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendarCheck,
                          size: 14,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${isSpanish ? 'Fecha preferida' : 'Preferred date'}: ${request.preferredDate}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                      ],
                    ),
                  if (request.notes != null) ...[
                    if (request.preferredDate != null) const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          LucideIcons.messageSquare,
                          size: 14,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            request.notes!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          
          // Scheduled date
          if (request.scheduledDate != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.calendar, size: 16, color: AppColors.info),
                  const SizedBox(width: 8),
                  Text(
                    '${isSpanish ? 'Capacitación agendada para' : 'Training scheduled for'}: ${_formatDate(request.scheduledDate!, isSpanish)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Actions based on status - solo para admin
          if (widget.isAdmin) ...[
            // Pendientes: Agendar o marcar como ya capacitado
            if (request.status == TrainingStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppSecondaryButton(
                    text: isSpanish ? 'Ya está Capacitado' : 'Already Trained',
                    onPressed: () => _handleMarkAlreadyTrained(request, isSpanish),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    text: isSpanish ? 'Agendar Capacitación' : 'Schedule Training',
                    icon: LucideIcons.calendar,
                    onPressed: () => _handleSchedule(request, isDark, isSpanish),
                  ),
                ],
              ),
            ],
            
            // Agendadas: Reagendar o marcar como capacitado
            if (request.status == TrainingStatus.scheduled ||
                request.status == TrainingStatus.rescheduled) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppSecondaryButton(
                    text: isSpanish ? 'Reagendar' : 'Reschedule',
                    onPressed: () => _handleReschedule(request, isDark, isSpanish),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    text: isSpanish ? 'Marcar como Capacitado' : 'Mark as Trained',
                    icon: LucideIcons.circleCheck,
                    onPressed: () => _handleComplete(request, isSpanish),
                  ),
                ],
              ),
            ],
            
            // Capacitados: Solo visualizacion (sin acciones)
            // No se muestra ningun boton para estado completed
          ] else ...[
            // Vista de solo lectura para docentes
            if (request.status == TrainingStatus.completed) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.circleCheck, size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isSpanish 
                            ? 'Este docente está autorizado para realizar reservas en el Aula VR.'
                            : 'This teacher is authorized to make VR classroom bookings.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, bool isSpanish) {
    final months = isSpanish
        ? ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic']
        : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _handleSchedule(TrainingRequest request, bool isDark, bool isSpanish) async {
    DateTime? selectedDate;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(LucideIcons.calendar, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                isSpanish ? 'Agendar Capacitación' : 'Schedule Training',
                style: TextStyle(
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isSpanish ? 'Docente' : 'Teacher'}: ${request.teacherName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isSpanish ? 'Seleccione fecha de capacitación:' : 'Select training date:',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
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
                        Icon(
                          LucideIcons.calendar,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate != null
                              ? _formatDate(selectedDate!, isSpanish)
                              : (isSpanish ? 'Seleccionar fecha...' : 'Select date...'),
                          style: TextStyle(
                            color: selectedDate != null
                                ? (isDark ? AppColors.darkText : AppColors.lightText)
                                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                isSpanish ? 'Cancelar' : 'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: selectedDate != null ? () => Navigator.pop(ctx, true) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(isSpanish ? 'Confirmar' : 'Confirm'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && selectedDate != null && mounted) {
      setState(() {
        request.status = TrainingStatus.scheduled;
        request.scheduledDate = selectedDate;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSpanish 
                ? 'Capacitación agendada para ${request.teacherName}'
                : 'Training scheduled for ${request.teacherName}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _handleComplete(TrainingRequest request, bool isSpanish) async {
    final confirmed = await AppConfirmModal.show(
      context: context,
      title: isSpanish ? '¿Marcar como capacitado?' : 'Mark as trained?',
      message: isSpanish
          ? '¿Confirma que ${request.teacherName} ha completado la capacitación? Podrá realizar reservas en el Aula VR.'
          : 'Confirm that ${request.teacherName} has completed the training? They will be able to make reservations in the VR Lab.',
      confirmText: isSpanish ? 'Confirmar' : 'Confirm',
    );

    if (confirmed == true && mounted) {
      setState(() {
        request.status = TrainingStatus.completed;
        request.completedDate = DateTime.now();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSpanish 
                      ? '${request.teacherName} ahora puede realizar reservas'
                      : '${request.teacherName} can now make reservations',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
  
  /// Marca a un docente como ya capacitado (ya uso los equipos antes)
  void _handleMarkAlreadyTrained(TrainingRequest request, bool isSpanish) async {
    final confirmed = await AppConfirmModal.show(
      context: context,
      title: isSpanish ? '¿Ya está capacitado?' : 'Already trained?',
      message: isSpanish
          ? '¿Confirma que ${request.teacherName} ya ha usado los equipos VR anteriormente y no necesita capacitación?'
          : 'Confirm that ${request.teacherName} has already used VR equipment before and doesn\'t need training?',
      confirmText: isSpanish ? 'Confirmar' : 'Confirm',
    );

    if (confirmed == true && mounted) {
      setState(() {
        request.status = TrainingStatus.completed;
        request.completedDate = DateTime.now();
        request.notes = '${request.notes ?? ""}${request.notes != null ? "\n" : ""}[${isSpanish ? "Ya capacitado previamente" : "Already trained"}]';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSpanish 
                      ? '${request.teacherName} marcado como capacitado'
                      : '${request.teacherName} marked as trained',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _handleReschedule(TrainingRequest request, bool isDark, bool isSpanish) async {
    DateTime? selectedDate;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.calendarClock, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isSpanish ? 'Reagendar Capacitación' : 'Reschedule Training',
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
                '${isSpanish ? 'Docente' : 'Teacher'}: ${request.teacherName}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isSpanish ? 'Nueva fecha de capacitación:' : 'New training date:',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 18,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedDate != null
                            ? _formatDate(selectedDate!, isSpanish)
                            : (isSpanish ? 'Seleccionar fecha' : 'Select date'),
                        style: TextStyle(
                          fontSize: 14,
                          color: selectedDate != null
                              ? (isDark ? AppColors.darkText : AppColors.lightText)
                              : (isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                isSpanish ? 'Cancelar' : 'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: selectedDate != null ? () => Navigator.pop(ctx, true) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: Text(isSpanish ? 'Reagendar' : 'Reschedule'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && selectedDate != null && mounted) {
      setState(() {
        request.status = TrainingStatus.rescheduled;
        request.scheduledDate = selectedDate;
        request.notes = '${request.notes ?? ''}\n[Reagendado el ${_formatDate(DateTime.now(), isSpanish)}]';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSpanish 
                  ? 'Capacitación reagendada para ${_formatDate(selectedDate!, isSpanish)}'
                  : 'Training rescheduled for ${_formatDate(selectedDate!, isSpanish)}',
            ),
            backgroundColor: Colors.purple,
          ),
        );
      }
    }
  }
}
