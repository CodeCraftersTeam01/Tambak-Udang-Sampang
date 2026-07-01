import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static String get baseUrl => dotenv.env['API_URL'] ?? 'http://localhost:8000/api';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String kolam = '/kolam';
  static const String produksiLog = '/produksi/log';
  static const String pakan = '/pakan';
  static const String panen = '/panen';
}
