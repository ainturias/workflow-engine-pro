class ApiConfig {
  // Para emulador Android: 10.0.2.2 redirige a localhost del host
  // Para dispositivo físico: usar la IP de tu PC (ej: 192.168.1.X)
  // Para Chrome: usar localhost
  static const String baseUrl = 'http://10.0.2.2:8080';
  static const String apiUrl = '$baseUrl/api';
}
