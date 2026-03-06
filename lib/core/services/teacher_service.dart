import '../models/models.dart';
import 'api_client.dart';

/// Servicio para gestión de docentes
class TeacherService {
  final ApiClient _api;
  
  TeacherService({ApiClient? api}) : _api = api ?? ApiClient();
  
  /// Obtiene todos los docentes
  Future<ApiResponse<List<Teacher>>> getTeachers({
    String? search,
    String? career,
    String? faculty,
    bool? hasTraining,
  }) async {
    final queryParams = <String, String>{};
    
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (career != null) queryParams['career'] = career;
    if (faculty != null) queryParams['faculty'] = faculty;
    if (hasTraining != null) queryParams['hasTraining'] = hasTraining.toString();
    
    return _api.get<List<Teacher>>(
      '/teachers',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) {
        final list = json as List;
        return list.map((item) => Teacher.fromJson(item)).toList();
      },
    );
  }
  
  /// Obtiene un docente por ID
  Future<ApiResponse<Teacher>> getTeacher(String id) async {
    return _api.get<Teacher>(
      '/teachers/$id',
      fromJson: (json) => Teacher.fromJson(json),
    );
  }
  
  /// Obtiene docente por email
  Future<ApiResponse<Teacher>> getTeacherByEmail(String email) async {
    return _api.get<Teacher>(
      '/teachers/by-email/$email',
      fromJson: (json) => Teacher.fromJson(json),
    );
  }
  
  /// Crea un nuevo docente
  Future<ApiResponse<Teacher>> createTeacher({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? position,
    String? faculty,
    String? career,
    String? subject,
    bool hasTraining = false,
  }) async {
    // Validaciones
    if (firstName.isEmpty || lastName.isEmpty) {
      return ApiResponse.error('El nombre es requerido');
    }
    
    if (!_isValidEmail(email)) {
      return ApiResponse.error('El correo electrónico no es válido');
    }
    
    return _api.post<Teacher>(
      '/teachers',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        if (phone != null) 'phone': phone,
        if (position != null) 'position': position,
        if (faculty != null) 'faculty': faculty,
        if (career != null) 'career': career,
        if (subject != null) 'subject': subject,
        'hasTraining': hasTraining,
      },
      fromJson: (json) => Teacher.fromJson(json),
    );
  }
  
  /// Actualiza un docente existente
  Future<ApiResponse<Teacher>> updateTeacher({
    required String id,
    String? firstName,
    String? lastName,
    String? phone,
    String? position,
    String? faculty,
    String? career,
    String? subject,
  }) async {
    return _api.put<Teacher>(
      '/teachers/$id',
      body: {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phone != null) 'phone': phone,
        if (position != null) 'position': position,
        if (faculty != null) 'faculty': faculty,
        if (career != null) 'career': career,
        if (subject != null) 'subject': subject,
      },
      fromJson: (json) => Teacher.fromJson(json),
    );
  }
  
  /// Elimina un docente
  Future<ApiResponse<void>> deleteTeacher(String id) async {
    return _api.delete('/teachers/$id');
  }
  
  /// Registra capacitación de un docente
  Future<ApiResponse<Teacher>> registerTraining({
    required String teacherId,
    required bool hasTraining,
    DateTime? trainingDate,
  }) async {
    return _api.put<Teacher>(
      '/teachers/$teacherId/training',
      body: {
        'hasTraining': hasTraining,
        if (trainingDate != null) 'trainingDate': trainingDate.toIso8601String(),
      },
      fromJson: (json) => Teacher.fromJson(json),
    );
  }
  
  /// Solicita capacitación para un docente
  Future<ApiResponse<TrainingRequest>> requestTraining({
    required String teacherId,
    String? preferredDate,
    String? notes,
  }) async {
    return _api.post<TrainingRequest>(
      '/teachers/$teacherId/training-request',
      body: {
        if (preferredDate != null) 'preferredDate': preferredDate,
        if (notes != null) 'notes': notes,
      },
      fromJson: (json) => TrainingRequest.fromJson(json),
    );
  }
  
  /// Obtiene solicitudes de capacitación pendientes
  Future<ApiResponse<List<TrainingRequest>>> getPendingTrainingRequests() async {
    return _api.get<List<TrainingRequest>>(
      '/training-requests/pending',
      fromJson: (json) {
        final list = json as List;
        return list.map((item) => TrainingRequest.fromJson(item)).toList();
      },
    );
  }
  
  /// Aprueba una solicitud de capacitación
  Future<ApiResponse<TrainingRequest>> approveTrainingRequest({
    required String requestId,
    required DateTime scheduledDate,
  }) async {
    return _api.put<TrainingRequest>(
      '/training-requests/$requestId/approve',
      body: {
        'scheduledDate': scheduledDate.toIso8601String(),
      },
      fromJson: (json) => TrainingRequest.fromJson(json),
    );
  }
  
  /// Rechaza una solicitud de capacitación
  Future<ApiResponse<TrainingRequest>> rejectTrainingRequest({
    required String requestId,
    String? reason,
  }) async {
    return _api.put<TrainingRequest>(
      '/training-requests/$requestId/reject',
      body: {
        if (reason != null) 'reason': reason,
      },
      fromJson: (json) => TrainingRequest.fromJson(json),
    );
  }
  
  /// Busca docentes por término
  Future<ApiResponse<List<Teacher>>> searchTeachers(String term) async {
    if (term.isEmpty) {
      return ApiResponse.success([]);
    }
    
    return getTeachers(search: term);
  }
  
  /// Obtiene estadísticas de docentes
  Future<ApiResponse<TeacherStats>> getStats() async {
    return _api.get<TeacherStats>(
      '/teachers/stats',
      fromJson: (json) => TeacherStats.fromJson(json),
    );
  }
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  void dispose() {
    _api.dispose();
  }
}

