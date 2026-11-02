import 'package:dio/dio.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://www.google.com',
        options: Options(receiveTimeout: const Duration(seconds: 5), sendTimeout: const Duration(seconds: 5)),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}