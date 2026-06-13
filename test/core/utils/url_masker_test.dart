import 'package:flutter_test/flutter_test.dart';
import 'package:turkquish/core/utils/url_masker.dart';

void main() {
  test('masks query parameter values for display', () {
    final masked = UrlMasker.maskForDisplay(
      'https://example.com/login?token=secret&user=ali',
    );

    expect(masked, 'https://example.com/login?token=***&user=***');
    expect(masked, isNot(contains('secret')));
  });

  test('uses domain for privacy-preserving history', () {
    expect(
      UrlMasker.domainOrMasked('https://sub.example.com/path?x=1'),
      'sub.example.com',
    );
  });
}
