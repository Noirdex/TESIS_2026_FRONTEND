import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';

/// Cliente HTTP base para comunicación con el backend
class ApiClient {
  static String get baseUrl => Environment.apiBaseUrl;
  
  final http.Client _client;
  String? _authToken;
  
  ApiClient({http.Client? client}) : _client = client ?? http.Client();
  
  /// Configura el token de autenticación
  void setAuthToken(String? token) {
    _authToken = token;
  }
  
  /// Headers comunes para todas las peticiones
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };
  
  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    T Function(dynamic json)? fromJson,
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      
      final response = await _client.get(uri, headers: _headers);
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Error de conexión: $e');
    }
  }
  
  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Error de conexión: $e');
    }
  }
  
  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client.put(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Error de conexión: $e');
    }
  }
  
  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client.delete(uri, headers: _headers);
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Error de conexión: $e');
    }
  }
  
  /// Procesa la respuesta HTTP
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic json)? fromJson,
  ) {
    final statusCode = response.statusCode;
    
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse.success(null as T);
      }
      
      final json = jsonDecode(response.body);
      
      if (fromJson != null) {
        return ApiResponse.success(fromJson(json));
      }
      
      return ApiResponse.success(json as T);
    }
    
    // Manejar errores
    String errorMessage;
    try {
      final json = jsonDecode(response.body);
      errorMessage = json['message'] ?? json['error'] ?? 'Error desconocido';
    } catch (_) {
      errorMessage = 'Error del servidor (código: $statusCode)';
    }
    
    return ApiResponse.error(errorMessage, statusCode: statusCode);
  }
  
  /// Liberar recursos
  void dispose() {
    _client.close();
  }
}

/// Respuesta genérica de la API
class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;
  final bool isSuccess;
  
  const ApiResponse._({
    this.data,
    this.error,
    this.statusCode,
    required this.isSuccess,
  });
  
  factory ApiResponse.success(T data) {
    return ApiResponse._(data: data, isSuccess: true);
  }
  
  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse._(
      error: message, 
      statusCode: statusCode, 
      isSuccess: false,
    );
  }
  
  /// Ejecuta callback si es exitoso
  void onSuccess(void Function(T data) callback) {
    if (isSuccess) {
      final d = data;
      if (d != null) {
        callback(d);
      }
    }
  }
  
  /// Ejecuta callback si hay error
  void onError(void Function(String error) callback) {
    if (!isSuccess) {
      final e = error;
      if (e != null) {
        callback(e);
      }
    }
  }
  
  /// Map para transformar el dato
  ApiResponse<R> map<R>(R Function(T data) transform) {
    if (isSuccess) {
      final d = data;
      if (d != null) {
        return ApiResponse.success(transform(d));
      }
    }
    return ApiResponse.error(error ?? 'Error desconocido', statusCode: statusCode);
  }
}
