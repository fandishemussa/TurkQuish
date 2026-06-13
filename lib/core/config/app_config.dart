import 'package:flutter_riverpod/flutter_riverpod.dart';

final appConfigProvider = Provider<AppConfig>(
  (_) => AppConfig.fromEnvironment(),
);

class AppConfig {
  const AppConfig({required this.apiBaseUrl, this.appVersion = '1.0.0'});

  factory AppConfig.fromEnvironment() {
    return const AppConfig(apiBaseUrl: String.fromEnvironment('API_BASE_URL'));
  }

  final String apiBaseUrl;
  final String appVersion;

  bool get hasApiBaseUrl => apiBaseUrl.trim().isNotEmpty;
  bool get usesHttps => Uri.tryParse(apiBaseUrl)?.scheme == 'https';
}
