import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';

class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 24.h,
            child: _ModernDockNavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: _goBranch,
              onAddTap: () => _showAddMenu(context),
            ),
          ).animate().slideY(begin: 1, curve: Curves.easeOutCubic, duration: 400.ms),
        ],
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border.all(color: AppColors.border, width: 1.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 30,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 36.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.zinc300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Gap(20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Gap(2.h),
                    Text(
                      'Select an action to continue',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(20.h),
              _QuickActionItem(
                title: 'New Transaction',
                subtitle: 'Record an expense or income',
                icon: LucideIcons.receipt,
                iconColor: AppColors.primary,
                iconBg: AppColors.zinc100,
                onTap: () {
                  context.pop();
                  context.push('/add-transaction');
                },
              ),
              Gap(10.h),
              _QuickActionItem(
                title: 'New Savings Goal',
                subtitle: 'Set a target for your future',
                icon: LucideIcons.target,
                iconColor: AppColors.success,
                iconBg: AppColors.successLight,
                onTap: () {
                  context.pop();
                  context.push('/add-goal');
                },
              ),
              Gap(10.h),
              _QuickActionItem(
                title: 'Transfer Funds',
                subtitle: 'Move money between accounts',
                icon: LucideIcons.arrowLeftRight,
                iconColor: AppColors.accentBlue,
                iconBg: AppColors.accentBlueLight,
                onTap: () {
                  context.pop();
                  context.push('/transfer');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border, width: 1.r),
        ),
        child: Row(
          children: [
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.r),
            ),
            Gap(14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16.r, color: AppColors.zinc400),
          ],
        ),
      ),
    );
  }
}

class _ModernDockNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddTap;

  const _ModernDockNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 64.h,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.border, width: 1.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavBarItem(
                icon: LucideIcons.home,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavBarItem(
                icon: LucideIcons.wrench,
                label: 'Tools',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _CentralAddButton(onTap: onAddTap),
              _NavBarItem(
                icon: LucideIcons.pieChart,
                label: 'Insights',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavBarItem(
                icon: LucideIcons.user,
                label: 'Profile',
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.zinc100 : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.textDark : AppColors.zinc400,
              size: 20.r,
            ),
            Gap(2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.textDark : AppColors.zinc400,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CentralAddButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CentralAddButton({required this.onTap});

  @override
  State<_CentralAddButton> createState() => _CentralAddButtonState();
}

class _CentralAddButtonState extends State<_CentralAddButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(_isPressed ? 0.92 : 1.0, _isPressed ? 0.92 : 1.0, 1.0),
        transformAlignment: Alignment.center,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(LucideIcons.plus, color: Colors.white, size: 22.r),
      ),
    );
  }
}

class Gap extends StatelessWidget {
  final double value;
  const Gap(this.value, {super.key});
  @override
  Widget build(BuildContext context) => SizedBox(width: value, height: value);
}
