/// Configuración de variables de entorno y helpers de URL.
/// Debug local:
///   flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8080/api
/// Debug Android:
///   flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080/api
/// Debug Android Genymotion:
///   flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.3.2:8080/api
/// En build:
///   flutter build apk --dart-define=API_BASE_URL=https://tu-dominio.com/api
/// Comando para ejecutar en mi iphone real conectado por USB:
///   open ios/Runner.xcworkspace
class Env {
  static const String _apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8080/api');

  /// Base URL para llamadas HTTP, sin barra final.
  static String get apiBaseUrl => _apiBaseUrl.endsWith('/')
      ? _apiBaseUrl.substring(0, _apiBaseUrl.length - 1)
      : _apiBaseUrl;

  /// Construye URL absolutas contra `apiBaseUrl`.
  static Uri apiUri(String path, {Map<String, dynamic>? query}) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$apiBaseUrl$normalized').replace(queryParameters: query);
  }
}