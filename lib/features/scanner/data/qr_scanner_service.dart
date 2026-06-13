class QrScannerService {
  const QrScannerService();

  String? firstUsablePayload(Iterable<String?> payloads) {
    for (final payload in payloads) {
      final trimmed = payload?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }
}
