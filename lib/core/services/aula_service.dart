import '../models/models.dart';
import 'api_client.dart';

/// Servicio para gestión de aulas VR
class AulaService {
  final ApiClient _api;
  
  AulaService({ApiClient? api}) : _api = api ?? ApiClient();
  
  /// Obtiene todas las aulas
  Future<ApiResponse<List<Aula>>> getAulas({
    String? location,
    bool? isActive,
  }) async {
    final queryParams = <String, String>{};
    
    if (location != null) queryParams['location'] = location;
    if (isActive != null) queryParams['isActive'] = isActive.toString();
    
    return _api.get<List<Aula>>(
      '/aulas',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) {
        final list = json as List;
        return list.map((item) => Aula.fromJson(item)).toList();
      },
    );
  }
  
  /// Obtiene un aula por ID
  Future<ApiResponse<Aula>> getAula(String id) async {
    return _api.get<Aula>(
      '/aulas/$id',
      fromJson: (json) => Aula.fromJson(json),
    );
  }
  
  /// Crea una nueva aula
  Future<ApiResponse<Aula>> createAula({
    required String name,
    required String location,
    required int capacity,
    String? schedule,
    String? mapUrl,
    String? imageUrl,
  }) async {
    if (name.isEmpty) {
      return ApiResponse.error('El nombre del aula es requerido');
    }
    
    if (capacity <= 0) {
      return ApiResponse.error('La capacidad debe ser mayor a 0');
    }
    
    return _api.post<Aula>(
      '/aulas',
      body: {
        'name': name,
        'location': location,
        'capacity': capacity,
        if (schedule != null) 'schedule': schedule,
        if (mapUrl != null) 'mapUrl': mapUrl,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'isActive': true,
      },
      fromJson: (json) => Aula.fromJson(json),
    );
  }
  
  /// Actualiza un aula existente
  Future<ApiResponse<Aula>> updateAula({
    required String id,
    String? name,
    String? location,
    int? capacity,
    String? schedule,
    String? mapUrl,
    String? imageUrl,
    bool? isActive,
  }) async {
    return _api.put<Aula>(
      '/aulas/$id',
      body: {
        if (name != null) 'name': name,
        if (location != null) 'location': location,
        if (capacity != null) 'capacity': capacity,
        if (schedule != null) 'schedule': schedule,
        if (mapUrl != null) 'mapUrl': mapUrl,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (isActive != null) 'isActive': isActive,
      },
      fromJson: (json) => Aula.fromJson(json),
    );
  }
  
  /// Elimina un aula
  Future<ApiResponse<void>> deleteAula(String id) async {
    return _api.delete('/aulas/$id');
  }
  
  /// Activa o desactiva un aula
  Future<ApiResponse<Aula>> toggleAulaStatus(String id, bool isActive) async {
    return updateAula(id: id, isActive: isActive);
  }
  
  /// Obtiene aulas disponibles para una fecha/hora específica
  Future<ApiResponse<List<Aula>>> getAvailableAulas({
    required DateTime date,
    required int startHour,
    required int endHour,
  }) async {
    return _api.get<List<Aula>>(
      '/aulas/available',
      queryParams: {
        'date': date.toIso8601String(),
        'startHour': startHour.toString(),
        'endHour': endHour.toString(),
      },
      fromJson: (json) {
        final list = json as List;
        return list.map((item) => Aula.fromJson(item)).toList();
      },
    );
  }
  
  /// Obtiene el estado de ocupación de un aula para una semana
  Future<ApiResponse<AulaOccupancy>> getAulaOccupancy({
    required String aulaId,
    required DateTime weekStart,
  }) async {
    return _api.get<AulaOccupancy>(
      '/aulas/$aulaId/occupancy',
      queryParams: {
        'weekStart': weekStart.toIso8601String(),
      },
      fromJson: (json) => AulaOccupancy.fromJson(json),
    );
  }
  
  /// Obtiene estadísticas de aulas
  Future<ApiResponse<AulaStats>> getStats() async {
    return _api.get<AulaStats>(
      '/aulas/stats',
      fromJson: (json) => AulaStats.fromJson(json),
    );
  }
  
  /// Sube imagen de un aula
  Future<ApiResponse<String>> uploadAulaImage({
    required String aulaId,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    // En producción, esto usaría multipart/form-data
    // Por ahora, retornamos error indicando que no está implementado
    return ApiResponse.error('Subida de imágenes no implementada');
  }
  
  void dispose() {
    _api.dispose();
  }
}

