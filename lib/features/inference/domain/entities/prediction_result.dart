import 'prediction_class.dart';
import 'risk_level.dart';
import 'top_feature.dart';

class LocalizedExplanation {
  const LocalizedExplanation({required this.en, required this.tr});

  final String en;
  final String tr;

  String forLanguage(String languageCode) => languageCode == 'tr' ? tr : en;

  Map<String, dynamic> toJson() => {'en': en, 'tr': tr};
}

class PredictionResult {
  const PredictionResult({
    required this.predictionId,
    required this.normalizedUrl,
    this.maskedUrl = '',
    this.domain = '',
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
    this.timingMs = const {},
    this.apiRequestResponseMs,
    this.urlOnly = true,
    this.decisionSource = 'unknown',
    this.primaryModel = const ModelDecision(name: 'unknown'),
    this.fallbackModel,
    this.uncertainty = const {},
    this.brandSignals,
    this.brandImpersonation,
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
  final double? apiRequestResponseMs;
  final bool urlOnly;
  final String decisionSource;
  final ModelDecision primaryModel;
  final ModelDecision? fallbackModel;
  final Map<String, Object?> uncertainty;
  final BrandSignals? brandSignals;
  final BrandImpersonation? brandImpersonation;

  bool get isPredictedMalicious =>
      predictedClass != PredictionClass.benign || riskScore >= threshold;
}

class ModelDecision {
  const ModelDecision({
    required this.name,
    this.used = true,
    this.confidence,
    this.margin,
    this.probabilities = const {},
  });

  final String name;
  final bool used;
  final double? confidence;
  final double? margin;
  final Map<String, double> probabilities;
}

class BrandSignals {
  const BrandSignals({
    this.impersonationDetected = false,
    this.risk = 'low',
    this.score = 0,
    this.registeredDomainLabel,
    this.suffix,
    this.detectedBrands = const [],
    this.domainBrands = const [],
    this.subdomainBrands = const [],
    this.pathBrands = const [],
    this.similarBrands = const [],
    this.signals = const [],
    this.explanation = const LocalizedExplanation(en: '', tr: ''),
    this.urlOnly = true,
    this.method = '',
  });

  final bool impersonationDetected;
  final String risk;
  final double score;
  final String? registeredDomainLabel;
  final String? suffix;
  final List<String> detectedBrands;
  final List<String> domainBrands;
  final List<String> subdomainBrands;
  final List<String> pathBrands;
  final List<SimilarBrandMatch> similarBrands;
  final List<String> signals;
  final LocalizedExplanation explanation;
  final bool urlOnly;
  final String method;

  bool get hasSignals =>
      impersonationDetected ||
      detectedBrands.isNotEmpty ||
      similarBrands.isNotEmpty ||
      signals.isNotEmpty;
}

class BrandImpersonation {
  const BrandImpersonation({
    this.detected = false,
    this.entity,
    this.category,
    this.matchedAlias,
    this.officialDomains = const [],
    this.observedDomain = '',
    this.confidence = 'none',
    this.reason,
  });

  final bool detected;
  final String? entity;
  final String? category;
  final String? matchedAlias;
  final List<String> officialDomains;
  final String observedDomain;
  final String confidence;
  final String? reason;
}

class SimilarBrandMatch {
  const SimilarBrandMatch({
    required this.brand,
    required this.token,
    required this.editDistance,
    required this.similarity,
    required this.location,
  });

  final String brand;
  final String token;
  final int editDistance;
  final double similarity;
  final String location;
}
