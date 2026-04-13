// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  TransactionType get type => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError; // Account linking
  String? get accountId => throw _privateConstructorUsedError;
  String? get transferToAccountId => throw _privateConstructorUsedError;
  double? get transferFee =>
      throw _privateConstructorUsedError; // Expense fields
  ExpenseCategory? get expenseCategory => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get receiptUrl => throw _privateConstructorUsedError;
  String? get receiptLocalPath => throw _privateConstructorUsedError;
  bool? get isRecurring => throw _privateConstructorUsedError; // Income fields
  IncomeSource? get incomeSource => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
          Transaction value, $Res Function(Transaction) then) =
      _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call(
      {String id,
      String userId,
      TransactionType type,
      double amount,
      DateTime date,
      String? accountId,
      String? transferToAccountId,
      double? transferFee,
      ExpenseCategory? expenseCategory,
      String? notes,
      String? receiptUrl,
      String? receiptLocalPath,
      bool? isRecurring,
      IncomeSource? incomeSource,
      DateTime createdAt});
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? amount = null,
    Object? date = null,
    Object? accountId = freezed,
    Object? transferToAccountId = freezed,
    Object? transferFee = freezed,
    Object? expenseCategory = freezed,
    Object? notes = freezed,
    Object? receiptUrl = freezed,
    Object? receiptLocalPath = freezed,
    Object? isRecurring = freezed,
    Object? incomeSource = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      accountId: freezed == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String?,
      transferToAccountId: freezed == transferToAccountId
          ? _value.transferToAccountId
          : transferToAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      transferFee: freezed == transferFee
          ? _value.transferFee
          : transferFee // ignore: cast_nullable_to_non_nullable
              as double?,
      expenseCategory: freezed == expenseCategory
          ? _value.expenseCategory
          : expenseCategory // ignore: cast_nullable_to_non_nullable
              as ExpenseCategory?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      receiptUrl: freezed == receiptUrl
          ? _value.receiptUrl
          : receiptUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      receiptLocalPath: freezed == receiptLocalPath
          ? _value.receiptLocalPath
          : receiptLocalPath // ignore: cast_nullable_to_non_nullable
              as String?,
      isRecurring: freezed == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool?,
      incomeSource: freezed == incomeSource
          ? _value.incomeSource
          : incomeSource // ignore: cast_nullable_to_non_nullable
              as IncomeSource?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
          _$TransactionImpl value, $Res Function(_$TransactionImpl) then) =
      __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      TransactionType type,
      double amount,
      DateTime date,
      String? accountId,
      String? transferToAccountId,
      double? transferFee,
      ExpenseCategory? expenseCategory,
      String? notes,
      String? receiptUrl,
      String? receiptLocalPath,
      bool? isRecurring,
      IncomeSource? incomeSource,
      DateTime createdAt});
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
      _$TransactionImpl _value, $Res Function(_$TransactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? amount = null,
    Object? date = null,
    Object? accountId = freezed,
    Object? transferToAccountId = freezed,
    Object? transferFee = freezed,
    Object? expenseCategory = freezed,
    Object? notes = freezed,
    Object? receiptUrl = freezed,
    Object? receiptLocalPath = freezed,
    Object? isRecurring = freezed,
    Object? incomeSource = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$TransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      accountId: freezed == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String?,
      transferToAccountId: freezed == transferToAccountId
          ? _value.transferToAccountId
          : transferToAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      transferFee: freezed == transferFee
          ? _value.transferFee
          : transferFee // ignore: cast_nullable_to_non_nullable
              as double?,
      expenseCategory: freezed == expenseCategory
          ? _value.expenseCategory
          : expenseCategory // ignore: cast_nullable_to_non_nullable
              as ExpenseCategory?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      receiptUrl: freezed == receiptUrl
          ? _value.receiptUrl
          : receiptUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      receiptLocalPath: freezed == receiptLocalPath
          ? _value.receiptLocalPath
          : receiptLocalPath // ignore: cast_nullable_to_non_nullable
              as String?,
      isRecurring: freezed == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool?,
      incomeSource: freezed == incomeSource
          ? _value.incomeSource
          : incomeSource // ignore: cast_nullable_to_non_nullable
              as IncomeSource?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionImpl implements _Transaction {
  const _$TransactionImpl(
      {required this.id,
      required this.userId,
      required this.type,
      required this.amount,
      required this.date,
      this.accountId,
      this.transferToAccountId,
      this.transferFee,
      this.expenseCategory,
      this.notes,
      this.receiptUrl,
      this.receiptLocalPath,
      this.isRecurring,
      this.incomeSource,
      required this.createdAt});

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final TransactionType type;
  @override
  final double amount;
  @override
  final DateTime date;
// Account linking
  @override
  final String? accountId;
  @override
  final String? transferToAccountId;
  @override
  final double? transferFee;
// Expense fields
  @override
  final ExpenseCategory? expenseCategory;
  @override
  final String? notes;
  @override
  final String? receiptUrl;
  @override
  final String? receiptLocalPath;
  @override
  final bool? isRecurring;
// Income fields
  @override
  final IncomeSource? incomeSource;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Transaction(id: $id, userId: $userId, type: $type, amount: $amount, date: $date, accountId: $accountId, transferToAccountId: $transferToAccountId, transferFee: $transferFee, expenseCategory: $expenseCategory, notes: $notes, receiptUrl: $receiptUrl, receiptLocalPath: $receiptLocalPath, isRecurring: $isRecurring, incomeSource: $incomeSource, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.transferToAccountId, transferToAccountId) ||
                other.transferToAccountId == transferToAccountId) &&
            (identical(other.transferFee, transferFee) ||
                other.transferFee == transferFee) &&
            (identical(other.expenseCategory, expenseCategory) ||
                other.expenseCategory == expenseCategory) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.receiptUrl, receiptUrl) ||
                other.receiptUrl == receiptUrl) &&
            (identical(other.receiptLocalPath, receiptLocalPath) ||
                other.receiptLocalPath == receiptLocalPath) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.incomeSource, incomeSource) ||
                other.incomeSource == incomeSource) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      type,
      amount,
      date,
      accountId,
      transferToAccountId,
      transferFee,
      expenseCategory,
      notes,
      receiptUrl,
      receiptLocalPath,
      isRecurring,
      incomeSource,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(
      this,
    );
  }
}

abstract class _Transaction implements Transaction {
  const factory _Transaction(
      {required final String id,
      required final String userId,
      required final TransactionType type,
      required final double amount,
      required final DateTime date,
      final String? accountId,
      final String? transferToAccountId,
      final double? transferFee,
      final ExpenseCategory? expenseCategory,
      final String? notes,
      final String? receiptUrl,
      final String? receiptLocalPath,
      final bool? isRecurring,
      final IncomeSource? incomeSource,
      required final DateTime createdAt}) = _$TransactionImpl;

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  TransactionType get type;
  @override
  double get amount;
  @override
  DateTime get date;
  @override // Account linking
  String? get accountId;
  @override
  String? get transferToAccountId;
  @override
  double? get transferFee;
  @override // Expense fields
  ExpenseCategory? get expenseCategory;
  @override
  String? get notes;
  @override
  String? get receiptUrl;
  @override
  String? get receiptLocalPath;
  @override
  bool? get isRecurring;
  @override // Income fields
  IncomeSource? get incomeSource;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
