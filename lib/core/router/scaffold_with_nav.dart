import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';

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
            bottom: 30.h,
            child: _NeoNavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: _goBranch,
              onAddTap: () => _showAddMenu(context),
            ),
          ).animate().slideY(begin: 1, curve: Curves.easeOutBack, duration: 800.ms),
        ],
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            border: Border(top: BorderSide(color: AppColors.border, width: 4.r)),
          ),
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
              Gap(32.h),
              Text(
                "WHAT'S NEW?",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              Gap(24.h),
              Row(
                children: [
                  Expanded(
                    child: NeoCard(
                      backgroundColor: AppColors.cardYellow,
                      onTap: () {
                        context.pop();
                        context.push('/add-commitment');
                      },
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Column(
                        children: [
                          Icon(LucideIcons.repeat, size: 32.r, color: AppColors.textDark),
                          Gap(12.h),
                          Text('PAYMENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp)),
                        ],
                      ),
                    ),
                  ),
                  Gap(16.w),
                  Expanded(
                    child: NeoCard(
                      backgroundColor: AppColors.secondary,
                      onTap: () {
                        context.pop();
                        context.push('/add-goal');
                      },
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Column(
                        children: [
                          Icon(LucideIcons.target, size: 32.r, color: AppColors.textDark),
                          Gap(12.h),
                          Text('GOAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp)),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate().slideY(begin: 0.2, curve: Curves.easeOutBack),
              Gap(16.h),
              // New Transaction button
              NeoCard(
                backgroundColor: AppColors.cardBlue,
                onTap: () {
                  context.pop();
                  context.push('/add-transaction');
                },
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.wallet, size: 28.r, color: AppColors.textDark),
                    Gap(12.w),
                    Text('EXPENSE / INCOME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp)),
                  ],
                ),
              ).animate().slideY(begin: 0.3, delay: 100.ms, curve: Curves.easeOutBack),
              Gap(24.h),
            ],
          ),
        );
      },
    );
  }
}

class _NeoNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onAddTap;

  const _NeoNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border, width: 3.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.border,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavBarItem(
            icon: LucideIcons.home,
            label: 'HOME',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavBarItem(
            icon: LucideIcons.wrench,
            label: 'TOOLS',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          // Central Add Button
          _CentralAddButton(onTap: onAddTap),
          _NavBarItem(
            icon: LucideIcons.pieChart,
            label: 'INSIGHTS',
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _NavBarItem(
            icon: LucideIcons.user,
            label: 'ME',
            isSelected: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textLight,
            size: isSelected ? 28.r : 24.r,
          ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), curve: Curves.easeOutBack),
          Gap(4.h),
          if (isSelected)
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn().slideY(begin: 0.5),
        ],
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
        duration: 100.ms,
        transform: Matrix4.translationValues(0, _isPressed ? 0 : -24.h, 0),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 3.r),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: AppColors.border,
                offset: Offset(0, 6.h),
              ),
          ],
        ),
        child: Icon(LucideIcons.plus, color: AppColors.white, size: 32.r),
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
