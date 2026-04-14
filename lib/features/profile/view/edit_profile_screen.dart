import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: NeoCard(
                backgroundColor: AppColors.background,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('CHOOSE PHOTO', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    const Gap(24),
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
                        const Gap(16),
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
                    const Gap(16),
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                          child: const Center(
                            child: Text('REMOVE PHOTO', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 14)),
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
                    const Gap(24),
                    const Text('SAVING CHANGES...', style: TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border, width: 3),
                              ),
                              child: const Icon(LucideIcons.arrowLeft, color: AppColors.textDark, size: 20),
                            ),
                          ),
                          const Gap(16),
                          const Text(
                            'EDIT PROFILE',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(),

                  const Gap(40),

                  // Avatar Section
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border, width: 4),
                              boxShadow: const [
                                BoxShadow(color: AppColors.border, offset: Offset(5, 5)),
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
                                      style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w900, color: AppColors.textDark),
                                    ),
                                  )
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.cardYellow,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border, width: 3),
                              boxShadow: const [
                                BoxShadow(color: AppColors.border, offset: Offset(2, 2)),
                              ],
                            ),
                            child: const Icon(LucideIcons.camera, size: 18, color: AppColors.textDark),
                          ),
                        ],
                      ).animate().scale(curve: Curves.easeOutBack),
                    ),
                  ),
                  const Gap(8),
                  Center(
                    child: const Text(
                      'TAP TO CHANGE PHOTO',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textLight, letterSpacing: 1),
                    ).animate().fadeIn(delay: 200.ms),
                  ),

                  const Gap(40),

                  // Form Fields
                  _buildFieldLabel('YOUR NAME', LucideIcons.user, 300),
                  const Gap(12),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => _markChanged(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    decoration: const InputDecoration(
                      hintText: 'What should we call you?',
                      contentPadding: EdgeInsets.all(20),
                    ),
                  ).animate().slideX(begin: 0.1, delay: 300.ms, curve: Curves.easeOutBack).fadeIn(),

                  const Gap(28),

                  _buildFieldLabel('BIO', LucideIcons.alignLeft, 400),
                  const Gap(12),
                  TextField(
                    controller: _bioController,
                    onChanged: (_) => _markChanged(),
                    maxLines: 3,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'Write something about yourself...',
                      contentPadding: EdgeInsets.all(20),
                    ),
                  ).animate().slideX(begin: 0.1, delay: 400.ms, curve: Curves.easeOutBack).fadeIn(),

                  const Gap(28),

                  _buildFieldLabel('EMAIL', LucideIcons.mail, 500),
                  const Gap(12),
                  TextField(
                    controller: _emailController,
                    enabled: false, // Email comes from Firebase, read-only
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textLight),
                    decoration: InputDecoration(
                      hintText: 'Your email',
                      contentPadding: const EdgeInsets.all(20),
                      suffixIcon: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: const Icon(LucideIcons.lock, size: 16, color: AppColors.textLight),
                      ),
                    ),
                  ).animate().slideX(begin: 0.1, delay: 500.ms, curve: Curves.easeOutBack).fadeIn(),

                  const Gap(12),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: const Text(
                      'Email is managed by Firebase and cannot be changed here.',
                      style: TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w600),
                    ).animate().fadeIn(delay: 550.ms),
                  ),

                  const Gap(48),

                  // Save Button
                  NeoButton(
                    text: _hasChanged ? 'SAVE CHANGES' : 'NO CHANGES',
                    backgroundColor: _hasChanged ? AppColors.secondary : AppColors.white,
                    textColor: AppColors.textDark,
                    onPressed: _save,
                  ).animate().slideY(begin: 0.3, delay: 600.ms, curve: Curves.easeOutBack).fadeIn(),

                  const Gap(100),
                ],
              ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, IconData icon, int delayMs) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const Gap(8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textLight, letterSpacing: 2),
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
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.textDark),
          const Gap(8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }
}
