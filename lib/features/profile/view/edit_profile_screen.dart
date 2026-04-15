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
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

  Future<ImageSource?> _showImageSourceDialog() async {
    return showGeneralDialog<ImageSource>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, _, _) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: NeoCard(
                backgroundColor: AppColors.background,
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('CHOOSE PHOTO', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900)),
                    Gap(24.h),
                    Row(
                      children: [
                        Expanded(
                          child: _ImageSourceOption(
                            icon: LucideIcons.camera,
                            label: 'CAMERA',
                            color: AppColors.cardYellow,
                            onTap: () => Navigator.pop(ctx, ImageSource.camera),
                          ),
                        ),
                        Gap(16.w),
                        Expanded(
                          child: _ImageSourceOption(
                            icon: LucideIcons.image,
                            label: 'GALLERY',
                            color: AppColors.cardBlue,
                            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                    Gap(16.h),
                    if (_profileImagePath != null)
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
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.red, width: 2.r),
                          ),
                          child: Center(
                            child: Text('REMOVE PHOTO', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 14.sp)),
                          ),
                        ),
                      ),
                  ],
                ),
              ).animate().scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack).fadeIn(),
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
      // Clear the image if removed
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
      body: SafeArea(
        child: _isSaving
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    Gap(24.h),
                    Text('SAVING CHANGES...', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp)),
                  ],
                ),
              )
            : ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: AppColors.border, width: 3.r),
                              ),
                              child: Icon(LucideIcons.arrowLeft, color: AppColors.textDark, size: 20.r),
                            ),
                          ),
                          Gap(16.w),
                          Text(
                            'EDIT PROFILE',
                            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, letterSpacing: -1),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(),

                  Gap(40.h),

                  // Avatar Section
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 130.r,
                            height: 130.r,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border, width: 4.r),
                              boxShadow: [
                                BoxShadow(color: AppColors.border, offset: Offset(5.w, 5.h)),
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
                                      style: TextStyle(fontSize: 52.sp, fontWeight: FontWeight.w900, color: AppColors.textDark),
                                    ),
                                  )
                                : null,
                          ),
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: AppColors.cardYellow,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border, width: 3.r),
                              boxShadow: [
                                BoxShadow(color: AppColors.border, offset: Offset(2.w, 2.h)),
                              ],
                            ),
                            child: Icon(LucideIcons.camera, size: 18.r, color: AppColors.textDark),
                          ),
                        ],
                      ).animate().scale(curve: Curves.easeOutBack),
                    ),
                  ),
                  Gap(8.h),
                  Center(
                    child: Text(
                      'TAP TO CHANGE PHOTO',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: AppColors.textLight, letterSpacing: 1),
                    ).animate().fadeIn(delay: 200.ms),
                  ),

                  Gap(40.h),

                  // Form Fields
                  _buildFieldLabel('YOUR NAME', LucideIcons.user, 300),
                  Gap(12.h),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => _markChanged(),
                    style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900),
                    decoration: InputDecoration(
                      hintText: 'What should we call you?',
                      contentPadding: EdgeInsets.all(20.r),
                    ),
                  ).animate().slideX(begin: 0.1, delay: 300.ms, curve: Curves.easeOutBack).fadeIn(),

                  Gap(28.h),

                  _buildFieldLabel('BIO', LucideIcons.alignLeft, 400),
                  Gap(12.h),
                  TextField(
                    controller: _bioController,
                    onChanged: (_) => _markChanged(),
                    maxLines: 3,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Write something about yourself...',
                      contentPadding: EdgeInsets.all(20.r),
                    ),
                  ).animate().slideX(begin: 0.1, delay: 400.ms, curve: Curves.easeOutBack).fadeIn(),

                  Gap(28.h),

                  _buildFieldLabel('EMAIL', LucideIcons.mail, 500),
                  Gap(12.h),
                  TextField(
                    controller: _emailController,
                    enabled: false, // Email comes from Firebase, read-only
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textLight),
                    decoration: InputDecoration(
                      hintText: 'Your email',
                      contentPadding: EdgeInsets.all(20.r),
                      suffixIcon: Container(
                        margin: EdgeInsets.only(right: 12.w),
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        child: Icon(LucideIcons.lock, size: 16.r, color: AppColors.textLight),
                      ),
                    ),
                  ).animate().slideX(begin: 0.1, delay: 500.ms, curve: Curves.easeOutBack).fadeIn(),

                  Gap(12.h),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: Text(
                      'Email is managed by Firebase and cannot be changed here.',
                      style: TextStyle(fontSize: 11.sp, color: AppColors.textLight, fontWeight: FontWeight.w600),
                    ).animate().fadeIn(delay: 550.ms),
                  ),

                  Gap(48.h),

                  // Save Button
                  NeoButton(
                    text: _hasChanged ? 'SAVE CHANGES' : 'NO CHANGES',
                    backgroundColor: _hasChanged ? AppColors.secondary : AppColors.white,
                    textColor: AppColors.textDark,
                    onPressed: _save,
                  ).animate().slideY(begin: 0.3, delay: 600.ms, curve: Curves.easeOutBack).fadeIn(),

                  Gap(100.h),
                ],
              ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, IconData icon, int delayMs) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: AppColors.textLight),
        Gap(8.w),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: AppColors.textLight, letterSpacing: 2),
        ),
      ],
    ).animate().fadeIn(delay: Duration(milliseconds: delayMs));
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      backgroundColor: color,
      isInteractive: true,
      onTap: onTap,
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        children: [
          Icon(icon, size: 28.r, color: AppColors.textDark),
          Gap(8.h),
          Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp)),
        ],
      ),
    );
  }
}
