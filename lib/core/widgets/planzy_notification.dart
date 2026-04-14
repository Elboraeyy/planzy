import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';

class PlanzyNotification {
  static OverlayEntry? _currentOverlay;

  static void show(
    BuildContext context, {
    required String message,
    NotificationType type = NotificationType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Remove any existing overlay
    _currentOverlay?.remove();
    _currentOverlay = null;

    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (context) => _NotificationWidget(
        message: message,
        type: type,
        onDismiss: () {
          _currentOverlay = null;
        },
      ),
    );

    _currentOverlay = entry;
    overlay.insert(entry);

    // Auto dismiss
    Future.delayed(duration, () {
      if (_currentOverlay == entry) {
        entry.remove();
        _currentOverlay = null;
      }
    });
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

enum NotificationType { success, error, warning, info }

class _NotificationWidget extends StatefulWidget {
  final String message;
  final NotificationType type;
  final VoidCallback onDismiss;

  const _NotificationWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    _controller.forward().then((_) {
      // Start auto-dismiss after animation completes
      // The actual dismissal is handled by the caller
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case NotificationType.success:
        return const Color(0xFF00C853); // Vibrant green
      case NotificationType.error:
        return AppColors.primary; // Deep maroon
      case NotificationType.warning:
        return AppColors.cardYellow; // Yellow
      case NotificationType.info:
        return AppColors.tertiary; // Cyber blue
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case NotificationType.success:
        return LucideIcons.checkCircle2;
      case NotificationType.error:
        return LucideIcons.xCircle;
      case NotificationType.warning:
        return LucideIcons.alertTriangle;
      case NotificationType.info:
        return LucideIcons.info;
    }
  }

  Color get _iconColor {
    switch (widget.type) {
      case NotificationType.warning:
        return AppColors.textDark;
      default:
        return AppColors.white;
    }
  }

  Color get _textColor {
    switch (widget.type) {
      case NotificationType.warning:
        return AppColors.textDark;
      default:
        return AppColors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    // Lower the notification position more (was 48, now 72)
    final safeTopPadding = statusBarHeight + 72;

    return Positioned(
      top: safeTopPadding,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: () {
              _controller.reverse().then((_) {
                widget.onDismiss();
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.border,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(_icon, color: _iconColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _controller.reverse().then((_) {
                        widget.onDismiss();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _textColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(LucideIcons.x, color: _textColor, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
