import '../../domain/entities/prediction_class.dart';
import '../../domain/entities/prediction_result.dart';
import '../../domain/entities/risk_level.dart';
import '../../domain/entities/top_feature.dart';

class PredictionResponseDto {
  const PredictionResponseDto({
    required this.predictionId,
    required this.normalizedUrl,
    required this.maskedUrl,
    required this.domain,
    required this.predictedClass,
    required this.riskScore,
    required this.riskLevel,
    required this.recommendedAction,
    required this.threshold,
    required this.probabilities,
    required this.explanation,
    required this.topFeatures,
    required this.modelVersion,
    required this.featureSchemaVersion,
    required this.latencyMs,
    required this.timingMs,
    required this.urlOnly,
    required this.decisionSource,
    required this.primaryModel,
    required this.fallbackModel,
    required this.uncertainty,
    required this.brandSignals,
    required this.brandImpersonation,
  });

  final String predictionId;
  final String normalizedUrl;
  final String maskedUrl;
  final String domain;
  final PredictionClass predictedClass;
  final double riskScore;
  final RiskLevel riskLevel;
  final RecommendedAction recommendedAction;
  final double threshold;
  final Map<PredictionClass, double> probabilities;
  final LocalizedExplanation explanation;
  final List<TopFeature> topFeatures;
  final String modelVersion;
  final String featureSchemaVersion;
  final int latencyMs;
  final Map<String, double> timingMs;
  final bool urlOnly;
  final String decisionSource;
  final ModelDecision primaryModel;
  final ModelDecision? fallbackModel;
  final Map<String, Object?> uncertainty;
  final BrandSignals? brandSignals;
  final BrandImpersonation? brandImpersonation;

  factory PredictionResponseDto.fromJson(Map<String, dynamic> json) {
    final probabilitiesJson = _asMap(json['probabilities']);
    final explanationJson = _asMap(json['explanation']);
    final topFeaturesJson = json['topFeatures'];

    if (json['predictionId'] == null || json['normalizedUrl'] == null) {
      throw const FormatException(
        'Prediction response is missing required identifiers.',
      );
    }

    return PredictionResponseDto(
      predictionId: json['predictionId'].toString(),
      normalizedUrl: json['normalizedUrl'].toString(),
      maskedUrl:
          json['maskedUrl']?.toString() ?? json['normalizedUrl'].toString(),
      domain: json['domain']?.toString() ?? '',
      predictedClass: predictionClassFromJson(json['predictedClass']),
      riskScore: _asDouble(json['riskScore']),
      riskLevel: riskLevelFromJson(json['riskLevel']),
      recommendedAction: recommendedActionFromJson(json['recommendedAction']),
      threshold: _asDouble(json['threshold'], fallback: 0.5),
      probabilities: {
        for (final predictionClass in PredictionClass.values)
          predictionClass: _asDouble(
            probabilitiesJson[predictionClass.wireName],
          ),
      },
      explanation: LocalizedExplanation(
        en:
            explanationJson['en']?.toString() ??
            'No English explanation was provided.',
        tr: explanationJson['tr']?.toString() ?? 'Türkçe açıklama sağlanmadı.',
      ),
      topFeatures: topFeaturesJson is List
          ? topFeaturesJson
                .whereType<Map>()
                .map(
                  (value) =>
                      TopFeature.fromJson(Map<String, dynamic>.from(value)),
                )
                .toList()
          : const [],
      modelVersion: json['modelVersion']?.toString() ?? 'unknown',
      featureSchemaVersion:
          json['featureSchemaVersion']?.toString() ?? 'unknown',
      latencyMs: _asInt(json['latencyMs']),
      timingMs: _asStringDoubleMap(json['timingMs']),
      urlOnly: _asBool(json['urlOnly'], fallback: true),
      decisionSource: json['decisionSource']?.toString() ?? 'unknown',
      primaryModel: _modelDecisionFromJson(
        _asMap(json['primaryModel']),
        fallbackName: 'unknown',
      ),
      fallbackModel: json['fallbackModel'] is Map
          ? _modelDecisionFromJson(_asMap(json['fallbackModel']))
          : null,
      uncertainty: _asObjectMap(json['uncertainty']),
      brandSignals: json['brandSignals'] is Map
          ? _brandSignalsFromJson(_asMap(json['brandSignals']))
          : null,
      brandImpersonation: _brandImpersonationJson(json) is Map
          ? _brandImpersonationFromJson(_asMap(_brandImpersonationJson(json)))
          : null,
    );
  }

