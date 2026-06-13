import 'package:dio/dio.dart';

enum ApiFailureType {
  developerConfig,
  timeout,
  offline,
  backendUnavailable,
  rateLimited,
  serverError,
  malformedResponse,
  invalidUrl,
  unexpected,
}

class ApiException implements Exception {
  const ApiException(this.type, this.message, {this.statusCode});

  final ApiFailureType type;
  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const ApiException(
        ApiFailureType.timeout,
        'The backend request timed out.',
      ),
      DioExceptionType.connectionError => const ApiException(
        ApiFailureType.offline,
        'No network connection or the backend could not be reached.',
      ),
      DioExceptionType.badResponse => _fromStatus(error.response?.statusCode),
      DioExceptionType.badCertificate => const ApiException(
        ApiFailureType.backendUnavailable,
        'The backend TLS certificate could not be trusted.',
      ),
      DioExceptionType.cancel => const ApiException(
        ApiFailureType.unexpected,
        'The backend request was cancelled.',
      ),
      DioExceptionType.unknown => const ApiException(
        ApiFailureType.unexpected,
        'An unexpected network error occurred.',
      ),
    };
  }

  static ApiException _fromStatus(int? statusCode) {
    if (statusCode == null) {
      return const ApiException(
        ApiFailureType.backendUnavailable,
        'Backend unavailable.',
      );
    }
    if (statusCode == 400 || statusCode == 422) {
      return ApiException(
        ApiFailureType.invalidUrl,
        'The backend rejected this URL as invalid.',
        statusCode: statusCode,
      );
    }
    if (statusCode == 429) {
      return const ApiException(
        ApiFailureType.rateLimited,
        'Too many requests. Try again shortly.',
        statusCode: 429,
      );
    }
    if (statusCode >= 500) {
      return ApiException(
        ApiFailureType.serverError,
        'The backend returned a server error.',
        statusCode: statusCode,
      );
    }
    return ApiException(
      ApiFailureType.backendUnavailable,
      'The backend returned HTTP $statusCode.',
      statusCode: statusCode,
    );
  }

  @override
  String toString() => 'ApiException($type, $message)';
}
