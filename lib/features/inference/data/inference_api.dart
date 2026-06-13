import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/entities/backend_status.dart';
import '../domain/entities/prediction_result.dart';
import '../domain/repositories/inference_repository.dart';
import 'dto/feedback_request_dto.dart';
import 'dto/prediction_request_dto.dart';
import 'dto/prediction_response_dto.dart';

final inferenceRepositoryProvider = Provider<InferenceRepository>((ref) {
  return InferenceRepositoryImpl(
    client: ref.watch(apiClientProvider),
    config: ref.watch(appConfigProvider),
  );
});

class InferenceRepositoryImpl implements InferenceRepository {
  const InferenceRepositoryImpl({
    required ApiClient client,
    required AppConfig config,
  }) : _client = client,
       _config = config;

  final ApiClient _client;
  final AppConfig _config;

  @override
  Future<BackendStatusSnapshot> backendStatus() async {
    if (!_config.hasApiBaseUrl) {
      throw const ApiException(
        ApiFailureType.developerConfig,
        'API_BASE_URL is not configured.',
      );
    }

    try {
      final startedAt = DateTime.now();
      final healthResponse = await _client.dio.get<dynamic>('/api/v1/health');
      final latencyMs = DateTime.now().difference(startedAt).inMilliseconds;
      final modelResponse = await _client.dio.get<dynamic>(
        '/api/v1/model-info',
      );
      final healthJson = _asMap(healthResponse.data);
      final modelJson = _asMap(modelResponse.data);
      return BackendStatusSnapshot(
        health: BackendHealth(
          status: healthJson['status']?.toString() ?? 'unknown',
          modelLoaded: _asBool(healthJson['modelLoaded']),
          modelVersion: healthJson['modelVersion']?.toString() ?? 'unknown',
          featureSchemaVersion:
              healthJson['featureSchemaVersion']?.toString() ?? 'unknown',
          urlOnly: _asBool(healthJson['urlOnly'], fallback: true),
          urlTransformerAvailable: _asBool(
            healthJson['urlTransformerAvailable'],
          ),
          latencyMs: latencyMs,
        ),
        modelInfo: BackendModelInfo(
          modelVersion: modelJson['modelVersion']?.toString() ?? 'unknown',
          featureSchemaVersion:
              modelJson['featureSchemaVersion']?.toString() ?? 'unknown',
          classes: _asStringList(modelJson['classes']),
          urlOnly: _asBool(modelJson['urlOnly'], fallback: true),
          nFeatures: _asInt(modelJson['nFeatures']),
          urlTransformerAvailable: _asBool(
            modelJson['urlTransformerAvailable'],
          ),
        ),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on FormatException catch (error) {
      throw ApiException(ApiFailureType.malformedResponse, error.message);
    }
  }

  @override
  Future<PredictionResult> predict({
    required String decodedUrl,
    required String locale,
  }) async {
    if (!_config.hasApiBaseUrl) {
      throw const ApiException(
        ApiFailureType.developerConfig,
        'API_BASE_URL is not configured.',
      );
    }
    final request = PredictionRequestDto(
      decodedUrl: decodedUrl,
      clientTimestamp: DateTime.now(),
      locale: locale,
      appVersion: _config.appVersion,
    );

    try {
      final requestWatch = Stopwatch()..start();
      final response = await _client.dio.post<dynamic>(
        '/api/v1/predict',
        data: request.toJson(),
      );
      requestWatch.stop();
      final apiRequestResponseMs = requestWatch.elapsedMicroseconds / 1000.0;
      final data = response.data;
      if (data is! Map) {
        throw const FormatException('Backend response was not a JSON object.');
      }
      debugPrint(
        'TurkQuishTiming api_request_response_ms='
        '${apiRequestResponseMs.toStringAsFixed(4)}',
      );
      debugPrint('TurkQuishTiming backend_latency_ms=${data['latencyMs']}');
      debugPrint('TurkQuishTiming backend_timing_ms=${data['timingMs']}');
      return PredictionResponseDto.fromJson(
        Map<String, dynamic>.from(data),
      ).toDomain(apiRequestResponseMs: apiRequestResponseMs);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on FormatException catch (error) {
      throw ApiException(ApiFailureType.malformedResponse, error.message);
    }
  }

  @override
  Future<void> submitFeedback({
    required String predictionId,
    required String feedbackType,
    String? comment,
  }) async {
    final request = FeedbackRequestDto(
      predictionId: predictionId,
      feedbackType: feedbackType,
      comment: comment,
      clientTimestamp: DateTime.now(),
    );
    try {
      await _client.dio.post<dynamic>(
        '/api/v1/feedback',
        data: request.toJson(),
      );
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw const FormatException('Backend response was not a JSON object.');
  }

  static List<String> _asStringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }
    return const [];
  }

  static bool _asBool(Object? value, {bool fallback = false}) {
    if (value is bool) {
      return value;
    }
    final normalized = value?.toString().toLowerCase();
    if (normalized == 'true') {
      return true;
    }
    if (normalized == 'false') {
      return false;
    }
    return fallback;
  }

  static int _asInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
