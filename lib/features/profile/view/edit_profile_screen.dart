import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;

  String? _profileImagePath;
  bool _isSaving = false;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _emailController = TextEditingController();

    // Pre-populate after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider).value;
      final currentUser = ref.read(currentUserProvider);
      if (settings != null) {
        _nameController.text = settings.userName;
        _bioController.text = settings.userBio;
        _emailController.text = currentUser?.email ?? settings.userEmail;
        _profileImagePath = settings.profileImagePath;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _markChanged() {
    if (!_hasChanged) setState(() => _hasChanged = true);
  }

  Future<void> _pickImage() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 80);
    if (picked == null) return;

    // Copy to app documents directory for persistence
    final appDir = await getApplicationDocumentsDirectory();
    final savedPath = '${appDir.path}/profile_image.jpg';
    await File(picked.path).copy(savedPath);

    setState(() {
      _profileImagePath = savedPath;
      _hasChanged = true;
    });
  }

  Future<ImageSource?> _showImageSourceDialog() {
    return showGeneralDialog<ImageSource?>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, _, _) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.border, width: 1.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Choose Photo',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textDark, letterSpacing: -0.3),
                    ),
                    Gap(16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _ImageSourceOption(
                            icon: LucideIcons.camera,
                            label: 'Camera',
                            onTap: () => Navigator.pop(ctx, ImageSource.camera),
                          ),
                        ),
                        Gap(12.w),
                        Expanded(
                          child: _ImageSourceOption(
                            icon: LucideIcons.image,
                            label: 'Gallery',
                            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                    if (_profileImagePath != null) ...[
                      Gap(12.h),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _profileImagePath = null;
                            _hasChanged = true;
                          });
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: AppColors.destructiveLight,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Text(
                              'Remove Photo',
                              style: TextStyle(color: AppColors.destructive, fontWeight: FontWeight.w600, fontSize: 13.sp),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_hasChanged) {
      context.pop();
      return;
    }

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();

    if (name.isNotEmpty) {
      await ref.read(settingsProvider.notifier).updateName(name);
    }
    await ref.read(settingsProvider.notifier).updateBio(bio);

    if (_profileImagePath != null) {
      await ref.read(settingsProvider.notifier).updateProfileImage(_profileImagePath!);
    } else {
      await ref.read(settingsProvider.notifier).updateProfileImage('');
    }

    if (mounted) {
      setState(() => _isSaving = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _profileImagePath != null && _profileImagePath!.isNotEmpty && File(_profileImagePath!).existsSync();
    final displayName = _nameController.text.isNotEmpty ? _nameController.text : 'P';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.3,
          ),
        ),
        leading: Center(
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: AppColors.zinc100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(LucideIcons.arrowLeft, color: AppColors.textDark, size: 18.r),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _isSaving
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : ListView(
                padding: EdgeInsets.all(20.r),
                children: [
                  // Avatar Section
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 110.r,
                            height: 110.r,
                            decoration: BoxDecoration(
                              color: AppColors.zinc950,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border, width: 2.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              image: hasImage
                                  ? DecorationImage(
                                      image: FileImage(File(_profileImagePath!)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: !hasImage
                                ? Center(
                                    child: Text(
                                      displayName[0].toUpperCase(),
                                      style: TextStyle(fontSize: 44.sp, fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                                  )
                                : null,
                          ),
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.surface, width: 2.r),
                            ),
                            child: Icon(LucideIcons.camera, size: 14.r, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(8.h),
                  Center(
                    child: Text(
                      'Tap to change photo',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: AppColors.textLight),
                    ),
                  ),

                  Gap(32.h),

                  // Form Fields
                  _buildFieldLabel('Full Name', LucideIcons.user),
                  Gap(8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.border, width: 1.r),
                    ),
                    child: TextField(
                      controller: _nameController,
                      onChanged: (_) => _markChanged(),
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: 'What should we call you?',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                      ),
                    ),
                  ),

                  Gap(20.h),

                  _buildFieldLabel('Bio', LucideIcons.alignLeft),
                  Gap(8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.border, width: 1.r),
                    ),
                    child: TextField(
                      controller: _bioController,
                      onChanged: (_) => _markChanged(),
                      maxLines: 3,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: 'Write something about yourself...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                      ),
                    ),
                  ),

                  Gap(20.h),

                  _buildFieldLabel('Email Address', LucideIcons.mail),
                  Gap(8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.zinc50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.border, width: 1.r),
                    ),
                    child: TextField(
                      controller: _emailController,
                      enabled: false,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.textLight),
                      decoration: InputDecoration(
                        hintText: 'Your email',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                        suffixIcon: Icon(LucideIcons.lock, size: 16.r, color: AppColors.zinc400),
                      ),
                    ),
                  ),

                  Gap(6.h),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: Text(
                      'Email is managed securely and cannot be changed directly.',
                      style: TextStyle(fontSize: 11.sp, color: AppColors.textLight, fontWeight: FontWeight.w400),
                    ),
                  ),

                  Gap(36.h),

                  // Save Button
                  NeoButton(
                    text: _hasChanged ? 'Save Changes' : 'No Changes',
                    backgroundColor: _hasChanged ? AppColors.primary : AppColors.zinc200,
                    textColor: _hasChanged ? Colors.white : AppColors.textLight,
                    onPressed: _save,
                  ),

                  Gap(40.h),
                ],
              ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14.r, color: AppColors.zinc400),
        Gap(6.w),
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textDark, letterSpacing: -0.2),
        ),
      ],
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.zinc100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24.r, color: AppColors.textDark),
            Gap(6.h),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}
