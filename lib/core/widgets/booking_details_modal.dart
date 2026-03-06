import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../models/booking.dart';
import 'app_button.dart';
import 'app_modal.dart';

// Iconos alternativos para versiones de lucide_icons que no tienen ciertos iconos
const _kLayers3Icon = LucideIcons.layers;
const _kAlertTriangleIcon = LucideIcons.triangleAlert;

/// Modal para mostrar detalles de una reserva
class BookingDetailsModal extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onCancel;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isAdmin;

  const BookingDetailsModal({
    super.key,
    required this.booking,
    this.onCancel,
    this.onEdit,
    this.onDelete,
    this.isAdmin = false,
  });

  /// Muestra el modal y retorna true si se realizó alguna acción
  static Future<bool?> show({
    required BuildContext context,
    required Booking booking,
    VoidCallback? onCancel,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    bool isAdmin = false,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => BookingDetailsModal(
        booking: booking,
        onCancel: onCancel,
        onEdit: onEdit,
        onDelete: onDelete,
        isAdmin: isAdmin,
      ),
    );
  }

  void _handleCancel(BuildContext context) async {
    final isSpanish = context.read<LocaleProvider>().isSpanish;

    final confirmed = await AppConfirmModal.show(
      context: context,
      title: isSpanish ? '¿Cancelar Reserva?' : 'Cancel Booking?',
      message: isSpanish 
          ? '¿Está seguro de cancelar esta reserva completa? Esta acción no se puede deshacer.'
          : 'Are you sure you want to cancel this entire booking? This action cannot be undone.',
      confirmText: isSpanish ? 'Sí, Cancelar' : 'Yes, Cancel',
      cancelText: isSpanish ? 'No, Volver' : 'No, Go Back',
      isDanger: true,
    );

    if (confirmed == true && context.mounted) {
      onCancel?.call();
      Navigator.of(context).pop(true);
    }
  }

  void _handleDelete(BuildContext context) async {
    final isSpanish = context.read<LocaleProvider>().isSpanish;

    final confirmed = await AppConfirmModal.show(
      context: context,
      title: isSpanish ? '¿Eliminar Bloqueo?' : 'Delete Block?',
      message: isSpanish 
          ? '¿Está seguro de eliminar este bloqueo de horarios?'
          : 'Are you sure you want to delete this schedule block?',
      confirmText: isSpanish ? 'Sí, Eliminar' : 'Yes, Delete',
      cancelText: isSpanish ? 'No, Volver' : 'No, Go Back',
      isDanger: true,
    );

    if (confirmed == true && context.mounted) {
      onDelete?.call();
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isSpanish = context.watch<LocaleProvider>().isSpanish;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
            _buildHeader(context, isDark, isSpanish),
            _buildContent(context, isDark, isSpanish),
            if (_shouldShowActions()) _buildActions(context, isDark, isSpanish),
          ],
        ),
      ),
    );
  }

  bool _shouldShowActions() {
    return booking.isActive && booking.type != BookingType.lunch;
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isSpanish) {
    IconData icon;
    Color color;
    String title;

    switch (booking.type) {
      case BookingType.lunch:
        icon = LucideIcons.coffee;
        color = AppColors.ucGold;
        title = isSpanish ? 'Hora de Almuerzo' : 'Lunch Hour';
        break;
      case BookingType.blocked:
        icon = LucideIcons.lock;
        color = Colors.grey;
        title = isSpanish ? 'Horario Bloqueado' : 'Blocked Schedule';
        break;
      case BookingType.regular:
        icon = LucideIcons.calendarCheck;
        color = AppColors.ucRed;
        title = isSpanish ? 'Detalles de la Reserva' : 'Booking Details';
        break;
    }

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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _buildStatusBadge(isDark, isSpanish),
                ],
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

  Widget _buildStatusBadge(bool isDark, bool isSpanish) {
    Color color;
    String text;

    if (booking.isCancelled) {
      color = AppColors.error;
      text = isSpanish ? 'Cancelada' : 'Cancelled';
    } else if (booking.isBlocked) {
      color = Colors.grey;
      text = isSpanish ? 'Bloqueado' : 'Blocked';
    } else {
      color = AppColors.success;
      text = isSpanish ? 'Activa' : 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, bool isSpanish) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información según el tipo de reserva
          if (booking.isRegular) ...[
            _buildInfoRow(
              isDark: isDark,
              icon: LucideIcons.user,
              label: isSpanish ? 'Docente' : 'Teacher',
              value: booking.teacherName,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              isDark: isDark,
              icon: LucideIcons.bookOpen,
              label: isSpanish ? 'Materia' : 'Subject',
              value: booking.subject,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    isDark: isDark,
                    icon: LucideIcons.graduationCap,
                    label: isSpanish ? 'Carrera' : 'Program',
                    value: booking.career,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoRow(
                    isDark: isDark,
                    icon: LucideIcons.layers,
                    label: isSpanish ? 'Ciclo' : 'Cycle',
                    value: booking.cycle ?? '-',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    isDark: isDark,
                    icon: LucideIcons.users,
                    label: isSpanish ? 'Paralelo' : 'Section',
                    value: booking.parallel ?? '-',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoRow(
                    isDark: isDark,
                    icon: LucideIcons.userCheck,
                    label: isSpanish ? 'Estudiantes' : 'Students',
                    value: '${booking.numStudents}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              isDark: isDark,
              icon: _kLayers3Icon,
              label: isSpanish ? 'Grupo' : 'Group',
              value: booking.group,
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Aula
          _buildInfoRow(
            isDark: isDark,
            icon: LucideIcons.mapPin,
            label: isSpanish ? 'Aula' : 'Classroom',
            value: booking.aulaName,
          ),
          
          const SizedBox(height: 16),
          
          // Horarios
          _buildScheduleSection(isDark, isSpanish),
          
          // Información adicional para bloqueos
          if (booking.isBlocked) ...[
            const SizedBox(height: 16),
            if (booking.repeatWeekly)
              _buildInfoChip(
                isDark: isDark,
                icon: LucideIcons.repeat,
                text: isSpanish ? 'Se repite semanalmente' : 'Repeats weekly',
                color: AppColors.ucGold,
              ),
            if (booking.createdBy != null) ...[
              const SizedBox(height: 12),
              Text(
                '${isSpanish ? 'Creado:' : 'Created:'} ${_formatDate(booking.createdAt ?? booking.date)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ],
          ],
          
          // Advertencia para bloqueos
          if (booking.isBlocked) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _kAlertTriangleIcon,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isSpanish 
                          ? 'Los docentes no pueden reservar estos horarios mientras estén bloqueados.'
                          : 'Teachers cannot book these hours while they are blocked.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.amber.shade100 : Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection(bool isDark, bool isSpanish) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.clock,
              size: 18,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              isSpanish ? 'Horarios' : 'Schedule',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: booking.schedule.map((slot) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.lightInputBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Text(
              slot,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required bool isDark,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildActions(BuildContext context, bool isDark, bool isSpanish) {
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
          if (booking.isBlocked && onDelete != null) ...[
            Expanded(
              child: AppButton(
                text: isSpanish ? 'Eliminar Bloqueo' : 'Delete Block',
                icon: LucideIcons.trash2,
                onPressed: () => _handleDelete(context),
                backgroundColor: AppColors.error,
              ),
            ),
          ] else if (booking.isRegular) ...[
            Expanded(
              child: AppSecondaryButton(
                text: isSpanish ? 'Cerrar' : 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            if (onCancel != null) ...[
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: isSpanish ? 'Cancelar Reserva' : 'Cancel Booking',
                  icon: LucideIcons.x,
                  onPressed: () => _handleCancel(context),
                  backgroundColor: AppColors.error,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
