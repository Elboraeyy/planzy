import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.border, width: 3),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(20),
              const Text(
                'ATTACH RECEIPT',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.camera_alt,
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
                  const Gap(16),
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.photo_library,
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
              const Gap(16),
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 3),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  size: 40,
                  color: AppColors.textLight,
                ),
              ),
              const Gap(12),
              const Text(
                'ATTACH RECEIPT',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: AppColors.textLight,
                ),
              ),
              const Text(
                'Optional',
                style: TextStyle(
                  fontSize: 12,
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
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.border,
                  offset: Offset(4, 4),
                ),
              ],
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
                          Icons.broken_image,
                          size: 50,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: const Icon(
                  Icons.close,
                  size: 20,
                  color: AppColors.white,
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
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 3),
          boxShadow: const [
            BoxShadow(
              color: AppColors.border,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.textDark,
            ),
            const Gap(8),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