/// Estado de ocupación de un aula
class AulaOccupancy {
  final String aulaId;
  final DateTime weekStart;
  final Map<String, List<OccupiedSlot>> slotsByDay;
  final double occupancyRate;
  
  const AulaOccupancy({
    required this.aulaId,
    required this.weekStart,
    required this.slotsByDay,
    required this.occupancyRate,
  });
  
  factory AulaOccupancy.fromJson(Map<String, dynamic> json) {
    final slots = <String, List<OccupiedSlot>>{};
    
    final slotsJson = json['slotsByDay'] as Map<String, dynamic>? ?? {};
    for (final entry in slotsJson.entries) {
      final daySlots = (entry.value as List)
          .map((s) => OccupiedSlot.fromJson(s))
          .toList();
      slots[entry.key] = daySlots;
    }
    
    return AulaOccupancy(
      aulaId: json['aulaId'] ?? '',
      weekStart: DateTime.parse(json['weekStart'] ?? DateTime.now().toIso8601String()),
      slotsByDay: slots,
      occupancyRate: (json['occupancyRate'] ?? 0).toDouble(),
    );
  }
  
  /// Verifica si un slot está ocupado
  bool isSlotOccupied(int dayIndex, int hour) {
    final dayKey = _getDayKey(dayIndex);
    final daySlots = slotsByDay[dayKey] ?? [];
    return daySlots.any((slot) => slot.hour == hour);
  }
  
  /// Obtiene el slot ocupado si existe
  OccupiedSlot? getSlot(int dayIndex, int hour) {
    final dayKey = _getDayKey(dayIndex);
    final daySlots = slotsByDay[dayKey] ?? [];
    try {
      return daySlots.firstWhere((slot) => slot.hour == hour);
    } catch (_) {
      return null;
    }
  }
  
  String _getDayKey(int dayIndex) {
    final date = weekStart.add(Duration(days: dayIndex));
    return date.toIso8601String().split('T')[0];
  }
}

/// Slot de tiempo ocupado
class OccupiedSlot {
  final int hour;
  final String? bookingId;
  final BookingType type;
  final String? teacherName;
  final String? subject;
  
  const OccupiedSlot({
    required this.hour,
    this.bookingId,
    required this.type,
    this.teacherName,
    this.subject,
  });
  
  factory OccupiedSlot.fromJson(Map<String, dynamic> json) {
    return OccupiedSlot(
      hour: json['hour'] ?? 0,
      bookingId: json['bookingId'],
      type: BookingType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => BookingType.regular,
      ),
      teacherName: json['teacherName'],
      subject: json['subject'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'hour': hour,
    if (bookingId != null) 'bookingId': bookingId,
    'type': type.name,
    if (teacherName != null) 'teacherName': teacherName,
    if (subject != null) 'subject': subject,
  };
}

/// Estadísticas de aulas
class AulaStats {
  final int totalAulas;
  final int activeAulas;
  final int totalCapacity;
  final double averageOccupancy;
  final Map<String, double> occupancyByAula;
  
  const AulaStats({
    required this.totalAulas,
    required this.activeAulas,
    required this.totalCapacity,
    required this.averageOccupancy,
    required this.occupancyByAula,
  });
  
  factory AulaStats.fromJson(Map<String, dynamic> json) {
    return AulaStats(
      totalAulas: json['totalAulas'] ?? 0,
      activeAulas: json['activeAulas'] ?? 0,
      totalCapacity: json['totalCapacity'] ?? 0,
      averageOccupancy: (json['averageOccupancy'] ?? 0).toDouble(),
      occupancyByAula: Map<String, double>.from(
        (json['occupancyByAula'] as Map? ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      ),
    );
  }
  
  factory AulaStats.empty() {
    return const AulaStats(
      totalAulas: 0,
      activeAulas: 0,
      totalCapacity: 0,
      averageOccupancy: 0,
      occupancyByAula: {},
    );
  }
}
