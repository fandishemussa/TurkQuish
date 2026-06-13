import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../features/inference/domain/entities/top_feature.dart';

class FeatureChip extends StatelessWidget {
  const FeatureChip({super.key, required this.group, required this.label});

  final FeatureGroup group;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (group) {
      FeatureGroup.lexicalStructural => AppColors.deepBlue,
      FeatureGroup.turkishLinguistic => AppColors.safeGreen,
      FeatureGroup.adversarialBrand => AppColors.cautionOrange,
      FeatureGroup.graphInfrastructure => AppColors.indigo,
      FeatureGroup.other => AppColors.neutral,
    };
    return Chip(
      avatar: Icon(_iconFor(group), color: color, size: 18),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.11),
      side: BorderSide(color: color.withValues(alpha: 0.25)),
    );
  }

  IconData _iconFor(FeatureGroup group) {
    return switch (group) {
      FeatureGroup.lexicalStructural => Icons.link,
      FeatureGroup.turkishLinguistic => Icons.translate,
      FeatureGroup.adversarialBrand => Icons.local_offer_outlined,
      FeatureGroup.graphInfrastructure => Icons.hub_outlined,
      FeatureGroup.other => Icons.extension_outlined,
    };
  }
}
