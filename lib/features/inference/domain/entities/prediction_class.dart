enum PredictionClass { benign, phishing, malware, scam, otherMalicious }

PredictionClass predictionClassFromJson(Object? value) {
  return switch (value?.toString()) {
    'benign' => PredictionClass.benign,
    'phishing' => PredictionClass.phishing,
    'malware' => PredictionClass.malware,
    'scam' => PredictionClass.scam,
    'other_malicious' || 'otherMalicious' => PredictionClass.otherMalicious,
    _ => PredictionClass.otherMalicious,
  };
}

extension PredictionClassX on PredictionClass {
  String get wireName {
    return switch (this) {
      PredictionClass.benign => 'benign',
      PredictionClass.phishing => 'phishing',
      PredictionClass.malware => 'malware',
      PredictionClass.scam => 'scam',
      PredictionClass.otherMalicious => 'other_malicious',
    };
  }

  String get displayName {
    return switch (this) {
      PredictionClass.benign => 'Benign',
      PredictionClass.phishing => 'Phishing',
      PredictionClass.malware => 'Malware',
      PredictionClass.scam => 'Scam',
      PredictionClass.otherMalicious => 'Other malicious',
    };
  }
}
