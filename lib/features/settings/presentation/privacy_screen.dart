import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/app_strings.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.text('privacyDetails')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: strings.text('back'),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PrivacyCard(
              icon: Icons.link_outlined,
              title: strings.text('urlOnlyPrivacyTitle'),
              body: strings.text('urlOnlyPrivacyBody'),
            ),
            _PrivacyCard(
              icon: Icons.cloud_upload_outlined,
              title: strings.text('sentToBackend'),
              body: strings.text('sentToBackendBody'),
            ),
            _PrivacyCard(
              icon: Icons.block,
              title: strings.text('neverPerformedTitle'),
              body: strings.text('neverPerformedBody'),
            ),
            _PrivacyCard(
              icon: Icons.history_toggle_off,
              title: strings.text('localHistory'),
              body: strings.text('localHistoryBody'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.deepBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
