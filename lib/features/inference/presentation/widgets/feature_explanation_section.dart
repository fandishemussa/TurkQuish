import 'package:flutter/material.dart';

import '../../../../core/widgets/feature_chip.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/entities/top_feature.dart';

class FeatureExplanationSection extends StatelessWidget {
  const FeatureExplanationSection({super.key, required this.features});

  final List<TopFeature> features;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final grouped = <FeatureGroup, List<TopFeature>>{};
    for (final feature in features) {
      grouped.putIfAbsent(feature.group, () => []).add(feature);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.text('topContributingUrlFeatures'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (features.isEmpty)
              Text(strings.text('noFeatureAttribution'))
            else
              for (final entry in grouped.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    strings.featureGroup(entry.key),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final feature in entry.value)
                      FeatureChip(
                        group: entry.key,
                        label:
                            '${strings.featureDisplayName(feature)} '
                            '(${feature.impact.toStringAsFixed(2)}, '
                            '${strings.featureDirection(feature.direction)})',
                      ),
                  ],
                ),
              ],
          ],
        ),
      ),
    );
  }
}
