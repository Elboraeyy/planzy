import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReceiptPicker extends ConsumerWidget {
  final File? localImage;
  final String? remoteUrl;
  final Function(File) onImageSelected;
  final VoidCallback? onImageRemoved;

  const ReceiptPicker({
    super.key,
    this.localImage,
    this.remoteUrl,
    required this.onImageSelected,
    this.onImageRemoved,
  });

  Future<void> _showSourceDialog(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.zinc300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(16),
              const Text(
                'Attach Receipt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
              const Gap(20),
              Row(
                children: [
                  Expanded(
                    child: _SourceButton(
                      icon: LucideIcons.camera,
                      label: 'Camera',
                      onTap: () async {
                        Navigator.pop(context);
                        final storage = ref.read(storageServiceProvider);
                        final image = await storage.pickFromCamera();
                        if (image != null) {
                          onImageSelected(image);
                        }
                      },
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _SourceButton(
                      icon: LucideIcons.image,
                      label: 'Gallery',
                      onTap: () async {
                        Navigator.pop(context);
                        final storage = ref.read(storageServiceProvider);
                        final image = await storage.pickFromGallery();
                        if (image != null) {
                          onImageSelected(image);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const Gap(12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasImage = localImage != null || remoteUrl != null;

    if (!hasImage) {
      return GestureDetector(
        onTap: () => _showSourceDialog(context, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.zinc100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.camera,
                  size: 22,
                  color: AppColors.zinc500,
                ),
              ),
              const Gap(10),
              const Text(
                'Attach Receipt',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: AppColors.textDark,
                ),
              ),
              const Gap(2),
              const Text(
                'Optional image or proof',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () => _showSourceDialog(context, ref),
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: localImage != null
                ? Image.file(
                    localImage!,
                    fit: BoxFit.cover,
                  )
                : remoteUrl != null
                    ? Image.network(
                        remoteUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          LucideIcons.image,
                          size: 40,
                          color: AppColors.textLight,
                        ),
                      )
                    : null,
          ),
        ),
        if (onImageRemoved != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onImageRemoved,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.x,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.zinc100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: AppColors.textDark,
            ),
            const Gap(6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
