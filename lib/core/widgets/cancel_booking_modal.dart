import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core.dart';

/// Modal para cancelar una reserva con motivo
class CancelBookingModal extends StatefulWidget {
  final Booking booking;
  final Function(Booking cancelledBooking) onCancel;
  /// Nombre del usuario que cancela (admin)
  final String cancelledByName;
  
  const CancelBookingModal({
    super.key,
    required this.booking,
    required this.onCancel,
    required this.cancelledByName,
  });
  
  /// Muestra el modal de cancelación
  static Future<Booking?> show({
    required BuildContext context,
    required Booking booking,
    required String cancelledByName,
  }) async {
    Booking? result;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CancelBookingModal(
        booking: booking,
        cancelledByName: cancelledByName,
        onCancel: (cancelledBooking) {
          result = cancelledBooking;
          Navigator.of(context).pop();
        },
      ),
    );
    
    return result;
  }

  @override
  State<CancelBookingModal> createState() => _CancelBookingModalState();
}

class _CancelBookingModalState extends State<CancelBookingModal> {
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  
  bool get _canCancel => _reasonController.text.trim().isNotEmpty;
  
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
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
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isDark, isSpanish),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información de la reserva
                  _buildBookingInfo(isDark, isSpanish),
                  const SizedBox(height: 24),
                  
                  // Advertencia
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.triangleAlert,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isSpanish 
                                ? 'Esta acción notificará al docente sobre la cancelación.'
                                : 'This action will notify the teacher about the cancellation.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Campo de motivo
                  Text(
                    isSpanish ? 'Motivo de cancelación *' : 'Cancellation reason *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark 
                          ? AppColors.darkTextSecondary 
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reasonController,
                    maxLines: 4,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: isSpanish 
                          ? 'Explique el motivo de la cancelación...'
                          : 'Explain the reason for cancellation...',
                      hintStyle: TextStyle(
                        color: isDark 
                            ? AppColors.darkTextMuted 
                            : AppColors.lightTextSecondary,
                      ),
                      filled: true,
                      fillColor: isDark 
                          ? AppColors.darkCardBackground 
                          : AppColors.lightCardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark 
                              ? AppColors.darkBorder 
                              : AppColors.lightBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark 
                              ? AppColors.darkBorder 
                              : AppColors.lightBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  
                  if (!_canCancel && _reasonController.text.isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      isSpanish 
                          ? 'El motivo es obligatorio'
                          : 'Reason is required',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
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
              color: AppColors.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              LucideIcons.ban,
              color: AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSpanish ? 'Cancelar Reserva' : 'Cancel Booking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                Text(
                  isSpanish 
                      ? 'Esta acción no se puede deshacer'
                      : 'This action cannot be undone',
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
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBookingInfo(bool isDark, bool isSpanish) {
    final booking = widget.booking;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightInputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSpanish ? 'Reserva a cancelar:' : 'Booking to cancel:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark 
                  ? AppColors.darkTextMuted 
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Materia
          Row(
            children: [
              Icon(
                LucideIcons.bookOpen,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  booking.subject,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Docente
          Row(
            children: [
              Icon(
                LucideIcons.user,
                size: 14,
                color: isDark 
                    ? AppColors.darkTextMuted 
                    : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                booking.teacherName,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark 
                      ? AppColors.darkTextSecondary 
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          // Horario
          Row(
            children: [
              Icon(
                LucideIcons.clock,
                size: 14,
                color: isDark 
                    ? AppColors.darkTextMuted 
                    : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                booking.schedule.join(', '),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark 
                      ? AppColors.darkTextSecondary 
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          // Aula
          Row(
            children: [
              Icon(
                LucideIcons.building,
                size: 14,
                color: isDark 
                    ? AppColors.darkTextMuted 
                    : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                booking.aulaName,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark 
                      ? AppColors.darkTextSecondary 
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
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
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isSpanish ? 'Volver' : 'Go back',
                style: TextStyle(
                  color: isDark 
                      ? AppColors.darkTextSecondary 
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _canCancel ? _handleCancel : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: _isLoading 
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(LucideIcons.ban, size: 18),
              label: Text(
                isSpanish ? 'Cancelar Reserva' : 'Cancel Booking',
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleCancel() async {
    if (!_canCancel) return;
    
    setState(() => _isLoading = true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final cancelledBooking = widget.booking.cancel(
        reason: _reasonController.text.trim(),
        cancelledByUser: widget.cancelledByName,
      );
      
      widget.onCancel(cancelledBooking);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
