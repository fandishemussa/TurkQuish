import 'package:flutter_test/flutter_test.dart';
import 'package:turkquish/core/utils/url_validator.dart';

void main() {
  group('UrlValidator', () {
    test('accepts http and https URLs with hosts', () {
      final https = UrlValidator.inspect(' HTTPS://Example.COM/login ');
      final http = UrlValidator.inspect('http://example.com');

      expect(https.isValid, isTrue);
      expect(https.normalizedUrl, 'https://example.com/login');
      expect(http.isValid, isTrue);
    });

    test('rejects non-web schemes without fetching anything', () {
      for (final value in [
        'mailto:user@example.com',
        'tel:+905551112233',
        'javascript:alert(1)',
        'data:text/plain,hello',
        'ftp://example.com/file',
      ]) {
        final result = UrlValidator.inspect(value);
        expect(result.isValid, isFalse);
        expect(result.warnings, contains(UrlWarning.nonHttpScheme));
      }
    });

    test('reports missing scheme and empty host', () {
      expect(
        UrlValidator.inspect('example.com/login').warnings,
        contains(UrlWarning.missingScheme),
      );
      expect(
        UrlValidator.inspect('https:///login').warnings,
        contains(UrlWarning.emptyHost),
      );
    });
  });
}
