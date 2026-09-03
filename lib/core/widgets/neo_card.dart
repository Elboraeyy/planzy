import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:planzy/core/theme/app_colors.dart';

class NeoCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;
  final bool isInteractive;
  final VoidCallback? onTap;

  const NeoCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor = AppColors.white,
    this.isInteractive = false,
    this.onTap,
  });

  @override
  State<NeoCard> createState() => _NeoCardState();
}

class _NeoCardState extends State<NeoCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.isInteractive || widget.onTap != null) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isInteractive || widget.onTap != null) {
      setState(() => _isPressed = false);
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    if (widget.isInteractive || widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(_isPressed ? 0.985 : 1.0, _isPressed ? 0.985 : 1.0, 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border, width: 1.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: widget.padding ?? EdgeInsets.all(20.r),
          child: widget.child,
        ),
      ),
    );

    return card;
  }
}
