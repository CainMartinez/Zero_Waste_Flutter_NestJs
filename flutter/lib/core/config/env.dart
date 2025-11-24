/// Configuración de variables de entorno y helpers de URL.
/// Debug local:
///   flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8080/api --dart-define=MINIO_BASE_URL=http://127.0.0.1:9000
/// Debug Android:
///   flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080/api --dart-define=MINIO_BASE_URL=http://10.0.2.2:9000
/// Debug Android Genymotion:
///   flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.3.2:8080/api --dart-define=MINIO_BASE_URL=http://10.0.3.2:9000
/// Debug iOS Cain, cambiar IP según red local:
/// flutter run -d Cain \ --dart-define=API_BASE_URL=http://192.168.0.105:8080/api --dart-define=MINIO_BASE_URL=http://192.168.0.105:9000
/// En build:
///   flutter build apk --dart-define=API_BASE_URL=https://tu-dominio.com/api --dart-define=MINIO_BASE_URL=https://minio.tu-dominio.com
/// Comando para ejecutar en mi iphone real conectado por USB:
///   open ios/Runner.xcworkspace
class Env {
  static const String _apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8080/api');
  
  static const String _minioBaseUrl =
      String.fromEnvironment('MINIO_BASE_URL', defaultValue: 'http://127.0.0.1:9000');

  /// Base URL para llamadas HTTP, sin barra final.
  static String get apiBaseUrl => _apiBaseUrl.endsWith('/')
      ? _apiBaseUrl.substring(0, _apiBaseUrl.length - 1)
      : _apiBaseUrl;

  /// Base URL del servidor (sin /api), para recursos estáticos
  static String get serverBaseUrl {
    final url = apiBaseUrl;
    // Si termina en /api, lo removemos
    if (url.endsWith('/api')) {
      return url.substring(0, url.length - 4);
    }
    return url;
  }

  /// Base URL de MinIO para servir imágenes, sin barra final.
  static String get minioBaseUrl => _minioBaseUrl.endsWith('/')
      ? _minioBaseUrl.substring(0, _minioBaseUrl.length - 1)
      : _minioBaseUrl;

  /// Construye URL absolutas contra `apiBaseUrl`.
  static Uri apiUri(String path, {Map<String, dynamic>? query}) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$apiBaseUrl$normalized').replace(queryParameters: query);
  }
}