  PredictionResult toDomain({double? apiRequestResponseMs}) {
    return PredictionResult(
      predictionId: predictionId,
      normalizedUrl: normalizedUrl,
      maskedUrl: maskedUrl,
      domain: domain,
      predictedClass: predictedClass,
      riskScore: riskScore,
      riskLevel: riskLevel,
      recommendedAction: recommendedAction,
      threshold: threshold,
      probabilities: probabilities,
      explanation: explanation,
      topFeatures: topFeatures,
      modelVersion: modelVersion,
      featureSchemaVersion: featureSchemaVersion,
      latencyMs: latencyMs,
      timingMs: timingMs,
      apiRequestResponseMs: apiRequestResponseMs,
      urlOnly: urlOnly,
      decisionSource: decisionSource,
      primaryModel: primaryModel,
      fallbackModel: fallbackModel,
      uncertainty: uncertainty,
      brandSignals: brandSignals,
      brandImpersonation: brandImpersonation,
    );
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const {};
  }

  static Map<String, Object?> _asObjectMap(Object? value) {
    if (value is Map) {
      return Map<String, Object?>.from(value);
    }
    return const {};
  }

  static ModelDecision _modelDecisionFromJson(
    Map<String, dynamic> json, {
    String fallbackName = 'unknown',
  }) {
    return ModelDecision(
      name: json['name']?.toString() ?? fallbackName,
      used: _asBool(json['used'], fallback: true),
      confidence: json.containsKey('confidence')
          ? _asDouble(json['confidence'])
          : null,
      margin: json.containsKey('margin') ? _asDouble(json['margin']) : null,
      probabilities: _asStringDoubleMap(json['probabilities']),
    );
  }

  static BrandSignals _brandSignalsFromJson(Map<String, dynamic> json) {
    final explanationJson = _asMap(json['explanation']);
    return BrandSignals(
      impersonationDetected: _asBool(json['impersonationDetected']),
      risk: json['risk']?.toString() ?? 'low',
      score: _asDouble(json['score']),
      registeredDomainLabel: json['registeredDomainLabel']?.toString(),
      suffix: json['suffix']?.toString(),
      detectedBrands: _asStringList(json['detectedBrands']),
      domainBrands: _asStringList(json['domainBrands']),
      subdomainBrands: _asStringList(json['subdomainBrands']),
      pathBrands: _asStringList(json['pathBrands']),
      similarBrands: json['similarBrands'] is List
          ? (json['similarBrands'] as List)
                .whereType<Map>()
                .map(
                  (value) =>
                      _similarBrandFromJson(Map<String, dynamic>.from(value)),
                )
                .toList()
          : const [],
      signals: _asStringList(json['signals']),
      explanation: LocalizedExplanation(
        en: explanationJson['en']?.toString() ?? '',
        tr: explanationJson['tr']?.toString() ?? '',
      ),
      urlOnly: _asBool(json['urlOnly'], fallback: true),
      method: json['method']?.toString() ?? '',
    );
  }

  static SimilarBrandMatch _similarBrandFromJson(Map<String, dynamic> json) {
    return SimilarBrandMatch(
      brand: json['brand']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      editDistance: _asInt(json['editDistance']),
      similarity: _asDouble(json['similarity']),
      location: json['location']?.toString() ?? 'unknown',
    );
  }

  static Object? _brandImpersonationJson(Map<String, dynamic> json) {
    return json['brand_impersonation'] ?? json['brandImpersonation'];
  }

  static BrandImpersonation _brandImpersonationFromJson(
    Map<String, dynamic> json,
  ) {
    return BrandImpersonation(
      detected: _asBool(json['detected']),
      entity: json['entity']?.toString(),
      category: json['category']?.toString(),
      matchedAlias:
          json['matched_alias']?.toString() ?? json['matchedAlias']?.toString(),
      officialDomains: _asStringList(
        json['official_domains'] ?? json['officialDomains'],
      ),
      observedDomain:
          json['observed_domain']?.toString() ??
          json['observedDomain']?.toString() ??
          '',
      confidence: json['confidence']?.toString() ?? 'none',
      reason: json['reason']?.toString(),
    );
  }

  static Map<String, double> _asStringDoubleMap(Object? value) {
    final map = _asMap(value);
    return {for (final entry in map.entries) entry.key: _asDouble(entry.value)};
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
    if (value is num) {
      return value != 0;
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

  static double _asDouble(Object? value, {double fallback = 0}) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int _asInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
