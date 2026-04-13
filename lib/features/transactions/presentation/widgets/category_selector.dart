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
          'CATEGORY',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const Gap(12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
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
          'SOURCE',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const Gap(12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
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
        curve: Curves.easeOutBack,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.border,
                    offset: Offset(4, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const Gap(4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isSelected ? AppColors.textDark : AppColors.textLight,
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
