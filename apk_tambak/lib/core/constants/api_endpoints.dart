import '../config/api_config.dart';

class ApiEndpoints {
  static String get baseUrl => ApiConfig.baseUrl;
  static const String login = '/login';
  static const String ponds = '/api/ponds';
  static const String monitoringLatest = '/monitoring/latest';
  static const String devices = '/devices';
  static const String farmSummary = '/farm-management/summary';
  static const String productionSummary = '/production-management/summary';
  static const String productionCycles = '/production-cycles';

  // Legacy compatibility aliases
  static const String register = '/api/auth/register';
  static const String logout = '/api/auth/logout';
  static const String kolam = '/api/ponds';
  static const String produksiLog = '/api/produksi/log';
  static const String pakan = '/api/pakan';
  static const String panen = '/api/panen';
}
