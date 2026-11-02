import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import 'api_exceptions.dart';

class ApiClient {
  late final Dio dio;
  static const String baseUrl = 'https://nivetha-fastapi-backend.onrender.com/api/v1';

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          final appException = ApiException.fromDioException(e);
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: appException,
              message: appException.message,
              response: e.response,
              type: e.type,
            ),
          );
        },
      ),
    );
  }
}