import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../l10n/app_strings.dart';
import '../../inference/domain/entities/prediction_class.dart';
import '../data/history_local_store.dart';
import '../domain/scan_history_item.dart';

enum _DateFilter { all, today, last7Days }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  PredictionClass? _filter;
  _DateFilter _dateFilter = _DateFilter.all;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(historyLocalStoreProvider);
    final items = store.items.where(_matches).toList();
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.text('scanHistory')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: strings.text('back'),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: strings.text('exportHistory'),
            onPressed: items.isEmpty ? null : () => _exportHistory(items),
            icon: const Icon(Icons.ios_share_outlined),
          ),
          IconButton(
            tooltip: strings.text('clearHistory'),
            onPressed: store.items.isEmpty
                ? null
                : () => _confirmClear(context),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: strings.text('searchDomainOrMaskedUrl'),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: Text(strings.text('all')),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
                for (final predictionClass in PredictionClass.values)
                  FilterChip(
                    label: Text(strings.predictionClass(predictionClass)),
                    selected: _filter == predictionClass,
                    onSelected: (_) =>
                        setState(() => _filter = predictionClass),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SegmentedButton<_DateFilter>(
              segments: [
                ButtonSegment(
                  value: _DateFilter.all,
                  icon: const Icon(Icons.all_inclusive),
                  label: Text(strings.text('allDates')),
                ),
                ButtonSegment(
                  value: _DateFilter.today,
                  icon: const Icon(Icons.today_outlined),
                  label: Text(strings.text('today')),
                ),
                ButtonSegment(
                  value: _DateFilter.last7Days,
                  icon: const Icon(Icons.date_range_outlined),
                  label: Text(strings.text('last7Days')),
                ),
              ],
              selected: {_dateFilter},
              onSelectionChanged: (selection) {
                setState(() => _dateFilter = selection.single);
              },
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const _EmptyHistory()
            else
              for (final item in items)
                _HistoryTile(
                  item: item,
                  onDelete: () => _confirmDelete(context, item),
                ),
          ],
        ),
      ),
    );
  }

  bool _matches(ScanHistoryItem item) {
    final now = DateTime.now();
    final localTimestamp = item.timestamp.toLocal();
    if (_dateFilter == _DateFilter.today &&
        (localTimestamp.year != now.year ||
            localTimestamp.month != now.month ||
            localTimestamp.day != now.day)) {
      return false;
    }
    if (_dateFilter == _DateFilter.last7Days &&
        localTimestamp.isBefore(now.subtract(const Duration(days: 7)))) {
      return false;
    }
    if (_filter != null && item.predictedClass != _filter) {
      return false;
    }
    if (_query.trim().isEmpty) {
      return true;
    }
    return item.displayUrl.toLowerCase().contains(_query.trim().toLowerCase());
  }

  Future<void> _exportHistory(List<ScanHistoryItem> items) async {
    final payload = items.map((item) => item.toJson()).toList(growable: false);
    await Clipboard.setData(
      ClipboardData(text: const JsonEncoder.withIndent('  ').convert(payload)),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).text('historyExported'))),
      );
    }
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: Text(AppStrings.of(context).text('clearLocalHistoryTitle')),
        content: Text(AppStrings.of(context).text('clearLocalHistoryMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.of(context).text('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppStrings.of(context).text('clear')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(historyLocalStoreProvider).clear();
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ScanHistoryItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: Text(AppStrings.of(context).text('deleteScan')),
        content: Text(AppStrings.of(context).text('deleteScanMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.of(context).text('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppStrings.of(context).text('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(historyLocalStoreProvider).delete(item.id);
    }
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item, required this.onDelete});

  final ScanHistoryItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(_iconFor(item.predictedClass), size: 20),
        ),
        title: Text(item.displayUrl, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${DateFormatter.compact(item.timestamp)} • ${item.modelVersion}',
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  strings.predictionClass(item.predictedClass),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(item.riskScore.toStringAsFixed(2)),
              ],
            ),
            IconButton(
              tooltip: strings.text('delete'),
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(PredictionClass predictionClass) {
    return switch (predictionClass) {
      PredictionClass.benign => Icons.verified_user_outlined,
      PredictionClass.phishing => Icons.phishing,
      PredictionClass.malware => Icons.bug_report_outlined,
      PredictionClass.scam => Icons.report_gmailerrorred_outlined,
      PredictionClass.otherMalicious => Icons.gpp_bad_outlined,
    };
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.history_toggle_off,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              strings.text('noLocalHistory'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              strings.text('noLocalHistoryBody'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
