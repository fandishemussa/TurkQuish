enum FeatureGroup {
  lexicalStructural,
  turkishLinguistic,
  adversarialBrand,
  graphInfrastructure,
  other,
}

FeatureGroup featureGroupFromJson(Object? value) {
  final normalized = value?.toString().toLowerCase().replaceAll('-', '_') ?? '';
  return switch (normalized) {
    'lexical' ||
    'structural' ||
    'lexical_structural' => FeatureGroup.lexicalStructural,
    'turkish_linguistic' || 'turkish' => FeatureGroup.turkishLinguistic,
    'adversarial' ||
    'brand' ||
    'adversarial_brand' => FeatureGroup.adversarialBrand,
    'graph' ||
    'graph_infrastructure' ||
    'infrastructure' => FeatureGroup.graphInfrastructure,
    _ => FeatureGroup.other,
  };
}

extension FeatureGroupX on FeatureGroup {
  String get displayName {
    return switch (this) {
      FeatureGroup.lexicalStructural => 'Lexical / structural',
      FeatureGroup.turkishLinguistic => 'Turkish linguistic',
      FeatureGroup.adversarialBrand => 'Adversarial / brand',
      FeatureGroup.graphInfrastructure => 'Graph infrastructure',
      FeatureGroup.other => 'Other',
    };
  }
}

class TopFeature {
  const TopFeature({
    required this.name,
    required this.displayName,
    this.displayNameEn,
    this.displayNameTr,
    required this.group,
    required this.value,
    required this.impact,
    required this.direction,
  });

  final String name;
  final String displayName;
  final String? displayNameEn;
  final String? displayNameTr;
  final FeatureGroup group;
  final Object? value;
  final double impact;
  final String direction;

  factory TopFeature.fromJson(Map<String, dynamic> json) {
    final localizedNames = _asMap(
      json['displayNameLocalized'] ?? json['localizedDisplayName'],
    );
    final displayNameEn = localizedNames['en']?.toString();
    final displayNameTr =
        localizedNames['tr']?.toString() ?? json['displayNameTr']?.toString();
    return TopFeature(
      name: json['name']?.toString() ?? 'unknown_feature',
      displayName:
          json['displayName']?.toString() ??
          displayNameEn ??
          json['name']?.toString() ??
          'Feature',
      displayNameEn: displayNameEn,
      displayNameTr: displayNameTr,
      group: featureGroupFromJson(json['group']),
      value: json['value'],
      impact: _asDouble(json['impact']),
      direction: json['direction']?.toString() ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      if (displayNameEn != null || displayNameTr != null)
        'displayNameLocalized': {
          if (displayNameEn != null) 'en': displayNameEn,
          if (displayNameTr != null) 'tr': displayNameTr,
        },
      'group': group.displayName,
      'value': value,
      'impact': impact,
      'direction': direction,
    };
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const {};
  }

  static double _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
