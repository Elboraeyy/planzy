import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

enum TransactionType { expense, income, transfer }

enum ExpenseCategory {
  food,
  transport,
  shopping,
  bills,
  health,
  entertainment,
  education,
  rent,
  other,
}

enum IncomeSource {
  salary,
  freelance,
  bonus,
  investment,
  gift,
  refund,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food & Dining';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.bills:
        return 'Bills & Utilities';
      case ExpenseCategory.health:
        return 'Health';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.education:
        return 'Education';
      case ExpenseCategory.rent:
        return 'Rent';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.food:
        return '🍔';
      case ExpenseCategory.transport:
        return '🚗';
      case ExpenseCategory.shopping:
        return '🛒';
      case ExpenseCategory.bills:
        return '💡';
      case ExpenseCategory.health:
        return '💊';
      case ExpenseCategory.entertainment:
        return '🎬';
      case ExpenseCategory.education:
        return '📚';
      case ExpenseCategory.rent:
        return '🏠';
      case ExpenseCategory.other:
        return '📦';
    }
  }
}

extension IncomeSourceExtension on IncomeSource {
  String get displayName {
    switch (this) {
      case IncomeSource.salary:
        return 'Salary';
      case IncomeSource.freelance:
        return 'Freelance';
      case IncomeSource.bonus:
        return 'Bonus';
      case IncomeSource.investment:
        return 'Investment';
      case IncomeSource.gift:
        return 'Gift';
      case IncomeSource.refund:
        return 'Refund';
      case IncomeSource.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case IncomeSource.salary:
        return '💰';
      case IncomeSource.freelance:
        return '💻';
      case IncomeSource.bonus:
        return '🎁';
      case IncomeSource.investment:
        return '📈';
      case IncomeSource.gift:
        return '🎀';
      case IncomeSource.refund:
        return '↩️';
      case IncomeSource.other:
        return '💵';
    }
  }
}

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String userId,
    required TransactionType type,
    required double amount,
    required DateTime date,

    // Account linking
    String? accountId,
    String? transferToAccountId,
    double? transferFee,

    // Expense fields
    ExpenseCategory? expenseCategory,
    String? notes,
    String? receiptUrl,
    String? receiptLocalPath,
    bool? isRecurring,

    // Income fields
    IncomeSource? incomeSource,

    required DateTime createdAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
