import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../utils/url_masker.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  return ApiClient(config);
});

class ApiClient {
  ApiClient(AppConfig config)
    : dio = Dio(
        BaseOptions(
          baseUrl: config.apiBaseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 12),
          sendTimeout: const Duration(seconds: 8),
          headers: const {'Content-Type': 'application/json'},
        ),
      ) {
    if (kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint(
              'TurkQuish API ${options.method} ${options.path} ${UrlMasker.maskDebugValue(options.data)}',
            );
            handler.next(options);
          },
          onError: (error, handler) {
            debugPrint(
              'TurkQuish API error ${error.type} ${error.response?.statusCode}',
            );
            handler.next(error);
          },
        ),
      );
    }
  }

  final Dio dio;
}
