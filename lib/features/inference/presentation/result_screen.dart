import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/url_masker.dart';
import '../../../core/widgets/probability_bar.dart';
import '../../../l10n/app_strings.dart';
import '../../feedback/presentation/feedback_sheet.dart';
import '../domain/entities/prediction_class.dart';
import '../domain/entities/prediction_result.dart';
import '../domain/entities/risk_level.dart';
import 'widgets/brand_signals_card.dart';
import 'widgets/explanation_tabs.dart';
import 'widgets/feature_explanation_section.dart';
import 'widgets/model_info_card.dart';
import 'widgets/prediction_header.dart';
import 'widgets/recommended_action_card.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final PredictionResult result;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => _goBack(context)),
        title: Text(strings.text('scanReport')),
        actions: [
          IconButton(
            tooltip: strings.text('history'),
            onPressed: () => context.push('/history'),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: strings.text('settings'),
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PredictionHeader(result: result),
            const SizedBox(height: 12),
            RecommendedActionCard(action: result.recommendedAction),
            const SizedBox(height: 12),
            _UrlCard(result: result, isMalicious: result.isPredictedMalicious),
            if (result.brandSignals != null) ...[
              const SizedBox(height: 12),
              BrandSignalsCard(signals: result.brandSignals!),
            ],
            const SizedBox(height: 12),
            _ProbabilityCard(result: result),
            const SizedBox(height: 12),
            ExplanationTabs(explanation: result.explanation),
            const SizedBox(height: 12),
            FeatureExplanationSection(features: result.topFeatures),
            const SizedBox(height: 12),
            ModelInfoCard(result: result),
            if (kDebugMode &&
                (result.timingMs.isNotEmpty ||
                    result.apiRequestResponseMs != null)) ...[
              const SizedBox(height: 12),
              _RuntimeTimingCard(result: result),
            ],
            const SizedBox(height: 12),
            _ModelTrustCard(result: result),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.go('/scanner'),
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(strings.text('scanAnother')),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _copyReport(context),
              icon: const Icon(Icons.description_outlined),
              label: Text(strings.text('copyReport')),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _copyJson(context),
              icon: const Icon(Icons.copy),
              label: Text(strings.text('copyJson')),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _showFeedback(context),
              icon: const Icon(Icons.feedback_outlined),
              label: Text(strings.text('reportFeedback')),
            ),
          ],
        ),
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/scanner');
  }

  Future<void> _copyJson(BuildContext context) async {
    final payload = {
      'predictionId': result.predictionId,
      'normalizedUrl': UrlMasker.maskForDisplay(result.normalizedUrl),
      'maskedUrl': result.maskedUrl,
      'domain': result.domain,
      'predictedClass': result.predictedClass.wireName,
      'riskScore': result.riskScore,
      'riskLevel': result.riskLevel.wireName,
      'recommendedAction': result.recommendedAction.wireName,
      'decisionSource': result.decisionSource,
      'urlOnly': result.urlOnly,
      'modelVersion': result.modelVersion,
      'featureSchemaVersion': result.featureSchemaVersion,
      'timingMs': result.timingMs,
      'apiRequestResponseMs': result.apiRequestResponseMs,
      'brandSignals': result.brandSignals == null
          ? null
          : {
              'impersonationDetected':
                  result.brandSignals!.impersonationDetected,
              'risk': result.brandSignals!.risk,
              'score': result.brandSignals!.score,
              'detectedBrands': result.brandSignals!.detectedBrands,
              'signals': result.brandSignals!.signals,
            },
    };
    final text = const JsonEncoder.withIndent('  ').convert(payload);
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).text('resultCopied'))),
      );
    }
  }

  Future<void> _copyReport(BuildContext context) async {
    final strings = AppStrings.of(context);
    await Clipboard.setData(
      ClipboardData(text: _reportText(strings, DateTime.now())),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.text('reportCopied'))));
    }
  }

  String _reportText(AppStrings strings, DateTime generatedAt) {
    final buffer = StringBuffer()
      ..writeln('TurkQuish ${strings.text('scanReport')}')
      ..writeln(
        '${strings.text('status')}: ${strings.predictionClass(result.predictedClass)}',
      )
      ..writeln(
        '${strings.text('riskScore')}: ${result.riskScore.toStringAsFixed(3)}',
      )
      ..writeln(
        '${strings.text('decisionThreshold')}: ${result.threshold.toStringAsFixed(2)}',
      )
      ..writeln(
        '${strings.text('recommendedActionLabel')}: ${strings.recommendedAction(result.recommendedAction)}',
      )
      ..writeln('${strings.text('host')}: ${result.domain}')
      ..writeln(
        '${strings.text('maskedUrl')}: ${result.maskedUrl.isNotEmpty ? result.maskedUrl : UrlMasker.maskForDisplay(result.normalizedUrl)}',
      )
      ..writeln('${strings.text('modelVersion')}: ${result.modelVersion}')
      ..writeln(
        '${strings.text('featureSchema')}: ${result.featureSchemaVersion}',
      )
      ..writeln('${strings.text('inferenceLatency')}: ${result.latencyMs} ms')
      ..writeln('${strings.text('appVersion')}: 1.0.0')
      ..writeln(
        '${strings.text('generatedAt')}: ${generatedAt.toUtc().toIso8601String()}',
      )
      ..writeln()
      ..writeln('${strings.text('explanation')}:')
      ..writeln(result.explanation.forLanguage(strings.locale.languageCode));
    if (result.topFeatures.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('${strings.text('topContributingUrlFeatures')}:');
      for (final feature in result.topFeatures) {
        buffer.writeln(
          '- ${strings.featureDisplayName(feature)} '
          '(${feature.impact.toStringAsFixed(2)}, '
          '${strings.featureDirection(feature.direction)})',
        );
      }
    }
    return buffer.toString();
  }

  Future<void> _showFeedback(BuildContext context) async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FeedbackSheet(predictionId: result.predictionId),
    );
    if (sent == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).text('feedbackSent'))),
      );
    }
  }
}

