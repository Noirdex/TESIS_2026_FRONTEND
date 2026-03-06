import '../models/models.dart';
import 'api_client.dart';

/// Servicio para gestión de reservas/agendamientos
class BookingService {
  final ApiClient _api;
  
  BookingService({ApiClient? api}) : _api = api ?? ApiClient();
  
  /// Obtiene todas las reservas
  Future<ApiResponse<List<Booking>>> getBookings({
    String? aulaId,
    String? teacherId,
    DateTime? startDate,
    DateTime? endDate,
    BookingStatus? status,
  }) async {
    final queryParams = <String, String>{};
    
    if (aulaId != null) queryParams['aulaId'] = aulaId;
    if (teacherId != null) queryParams['teacherId'] = teacherId;
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
    if (status != null) queryParams['status'] = status.name;
    
    return _api.get<List<Booking>>(
      '/bookings',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) {
        final list = json as List;
        return list.map((item) => Booking.fromJson(item)).toList();
      },
    );
  }
  
  /// Obtiene una reserva por ID
  Future<ApiResponse<Booking>> getBooking(String id) async {
    return _api.get<Booking>(
      '/bookings/$id',
      fromJson: (json) => Booking.fromJson(json),
    );
  }
  
  /// Obtiene reservas por semana
  Future<ApiResponse<List<Booking>>> getBookingsByWeek({
    required String aulaId,
    required DateTime weekStart,
  }) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    return getBookings(
      aulaId: aulaId,
      startDate: weekStart,
      endDate: weekEnd,
    );
  }
  
  /// Crea una nueva reserva
  Future<ApiResponse<Booking>> createBooking({
    required String aulaId,
    required String teacherId,
    required DateTime date,
    required int startHour,
    required int endHour,
    required String subject,
    required String career,
    String? parallel,
    String? cycle,
    int? numStudents,
    String? notes,
    BookingType type = BookingType.regular,
  }) async {
    // Validaciones
    if (startHour >= endHour) {
      return ApiResponse.error('La hora de inicio debe ser menor a la de fin');
    }
    
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return ApiResponse.error('No se puede reservar en fechas pasadas');
    }
    
    return _api.post<Booking>(
      '/bookings',
      body: {
        'aulaId': aulaId,
        'teacherId': teacherId,
        'date': date.toIso8601String(),
        'startHour': startHour,
        'endHour': endHour,
        'subject': subject,
        'career': career,
        if (parallel != null) 'parallel': parallel,
        if (cycle != null) 'cycle': cycle,
        if (numStudents != null) 'numStudents': numStudents,
        if (notes != null) 'notes': notes,
        'type': type.name,
      },
      fromJson: (json) => Booking.fromJson(json),
    );
  }
  
  /// Crea múltiples reservas (para grupos)
  Future<ApiResponse<List<Booking>>> createGroupBookings({
    required String aulaId,
    required String teacherId,
    required String subject,
    required String career,
    required List<BookingSlot> group1Slots,
    required List<BookingSlot> group2Slots,
    String? parallel,
    String? cycle,
    int? numStudents,
  }) async {
    final allSlots = [
      ...group1Slots.map((s) => s.copyWith(groupNumber: 1)),
      ...group2Slots.map((s) => s.copyWith(groupNumber: 2)),
    ];
    
    return _api.post<List<Booking>>(
      '/bookings/batch',
      body: {
        'aulaId': aulaId,
        'teacherId': teacherId,
        'subject': subject,
        'career': career,
        if (parallel != null) 'parallel': parallel,
        if (cycle != null) 'cycle': cycle,
        if (numStudents != null) 'numStudents': numStudents,
        'slots': allSlots.map((s) => s.toJson()).toList(),
      },
      fromJson: (json) {
        final list = json as List;
        return list.map((item) => Booking.fromJson(item)).toList();
      },
    );
  }
  
  /// Actualiza una reserva existente
  Future<ApiResponse<Booking>> updateBooking({
    required String id,
    DateTime? date,
    int? startHour,
    int? endHour,
    String? subject,
    String? career,
    String? parallel,
    String? cycle,
    int? numStudents,
    String? notes,
  }) async {
    return _api.put<Booking>(
      '/bookings/$id',
      body: {
        if (date != null) 'date': date.toIso8601String(),
        if (startHour != null) 'startHour': startHour,
        if (endHour != null) 'endHour': endHour,
        if (subject != null) 'subject': subject,
        if (career != null) 'career': career,
        if (parallel != null) 'parallel': parallel,
        if (cycle != null) 'cycle': cycle,
        if (numStudents != null) 'numStudents': numStudents,
        if (notes != null) 'notes': notes,
      },
      fromJson: (json) => Booking.fromJson(json),
    );
  }
  
  /// Cancela una reserva
  Future<ApiResponse<Booking>> cancelBooking(String id, {String? reason}) async {
    return _api.put<Booking>(
      '/bookings/$id/cancel',
      body: {
        'status': BookingStatus.cancelled.name,
        if (reason != null) 'cancellationReason': reason,
      },
      fromJson: (json) => Booking.fromJson(json),
    );
  }
  
  /// Elimina una reserva (solo admin)
  Future<ApiResponse<void>> deleteBooking(String id) async {
    return _api.delete('/bookings/$id');
  }
  
  /// Bloquea un horario (admin)
  Future<ApiResponse<Booking>> blockSchedule({
    required String aulaId,
    required DateTime date,
    required int startHour,
    required int endHour,
    String? reason,
    bool repeatWeekly = false,
    DateTime? repeatUntil,
  }) async {
    return _api.post<Booking>(
      '/bookings/block',
      body: {
        'aulaId': aulaId,
        'date': date.toIso8601String(),
        'startHour': startHour,
        'endHour': endHour,
        'type': BookingType.blocked.name,
        if (reason != null) 'notes': reason,
        'repeatWeekly': repeatWeekly,
        if (repeatUntil != null) 'repeatUntil': repeatUntil.toIso8601String(),
      },
      fromJson: (json) => Booking.fromJson(json),
    );
  }
  
  /// Desbloquea un horario
  Future<ApiResponse<void>> unblockSchedule(String bookingId) async {
    return _api.delete('/bookings/block/$bookingId');
  }
  
  /// Verifica disponibilidad de un horario
  Future<ApiResponse<bool>> checkAvailability({
    required String aulaId,
    required DateTime date,
    required int startHour,
    required int endHour,
  }) async {
    return _api.get<bool>(
      '/bookings/availability',
      queryParams: {
        'aulaId': aulaId,
        'date': date.toIso8601String(),
        'startHour': startHour.toString(),
        'endHour': endHour.toString(),
      },
      fromJson: (json) => json['available'] as bool,
    );
  }
  
  /// Obtiene estadísticas de reservas
  Future<ApiResponse<BookingStats>> getStats({
    DateTime? startDate,
    DateTime? endDate,
    String? aulaId,
  }) async {
    final queryParams = <String, String>{};
    
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
    if (aulaId != null) queryParams['aulaId'] = aulaId;
    
    return _api.get<BookingStats>(
      '/bookings/stats',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) => BookingStats.fromJson(json),
    );
  }
  
  void dispose() {
    _api.dispose();
  }
}

