import 'user.dart';

/// Modelo de Docente
class Teacher extends User {
  final String? position;
  final String? faculty;
  final String? career;
  final String? subject;
  final bool hasTraining;
  final DateTime? trainingDate;

  const Teacher({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.phone,
    super.createdAt,
    this.position,
    this.faculty,
    this.career,
    this.subject,
    this.hasTraining = false,
    this.trainingDate,
  }) : super(role: UserRole.teacher);

  @override
  Teacher copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    UserRole? role,
    DateTime? createdAt,
    String? position,
    String? faculty,
    String? career,
    String? subject,
    bool? hasTraining,
    DateTime? trainingDate,
  }) {
    return Teacher(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      position: position ?? this.position,
      faculty: faculty ?? this.faculty,
      career: career ?? this.career,
      subject: subject ?? this.subject,
      hasTraining: hasTraining ?? this.hasTraining,
      trainingDate: trainingDate ?? this.trainingDate,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'position': position,
      'faculty': faculty,
      'career': career,
      'subject': subject,
      'hasTraining': hasTraining,
      'trainingDate': trainingDate?.toIso8601String(),
    };
  }

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      position: json['position'] as String?,
      faculty: json['faculty'] as String?,
      career: json['career'] as String?,
      subject: json['subject'] as String?,
      hasTraining: json['hasTraining'] as bool? ?? false,
      trainingDate: json['trainingDate'] != null 
          ? DateTime.parse(json['trainingDate'] as String)
          : null,
    );
  }

  /// Crea un Teacher vacío para formularios
  factory Teacher.empty() {
    return const Teacher(
      id: '',
      firstName: '',
      lastName: '',
      email: '',
    );
  }

  /// Verifica si el teacher tiene todos los datos requeridos
  bool get isValid {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        email.isNotEmpty &&
        position?.isNotEmpty == true &&
        faculty?.isNotEmpty == true &&
        career?.isNotEmpty == true &&
        subject?.isNotEmpty == true;
  }
}
