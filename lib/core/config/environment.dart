/// Configuración de entorno para la aplicación
/// 
/// Para compilar en producción usar:
/// flutter build web --release --dart-define=ENV=prod
class Environment {
  static const String _envKey = String.fromEnvironment('ENV', defaultValue: 'dev');
  
  /// URLs de la API según el entorno
  static const String _devApiUrl = 'http://localhost:5000/api';
  static const String _prodApiUrl = 'https://agendamiento-vr-api.onrender.com/api';
  
  /// Verifica si estamos en producción
  static bool get isProduction => _envKey == 'prod';
  
  /// Verifica si estamos en desarrollo
  static bool get isDevelopment => _envKey == 'dev';
  
  /// Obtiene la URL base de la API según el entorno
  static String get apiBaseUrl => isProduction ? _prodApiUrl : _devApiUrl;
  
  /// Nombre del entorno actual
  static String get currentEnvironment => _envKey;
  
  /// Imprime información del entorno (solo para debug)
  static void printInfo() {
    assert(() {
      print('╔══════════════════════════════════════════╗');
      print('║     ENVIRONMENT CONFIGURATION            ║');
      print('╠══════════════════════════════════════════╣');
      print('║ Environment: ${_envKey.padRight(27)}║');
      print('║ API URL: ${apiBaseUrl.padRight(31)}║');
      print('║ Is Production: ${isProduction.toString().padRight(25)}║');
      print('╚══════════════════════════════════════════╝');
      return true;
    }());
  }
}
