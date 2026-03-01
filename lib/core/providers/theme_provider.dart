import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyTheme = 'is_dark_theme';

class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true; // default dark
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_keyTheme) ?? true;
  }

  /// Manual toggle (used by the Settings switch)
  Future<void> toggleTheme() => setTheme(isDark: !state);

  /// Programmatic set (used by the light sensor)
  Future<void> setTheme({required bool isDark}) async {
    if (state == isDark) return;
    state = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTheme, isDark);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, bool>(
  ThemeNotifier.new,
);