/// Solicitud de capacitación
class TrainingRequest {
  final String id;
  final String teacherId;
  final String teacherName;
  final String? preferredDate;
  final String? notes;
  final DateTime? scheduledDate;
  final TrainingRequestStatus status;
  final DateTime createdAt;
  
  const TrainingRequest({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    this.preferredDate,
    this.notes,
    this.scheduledDate,
    required this.status,
    required this.createdAt,
  });
  
  factory TrainingRequest.fromJson(Map<String, dynamic> json) {
    return TrainingRequest(
      id: json['id'] ?? '',
      teacherId: json['teacherId'] ?? '',
      teacherName: json['teacherName'] ?? '',
      preferredDate: json['preferredDate'],
      notes: json['notes'],
      scheduledDate: json['scheduledDate'] != null 
          ? DateTime.parse(json['scheduledDate']) 
          : null,
      status: TrainingRequestStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => TrainingRequestStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'teacherId': teacherId,
    'teacherName': teacherName,
    if (preferredDate != null) 'preferredDate': preferredDate,
    if (notes != null) 'notes': notes,
    if (scheduledDate != null) 'scheduledDate': scheduledDate!.toIso8601String(),
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };
}

/// Estado de solicitud de capacitación
enum TrainingRequestStatus {
  pending,
  approved,
  rejected,
  completed,
}

/// Estadísticas de docentes
class TeacherStats {
  final int totalTeachers;
  final int trainedTeachers;
  final int pendingTraining;
  final int activeThisMonth;
  final Map<String, int> teachersByFaculty;
  final Map<String, int> teachersByCareer;
  
  const TeacherStats({
    required this.totalTeachers,
    required this.trainedTeachers,
    required this.pendingTraining,
    required this.activeThisMonth,
    required this.teachersByFaculty,
    required this.teachersByCareer,
  });
  
  factory TeacherStats.fromJson(Map<String, dynamic> json) {
    return TeacherStats(
      totalTeachers: json['totalTeachers'] ?? 0,
      trainedTeachers: json['trainedTeachers'] ?? 0,
      pendingTraining: json['pendingTraining'] ?? 0,
      activeThisMonth: json['activeThisMonth'] ?? 0,
      teachersByFaculty: Map<String, int>.from(json['teachersByFaculty'] ?? {}),
      teachersByCareer: Map<String, int>.from(json['teachersByCareer'] ?? {}),
    );
  }
  
  factory TeacherStats.empty() {
    return const TeacherStats(
      totalTeachers: 0,
      trainedTeachers: 0,
      pendingTraining: 0,
      activeThisMonth: 0,
      teachersByFaculty: {},
      teachersByCareer: {},
    );
  }
  
  double get trainingRate => totalTeachers > 0 
      ? trainedTeachers / totalTeachers 
      : 0;
}
