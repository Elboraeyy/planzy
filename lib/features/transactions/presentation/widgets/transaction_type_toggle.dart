import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/features/transactions/data/models/transaction.dart';

class TransactionTypeToggle extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  const TransactionTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.zinc100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Expense',
              icon: '💸',
              isSelected: selectedType == TransactionType.expense,
              onTap: () => onTypeChanged(TransactionType.expense),
            ),
          ),
          const Gap(4),
          Expanded(
            child: _ToggleButton(
              label: 'Income',
              icon: '💰',
              isSelected: selectedType == TransactionType.income,
              onTap: () => onTypeChanged(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 16),
            ),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.textDark : AppColors.textLight,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
