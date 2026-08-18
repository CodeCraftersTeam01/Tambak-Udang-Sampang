import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../security/secure_storage.dart';

class ApiClient {
  final Dio dio;
  final SecureStorage secureStorage;
  final Function()? onUnauthorized;

  ApiClient({required this.secureStorage, this.onUnauthorized}) : dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  ) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers['Accept'] = 'application/json';
        options.headers['Content-Type'] = 'application/json';
        debugPrint('[API REQUEST] ${options.method} ${options.uri}');

        final token = await secureStorage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          await secureStorage.deleteToken();
          if (onUnauthorized != null) {
            onUnauthorized!();
          }
        }
        return handler.next(e);
      },
    ));
  }
}
