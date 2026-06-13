import '../../inference/domain/entities/prediction_class.dart';

class ScanHistoryItem {
  const ScanHistoryItem({
    required this.id,
    required this.timestamp,
    required this.displayUrl,
    required this.predictedClass,
    required this.riskScore,
    required this.modelVersion,
  });

  final String id;
  final DateTime timestamp;
  final String displayUrl;
  final PredictionClass predictedClass;
  final double riskScore;
  final String modelVersion;

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      id:
          json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      timestamp:
          DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      displayUrl: json['displayUrl']?.toString() ?? 'unknown',
      predictedClass: predictionClassFromJson(json['predictedClass']),
      riskScore: _asDouble(json['riskScore']),
      modelVersion: json['modelVersion']?.toString() ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'displayUrl': displayUrl,
      'predictedClass': predictedClass.wireName,
      'riskScore': riskScore,
      'modelVersion': modelVersion,
    };
  }

  static double _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
