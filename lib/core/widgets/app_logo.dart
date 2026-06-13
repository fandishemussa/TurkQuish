import 'package:flutter/material.dart';

import '../../l10n/app_strings.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width = 220,
    this.height,
    this.fit = BoxFit.contain,
  });

  static const assetName = 'assets/images/turkquish.png';

  final double width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        assetName,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.high,
        semanticLabel: AppStrings.of(context).text('appLogoSemanticLabel'),
      ),
    );
  }
}
