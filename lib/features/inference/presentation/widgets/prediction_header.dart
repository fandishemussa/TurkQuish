import 'package:flutter/material.dart';

import '../../../../core/widgets/risk_badge.dart';
import '../../../../core/widgets/risk_gauge.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/entities/prediction_result.dart';

class PredictionHeader extends StatelessWidget {
  const PredictionHeader({super.key, required this.result});

  final PredictionResult result;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final tone = riskToneFor(
      predictedClass: result.predictedClass,
      riskLevel: result.riskLevel,
      riskScore: result.riskScore,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: tone.color.withValues(alpha: 0.13),
                  child: Icon(tone.icon, color: tone.color, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.predictionClass(result.predictedClass),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      RiskBadge(
                        predictedClass: result.predictedClass,
                        riskLevel: result.riskLevel,
                        riskScore: result.riskScore,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            RiskGauge(score: result.riskScore),
            const SizedBox(height: 12),
            Text(
              strings.text('probabilisticNotice'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
