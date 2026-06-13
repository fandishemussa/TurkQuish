import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../features/inference/domain/entities/prediction_class.dart';
import '../../features/inference/domain/entities/risk_level.dart';
import '../../l10n/app_strings.dart';

class RiskTone {
  const RiskTone({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;
}

RiskTone riskToneFor({
  required PredictionClass predictedClass,
  required RiskLevel riskLevel,
  required double riskScore,
}) {
  if (predictedClass == PredictionClass.benign && riskScore < 0.4) {
    return const RiskTone(
      color: AppColors.safeGreen,
      icon: Icons.verified_user_outlined,
      label: 'Benign',
    );
  }
  return switch (riskLevel) {
    RiskLevel.low => const RiskTone(
      color: AppColors.cyan,
      icon: Icons.info_outline,
      label: 'Low risk',
    ),
    RiskLevel.medium => const RiskTone(
      color: AppColors.cautionOrange,
      icon: Icons.warning_amber_rounded,
      label: 'Medium risk',
    ),
    RiskLevel.high || RiskLevel.critical => const RiskTone(
      color: AppColors.dangerRed,
      icon: Icons.gpp_bad_outlined,
      label: 'High risk',
    ),
    RiskLevel.unknown => const RiskTone(
      color: AppColors.neutral,
      icon: Icons.help_outline,
      label: 'Unknown risk',
    ),
  };
}

class RiskBadge extends StatelessWidget {
  const RiskBadge({
    super.key,
    required this.predictedClass,
    required this.riskLevel,
    required this.riskScore,
  });

  final PredictionClass predictedClass;
  final RiskLevel riskLevel;
  final double riskScore;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final tone = riskToneFor(
      predictedClass: predictedClass,
      riskLevel: riskLevel,
      riskScore: riskScore,
    );
    return Chip(
      avatar: Icon(tone.icon, color: tone.color, size: 20),
      label: Text(
        strings.riskTone(
          predictedClass: predictedClass,
          riskLevel: riskLevel,
          riskScore: riskScore,
        ),
      ),
      side: BorderSide(color: tone.color.withValues(alpha: 0.35)),
      backgroundColor: tone.color.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: tone.color, fontWeight: FontWeight.w700),
    );
  }
}
