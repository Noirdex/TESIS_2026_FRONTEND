/// Tipos de reserva
enum BookingType {
  regular,  // Clase regular
  lunch,    // Hora de almuerzo
  blocked,  // Horario bloqueado por admin
}

/// Estados de reserva
enum BookingStatus {
  active,
  cancelled,
  completed,
}

/// Modelo de Reserva/Agendamiento
class Booking {
  final String id;
  final String teacherId;
  final String teacherName;
  final String aulaId;
  final String aulaName;
  final String subject;
  final String career;
  final String? parallel;
  final String? cycle;
  final int? numStudents;
  final String group; // "Grupo único", "Grupo 1", "Grupo 2", "Grupos 1 y 2"
  final List<String> schedule; // ["Lun-08:00", "Mié-08:00"]
  final DateTime date;
  final int startHour;  // Hora de inicio (7-17)
  final int endHour;    // Hora de fin (8-18)
  final String? notes;  // Notas adicionales
  final BookingType type;
  final BookingStatus status;
  final String? createdBy;
  final bool repeatWeekly;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Campos de cancelación
  final String? cancellationReason;  // Motivo de cancelación
  final String? cancelledBy;         // ID/nombre del admin que canceló
  final DateTime? cancelledAt;       // Fecha de cancelación
  
  // Información del técnico del aula (para contacto)
  final String? aulaTechnicianName;
  final String? aulaTechnicianEmail;
  final String? aulaTechnicianPhone;
  
  // Ubicación del aula
  final double? aulaLatitude;
  final double? aulaLongitude;

  const Booking({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.aulaId,
    required this.aulaName,
    required this.subject,
    required this.career,
    this.parallel,
    this.cycle,
    this.numStudents,
    required this.group,
    required this.schedule,
    required this.date,
    this.startHour = 7,
    this.endHour = 8,
    this.notes,
    this.type = BookingType.regular,
    this.status = BookingStatus.active,
    this.createdBy,
    this.repeatWeekly = false,
    this.createdAt,
    this.updatedAt,
    this.cancellationReason,
    this.cancelledBy,
    this.cancelledAt,
    this.aulaTechnicianName,
    this.aulaTechnicianEmail,
    this.aulaTechnicianPhone,
    this.aulaLatitude,
    this.aulaLongitude,
  });

  Booking copyWith({
    String? id,
    String? teacherId,
    String? teacherName,
    String? aulaId,
    String? aulaName,
    String? subject,
    String? career,
    String? parallel,
    String? cycle,
    int? numStudents,
    String? group,
    List<String>? schedule,
    DateTime? date,
    int? startHour,
    int? endHour,
    String? notes,
    BookingType? type,
    BookingStatus? status,
    String? createdBy,
    bool? repeatWeekly,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cancellationReason,
    String? cancelledBy,
    DateTime? cancelledAt,
    String? aulaTechnicianName,
    String? aulaTechnicianEmail,
    String? aulaTechnicianPhone,
    double? aulaLatitude,
    double? aulaLongitude,
  }) {
    return Booking(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      aulaId: aulaId ?? this.aulaId,
      aulaName: aulaName ?? this.aulaName,
      subject: subject ?? this.subject,
      career: career ?? this.career,
      parallel: parallel ?? this.parallel,
      cycle: cycle ?? this.cycle,
      numStudents: numStudents ?? this.numStudents,
      group: group ?? this.group,
      schedule: schedule ?? this.schedule,
      date: date ?? this.date,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      repeatWeekly: repeatWeekly ?? this.repeatWeekly,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      aulaTechnicianName: aulaTechnicianName ?? this.aulaTechnicianName,
      aulaTechnicianEmail: aulaTechnicianEmail ?? this.aulaTechnicianEmail,
      aulaTechnicianPhone: aulaTechnicianPhone ?? this.aulaTechnicianPhone,
      aulaLatitude: aulaLatitude ?? this.aulaLatitude,
      aulaLongitude: aulaLongitude ?? this.aulaLongitude,
    );
  }
  
  /// Verifica si el aula tiene ubicación
  bool get hasLocation => aulaLatitude != null && aulaLongitude != null;

