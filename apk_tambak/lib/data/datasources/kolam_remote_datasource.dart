import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/kolam_model.dart';

abstract class KolamRemoteDataSource {
  Future<List<KolamModel>> getKolams();
  Future<KolamModel> addKolam(Map<String, dynamic> payload);
  Future<void> updateKolam(int id, Map<String, dynamic> payload);
  Future<void> deleteKolam(int id);
  Future<void> addRelaysBatch(int kolamId, List<String> relays);
}

class KolamRemoteDataSourceImpl implements KolamRemoteDataSource {
  final ApiClient apiClient;

  KolamRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<KolamModel>> getKolams() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.kolam);
      
      Map<String, dynamic> responseMap;
      if (response.data is String) {
        responseMap = jsonDecode(response.data);
      } else {
        responseMap = response.data as Map<String, dynamic>;
      }

      final List<dynamic> dataList = responseMap['data'];
      return dataList.map((json) => KolamModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Gagal mengambil data kolam');
      } else {
        throw Exception(e.message);
      }
    }
  }

  @override
  Future<KolamModel> addKolam(Map<String, dynamic> payload) async {
    try {
      final response = await apiClient.dio.post(ApiEndpoints.kolam, data: payload);
      Map<String, dynamic> responseMap;
      if (response.data is String) {
        responseMap = jsonDecode(response.data);
      } else {
        responseMap = response.data as Map<String, dynamic>;
      }
      return KolamModel.fromJson(responseMap['data']);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Gagal menambah kolam');
      } else {
        throw Exception(e.message);
      }
    }
  }

  @override
  Future<void> addRelaysBatch(int kolamId, List<String> relayNames) async {
    try {
      final payload = {
        'kolam_id': kolamId,
        'relays': relayNames.map((name) => {'nama_relay': name}).toList(),
      };
      await apiClient.dio.post('${apiClient.dio.options.baseUrl.replaceAll('/api', '')}/api/relay', data: payload);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Gagal menambah relay');
      } else {
        throw Exception(e.message);
      }
    }
  }
  @override
  Future<void> updateKolam(int id, Map<String, dynamic> payload) async {
    try {
      await apiClient.dio.put('${ApiEndpoints.kolam}/$id', data: payload);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Gagal mengupdate kolam');
      } else {
        throw Exception(e.message);
      }
    }
  }

  @override
  Future<void> deleteKolam(int id) async {
    try {
      await apiClient.dio.delete('${ApiEndpoints.kolam}/$id');
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'Gagal menghapus kolam');
      } else {
        throw Exception(e.message);
      }
    }
  }
}
