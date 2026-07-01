import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/kolam_model.dart';

abstract class KolamRemoteDataSource {
  Future<List<KolamModel>> getKolams();
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
}