  /// Marca como cancelada con motivo
  Booking cancel({
    required String reason,
    required String cancelledByUser,
  }) => copyWith(
    status: BookingStatus.cancelled,
    cancellationReason: reason,
    cancelledBy: cancelledByUser,
    cancelledAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  /// Verifica si es una clase regular
  bool get isRegular => type == BookingType.regular;

  /// Verifica si es almuerzo
  bool get isLunch => type == BookingType.lunch;

  /// Verifica si está bloqueado
  bool get isBlocked => type == BookingType.blocked;

  /// Verifica si está activa
  bool get isActive => status == BookingStatus.active;

  /// Verifica si está cancelada
  bool get isCancelled => status == BookingStatus.cancelled;
  
  /// Verifica si está completada
  bool get isCompleted => status == BookingStatus.completed;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'aulaId': aulaId,
      'aulaName': aulaName,
      'subject': subject,
      'career': career,
      'parallel': parallel,
      'cycle': cycle,
      'numStudents': numStudents,
      'group': group,
      'schedule': schedule,
      'date': date.toIso8601String(),
      'startHour': startHour,
      'endHour': endHour,
      'notes': notes,
      'type': type.name,
      'status': status.name,
      'createdBy': createdBy,
      'repeatWeekly': repeatWeekly,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'cancelledBy': cancelledBy,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'aulaTechnicianName': aulaTechnicianName,
      'aulaTechnicianEmail': aulaTechnicianEmail,
      'aulaTechnicianPhone': aulaTechnicianPhone,
      'aulaLatitude': aulaLatitude,
      'aulaLongitude': aulaLongitude,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      teacherId: json['teacherId'] as String,
      teacherName: json['teacherName'] as String,
      aulaId: json['aulaId'] as String,
      aulaName: json['aulaName'] as String,
      subject: json['subject'] as String,
      career: json['career'] as String,
      parallel: json['parallel'] as String?,
      cycle: json['cycle'] as String?,
      numStudents: json['numStudents'] as int?,
      group: json['group'] as String? ?? 'Grupo único',
      schedule: (json['schedule'] as List<dynamic>?)?.cast<String>() ?? [],
      date: DateTime.parse(json['date'] as String),
      startHour: json['startHour'] as int? ?? 7,
      endHour: json['endHour'] as int? ?? 8,
      notes: json['notes'] as String?,
      type: BookingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BookingType.regular,
      ),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.active,
      ),
      createdBy: json['createdBy'] as String?,
      repeatWeekly: json['repeatWeekly'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      cancellationReason: json['cancellationReason'] as String?,
      cancelledBy: json['cancelledBy'] as String?,
      cancelledAt: json['cancelledAt'] != null 
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      aulaTechnicianName: json['aulaTechnicianName'] as String?,
      aulaTechnicianEmail: json['aulaTechnicianEmail'] as String?,
      aulaTechnicianPhone: json['aulaTechnicianPhone'] as String?,
      aulaLatitude: (json['aulaLatitude'] as num?)?.toDouble(),
      aulaLongitude: (json['aulaLongitude'] as num?)?.toDouble(),
    );
  }

  /// Crea una reserva de bloqueo
  factory Booking.blocked({
    required String id,
    required String aulaId,
    required String aulaName,
    required List<String> schedule,
    required String createdBy,
    int startHour = 7,
    int endHour = 8,
    String? notes,
    bool repeatWeekly = false,
  }) {
    return Booking(
      id: id,
      teacherId: 'admin',
      teacherName: 'ADMINISTRADOR',
      aulaId: aulaId,
      aulaName: aulaName,
      subject: 'HORARIO NO DISPONIBLE',
      career: '-',
      group: '-',
      schedule: schedule,
      date: DateTime.now(),
      startHour: startHour,
      endHour: endHour,
      notes: notes,
      type: BookingType.blocked,
      status: BookingStatus.active,
      createdBy: createdBy,
      repeatWeekly: repeatWeekly,
      createdAt: DateTime.now(),
    );
  }

  /// Crea una reserva de almuerzo
  factory Booking.lunch({
    required String id,
    required String aulaId,
    required String aulaName,
    required List<String> schedule,
    required String createdBy,
  }) {
    return Booking(
      id: id,
      teacherId: 'system',
      teacherName: 'ALMUERZO',
      aulaId: aulaId,
      aulaName: aulaName,
      subject: 'HORA DE ALMUERZO',
      career: '-',
      group: '-',
      schedule: schedule,
      date: DateTime.now(),
      startHour: 12,
      endHour: 13,
      type: BookingType.lunch,
      status: BookingStatus.active,
      createdBy: createdBy,
      repeatWeekly: true,
      createdAt: DateTime.now(),
    );
  }
}

/// Estado de celda del calendario
enum CalendarCellStatus {
  free,
  occupied,
  myBooking,
  cancelled,
  lunch,
  blocked,
  selected,
  group1,
  group2,
}

/// Modelo de celda del calendario
class CalendarCell {
  final CalendarCellStatus status;
  final String? subject;
  final String? teacher;
  final String? cycle;
  final String? parallel;
  final String? group;
  final Booking? booking;

  const CalendarCell({
    required this.status,
    this.subject,
    this.teacher,
    this.cycle,
    this.parallel,
    this.group,
    this.booking,
  });

  /// Celda libre
  static const CalendarCell free = CalendarCell(status: CalendarCellStatus.free);

  /// Crea una celda ocupada
  factory CalendarCell.occupied(Booking booking) {
    return CalendarCell(
      status: CalendarCellStatus.occupied,
      subject: booking.subject,
      teacher: booking.teacherName,
      cycle: booking.cycle,
      parallel: booking.parallel,
      group: booking.group,
      booking: booking,
    );
  }

  /// Crea una celda de almuerzo
  factory CalendarCell.lunch(Booking booking) {
    return CalendarCell(
      status: CalendarCellStatus.lunch,
      subject: 'ALMUERZO',
      booking: booking,
    );
  }

  /// Crea una celda bloqueada
  factory CalendarCell.blocked(Booking booking) {
    return CalendarCell(
      status: CalendarCellStatus.blocked,
      subject: 'NO DISPONIBLE',
      booking: booking,
    );
  }

  /// Crea una celda cancelada
  factory CalendarCell.cancelled(Booking booking) {
    return CalendarCell(
      status: CalendarCellStatus.cancelled,
      subject: booking.subject,
      teacher: booking.teacherName,
      booking: booking,
    );
  }
}
