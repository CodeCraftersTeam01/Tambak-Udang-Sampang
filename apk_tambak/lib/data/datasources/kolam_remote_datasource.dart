import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
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
      final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.kolam}');
      final request = http.MultipartRequest('POST', uri);

      final token = await apiClient.secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      payload.forEach((key, value) {
        if (key != 'image_file' && value != null) {
          if (value is List) {
            for (int i = 0; i < value.length; i++) {
              request.fields['$key[$i]'] = value[i].toString();
            }
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      if (payload['image_file'] != null) {
        final file = payload['image_file'] as File;
        request.files.add(
          await http.MultipartFile.fromPath('image_file', file.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Map<String, dynamic> responseMap = jsonDecode(response.body);
        return KolamModel.fromJson(responseMap['data']);
      } else {
        try {
          final responseMap = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(responseMap['message'] ?? 'Gagal menambah kolam');
        } catch (_) {
          throw Exception('Gagal menambah kolam: Status Code ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> addRelaysBatch(int kolamId, List<String> relayNames) async {
    try {
      final payload = {
        'kolam_id': kolamId,
        'relays': relayNames.map((name) => {'nama_relay': name}).toList(),
      };
      await apiClient.dio.post('/api/relay', data: payload);
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
      final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.kolam}/$id');
      final request = http.MultipartRequest('POST', uri);

      final token = await apiClient.secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      request.fields['_method'] = 'PUT'; // Method spoofing for Laravel PUT multipart support

      payload.forEach((key, value) {
        if (key != 'image_file' && value != null) {
          if (value is List) {
            for (int i = 0; i < value.length; i++) {
              request.fields['$key[$i]'] = value[i].toString();
            }
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      if (payload['image_file'] != null) {
        final file = payload['image_file'] as File;
        request.files.add(
          await http.MultipartFile.fromPath('image_file', file.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        try {
          final responseMap = jsonDecode(response.body) as Map<String, dynamic>;
          throw Exception(responseMap['message'] ?? 'Gagal mengupdate kolam');
        } catch (_) {
          throw Exception('Gagal mengupdate kolam: Status Code ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
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
