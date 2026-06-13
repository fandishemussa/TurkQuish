import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../l10n/app_strings.dart';

class RiskGauge extends StatelessWidget {
  const RiskGauge({super.key, required this.score, this.height = 14});

  final double score;
  final double height;

  Color get _color {
    if (score >= 0.75) {
      return AppColors.dangerRed;
    }
    if (score >= 0.45) {
      return AppColors.cautionOrange;
    }
    if (score >= 0.25) {
      return AppColors.cyan;
    }
    return AppColors.safeGreen;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final clamped = score.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(strings.text('riskScore')),
            Text(
              clamped.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: LinearProgressIndicator(
            minHeight: height,
            value: clamped,
            color: _color,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
