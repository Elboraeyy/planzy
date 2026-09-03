import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:planzy/core/theme/app_colors.dart';

class NeoDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    String? cancelText,
    required VoidCallback onConfirm,
    bool isDestructive = false,
    Widget? customContent,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Gap(8),
                    if (customContent != null)
                      customContent
                    else
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textLight,
                          height: 1.5,
                        ),
                      ),
                    const Gap(24),
                    Row(
                      children: [
                        if (cancelText != null) ...[
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.zinc100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border, width: 1),
                                ),
                                child: Text(
                                  cancelText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Gap(12),
                        ],
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              onConfirm();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isDestructive ? AppColors.destructive : AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                confirmText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutCubic, duration: 150.ms).fadeIn(),
            ),
          ),
        );
      },
    );
  }
}
