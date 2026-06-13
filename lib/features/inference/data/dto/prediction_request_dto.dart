class PredictionRequestDto {
  const PredictionRequestDto({
    required this.decodedUrl,
    required this.clientTimestamp,
    required this.locale,
    required this.appVersion,
  });

  final String decodedUrl;
  final DateTime clientTimestamp;
  final String locale;
  final String appVersion;

  Map<String, dynamic> toJson() {
    return {
      'decodedUrl': decodedUrl,
      'clientTimestamp': clientTimestamp.toUtc().toIso8601String(),
      'locale': locale,
      'appVersion': appVersion,
    };
  }
}
