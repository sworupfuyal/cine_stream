import 'dart:io';

import 'package:cine_stream/features/dashboard/userprofile/domain/usecases/update_user_profile_usecase.dart';
import 'package:cine_stream/features/dashboard/userprofile/presentation/state/user_profile_state.dart';
import 'package:cine_stream/features/dashboard/userprofile/presentation/view_model/user_profile_view_model.dart';
import 'package:cine_stream/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  File? _selectedImage;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileViewModelProvider.notifier).getUserProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  /* ---------------- PERMISSIONS ---------------- */

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog();
    }
    return false;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Permission Required"),
        content: const Text(
          "Please enable permission from settings to continue.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  /* ---------------- IMAGE PICK ---------------- */

  Future<void> _pickFromCamera() async {
    final granted = await _requestPermission(Permission.camera);
    if (!granted) return;

    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _hasChanges = true;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

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
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pickerTile(
              icon: Icons.camera_alt,
              label: "Open Camera",
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            _pickerTile(
              icon: Icons.photo_library,
              label: "Open Gallery",
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      onTap: onTap,
    );
  }

  /* ---------------- SAVE ---------------- */

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      await ref.read(userProfileViewModelProvider.notifier).updateProfile(
            UpdateUserProfileUsecaseParams(
              fullName: _nameController.text.trim().isNotEmpty
                  ? _nameController.text.trim()
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
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    }
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileViewModelProvider);

    if (state.status == UserProfileStatus.loading && state.profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = state.profile;
    if (profile == null) return const SizedBox.shrink();

    _nameController.text = profile.fullName ?? '';
    _phoneController.text = profile.phoneNumber ?? '';
    _locationController.text = profile.location ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _hasChanges
          ? FloatingActionButton.extended(
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Icon(Icons.save),
              label: Text(_isSaving ? "Saving..." : "Save Changes"),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  GestureDetector(
                    onTap: _showImagePickerSheet,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (profile.profileImage != null &&
                                  profile.profileImage!.isNotEmpty)
                              ? NetworkImage(
                                  "http://10.0.2.2:6050${profile.profileImage}",
                                )
                              : const AssetImage(
                                      "assets/images/moviewall2.png")
                                  as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(profile.fullName ?? "No Name"),
                  Text(profile.email ?? "No Email"),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _editableField(
                    label: "Name",
                    icon: Icons.person_outline,
                    controller: _nameController,
                  ),
                  _editableField(
                    label: "Phone",
                    icon: Icons.phone_outlined,
                    controller: _phoneController,
                  ),
                  _editableField(
                    label: "Location",
                    icon: Icons.location_on_outlined,
                    controller: _locationController,
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editableField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        onChanged: (_) => _onFieldChanged(),
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
