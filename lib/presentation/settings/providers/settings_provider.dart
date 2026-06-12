import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool darkMode;
  final bool notificationsEnabled;
  final String language;
  final bool autoRefresh;
  final int refreshInterval;

  const SettingsState({
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.language = 'ar',
    this.autoRefresh = true,
    this.refreshInterval = 30,
  });

  SettingsState copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    String? language,
    bool? autoRefresh,
    int? refreshInterval,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      refreshInterval: refreshInterval ?? this.refreshInterval,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      darkMode: prefs.getBool('darkMode') ?? false,
      notificationsEnabled: prefs.getBool('notificationsEnabled') ?? true,
      language: prefs.getString('language') ?? 'ar',
      autoRefresh: prefs.getBool('autoRefresh') ?? true,
      refreshInterval: prefs.getInt('refreshInterval') ?? 30,
    );
  }

  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.darkMode;
    await prefs.setBool('darkMode', newValue);
    state = state.copyWith(darkMode: newValue);
  }

  Future<void> toggleNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.notificationsEnabled;
    await prefs.setBool('notificationsEnabled', newValue);
    state = state.copyWith(notificationsEnabled: newValue);
  }

  Future<void> toggleAutoRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.autoRefresh;
    await prefs.setBool('autoRefresh', newValue);
    state = state.copyWith(autoRefresh: newValue);
  }

  Future<void> setRefreshInterval(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('refreshInterval', minutes);
    state = state.copyWith(refreshInterval: minutes);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
