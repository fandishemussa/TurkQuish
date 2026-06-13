import '../entities/backend_status.dart';
import '../entities/prediction_result.dart';

abstract class InferenceRepository {
  Future<BackendStatusSnapshot> backendStatus();

  Future<PredictionResult> predict({
    required String decodedUrl,
    required String locale,
  });

  Future<void> submitFeedback({
    required String predictionId,
    required String feedbackType,
    String? comment,
  });
}
