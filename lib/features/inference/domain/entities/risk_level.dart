enum RiskLevel { low, medium, high, critical, unknown }

RiskLevel riskLevelFromJson(Object? value) {
  return switch (value?.toString()) {
    'low' => RiskLevel.low,
    'medium' => RiskLevel.medium,
    'high' => RiskLevel.high,
    'critical' => RiskLevel.critical,
    _ => RiskLevel.unknown,
  };
}

extension RiskLevelX on RiskLevel {
  String get wireName {
    return switch (this) {
      RiskLevel.low => 'low',
      RiskLevel.medium => 'medium',
      RiskLevel.high => 'high',
      RiskLevel.critical => 'critical',
      RiskLevel.unknown => 'unknown',
    };
  }

  String get displayName {
    return switch (this) {
      RiskLevel.low => 'Low',
      RiskLevel.medium => 'Medium',
      RiskLevel.high => 'High',
      RiskLevel.critical => 'Critical',
      RiskLevel.unknown => 'Unknown',
    };
  }
}

enum RecommendedAction { proceed, caution, block, report }

RecommendedAction recommendedActionFromJson(Object? value) {
  return switch (value?.toString()) {
    'proceed' => RecommendedAction.proceed,
    'caution' => RecommendedAction.caution,
    'block' => RecommendedAction.block,
    'report' => RecommendedAction.report,
    _ => RecommendedAction.caution,
  };
}

extension RecommendedActionX on RecommendedAction {
  String get wireName {
    return switch (this) {
      RecommendedAction.proceed => 'proceed',
      RecommendedAction.caution => 'caution',
      RecommendedAction.block => 'block',
      RecommendedAction.report => 'report',
    };
  }

  String get displayName {
    return switch (this) {
      RecommendedAction.proceed => 'Proceed',
      RecommendedAction.caution => 'Use caution',
      RecommendedAction.block => 'Block',
      RecommendedAction.report => 'Report',
    };
  }
}
