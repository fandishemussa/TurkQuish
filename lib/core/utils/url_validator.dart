enum UrlWarning {
  missingScheme,
  unsupportedScheme,
  emptyHost,
  nonHttpScheme,
  suspiciouslyLong,
}

class UrlValidationResult {
  const UrlValidationResult({
    required this.original,
    required this.trimmed,
    required this.isValid,
    this.normalizedUrl,
    this.host,
    this.errorMessage,
    this.warnings = const [],
  });

  final String original;
  final String trimmed;
  final bool isValid;
  final String? normalizedUrl;
  final String? host;
  final String? errorMessage;
  final List<UrlWarning> warnings;
}

class UrlValidator {
  const UrlValidator._();

  static const _acceptedSchemes = {'http', 'https'};
  static const _blockedSchemes = {
    'mailto',
    'tel',
    'sms',
    'file',
    'javascript',
    'data',
    'ftp',
  };

  static UrlValidationResult inspect(String payload) {
    final trimmed = payload.trim();
    final warnings = <UrlWarning>[];

    if (trimmed.isEmpty) {
      return UrlValidationResult(
        original: payload,
        trimmed: trimmed,
        isValid: false,
        errorMessage: 'This QR code does not contain a valid web URL.',
      );
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return UrlValidationResult(
        original: payload,
        trimmed: trimmed,
        isValid: false,
        errorMessage: 'This QR code does not contain a valid web URL.',
      );
    }

    if (uri.scheme.isEmpty) {
      warnings.add(UrlWarning.missingScheme);
      return UrlValidationResult(
        original: payload,
        trimmed: trimmed,
        isValid: false,
        errorMessage: 'Only http:// and https:// URLs can be analyzed.',
        warnings: warnings,
      );
    }

    final scheme = uri.scheme.toLowerCase();
    if (_blockedSchemes.contains(scheme) ||
        !_acceptedSchemes.contains(scheme)) {
      warnings
        ..add(UrlWarning.unsupportedScheme)
        ..add(UrlWarning.nonHttpScheme);
      return UrlValidationResult(
        original: payload,
        trimmed: trimmed,
        isValid: false,
        errorMessage: 'Only http:// and https:// URLs can be analyzed.',
        warnings: warnings,
      );
    }

    if (uri.host.trim().isEmpty) {
      warnings.add(UrlWarning.emptyHost);
      return UrlValidationResult(
        original: payload,
        trimmed: trimmed,
        isValid: false,
        errorMessage: 'The URL must include a host or domain.',
        warnings: warnings,
      );
    }

    if (trimmed.length > 2048) {
      warnings.add(UrlWarning.suspiciouslyLong);
    }

    final normalized = uri.replace(
      scheme: scheme,
      host: uri.host.toLowerCase(),
    );

    return UrlValidationResult(
      original: payload,
      trimmed: trimmed,
      isValid: true,
      normalizedUrl: normalized.toString(),
      host: normalized.host,
      warnings: warnings,
    );
  }

  static bool isValidWebUrl(String payload) => inspect(payload).isValid;
}

extension UrlWarningLabel on UrlWarning {
  String get label {
    return switch (this) {
      UrlWarning.missingScheme => 'Missing scheme',
      UrlWarning.unsupportedScheme => 'Unsupported scheme',
      UrlWarning.emptyHost => 'Empty host',
      UrlWarning.nonHttpScheme => 'Non-http/https scheme',
      UrlWarning.suspiciouslyLong => 'Suspiciously long URL',
    };
  }
}
