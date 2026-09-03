import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/app_button.dart';
import 'package:planzy/core/widgets/app_card.dart';

class AppDialog {
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
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: AppCard(
                backgroundColor: AppColors.background,
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Gap(16),
                    if (customContent != null)
                      customContent
                    else
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    Gap(32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppButton(
                          text: confirmText,
                          backgroundColor: isDestructive ? Colors.red : AppColors.secondary,
                          textColor: isDestructive ? AppColors.white : AppColors.textDark,
                          onPressed: () {
                            Navigator.pop(context);
                            onConfirm();
                          },
                        ),
                        if (cancelText != null) ...[
                          Gap(16),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border, width: 1),
                              ),
                              child: Text(
                                cancelText.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppColors.textDark,
                                  
                                ),
                              ),
                            ),
                          ),
                        ]
                      ],
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
}
