import 'package:flutter_test/flutter_test.dart';
import 'package:turkquish/app/theme/app_colors.dart';
import 'package:turkquish/core/widgets/risk_badge.dart';
import 'package:turkquish/features/inference/domain/entities/prediction_class.dart';
import 'package:turkquish/features/inference/domain/entities/risk_level.dart';

void main() {
  test('maps benign low scores to safe tone', () {
    final tone = riskToneFor(
      predictedClass: PredictionClass.benign,
      riskLevel: RiskLevel.low,
      riskScore: 0.1,
    );

    expect(tone.color, AppColors.safeGreen);
    expect(tone.label, 'Benign');
  });

  test('maps high risk to danger tone', () {
    final tone = riskToneFor(
      predictedClass: PredictionClass.phishing,
      riskLevel: RiskLevel.high,
      riskScore: 0.91,
    );

    expect(tone.color, AppColors.dangerRed);
    expect(tone.label, 'High risk');
  });
}
