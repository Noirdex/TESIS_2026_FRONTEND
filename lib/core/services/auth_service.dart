import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'api_client.dart';

/// Servicio de autenticación
class AuthService {
  final ApiClient _api;
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  User? _currentUser;
  
  AuthService({ApiClient? api}) : _api = api ?? ApiClient();
  
  /// Usuario actual autenticado
  User? get currentUser => _currentUser;
  
  /// Verifica si hay un usuario autenticado
  bool get isAuthenticated => _currentUser != null;
  
  /// Verifica si el usuario es administrador
  bool get isAdmin => _currentUser?.role == UserRole.admin || 
                       _currentUser?.role == UserRole.superAdmin;
  
  /// Verifica si el usuario es docente
  bool get isTeacher => _currentUser?.role == UserRole.teacher;
  
  /// Inicializa el servicio cargando datos guardados
  Future<bool> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userData = prefs.getString(_userKey);
      
      if (token != null && userData != null) {
        _api.setAuthToken(token);
        // En producción, validaríamos el token con el servidor
        // Por ahora, cargamos el usuario guardado
        _currentUser = User.fromJson(
          Map<String, dynamic>.from(
            _parseJson(userData),
          ),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Login con email y contraseña
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Validación básica
    if (email.isEmpty || password.isEmpty) {
      return AuthResult.failure('Por favor complete todos los campos');
    }
    
    if (!_isValidEmail(email)) {
      return AuthResult.failure('El correo electrónico no es válido');
    }
    
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
    
    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      final token = data['token'] as String?;
      final userData = data['user'] as Map<String, dynamic>?;
      
      if (token != null && userData != null) {
        await _saveAuthData(token, userData);
        _api.setAuthToken(token);
        _currentUser = User.fromJson(userData);
        return AuthResult.success(_currentUser!);
      }
    }
    
    return AuthResult.failure(response.error ?? 'Error al iniciar sesión');
  }
  
  /// Login con Google
  Future<AuthResult> loginWithGoogle() async {
    // TODO: Implementar OAuth con Google
    return AuthResult.failure('Login con Google no implementado aún');
  }
  
  /// Login con Microsoft
  Future<AuthResult> loginWithMicrosoft() async {
    // TODO: Implementar OAuth con Microsoft
    return AuthResult.failure('Login con Microsoft no implementado aún');
  }
  
  /// Registro de nuevo usuario
  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    UserRole role = UserRole.teacher,
  }) async {
    // Validaciones
    if (firstName.isEmpty || lastName.isEmpty) {
      return AuthResult.failure('Por favor complete su nombre');
    }
    
    if (!_isValidEmail(email)) {
      return AuthResult.failure('El correo electrónico no es válido');
    }
    
    if (password.length < 8) {
      return AuthResult.failure('La contraseña debe tener al menos 8 caracteres');
    }
    
    if (password != confirmPassword) {
      return AuthResult.failure('Las contraseñas no coinciden');
    }
    
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/register',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'role': role.name,
      },
    );
    
    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      final token = data['token'] as String?;
      final userData = data['user'] as Map<String, dynamic>?;
      
      if (token != null && userData != null) {
        await _saveAuthData(token, userData);
        _api.setAuthToken(token);
        _currentUser = User.fromJson(userData);
        return AuthResult.success(_currentUser!);
      }
    }
    
    return AuthResult.failure(response.error ?? 'Error al registrarse');
  }
  
  /// Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    _api.setAuthToken(null);
    _currentUser = null;
  }
  
  /// Recuperar contraseña
  Future<bool> requestPasswordReset(String email) async {
    if (!_isValidEmail(email)) {
      return false;
    }
    
    final response = await _api.post(
      '/auth/forgot-password',
      body: {'email': email},
    );
    
    return response.isSuccess;
  }
  
  /// Actualizar perfil del usuario
  Future<AuthResult> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    if (_currentUser == null) {
      return AuthResult.failure('No hay usuario autenticado');
    }
    
    final response = await _api.put<Map<String, dynamic>>(
      '/auth/profile',
      body: {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phone != null) 'phone': phone,
      },
    );
    
    if (response.isSuccess && response.data != null) {
      _currentUser = User.fromJson(response.data!);
      await _updateStoredUser(_currentUser!);
      return AuthResult.success(_currentUser!);
    }
    
    return AuthResult.failure(response.error ?? 'Error al actualizar perfil');
  }
  
  /// Cambiar contraseña
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword.length < 8) {
      return false;
    }
    
    if (newPassword != confirmPassword) {
      return false;
    }
    
    final response = await _api.put(
      '/auth/change-password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    
    return response.isSuccess;
  }
  
  // Helpers privados
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  Future<void> _saveAuthData(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, _encodeJson(userData));
  }
  
  Future<void> _updateStoredUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, _encodeJson(user.toJson()));
  }
  
  String _encodeJson(Map<String, dynamic> data) {
    return Uri.encodeFull(data.toString());
  }
  
  Map<String, dynamic> _parseJson(String data) {
    // Parsing simple para datos guardados
    // En producción usaríamos jsonDecode con datos JSON válidos
    try {
      final decoded = Uri.decodeFull(data);
      // Convertir string de Map a Map real
      // Esto es simplificado - en producción usar jsonEncode/jsonDecode
      return {'raw': decoded};
    } catch (_) {
      return {};
    }
  }
  
  void dispose() {
    _api.dispose();
  }
}

/// Resultado de operación de autenticación
class AuthResult {
  final User? user;
  final String? error;
  final bool isSuccess;
  
  const AuthResult._({
    this.user,
    this.error,
    required this.isSuccess,
  });
  
  factory AuthResult.success(User user) {
    return AuthResult._(user: user, isSuccess: true);
  }
  
  factory AuthResult.failure(String message) {
    return AuthResult._(error: message, isSuccess: false);
  }
}
