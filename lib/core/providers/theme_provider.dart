import 'package:cine_stream/core/services/storage/user_session_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

class ThemeNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'isDarkTheme';

  ThemeNotifier(this._prefs) : super(_prefs.getBool('isDarkTheme') ?? true);
  // defaults to dark theme, change to false if you want light as default

  void toggleTheme() {
    state = !state;
    _prefs.setBool(_key, state);
  }

  bool get isDark => state;
}