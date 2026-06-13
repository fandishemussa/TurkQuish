import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/url_masker.dart';
import '../../../core/utils/url_validator.dart';
import '../../../l10n/app_strings.dart';
import '../../settings/data/settings_store.dart';

class UrlPreviewScreen extends ConsumerWidget {
  const UrlPreviewScreen({super.key, required this.decodedUrl});

  final String decodedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final result = UrlValidator.inspect(decodedUrl);
    final displayUrl = UrlMasker.maskForDisplay(
      decodedUrl,
      maskQuery: settings.maskUrls,
    );
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.text('preview'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          result.isValid ? Icons.link : Icons.link_off,
                          color: result.isValid
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            result.isValid
                                ? strings.text('decodedWebUrl')
                                : strings.text('invalidQrPayload'),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SelectableText(displayUrl),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.public),
                      title: Text(strings.text('host')),
                      subtitle: Text(
                        result.host ?? strings.text('noHostDetected'),
                      ),
                    ),
                    if (result.warnings.isNotEmpty) ...[
                      const Divider(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final warning in result.warnings)
                            Chip(
                              avatar: const Icon(
                                Icons.warning_amber_rounded,
                                size: 18,
                              ),
                              label: Text(strings.urlWarning(warning)),
                            ),
                        ],
                      ),
                    ],
                    if (!result.isValid) ...[
                      const SizedBox(height: 12),
                      Text(
                        strings.validationError(result),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.privacy_tip_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        strings.text('onlyDecodedUrlSubmitted'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: result.isValid
                  ? () => context.push('/analysis', extra: result.normalizedUrl)
                  : null,
              icon: const Icon(Icons.analytics_outlined),
              label: Text(strings.text('analyzeUrl')),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: decodedUrl));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(strings.text('urlCopied'))),
                  );
                }
              },
              icon: const Icon(Icons.copy),
              label: Text(strings.text('copyUrl')),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(strings.text('cancel')),
            ),
          ],
        ),
      ),
    );
  }
}
