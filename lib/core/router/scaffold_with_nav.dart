import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
            left: 20,
            right: 20,
            bottom: 30,
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
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: AppColors.border, width: 4)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const Gap(32),
              const Text(
                "WHAT'S NEW?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: NeoCard(
                      backgroundColor: AppColors.cardYellow,
                      onTap: () {
                        context.pop();
                        context.push('/add-commitment');
                      },
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: const Column(
                        children: [
                          Icon(LucideIcons.repeat, size: 32, color: AppColors.textDark),
                          Gap(12),
                          Text('PAYMENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: NeoCard(
                      backgroundColor: AppColors.secondary,
                      onTap: () {
                        context.pop();
                        context.push('/add-goal');
                      },
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: const Column(
                        children: [
                          Icon(LucideIcons.target, size: 32, color: AppColors.textDark),
                          Gap(12),
                          Text('GOAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate().slideY(begin: 0.2, curve: Curves.easeOutBack),
              const Gap(16),
              // New Transaction button
              NeoCard(
                backgroundColor: AppColors.cardBlue,
                onTap: () {
                  context.pop();
                  context.push('/add-transaction');
                },
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(LucideIcons.wallet, size: 28, color: AppColors.textDark),
                    Gap(12),
                    Text('EXPENSE / INCOME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  ],
                ),
              ).animate().slideY(begin: 0.3, delay: 100.ms, curve: Curves.easeOutBack),
              const Gap(24),
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
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 3),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            icon: LucideIcons.calendarDays,
            label: 'TIME',
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
            size: isSelected ? 28 : 24,
          ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), curve: Curves.easeOutBack),
          const Gap(4),
          if (isSelected)
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
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
        transform: Matrix4.translationValues(0, _isPressed ? 4 : -10, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 3),
          boxShadow: [
            if (!_isPressed)
              const BoxShadow(
                color: AppColors.border,
                offset: Offset(0, 6),
              ),
          ],
        ),
        child: const Icon(LucideIcons.plus, color: AppColors.white, size: 30),
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
