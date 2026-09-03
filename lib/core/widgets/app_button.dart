import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? trailing;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.prefix,
    this.suffix,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ShadButton(
      onPressed: onPressed,
      width: double.infinity,
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null || prefix != null) ...[ icon ?? prefix!, const SizedBox(width: 8) ],
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (suffix != null || trailing != null) ...[
            const SizedBox(width: 8),
            suffix ?? trailing!,
          ]
        ],
      ),
    );
  }
}
