import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((_) {
  throw StateError('SharedPreferences must be provided at app startup.');
});

final settingsStoreProvider = ChangeNotifierProvider<SettingsStore>((ref) {
  return SettingsStore(ref.watch(sharedPreferencesProvider));
});

class SettingsStore extends ChangeNotifier {
  SettingsStore(this._preferences)
    : _languageCode = _preferences.getString(_languageKey) ?? 'system',
      _themeModeName = _preferences.getString(_themeKey) ?? 'system',
      _quickScanMode = _preferences.getBool(_quickScanKey) ?? false,
      _storeHistory = _preferences.getBool(_storeHistoryKey) ?? true,
      _maskUrls = _preferences.getBool(_maskUrlsKey) ?? true,
      _onboardingComplete = _preferences.getBool(_onboardingKey) ?? false;

  static const _languageKey = 'settings.language';
  static const _themeKey = 'settings.theme';
  static const _quickScanKey = 'settings.quickScanMode';
  static const _storeHistoryKey = 'settings.storeHistory';
  static const _maskUrlsKey = 'settings.maskUrls';
  static const _onboardingKey = 'settings.onboardingComplete';

  final SharedPreferences _preferences;

  String _languageCode;
  String _themeModeName;
  bool _quickScanMode;
  bool _storeHistory;
  bool _maskUrls;
  bool _onboardingComplete;

  String get languageCode => _languageCode;
  String get themeModeName => _themeModeName;
  bool get quickScanMode => _quickScanMode;
  bool get storeHistory => _storeHistory;
  bool get maskUrls => _maskUrls;
  bool get onboardingComplete => _onboardingComplete;

  Locale? get locale =>
      _languageCode == 'system' ? null : Locale(_languageCode);

  ThemeMode get themeMode {
    return switch (_themeModeName) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setLanguageCode(String value) async {
    if (!{'system', 'en', 'tr'}.contains(value)) {
      return;
    }
    _languageCode = value;
    await _preferences.setString(_languageKey, value);
    notifyListeners();
  }

  Future<void> setThemeModeName(String value) async {
    if (!{'system', 'light', 'dark'}.contains(value)) {
      return;
    }
    _themeModeName = value;
    await _preferences.setString(_themeKey, value);
    notifyListeners();
  }

  Future<void> setQuickScanMode(bool value) async {
    _quickScanMode = value;
    await _preferences.setBool(_quickScanKey, value);
    notifyListeners();
  }

  Future<void> setStoreHistory(bool value) async {
    _storeHistory = value;
    await _preferences.setBool(_storeHistoryKey, value);
    notifyListeners();
  }

  Future<void> setMaskUrls(bool value) async {
    _maskUrls = value;
    await _preferences.setBool(_maskUrlsKey, value);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    await _preferences.setBool(_onboardingKey, true);
    notifyListeners();
  }
}
