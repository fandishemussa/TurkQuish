class BackendHealth {
  const BackendHealth({
    required this.status,
    required this.modelLoaded,
    required this.modelVersion,
    required this.featureSchemaVersion,
    required this.urlOnly,
    required this.urlTransformerAvailable,
    required this.latencyMs,
  });

  final String status;
  final bool modelLoaded;
  final String modelVersion;
  final String featureSchemaVersion;
  final bool urlOnly;
  final bool urlTransformerAvailable;
  final int latencyMs;

  bool get isOk => status.toLowerCase() == 'ok' && modelLoaded;
}

class BackendModelInfo {
  const BackendModelInfo({
    required this.modelVersion,
    required this.featureSchemaVersion,
    required this.classes,
    required this.urlOnly,
    required this.nFeatures,
    required this.urlTransformerAvailable,
  });

  final String modelVersion;
  final String featureSchemaVersion;
  final List<String> classes;
  final bool urlOnly;
  final int nFeatures;
  final bool urlTransformerAvailable;
}

class BackendStatusSnapshot {
  const BackendStatusSnapshot({required this.health, required this.modelInfo});

  final BackendHealth health;
  final BackendModelInfo modelInfo;
}
