import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turkquish/features/inference/domain/entities/prediction_class.dart';
import 'package:turkquish/features/inference/domain/entities/prediction_result.dart';
import 'package:turkquish/features/inference/domain/entities/risk_level.dart';
import 'package:turkquish/features/inference/domain/entities/top_feature.dart';
import 'package:turkquish/features/inference/presentation/result_screen.dart';
import 'package:turkquish/l10n/app_strings.dart';

void main() {
  testWidgets('ResultScreen renders prediction details', (tester) async {
    await _pumpResultScreen(tester);

    expect(find.text('Scan report'), findsOneWidget);
    expect(find.text('Phishing'), findsWidgets);
    expect(find.text('Risk score'), findsOneWidget);
    expect(find.text('Use caution'), findsNothing);
    expect(find.text('Block'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Class probabilities'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Class probabilities'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Explanation'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Explanation'), findsOneWidget);
  });

  testWidgets('ResultScreen renders Turkish labels', (tester) async {
    await _pumpResultScreen(tester, locale: const Locale('tr'));

    expect(find.text('Tarama raporu'), findsOneWidget);
    expect(find.text('Kimlik avı'), findsWidgets);
    expect(find.text('Risk skoru'), findsOneWidget);
    expect(find.text('Engelle'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Marka taklidi'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Marka taklidi'), findsOneWidget);
    expect(find.text('Marka riski: Orta risk'), findsOneWidget);
    expect(find.text('Marka alt alanda'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Sınıf olasılıkları'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Sınıf olasılıkları'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('En çok katkı yapan URL özellikleri'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('URL uzunluğu (0.40, riski artırır)'), findsOneWidget);
  });
}

Future<void> _pumpResultScreen(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: ResultScreen(result: _sampleResult()),
    ),
  );
  await tester.pump();
}

PredictionResult _sampleResult() {
  return const PredictionResult(
    predictionId: 'p1',
    normalizedUrl: 'https://example.com/login',
    predictedClass: PredictionClass.phishing,
    riskScore: 0.92,
    riskLevel: RiskLevel.high,
    recommendedAction: RecommendedAction.block,
    threshold: 0.5,
    probabilities: {
      PredictionClass.benign: 0.08,
      PredictionClass.phishing: 0.74,
      PredictionClass.malware: 0.06,
      PredictionClass.scam: 0.09,
      PredictionClass.otherMalicious: 0.03,
    },
    explanation: LocalizedExplanation(
      en: 'The URL contains suspicious login terms.',
      tr: 'URL supheli giris terimleri iceriyor.',
    ),
    topFeatures: [
      TopFeature(
        name: 'url_len',
        displayName: 'URL length',
        group: FeatureGroup.lexicalStructural,
        value: 86,
        impact: 0.4,
        direction: 'malicious',
      ),
    ],
    modelVersion: 'histgb-v1.0.0',
    featureSchemaVersion: 'tumc-135-v1',
    latencyMs: 3,
    brandSignals: BrandSignals(
      impersonationDetected: true,
      risk: 'medium',
      score: 3,
      registeredDomainLabel: 'example',
      detectedBrands: ['garanti'],
      signals: ['brand_in_subdomain'],
      explanation: LocalizedExplanation(
        en: 'The URL mentions a brand in a suspicious location.',
        tr: 'URL markayı şüpheli bir konumda kullanıyor.',
      ),
    ),
  );
}
