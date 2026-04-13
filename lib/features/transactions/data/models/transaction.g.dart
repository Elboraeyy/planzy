// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      expenseCategory: $enumDecodeNullable(
          _$ExpenseCategoryEnumMap, json['expenseCategory']),
      notes: json['notes'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      receiptLocalPath: json['receiptLocalPath'] as String?,
      isRecurring: json['isRecurring'] as bool?,
      incomeSource:
          $enumDecodeNullable(_$IncomeSourceEnumMap, json['incomeSource']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'expenseCategory': _$ExpenseCategoryEnumMap[instance.expenseCategory],
      'notes': instance.notes,
      'receiptUrl': instance.receiptUrl,
      'receiptLocalPath': instance.receiptLocalPath,
      'isRecurring': instance.isRecurring,
      'incomeSource': _$IncomeSourceEnumMap[instance.incomeSource],
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.expense: 'expense',
  TransactionType.income: 'income',
};

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.food: 'food',
  ExpenseCategory.transport: 'transport',
  ExpenseCategory.shopping: 'shopping',
  ExpenseCategory.bills: 'bills',
  ExpenseCategory.health: 'health',
  ExpenseCategory.entertainment: 'entertainment',
  ExpenseCategory.education: 'education',
  ExpenseCategory.rent: 'rent',
  ExpenseCategory.other: 'other',
};

const _$IncomeSourceEnumMap = {
  IncomeSource.salary: 'salary',
  IncomeSource.freelance: 'freelance',
  IncomeSource.bonus: 'bonus',
  IncomeSource.investment: 'investment',
  IncomeSource.gift: 'gift',
  IncomeSource.refund: 'refund',
  IncomeSource.other: 'other',
};
