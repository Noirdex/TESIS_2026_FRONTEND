/// Modelo de Aula VR
class Aula {
  final String id;
  final String name;
  final String location;
  final int capacity;
  final String schedule;        // Horario de operación: "07:00 - 16:00"
  final String? lunchBreak;     // Horario de almuerzo: "12:00 - 13:00"
  final List<int> availableDays; // Días disponibles: 1=Lun, 2=Mar, ..., 7=Dom
  final String? imageUrl;       // URL de foto del aula
  final String? mapUrl;         // URL para ver ubicación en mapa
  final double? latitude;       // Coordenada latitud para mapa
  final double? longitude;      // Coordenada longitud para mapa
  final bool isActive;
  final String? description;
  // Información del técnico asignado al aula
  final String? technicianId;
  final String? technicianName;
  final String? technicianEmail;
  final String? technicianPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Aula({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.schedule,
    this.lunchBreak,
    this.availableDays = const [1, 2, 3, 4, 5], // Por defecto Lun-Vie
    this.imageUrl,
    this.mapUrl,
    this.latitude,
    this.longitude,
    this.isActive = true,
    this.description,
    this.technicianId,
    this.technicianName,
    this.technicianEmail,
    this.technicianPhone,
    this.createdAt,
    this.updatedAt,
  });

  Aula copyWith({
    String? id,
    String? name,
    String? location,
    int? capacity,
    String? schedule,
    String? lunchBreak,
    List<int>? availableDays,
    String? imageUrl,
    String? mapUrl,
    double? latitude,
    double? longitude,
    bool? isActive,
    String? description,
    String? technicianId,
    String? technicianName,
    String? technicianEmail,
    String? technicianPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Aula(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      schedule: schedule ?? this.schedule,
      lunchBreak: lunchBreak ?? this.lunchBreak,
      availableDays: availableDays ?? this.availableDays,
      imageUrl: imageUrl ?? this.imageUrl,
      mapUrl: mapUrl ?? this.mapUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      technicianEmail: technicianEmail ?? this.technicianEmail,
      technicianPhone: technicianPhone ?? this.technicianPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'capacity': capacity,
      'schedule': schedule,
      'lunchBreak': lunchBreak,
      'availableDays': availableDays,
      'imageUrl': imageUrl,
      'mapUrl': mapUrl,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
      'description': description,
      'technicianId': technicianId,
      'technicianName': technicianName,
      'technicianEmail': technicianEmail,
      'technicianPhone': technicianPhone,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Aula.fromJson(Map<String, dynamic> json) {
    // Handle backend snake_case format (horario_inicio/horario_fin) or frontend format (schedule)
    String schedule = '';
    if (json.containsKey('schedule')) {
      schedule = json['schedule'] as String? ?? '7:00 - 17:00';
    } else {
      final horarioInicio = json['horario_inicio']?.toString() ?? '07:00';
      final horarioFin = json['horario_fin']?.toString() ?? '17:00';
      schedule = '$horarioInicio - $horarioFin';
    }
    
    return Aula(
      id: (json['id'] ?? json['id_aula'] ?? '').toString(),
      name: (json['name'] ?? json['nombre'] ?? '') as String,
      location: (json['location'] ?? json['ubicacion'] ?? '') as String,
      capacity: (json['capacity'] ?? json['capacidad'] ?? 15) as int,
      schedule: schedule,
      lunchBreak: json['lunchBreak'] ?? json['almuerzo'] as String?,
      availableDays: (json['availableDays'] ?? json['dias_disponibles'] as List<dynamic>?)
          ?.map((e) => e as int).toList() ?? [1, 2, 3, 4, 5],
      imageUrl: (json['imageUrl'] ?? json['foto_url']) as String?,
      mapUrl: json['mapUrl'] as String?,
      latitude: (json['latitude'] ?? json['latitud']) as double?,
      longitude: (json['longitude'] ?? json['longitud']) as double?,
      isActive: (json['isActive'] ?? json['is_active']) as bool? ?? true,
      description: (json['description'] ?? json['descripcion']) as String?,
      technicianId: json['technicianId']?.toString() ?? json['id_tecnico']?.toString(),
      technicianName: json['technicianName'] as String?,
      technicianEmail: json['technicianEmail'] as String?,
      technicianPhone: json['technicianPhone'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : (json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : (json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null),
    );
  }
  
  /// Retorna los días disponibles como strings
  List<String> get availableDaysNames {
    const days = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return availableDays.map((d) => days[d]).toList();
  }
  
  /// Retorna las horas de inicio y fin
  (int, int) get scheduleHours {
    try {
      final parts = schedule.split(' - ');
      final startHour = int.parse(parts[0].split(':')[0]);
      final endHour = int.parse(parts[1].split(':')[0]);
      return (startHour, endHour);
    } catch (e) {
      return (7, 17); // Valores por defecto
    }
  }
  
  /// Retorna las horas de almuerzo (inicio, fin)
  (int, int)? get lunchBreakHours {
    if (lunchBreak == null) return null;
    try {
      final parts = lunchBreak!.split(' - ');
      final startHour = int.parse(parts[0].split(':')[0]);
      final endHour = int.parse(parts[1].split(':')[0]);
      return (startHour, endHour);
    } catch (e) {
      return null;
    }
  }
  
  /// Indica si tiene ubicación GPS configurada
  bool get hasGpsLocation => latitude != null && longitude != null;
  
  /// Indica si tiene técnico asignado
  bool get hasTechnician => technicianId != null && technicianName != null;
}
