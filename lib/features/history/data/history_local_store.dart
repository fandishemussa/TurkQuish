import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/url_masker.dart';
import '../../inference/domain/entities/prediction_result.dart';
import '../../settings/data/settings_store.dart';
import '../domain/scan_history_item.dart';

final historyLocalStoreProvider = ChangeNotifierProvider<HistoryLocalStore>((
  ref,
) {
  return HistoryLocalStore(ref.watch(sharedPreferencesProvider));
});

class HistoryLocalStore extends ChangeNotifier {
  HistoryLocalStore(this._preferences) {
    _items = _readItems();
  }

  static const _historyKey = 'history.items';
  static const _maxItems = 100;

  final SharedPreferences _preferences;
  late List<ScanHistoryItem> _items;

  List<ScanHistoryItem> get items => List.unmodifiable(_items);

  Future<void> addFromPrediction({
    required PredictionResult result,
    required String submittedUrl,
    required bool enabled,
    required bool maskQuery,
  }) async {
    if (!enabled) {
      return;
    }
    final item = ScanHistoryItem(
      id: result.predictionId,
      timestamp: DateTime.now(),
      displayUrl: result.domain.isNotEmpty
          ? result.domain
          : UrlMasker.domainOrMasked(submittedUrl, maskQuery: maskQuery),
      predictedClass: result.predictedClass,
      riskScore: result.riskScore,
      modelVersion: result.modelVersion,
    );
    _items = [item, ..._items].take(_maxItems).toList();
    await _writeItems();
    notifyListeners();
  }

  Future<void> clear() async {
    _items = [];
    await _preferences.remove(_historyKey);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _items = _items.where((item) => item.id != id).toList();
    await _writeItems();
    notifyListeners();
  }

  List<ScanHistoryItem> _readItems() {
    final encoded = _preferences.getStringList(_historyKey) ?? const [];
    return encoded
        .map((value) {
          try {
            return ScanHistoryItem.fromJson(
              jsonDecode(value) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<ScanHistoryItem>()
        .toList();
  }

  Future<void> _writeItems() async {
    final encoded = _items
        .map((item) => jsonEncode(item.toJson()))
        .toList(growable: false);
    await _preferences.setStringList(_historyKey, encoded);
  }
}
