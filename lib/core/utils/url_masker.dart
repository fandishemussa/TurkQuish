class UrlMasker {
  const UrlMasker._();

  static String maskForDisplay(String value, {bool maskQuery = true}) {
    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.host.isEmpty) {
      return _truncate(trimmed);
    }

    if (!maskQuery || uri.query.isEmpty) {
      return _truncate(uri.toString());
    }

    final maskedQuery = uri.queryParametersAll.keys
        .map((key) => '${Uri.encodeQueryComponent(key)}=***')
        .join('&');
    return _truncate(uri.replace(query: maskedQuery).toString());
  }

  static String domainOrMasked(String value, {bool maskQuery = true}) {
    final uri = Uri.tryParse(value.trim());
    if (uri != null && uri.host.isNotEmpty) {
      return uri.host.toLowerCase();
    }
    return maskForDisplay(value, maskQuery: maskQuery);
  }

  static String maskDebugValue(Object? value) {
    if (value is Map) {
      final clone = Map<Object?, Object?>.from(value);
      final decoded = clone['decodedUrl'];
      if (decoded is String) {
        clone['decodedUrl'] = maskForDisplay(decoded);
      }
      return clone.toString();
    }
    if (value is String) {
      return maskForDisplay(value);
    }
    return value.toString();
  }

  static String _truncate(String value) {
    const max = 180;
    if (value.length <= max) {
      return value;
    }
    return '${value.substring(0, max - 1)}...';
  }
}
