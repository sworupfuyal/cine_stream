import 'package:cine_stream/core/providers/sensor_settings_provider.dart';
import 'package:cine_stream/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark        = ref.watch(themeProvider);
    final sensorState   = ref.watch(sensorSettingsProvider);
    final theme         = Theme.of(context);
    final colors        = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [

          // ── Appearance ────────────────────────────────────────────────
          _SectionLabel(label: "APPEARANCE"),
          const SizedBox(height: 10),
          _SettingsCard(children: [
            _ToggleTile(
              icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              label: "Dark Mode",
              subtitle: isDark ? "Using dark theme" : "Using light theme",
              value: isDark,
              // Disable manual toggle when auto light sensor is on
              enabled: !sensorState.autoLightTheme,
              onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
            ),
          ]),

          const SizedBox(height: 24),

          // ── Sensors ───────────────────────────────────────────────────
          _SectionLabel(label: "SENSORS"),
          const SizedBox(height: 10),
          _SettingsCard(children: [
            _ToggleTile(
              icon: Icons.light_mode_outlined,
              label: "Auto Light Theme",
              subtitle: sensorState.autoLightTheme
                  ? "Theme adjusts with ambient light"
                  : "Manually control theme",
              value: sensorState.autoLightTheme,
              onChanged: (_) => ref
                  .read(sensorSettingsProvider.notifier)
                  .toggleAutoLightTheme(),
            ),
            Divider(
              height: 1,
              indent: 56,
              color: colors.onSurface.withOpacity(0.08),
            ),
            _ToggleTile(
              icon: Icons.vibration_outlined,
              label: "Shake to Log Out",
              subtitle: sensorState.shakeToLogout
                  ? "Shake phone to trigger logout"
                  : "Manual logout only",
              value: sensorState.shakeToLogout,
              onChanged: (_) => ref
                  .read(sensorSettingsProvider.notifier)
                  .toggleShakeToLogout(),
            ),
          ]),

          // ── Sensor info hint ──────────────────────────────────────────
          if (sensorState.autoLightTheme || sensorState.shakeToLogout) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 14, color: colors.onSurface.withOpacity(0.4)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      sensorState.autoLightTheme
                          ? "Manual dark mode toggle is disabled while auto theme is active."
                          : "Shake the device to get a logout prompt.",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ── About ─────────────────────────────────────────────────────
          _SectionLabel(label: "ABOUT"),
          const SizedBox(height: 10),
          _SettingsCard(children: [
            _InfoTile(
              icon: Icons.movie_outlined,
              label: "App Name",
              value: "CineStream",
            ),
            Divider(
              height: 1,
              indent: 56,
              color: colors.onSurface.withOpacity(0.08),
            ),
            _InfoTile(
              icon: Icons.info_outline_rounded,
              label: "App Version",
              value: "1.0.0",
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onSurface.withOpacity(0.45),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ── Card wrapper ──────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }
}

// ── Toggle tile ───────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final colors = theme.colorScheme;
    final dimmed = !enabled;

    return Opacity(
      opacity: dimmed ? 0.4 : 1.0,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: colors.primary),
        ),
        title: Text(
          label,
          style:
              theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle, style: theme.textTheme.bodyMedium),
        trailing: Switch(
          value: value,
          activeColor: colors.primary,
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}

// ── Info tile ─────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: colors.primary),
      ),
      title: Text(
        label,
        style:
            theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: Text(
        value,
        style: theme.textTheme.bodySmall
            ?.copyWith(color: colors.onSurface.withOpacity(0.45)),
      ),
    );
  }
}