import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/entities/prediction_result.dart';

class BrandSignalsCard extends StatelessWidget {
  const BrandSignalsCard({super.key, required this.signals});

  final BrandSignals signals;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final color = _riskColor(signals.risk);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  signals.impersonationDetected
                      ? Icons.gpp_bad_outlined
                      : Icons.verified_user_outlined,
                  color: color,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.text('brandImpersonation'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        signals.impersonationDetected
                            ? strings.text('brandImpersonationDetected')
                            : strings.text('brandImpersonationNotDetected'),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(signals.explanation.forLanguage(strings.locale.languageCode)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(Icons.speed, color: color, size: 18),
                  label: Text(
                    '${strings.text('brandRisk')}: '
                    '${strings.brandRisk(signals.risk)}',
                  ),
                ),
                Chip(
                  avatar: Icon(Icons.percent, color: color, size: 18),
                  label: Text(
                    '${strings.text('brandScore')}: ${signals.score.toStringAsFixed(2)}',
                  ),
                ),
                if (signals.registeredDomainLabel?.isNotEmpty == true)
                  Chip(
                    avatar: const Icon(Icons.public, size: 18),
                    label: Text(
                      '${strings.text('registeredDomain')}: ${signals.registeredDomainLabel}',
                    ),
                  ),
              ],
            ),
            _ChipGroup(
              label: strings.text('detectedBrands'),
              values: signals.detectedBrands,
            ),
            _ChipGroup(
              label: strings.text('similarBrands'),
              values: [
                for (final match in signals.similarBrands)
                  '${match.token} -> ${match.brand} (${match.similarity.toStringAsFixed(2)})',
              ],
            ),
            _ChipGroup(
              label: strings.text('signals'),
              values: signals.signals.map(strings.brandSignal).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _riskColor(String risk) {
    return switch (risk.toLowerCase()) {
      'high' || 'critical' => AppColors.dangerRed,
      'medium' => AppColors.cautionOrange,
      _ => AppColors.safeGreen,
    };
  }
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({required this.label, required this.values});

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in values)
                Chip(label: Text(value, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }
}
