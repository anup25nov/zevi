import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// State
// ─────────────────────────────────────────────
class SettingsState {
  final bool briefingEnabled;
  final TimeOfDay briefingTime;
  final String language;
  final ThemeMode themeMode;
  final bool notificationsEnabled;

  const SettingsState({
    this.briefingEnabled = true,
    this.briefingTime = const TimeOfDay(hour: 8, minute: 0),
    this.language = 'English (US)',
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
  });

  SettingsState copyWith({
    bool? briefingEnabled,
    TimeOfDay? briefingTime,
    String? language,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
  }) {
    return SettingsState(
      briefingEnabled: briefingEnabled ?? this.briefingEnabled,
      briefingTime: briefingTime ?? this.briefingTime,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

// ─────────────────────────────────────────────
// Pref keys
// ─────────────────────────────────────────────
const _kBriefingEnabled = 'briefing_enabled';
const _kBriefingHour = 'briefing_hour';
const _kBriefingMin = 'briefing_min';
const _kLanguage = 'language';
const _kThemeMode = 'theme_mode';
const _kNotifications = 'notifications_enabled';

// ─────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      briefingEnabled: prefs.getBool(_kBriefingEnabled) ?? true,
      briefingTime: TimeOfDay(
        hour: prefs.getInt(_kBriefingHour) ?? 8,
        minute: prefs.getInt(_kBriefingMin) ?? 0,
      ),
      language: prefs.getString(_kLanguage) ?? 'English (US)',
      themeMode: ThemeMode.values[prefs.getInt(_kThemeMode) ?? 0],
      notificationsEnabled: prefs.getBool(_kNotifications) ?? true,
    );
  }

  Future<void> toggleBriefing() async {
    final next = !state.briefingEnabled;
    state = state.copyWith(briefingEnabled: next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBriefingEnabled, next);
  }

  Future<void> setBriefingTime(TimeOfDay time) async {
    state = state.copyWith(briefingTime: time);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kBriefingHour, time.hour);
    await prefs.setInt(_kBriefingMin, time.minute);
  }

  Future<void> setLanguage(String lang) async {
    state = state.copyWith(language: lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, lang);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeMode, mode.index);
  }

  Future<void> toggleNotifications() async {
    final next = !state.notificationsEnabled;
    state = state.copyWith(notificationsEnabled: next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, next);
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
