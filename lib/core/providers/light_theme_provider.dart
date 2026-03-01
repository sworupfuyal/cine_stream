import 'dart:async';
import 'package:cine_stream/core/providers/sensor_settings_provider.dart';
import 'package:cine_stream/core/providers/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_sensor/light_sensor.dart';

/// Wraps any widget and auto-switches the theme based on ambient lux.
///
/// Place high in your widget tree, e.g. in main.dart:
///   home: LightThemeListener(child: DashboardScreen())
///
/// Only activates when the user enables "Auto Light Theme" in Settings.
/// Gracefully no-ops on emulators or devices without a light sensor.
///
/// Lux reference:
///   < 10 lux  → dark room / night   → dark theme
///   10–50 lux → dim indoor          → dark theme
///   50+ lux   → normal indoor/sun   → light theme
class LightThemeListener extends ConsumerStatefulWidget {
  final Widget child;

  /// Lux below this value → dark mode. Default: 20 lux.
  final double darkThreshold;

  const LightThemeListener({
    super.key,
    required this.child,
    this.darkThreshold = 20.0,
  });

  @override
  ConsumerState<LightThemeListener> createState() => _LightThemeListenerState();
}

class _LightThemeListenerState extends ConsumerState<LightThemeListener> {
  StreamSubscription<int>? _lightSub;
  bool _sensorAvailable = false;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  Future<void> _startListening() async {
    // ── 1. Check sensor availability ──────────────────────────────────
    bool hasSensor = false;
    try {
      hasSensor = await LightSensor.hasSensor();
    } catch (e) {
      debugPrint('[LightThemeListener] hasSensor() error: $e');
    }

    if (!mounted) return;
    setState(() => _sensorAvailable = hasSensor);

    if (!hasSensor) {
      debugPrint(
        '[LightThemeListener] No light sensor detected. '
        'This is expected on emulators — test on a real device.',
      );
      return;
    }

    debugPrint('[LightThemeListener] Light sensor found — starting stream.');

    // ── 2. Subscribe to lux stream ─────────────────────────────────────
    try {
      _lightSub = LightSensor.luxStream().listen(
        _onLux,
        onError: (e) => debugPrint('[LightThemeListener] Stream error: $e'),
      );
    } catch (e) {
      debugPrint('[LightThemeListener] Could not start luxStream: $e');
    }
  }

  void _onLux(int lux) {
    // Guard: only act when the feature is toggled on
    final autoEnabled = ref.read(sensorSettingsProvider).autoLightTheme;
    if (!autoEnabled) return;

    final currentlyDark = ref.read(themeProvider);
    final shouldBeDark  = lux < widget.darkThreshold;

    debugPrint(
      '[LightThemeListener] lux=$lux  '
      'shouldBeDark=$shouldBeDark  currentlyDark=$currentlyDark',
    );

    // Only write when there is an actual mismatch — avoids rapid toggling
    if (shouldBeDark != currentlyDark) {
      ref.read(themeProvider.notifier).setTheme(isDark: shouldBeDark);
    }
  }

  @override
  void dispose() {
    _lightSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Debug-only badge so you immediately know the sensor is unavailable
    if (kDebugMode && !_sensorAvailable) {
      return Stack(
        children: [
          widget.child,
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '⚠ No light sensor',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return widget.child;
  }
}