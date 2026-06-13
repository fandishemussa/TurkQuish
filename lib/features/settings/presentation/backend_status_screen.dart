import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../features/inference/data/inference_api.dart';
import '../../../features/inference/domain/entities/backend_status.dart';
import '../../../l10n/app_strings.dart';

class BackendStatusScreen extends ConsumerStatefulWidget {
  const BackendStatusScreen({super.key});

  @override
  ConsumerState<BackendStatusScreen> createState() =>
      _BackendStatusScreenState();
}

class _BackendStatusScreenState extends ConsumerState<BackendStatusScreen> {
  late Future<BackendStatusSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<BackendStatusSnapshot> _load() {
    return ref.read(inferenceRepositoryProvider).backendStatus();
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final config = ref.watch(appConfigProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.text('backendStatus')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: strings.text('back'),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: strings.text('refresh'),
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<BackendStatusSnapshot>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final error = snapshot.error;
            if (error != null) {
              return _StatusError(
                message: error is ApiException
                    ? strings.apiFailureMessage(error)
                    : strings.text('apiFailureUnexpected'),
                onRetry: _refresh,
              );
            }
            return _StatusBody(config: config, snapshot: snapshot.requireData);
          },
        ),
      ),
    );
  }
}

class _StatusBody extends StatelessWidget {
  const _StatusBody({required this.config, required this.snapshot});

  final AppConfig config;
  final BackendStatusSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final health = snapshot.health;
    final modelInfo = snapshot.modelInfo;
    final ok = health.isOk;
    final color = ok
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  ok ? Icons.cloud_done_outlined : Icons.cloud_off,
                  color: color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ok
                            ? strings.text('backendOnline')
                            : strings.text('backendOffline'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(strings.text('backendStatusBody')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _InfoSection(
          title: strings.text('backend'),
          rows: [
            (strings.text('apiBaseUrl'), config.apiBaseUrl),
            (strings.text('status'), health.status),
            (strings.text('inferenceLatency'), '${health.latencyMs} ms'),
            (
              strings.text('productionUseHttps'),
              config.usesHttps ? strings.text('yes') : strings.text('no'),
            ),
          ],
        ),
        _InfoSection(
          title: strings.text('modelInformation'),
          rows: [
            (
              strings.text('modelLoaded'),
              health.modelLoaded ? strings.text('yes') : strings.text('no'),
            ),
            (strings.text('modelVersion'), modelInfo.modelVersion),
            (strings.text('featureSchema'), modelInfo.featureSchemaVersion),
            (strings.text('featureCount'), modelInfo.nFeatures.toString()),
            (
              strings.text('urlTransformer'),
              modelInfo.urlTransformerAvailable
                  ? strings.text('yes')
                  : strings.text('no'),
            ),
            (
              strings.text('modelClasses'),
              modelInfo.classes
                  .map((value) => strings.text('prediction${_classKey(value)}'))
                  .join(', '),
            ),
          ],
        ),
      ],
    );
  }

  String _classKey(String value) {
    return switch (value) {
      'benign' => 'Benign',
      'phishing' => 'Phishing',
      'malware' => 'Malware',
      'scam' => 'Scam',
      'other_malicious' => 'OtherMalicious',
      _ => value,
    };
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
            const SizedBox(height: 10),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        row.$1,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Expanded(child: SelectableText(row.$2)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusError extends StatelessWidget {
  const _StatusError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 56),
            const SizedBox(height: 12),
            Text(
              strings.text('backendOffline'),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(strings.text('refresh')),
            ),
          ],
        ),
      ),
    );
  }
}
