import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Dio HTTP client configured for the AI API
class ApiClient {
  static Dio? _dio;
  static Dio? _customDio;

  /// Singleton Dio instance for Gemini API
  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  /// Singleton Dio instance for our Custom NLP Python Backend
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
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Logging interceptor (debug only)
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[API] $obj'),
      ),
    );

    // Add API key query parameter interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.queryParameters['key'] = AppConstants.geminiApiKey;
        return handler.next(options);
      },
    ));

    return dio;
  }

  /// Creates a Dio instance pointing to our Python NLP backend
  static Dio _createCustomDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.customBackendUrl,
        connectTimeout: const Duration(milliseconds: 10000),
        receiveTimeout: const Duration(milliseconds: 30000),
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

  /// Reset the Dio instance (useful for testing)
  static void reset() {
    _dio?.close();
    _customDio?.close();
    _dio = null;
    _customDio = null;
  }
}
