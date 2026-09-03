import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/features/transactions/data/models/transaction.dart';

class CategorySelector extends StatelessWidget {
  final TransactionType type;
  final dynamic selectedCategory;
  final ValueChanged<dynamic> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.type,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (type == TransactionType.expense) {
      return _ExpenseCategorySelector(
        selectedCategory: selectedCategory as ExpenseCategory?,
        onCategorySelected: onCategorySelected,
      );
    } else {
      return _IncomeSourceSelector(
        selectedSource: selectedCategory as IncomeSource?,
        onSourceSelected: onCategorySelected,
      );
    }
  }
}

class _ExpenseCategorySelector extends StatelessWidget {
  final ExpenseCategory? selectedCategory;
  final ValueChanged<ExpenseCategory> onCategorySelected;

  const _ExpenseCategorySelector({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: AppColors.textDark,
          ),
        ),
        const Gap(10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.2,
          children: ExpenseCategory.values.map((category) {
            final isSelected = category == selectedCategory;
            return _CategoryItem(
              icon: category.icon,
              label: _getShortLabel(category.displayName),
              isSelected: isSelected,
              onTap: () => onCategorySelected(category),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getShortLabel(String displayName) {
    if (displayName.contains('&')) {
      return displayName.split(' & ')[0];
    }
    return displayName;
  }
}

class _IncomeSourceSelector extends StatelessWidget {
  final IncomeSource? selectedSource;
  final ValueChanged<IncomeSource> onSourceSelected;

  const _IncomeSourceSelector({
    required this.selectedSource,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Income Source',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: AppColors.textDark,
          ),
        ),
        const Gap(10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.2,
          children: IncomeSource.values.map((source) {
            final isSelected = source == selectedSource;
            return _CategoryItem(
              icon: source.icon,
              label: source.displayName,
              isSelected: isSelected,
              onTap: () => onSourceSelected(source),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.label,
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
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 22),
            ),
            const Gap(6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: -0.2,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
