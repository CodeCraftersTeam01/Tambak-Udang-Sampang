import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  // TODO: [URGENT NETWORK CONFIG] Update this IP address to match your current Wi-Fi IPv4 address (run 'ipconfig' in terminal).
  // If testing on an Android Emulator, change this to: 'http://10.0.2.2:8000/api'
  // If testing on a physical Android device, use your local Wi-Fi IPv4 (e.g., 'http://192.168.X.X:8000/api')
  static String get baseUrl => dotenv.env['API_URL'] ?? 'http://192.168.1.191:8000/api';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String kolam = '/kolam';
  static const String produksiLog = '/produksi/log';
  static const String pakan = '/pakan';
  static const String panen = '/panen';
}
