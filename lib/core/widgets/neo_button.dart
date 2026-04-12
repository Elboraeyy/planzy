import 'package:flutter/material.dart';
import 'package:planzy/core/theme/app_colors.dart';

class NeoButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;

  const NeoButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor = AppColors.primary,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) => setState(() => _isPressed = true);
  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onPressed();
  }
  void _handleTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    const double shadowOffset = 6.0;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(
          _isPressed ? shadowOffset - 2 : 0, 
          _isPressed ? shadowOffset - 2 : 0, 
          0
        ),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.border,
              offset: Offset(
                _isPressed ? 0 : shadowOffset, 
                _isPressed ? 0 : shadowOffset
              ),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.text.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textDark, // With Neo-brutalism, button text is often bold black
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