/// Slot de reserva para creación por lotes
class BookingSlot {
  final DateTime date;
  final int startHour;
  final int endHour;
  final int? groupNumber;
  
  const BookingSlot({
    required this.date,
    required this.startHour,
    required this.endHour,
    this.groupNumber,
  });
  
  BookingSlot copyWith({int? groupNumber}) {
    return BookingSlot(
      date: date,
      startHour: startHour,
      endHour: endHour,
      groupNumber: groupNumber ?? this.groupNumber,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'startHour': startHour,
    'endHour': endHour,
    if (groupNumber != null) 'groupNumber': groupNumber,
  };
}

/// Estadísticas de reservas
class BookingStats {
  final int totalBookings;
  final int activeBookings;
  final int cancelledBookings;
  final int completedBookings;
  final double occupancyRate;
  final Map<String, int> bookingsByCareer;
  final Map<String, int> bookingsByAula;
  
  const BookingStats({
    required this.totalBookings,
    required this.activeBookings,
    required this.cancelledBookings,
    required this.completedBookings,
    required this.occupancyRate,
    required this.bookingsByCareer,
    required this.bookingsByAula,
  });
  
  factory BookingStats.fromJson(Map<String, dynamic> json) {
    return BookingStats(
      totalBookings: json['totalBookings'] ?? 0,
      activeBookings: json['activeBookings'] ?? 0,
      cancelledBookings: json['cancelledBookings'] ?? 0,
      completedBookings: json['completedBookings'] ?? 0,
      occupancyRate: (json['occupancyRate'] ?? 0).toDouble(),
      bookingsByCareer: Map<String, int>.from(json['bookingsByCareer'] ?? {}),
      bookingsByAula: Map<String, int>.from(json['bookingsByAula'] ?? {}),
    );
  }
  
  factory BookingStats.empty() {
    return const BookingStats(
      totalBookings: 0,
      activeBookings: 0,
      cancelledBookings: 0,
      completedBookings: 0,
      occupancyRate: 0,
      bookingsByCareer: {},
      bookingsByAula: {},
    );
  }
}
