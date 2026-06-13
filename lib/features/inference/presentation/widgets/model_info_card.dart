import 'package:flutter/material.dart';

import '../../../../l10n/app_strings.dart';
import '../../domain/entities/prediction_result.dart';

class ModelInfoCard extends StatelessWidget {
  const ModelInfoCard({super.key, required this.result});

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
              strings.text('modelInformation'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: strings.text('decisionSource'),
              value: _formatKey(result.decisionSource),
            ),
            _InfoRow(
              label: strings.text('urlOnly'),
              value: result.urlOnly ? strings.text('yes') : strings.text('no'),
            ),
            _InfoRow(
              label: strings.text('modelVersion'),
              value: result.modelVersion,
            ),
            _InfoRow(
              label: strings.text('featureSchema'),
              value: result.featureSchemaVersion,
            ),
            _InfoRow(
              label: strings.text('inferenceLatency'),
              value: '${result.latencyMs} ms',
            ),
            _InfoRow(
              label: strings.text('decisionThreshold'),
              value: result.threshold.toStringAsFixed(2),
            ),
            _InfoRow(
              label: strings.text('primaryModel'),
              value: _modelSummary(result.primaryModel, strings),
            ),
            if (result.fallbackModel != null)
              _InfoRow(
                label: strings.text('fallbackModel'),
                value: _modelSummary(result.fallbackModel!, strings),
              ),
            if (result.uncertainty.isNotEmpty)
              _InfoRow(
                label: strings.text('uncertainty'),
                value: _uncertaintySummary(result.uncertainty),
              ),
          ],
        ),
      ),
    );
  }

  String _modelSummary(ModelDecision model, AppStrings strings) {
    final parts = <String>[
      model.name,
      model.used ? strings.text('modelUsed') : strings.text('modelNotUsed'),
    ];
    if (model.confidence != null) {
      parts.add(
        '${strings.text('confidence')} ${model.confidence!.toStringAsFixed(3)}',
      );
    }
    if (model.margin != null) {
      parts.add(
        '${strings.text('margin')} ${model.margin!.toStringAsFixed(3)}',
      );
    }
    return parts.join(' - ');
  }

  String _uncertaintySummary(Map<String, Object?> uncertainty) {
    return uncertainty.entries
        .map((entry) => '${_formatKey(entry.key)}: ${entry.value}')
        .join(', ');
  }

  String _formatKey(String value) {
    return value
        .replaceAll('_', ' ')
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        )
        .trim();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
