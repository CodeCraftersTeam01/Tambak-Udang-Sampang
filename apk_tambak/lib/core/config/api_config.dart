class ApiConfig {
  static const String baseUrl = 'http://192.168.1.191:8000';
  static String get webUrl => baseUrl.replaceAll(':8000', ':4173');
}
