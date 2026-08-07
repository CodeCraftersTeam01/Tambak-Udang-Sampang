import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';

class MonitoringRemoteDataSourceImpl {
  final ApiClient apiClient;

  MonitoringRemoteDataSourceImpl({required this.apiClient});

  Future<Map<String, dynamic>> getLatestMonitoring(int kolamId) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.monitoringLatest,
        queryParameters: {'pond_id': kolamId},
      );
      
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      return {};
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        }
      }
      throw Exception(e.message ?? 'Gagal mengambil monitoring.');
    }
  }

  Future<Map<String, dynamic>> getSensorHistory(int pondId) async {
    try {
      final response = await apiClient.dio.get(
        '/api/ponds/$pondId/sensors/history',
      );
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      return {};
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        }
      }
      throw Exception(e.message ?? 'Gagal mengambil riwayat sensor.');
    }
  }
}
