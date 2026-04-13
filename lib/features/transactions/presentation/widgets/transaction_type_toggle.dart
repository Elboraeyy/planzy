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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 3),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'EXPENSE',
              icon: '💸',
              isSelected: selectedType == TransactionType.expense,
              selectedColor: AppColors.primary,
              onTap: () => onTypeChanged(TransactionType.expense),
            ),
          ),
          const Gap(4),
          Expanded(
            child: _ToggleButton(
              label: 'INCOME',
              icon: '💰',
              isSelected: selectedType == TransactionType.income,
              selectedColor: AppColors.secondary,
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
  final Color selectedColor;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppColors.border, width: 2)
              : null,
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.border,
                    offset: Offset(2, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 18),
            ),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.textDark : AppColors.textLight,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
