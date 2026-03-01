import 'dart:async';
import 'dart:math';
import 'package:cine_stream/core/api/api_endpoints.dart';
import 'package:cine_stream/core/providers/sensor_settings_provider.dart';
import 'package:cine_stream/core/services/storage/token_service.dart';
import 'package:cine_stream/features/auth/presentation/pages/signin_screen.dart';
import 'package:cine_stream/features/dashboard/userprofile/presentation/pages/settings_page.dart';
import 'package:cine_stream/features/dashboard/userprofile/presentation/pages/update_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../state/user_profile_state.dart';
import '../view_model/user_profile_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  StreamSubscription<AccelerometerEvent>? _accelSub;

  static const double _shakeThreshold  = 15.0; // m/s²
  static const int    _shakeCooldownMs = 2000;
  int _lastShakeTime = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileViewModelProvider.notifier).getUserProfile();
    });
    _startShakeDetection();
  }

  void _startShakeDetection() {
    _accelSub = accelerometerEventStream().listen((AccelerometerEvent e) {
      final shakeEnabled = ref.read(sensorSettingsProvider).shakeToLogout;
      if (!shakeEnabled) return;

      final magnitude = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
      final now = DateTime.now().millisecondsSinceEpoch;

      if (magnitude > _shakeThreshold && now - _lastShakeTime > _shakeCooldownMs) {
        _lastShakeTime = now;
        _logout();
      }
    });
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Log Out',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await ref.read(tokenServiceProvider).removeToken();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state  = ref.watch(userProfileViewModelProvider);
    final theme  = Theme.of(context);
    final colors = theme.colorScheme;

    if (state.status == UserProfileStatus.loading && state.profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profile = state.profile;
    if (profile == null) return const SizedBox.shrink();

    final avatarUrl = (profile.profileImage != null && profile.profileImage!.isNotEmpty)
        ? "${ApiEndpoints.baseUrl}${profile.profileImage}"
        : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero header ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.primary.withOpacity(0.3),
                    colors.surface,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: colors.primary.withOpacity(0.2),
                        backgroundImage:
                            avatarUrl != null ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl == null
                            ? Icon(Icons.person_rounded,
                                size: 52, color: colors.primary)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.fullName ?? "No Name",
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(profile.email ?? "",
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Menu tiles ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _MenuCard(children: [
                    _MenuTile(
                      icon: Icons.edit_outlined,
                      label: "Update Profile",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const UpdateProfileScreen()),
                      ).then((_) => ref
                          .read(userProfileViewModelProvider.notifier)
                          .getUserProfile()),
                    ),
                    _divider(colors),
                    _MenuTile(
                      icon: Icons.settings_outlined,
                      label: "Settings",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 12),

                  _MenuCard(children: [
                    _MenuTile(
                      icon: Icons.info_outline_rounded,
                      label: "App Version",
                      trailing: Text(
                        "1.0.0",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.45),
                        ),
                      ),
                      onTap: null,
                    ),
                  ]),

                  const SizedBox(height: 12),

                  _MenuCard(children: [
                    _MenuTile(
                      icon: Icons.logout_rounded,
                      label: "Log Out",
                      isDestructive: true,
                      onTap: _logout,
                    ),
                  ]),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Divider _divider(ColorScheme c) => Divider(
        height: 1,
        indent: 56,
        color: c.onSurface.withOpacity(0.08),
      );
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: children),
      );
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final colors = theme.colorScheme;
    final color      = isDestructive ? colors.error : colors.onSurface;
    final iconBg     = isDestructive
        ? colors.error.withOpacity(0.1)
        : colors.primary.withOpacity(0.1);
    final iconColor  = isDestructive ? colors.error : colors.primary;

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: color,
          fontWeight: isDestructive ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right_rounded,
                  color: colors.onSurface.withOpacity(0.3), size: 20)
              : null),
    );
  }
}