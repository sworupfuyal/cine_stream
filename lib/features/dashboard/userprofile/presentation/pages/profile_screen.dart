import 'dart:async';
import 'dart:io';
import 'package:cine_stream/core/api/api_endpoints.dart';
import 'package:cine_stream/core/services/storage/token_service.dart';
import 'package:cine_stream/features/auth/presentation/pages/signin_screen.dart';
import 'package:cine_stream/features/dashboard/userprofile/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

import '../../domain/usecases/update_user_profile_usecase.dart';
import '../state/user_profile_state.dart';
import '../view_model/user_profile_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  File? _selectedImage;
  bool _hasChanges = false;
  bool _isSaving = false;
  bool _controllersInitialized = false;

  // ── Proximity logout fields
  StreamSubscription<int>? _proximitySub;
  bool _isNear = false;
  int _proximityValue = 0;
  int _lastLogoutTime = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileViewModelProvider.notifier).getUserProfile();
    });

    _proximitySub = ProximitySensor.events.listen((int event) {
      _proximityValue = event;
      bool near = event < 4;
      _isNear = near;

      int now = DateTime.now().millisecondsSinceEpoch;
      if (near && now - _lastLogoutTime > 1000) {
        _lastLogoutTime = now;
        _logout();
      }
    });
  }

  @override
  void dispose() {
    _proximitySub?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _populateControllers(dynamic profile) {
    if (_controllersInitialized) return;
    _controllersInitialized = true;
    _nameController.text = profile.fullName ?? '';
    _emailController.text = profile.email ?? '';
    _phoneController.text = profile.phoneNumber ?? '';
    _locationController.text = profile.location ?? '';
  }

  void _onFieldChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
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

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }
    if (status.isPermanentlyDenied) openAppSettings();
    return false;
  }

  Future<void> _pickFromCamera() async {
    final granted = await _requestPermission(Permission.camera);
    if (!granted) return;
    final image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _hasChanges = true;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _hasChanges = true;
      });
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetTile(Icons.camera_alt, "Open Camera", _pickFromCamera),
              _sheetTile(
                  Icons.photo_library, "Open Gallery", _pickFromGallery),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetTile(IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      await ref.read(userProfileViewModelProvider.notifier).updateProfile(
            UpdateUserProfileUsecaseParams(
              fullName: _nameController.text.trim().isNotEmpty
                  ? _nameController.text.trim()
                  : null,
              email: _emailController.text.trim().isNotEmpty
                  ? _emailController.text.trim()
                  : null,
              phoneNumber: _phoneController.text.trim().isNotEmpty
                  ? _phoneController.text.trim()
                  : null,
              location: _locationController.text.trim().isNotEmpty
                  ? _locationController.text.trim()
                  : null,
              profileImage: _selectedImage,
            ),
          );

      await ref.read(userProfileViewModelProvider.notifier).getUserProfile();

      setState(() {
        _hasChanges = false;
        _selectedImage = null;
        _isSaving = false;
        _controllersInitialized = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileViewModelProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (state.status == UserProfileStatus.loading && state.profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = state.profile;
    if (profile == null) return const SizedBox.shrink();

    _populateControllers(profile);

    return Scaffold(
      floatingActionButton: _hasChanges
          ? FloatingActionButton.extended(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? "Saving..." : "Save Changes"),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.primary.withOpacity(0.35),
              colors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ── Header Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            "Profile",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // ── Settings icon 👇
                          IconButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingsScreen()),
                            ),
                            icon: const Icon(Icons.settings_outlined),
                            tooltip: 'Settings',
                          ),
                          // ── Logout button
                          TextButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout,
                                color: Colors.redAccent, size: 18),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                  color: Colors.redAccent, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Avatar Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colors.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _showImagePickerSheet,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: colors.primary,
                                    backgroundImage: _selectedImage != null
                                        ? FileImage(_selectedImage!)
                                        : (profile.profileImage != null &&
                                                profile.profileImage!.isNotEmpty)
                                            ? NetworkImage(
                                                "${ApiEndpoints.baseUrl}${profile.profileImage}",
                                              )
                                            : null,
                                    child: _selectedImage == null &&
                                            (profile.profileImage == null ||
                                                profile.profileImage!.isEmpty)
                                        ? Icon(Icons.person,
                                            size: 50, color: colors.onPrimary)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: colors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: colors.surface, width: 2),
                                      ),
                                      child: Icon(Icons.camera_alt,
                                          size: 16, color: colors.onPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              profile.fullName ?? "No Name",
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.email ?? "No Email",
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      colors.onSurface.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Editable Fields Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colors.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            _modernField("Name", Icons.person_outline,
                                _nameController),
                            const SizedBox(height: 16),
                            _modernField(
                                "Email", Icons.email_outlined, _emailController,
                                keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 16),
                            _modernField(
                                "Phone", Icons.phone_outlined, _phoneController,
                                keyboardType: TextInputType.phone),
                            const SizedBox(height: 16),
                            _modernField("Location",
                                Icons.location_on_outlined, _locationController),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Logout Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _logout,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(
                                color: Colors.redAccent, width: 1),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('Logout',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernField(
      String label, IconData icon, TextEditingController controller,
      {TextInputType? keyboardType}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextField(
      controller: controller,
      onChanged: (_) => _onFieldChanged(),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: colors.primary),
        labelText: label,
        filled: true,
        fillColor: colors.surface.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}