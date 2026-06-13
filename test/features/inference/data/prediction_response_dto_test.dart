import 'package:flutter_test/flutter_test.dart';
import 'package:turkquish/features/inference/data/dto/prediction_response_dto.dart';
import 'package:turkquish/features/inference/domain/entities/prediction_class.dart';
import 'package:turkquish/features/inference/domain/entities/risk_level.dart';

void main() {
  test('parses complete prediction response', () {
    final result = PredictionResponseDto.fromJson({
      'predictionId': 'abc',
      'normalizedUrl': 'https://example.com/login',
      'maskedUrl': 'https://example.com/login?token=***',
      'domain': 'example.com',
      'predictedClass': 'phishing',
      'riskScore': 0.92,
      'riskLevel': 'high',
      'recommendedAction': 'block',
      'threshold': 0.5,
      'probabilities': {
        'benign': 0.08,
        'phishing': 0.74,
        'malware': 0.06,
        'scam': 0.09,
        'other_malicious': 0.03,
      },
      'explanation': {'en': 'Suspicious URL.', 'tr': 'Supheli URL.'},
      'topFeatures': [
        {
          'name': 'contains_login_keyword',
          'displayName': 'Login keyword',
          'displayNameLocalized': {
            'en': 'Login keyword',
            'tr': 'Giriş anahtar kelimesi',
          },
          'group': 'lexical',
          'value': 1,
          'impact': 0.31,
          'direction': 'malicious',
        },
      ],
      'modelVersion': 'histgb-v1.0.0',
      'featureSchemaVersion': 'tumc-135-v1',
      'latencyMs': 3,
      'timingMs': {
        'total_backend': 3.4,
        'histgb_inference': 0.2,
        'decision_fusion': 0.1,
      },
      'urlOnly': true,
      'decisionSource': 'histgb_urltransformer_agreement',
      'primaryModel': {
        'name': 'HistGB',
        'used': true,
        'confidence': 0.74,
        'margin': 0.65,
        'probabilities': {'benign': 0.08, 'phishing': 0.74},
      },
      'fallbackModel': {
        'name': 'URL-Transformer',
        'used': true,
        'probabilities': {'benign': 0.12, 'phishing': 0.70},
      },
      'uncertainty': {
        'lowConfidence': false,
        'brandImpersonationDetected': true,
      },
      'brandSignals': {
        'impersonationDetected': true,
        'risk': 'medium',
        'score': 3.0,
        'registeredDomainLabel': 'example',
        'suffix': 'com',
        'detectedBrands': ['garanti'],
        'domainBrands': [],
        'subdomainBrands': [],
        'pathBrands': ['garanti'],
        'similarBrands': [
          {
            'brand': 'garanti',
            'token': 'garantii',
            'editDistance': 1,
            'similarity': 0.875,
            'location': 'domain',
          },
        ],
        'signals': ['levenshtein_brand_lookalike'],
        'explanation': {'en': 'Brand lookalike.', 'tr': 'Marka benzeri.'},
        'urlOnly': true,
        'method': 'brand_rules_plus_levenshtein_edit_distance',
      },
      'brand_impersonation': {
        'detected': true,
        'entity': 'Garanti BBVA',
        'category': 'bank',
        'matched_alias': 'garanti',
        'official_domains': ['garanti.com.tr'],
        'observed_domain': 'garanti-guvenli.com',
        'confidence': 'critical',
        'reason': 'Protected entity alias appears in an unofficial domain.',
      },
    }).toDomain();

    expect(result.maskedUrl, 'https://example.com/login?token=***');
    expect(result.domain, 'example.com');
    expect(result.predictedClass, PredictionClass.phishing);
    expect(result.riskLevel, RiskLevel.high);
    expect(result.probabilities[PredictionClass.phishing], 0.74);
    expect(result.topFeatures.single.displayName, 'Login keyword');
    expect(result.topFeatures.single.displayNameTr, 'Giriş anahtar kelimesi');
    expect(result.decisionSource, 'histgb_urltransformer_agreement');
    expect(result.timingMs['total_backend'], 3.4);
    expect(result.timingMs['histgb_inference'], 0.2);
    expect(result.primaryModel.name, 'HistGB');
    expect(result.fallbackModel?.name, 'URL-Transformer');
    expect(result.brandSignals?.impersonationDetected, isTrue);
    expect(result.brandSignals?.similarBrands.single.brand, 'garanti');
    expect(result.brandImpersonation?.detected, isTrue);
    expect(result.brandImpersonation?.entity, 'Garanti BBVA');
    expect(result.brandImpersonation?.matchedAlias, 'garanti');
    expect(result.brandImpersonation?.officialDomains.single, 'garanti.com.tr');
  });

  test('handles unknown enum values gracefully', () {
    final result = PredictionResponseDto.fromJson({
      'predictionId': 'abc',
      'normalizedUrl': 'https://example.com',
      'predictedClass': 'brand_new_class',
      'riskScore': 0.3,
      'riskLevel': 'new_risk',
      'recommendedAction': 'new_action',
      'threshold': 0.5,
      'probabilities': {},
      'explanation': {},
      'topFeatures': [],
      'modelVersion': 'm',
      'featureSchemaVersion': 's',
      'latencyMs': 1,
    }).toDomain();

    expect(result.predictedClass, PredictionClass.otherMalicious);
    expect(result.riskLevel, RiskLevel.unknown);
    expect(result.recommendedAction, RecommendedAction.caution);
  });

  test('throws FormatException for invalid backend response', () {
    expect(
      () => PredictionResponseDto.fromJson({
        'predictionId': 'missing-normalized-url',
      }),
      throwsFormatException,
    );
  });
}
