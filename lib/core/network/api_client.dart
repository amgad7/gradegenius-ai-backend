import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class ApiClient {
  static Dio? _dio;
  static Dio? _customDio;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio get customInstance {
    _customDio ??= _createCustomDio();
    return _customDio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectTimeoutMs,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeoutMs,
        ),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[API] $obj'),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters['key'] = AppConstants.geminiApiKey;
          return handler.next(options);
        },
      ),
    );

    return dio;
  }

  static Dio _createCustomDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.customBackendUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectTimeoutMs,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeoutMs,
        ),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[CUSTOM MODEL] $obj'),
      ),
    );

    return dio;
  }

  static void reset() {
    _dio?.close();
    _customDio?.close();
    _dio = null;
    _customDio = null;
  }
}
