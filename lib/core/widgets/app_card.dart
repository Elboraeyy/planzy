import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:planzy/core/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;
  final bool isInteractive;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor = AppColors.card,
    this.isInteractive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = ShadCard(
      padding: padding ?? const EdgeInsets.all(20),
      backgroundColor: backgroundColor,
      child: child,
    );

    if (isInteractive || onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: card,
        ),
      );
    }

    return card;
  }
}
