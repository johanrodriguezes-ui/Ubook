/// Configuración centralizada de la API.
///
/// Antes esta URL estaba repetida (hardcodeada) en cada archivo de servicio.
/// Ahora todos los servicios importan `ApiConfig.baseUrl` desde un solo lugar,
/// así que para apuntar la app a otro backend (por ejemplo, tu IP local si
/// pruebas en un celular físico, o un emulador Android) solo hay que cambiar
/// esta línea.
class ApiConfig {
  /// URL base del backend PHP.
  ///
  /// - iOS Simulator / Chrome / Windows / macOS -> "http://127.0.0.1/api"
  /// - Emulador de Android -> "http://10.0.2.2/api"
  /// - Celular físico en la misma red Wi-Fi -> "http://TU_IP_LOCAL/api"
  ///   (por ejemplo "http://192.168.1.10/api")
  static const String baseUrl = "http://127.0.0.1/api";
}
