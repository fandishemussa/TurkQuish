import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../l10n/app_strings.dart';
import '../../history/data/history_local_store.dart';
import '../data/settings_store.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStoreProvider);
    final config = ref.watch(appConfigProvider);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.text('settings')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: strings.text('back'),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: strings.text('preferences'),
            children: [
              DropdownButtonFormField<String>(
                initialValue: settings.languageCode,
                decoration: InputDecoration(
                  labelText: strings.text('language'),
                  prefixIcon: const Icon(Icons.language),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'system',
                    child: Text(strings.text('systemDefault')),
                  ),
                  DropdownMenuItem(
                    value: 'en',
                    child: Text(strings.text('english')),
                  ),
                  DropdownMenuItem(
                    value: 'tr',
                    child: Text(strings.text('turkish')),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsStoreProvider).setLanguageCode(value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: settings.themeModeName,
                decoration: InputDecoration(
                  labelText: strings.text('settingsTheme'),
                  prefixIcon: const Icon(Icons.contrast),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'system',
                    child: Text(strings.text('system')),
                  ),
                  DropdownMenuItem(
                    value: 'light',
                    child: Text(strings.text('themeLight')),
                  ),
                  DropdownMenuItem(
                    value: 'dark',
                    child: Text(strings.text('themeDark')),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsStoreProvider).setThemeModeName(value);
                  }
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.flash_on_outlined),
                title: Text(strings.text('quickScanMode')),
                subtitle: Text(strings.text('quickScanModeBody')),
                value: settings.quickScanMode,
                onChanged: ref.read(settingsStoreProvider).setQuickScanMode,
              ),
            ],
          ),
          _Section(
            title: strings.text('privacy'),
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.history),
                title: Text(strings.text('storeLocalHistory')),
                value: settings.storeHistory,
                onChanged: ref.read(settingsStoreProvider).setStoreHistory,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.visibility_off_outlined),
                title: Text(strings.text('maskUrlQueryParameters')),
                value: settings.maskUrls,
                onChanged: ref.read(settingsStoreProvider).setMaskUrls,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(strings.text('privacyDetails')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/privacy'),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: Text(strings.text('clearHistory')),
                onPressed: () async {
                  await ref.read(historyLocalStoreProvider).clear();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.text('historyCleared'))),
                    );
                  }
                },
              ),
            ],
          ),
          _Section(
            title: strings.text('backend'),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.dns_outlined),
                title: Text(strings.text('apiBaseUrl')),
                subtitle: SelectableText(
                  config.hasApiBaseUrl
                      ? config.apiBaseUrl
                      : strings.text('missingApiBaseUrl'),
                ),
              ),
              if (config.hasApiBaseUrl && !config.usesHttps)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.warning_amber_rounded),
                  title: Text(strings.text('productionUseHttps')),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.monitor_heart_outlined),
                title: Text(strings.text('backendStatus')),
                subtitle: Text(strings.text('backendStatusBody')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/backend-status'),
              ),
            ],
          ),
          _Section(
            title: strings.text('about'),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.shield_outlined),
                title: const Text('TurkQuish'),
                subtitle: Text(strings.text('aboutDescription')),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.model_training_outlined),
                title: Text(strings.text('modelInformation')),
                subtitle: Text(strings.text('modelInfoDescription')),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline),
                title: Text(strings.text('appVersion')),
                subtitle: Text(config.appVersion),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
