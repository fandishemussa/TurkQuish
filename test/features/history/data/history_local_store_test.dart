import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turkquish/features/history/data/history_local_store.dart';
import 'package:turkquish/features/inference/domain/entities/prediction_class.dart';
import 'package:turkquish/features/inference/domain/entities/prediction_result.dart';
import 'package:turkquish/features/inference/domain/entities/risk_level.dart';

void main() {
  test('stores only domain or masked URL history by default', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = HistoryLocalStore(preferences);

    await store.addFromPrediction(
      result: _sampleResult(),
      submittedUrl: 'https://example.com/login?token=secret',
      enabled: true,
      maskQuery: true,
    );

    expect(store.items, hasLength(1));
    expect(store.items.single.displayUrl, 'example.com');
    expect(
      preferences.getStringList('history.items').toString(),
      isNot(contains('secret')),
    );
  });

  test('does not write history when disabled', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = HistoryLocalStore(preferences);

    await store.addFromPrediction(
      result: _sampleResult(),
      submittedUrl: 'https://example.com/login',
      enabled: false,
      maskQuery: true,
    );

    expect(store.items, isEmpty);
  });

  test('deletes a single history item', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = HistoryLocalStore(preferences);

    await store.addFromPrediction(
      result: _sampleResult(id: 'p1', domain: 'one.example'),
      submittedUrl: 'https://one.example/login',
      enabled: true,
      maskQuery: true,
    );
    await store.addFromPrediction(
      result: _sampleResult(id: 'p2', domain: 'two.example'),
      submittedUrl: 'https://two.example/login',
      enabled: true,
      maskQuery: true,
    );

    await store.delete('p1');

    expect(store.items, hasLength(1));
    expect(store.items.single.id, 'p2');
    expect(
      preferences.getStringList('history.items').toString(),
      isNot(contains('p1')),
    );
  });
}

PredictionResult _sampleResult({
  String id = 'p1',
  String domain = 'example.com',
}) {
  return PredictionResult(
    predictionId: id,
    normalizedUrl: 'https://example.com/login',
    domain: domain,
    predictedClass: PredictionClass.phishing,
    riskScore: 0.9,
    riskLevel: RiskLevel.high,
    recommendedAction: RecommendedAction.block,
    threshold: 0.5,
    probabilities: {
      PredictionClass.benign: 0.1,
      PredictionClass.phishing: 0.8,
      PredictionClass.malware: 0.04,
      PredictionClass.scam: 0.03,
      PredictionClass.otherMalicious: 0.03,
    },
    explanation: LocalizedExplanation(en: 'Suspicious.', tr: 'Supheli.'),
    topFeatures: [],
    modelVersion: 'histgb-v1.0.0',
    featureSchemaVersion: 'tumc-135-v1',
    latencyMs: 3,
  );
}
