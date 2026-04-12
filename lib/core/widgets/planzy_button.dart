import 'package:flutter/material.dart';
import 'package:planzy/core/theme/app_colors.dart';

class PlanzyButton extends StatelessWidget {
  const PlanzyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? AppColors.white : AppColors.primary,
        foregroundColor: isSecondary ? AppColors.textDark : AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        side: isSecondary ? BorderSide(color: AppColors.textDark.withValues(alpha: 0.1)) : null,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
