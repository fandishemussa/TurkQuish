import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/entities/risk_level.dart';

class RecommendedActionCard extends StatelessWidget {
  const RecommendedActionCard({super.key, required this.action});

  final RecommendedAction action;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final (icon, color) = switch (action) {
      RecommendedAction.proceed => (
        Icons.check_circle_outline,
        AppColors.safeGreen,
      ),
      RecommendedAction.caution => (
        Icons.warning_amber_rounded,
        AppColors.cautionOrange,
      ),
      RecommendedAction.block => (Icons.block, AppColors.dangerRed),
      RecommendedAction.report => (
        Icons.report_gmailerrorred_outlined,
        AppColors.dangerRed,
      ),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.recommendedAction(action),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(strings.recommendedActionSummary(action)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
