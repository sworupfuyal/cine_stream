import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyAutoLightTheme = 'auto_light_theme';
const _keyShakeToLogout  = 'shake_to_logout';

class SensorSettings {
  final bool autoLightTheme;
  final bool shakeToLogout;

  const SensorSettings({
    this.autoLightTheme = false,
    this.shakeToLogout  = false,
  });

  SensorSettings copyWith({bool? autoLightTheme, bool? shakeToLogout}) =>
      SensorSettings(
        autoLightTheme: autoLightTheme ?? this.autoLightTheme,
        shakeToLogout:  shakeToLogout  ?? this.shakeToLogout,
      );
}

class SensorSettingsNotifier extends Notifier<SensorSettings> {
  @override
  SensorSettings build() {
    _load();
    return const SensorSettings();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SensorSettings(
      autoLightTheme: prefs.getBool(_keyAutoLightTheme) ?? false,
      shakeToLogout:  prefs.getBool(_keyShakeToLogout)  ?? false,
    );
  }

  Future<void> toggleAutoLightTheme() async {
    final next = !state.autoLightTheme;
    state = state.copyWith(autoLightTheme: next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoLightTheme, next);
  }

  Future<void> toggleShakeToLogout() async {
    final next = !state.shakeToLogout;
    state = state.copyWith(shakeToLogout: next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShakeToLogout, next);
  }
}

final sensorSettingsProvider =
    NotifierProvider<SensorSettingsNotifier, SensorSettings>(
  SensorSettingsNotifier.new,
);