class _UrlCard extends StatelessWidget {
  const _UrlCard({required this.result, required this.isMalicious});

  final PredictionResult result;
  final bool isMalicious;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.text('urlSummary'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            _UrlInfoRow(
              label: strings.text('maskedUrl'),
              value: result.maskedUrl.isNotEmpty
                  ? result.maskedUrl
                  : UrlMasker.maskForDisplay(result.normalizedUrl),
            ),
            if (result.domain.isNotEmpty)
              _UrlInfoRow(label: strings.text('host'), value: result.domain),
            _UrlInfoRow(
              label: strings.text('normalizedUrl'),
              value: UrlMasker.maskForDisplay(result.normalizedUrl),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _confirmOpen(context),
              icon: const Icon(Icons.open_in_new),
              label: Text(
                isMalicious
                    ? strings.text('openUrlWithConfirmation')
                    : strings.text('openUrl'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOpen(BuildContext context) async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          isMalicious ? Icons.gpp_bad_outlined : Icons.open_in_new,
          color: isMalicious ? Theme.of(context).colorScheme.error : null,
        ),
        title: Text(strings.text('safetyCheck')),
        content: Text(
          isMalicious
              ? strings.text('highRiskOpenMessage')
              : strings.text('safeOpenMessage'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.text('cancel')),
          ),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: result.normalizedUrl),
              );
              if (context.mounted) {
                Navigator.of(context).pop(false);
              }
            },
            child: Text(strings.text('copyUrl')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              isMalicious ? strings.text('openAnyway') : strings.text('open'),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    final uri = Uri.tryParse(result.normalizedUrl);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ModelTrustCard extends StatelessWidget {
  const _ModelTrustCard({required this.result});

  final PredictionResult result;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.text('modelTrust'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(strings.text('modelTrustBody')),
            const SizedBox(height: 8),
            Text(strings.text('probabilisticNotice')),
            const SizedBox(height: 8),
            Text(
              '${strings.text('decisionThreshold')}: '
              '${result.threshold.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuntimeTimingCard extends StatelessWidget {
  const _RuntimeTimingCard({required this.result});

  final PredictionResult result;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, double)>[
      if (result.apiRequestResponseMs != null)
        ('API request-response', result.apiRequestResponseMs!),
      ('Backend latency', result.latencyMs.toDouble()),
      if (_timing('total_backend') != null)
        ('Backend total', _timing('total_backend')!),
      if (_timing('feature_extraction') != null)
        ('Feature extraction', _timing('feature_extraction')!),
      if (_timing('histgb_inference') != null)
        ('HistGB inference', _timing('histgb_inference')!),
      if (_timing('url_transformer_inference') != null)
        ('URL Transformer inference', _timing('url_transformer_inference')!),
      if (_timing('decision_fusion') != null)
        ('Decision fusion', _timing('decision_fusion')!),
    ];
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Runtime timing',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 180,
                      child: Text(
                        row.$1,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Expanded(
                      child: SelectableText('${row.$2.toStringAsFixed(4)} ms'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  double? _timing(String key) => result.timingMs[key];
}

class _UrlInfoRow extends StatelessWidget {
  const _UrlInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          SelectableText(value),
        ],
      ),
    );
  }
}

class _ProbabilityCard extends StatelessWidget {
  const _ProbabilityCard({required this.result});

  final PredictionResult result;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.text('classProbabilities'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final predictionClass in PredictionClass.values)
              ProbabilityBar(
                label: strings.predictionClass(predictionClass),
                value: result.probabilities[predictionClass] ?? 0,
              ),
          ],
        ),
      ),
    );
  }
}
