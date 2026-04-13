// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'financial_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FinancialAccount _$FinancialAccountFromJson(Map<String, dynamic> json) {
  return _FinancialAccount.fromJson(json);
}

/// @nodoc
mixin _$FinancialAccount {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  AccountType get type => throw _privateConstructorUsedError;
  double get balance => throw _privateConstructorUsedError;
  bool get isDefault =>
      throw _privateConstructorUsedError; // Visual customization
  String? get colorHex => throw _privateConstructorUsedError;
  String? get iconEmoji =>
      throw _privateConstructorUsedError; // Optional metadata — card details
  String? get lastFourDigits => throw _privateConstructorUsedError;
  String? get cardholderName => throw _privateConstructorUsedError;
  String? get expiryDate =>
      throw _privateConstructorUsedError; // Optional metadata — bank details
  String? get iban => throw _privateConstructorUsedError;
  String? get accountNumber => throw _privateConstructorUsedError;
  String? get bankName =>
      throw _privateConstructorUsedError; // Optional metadata — e-wallet details
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get walletProvider => throw _privateConstructorUsedError; // Notes
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FinancialAccountCopyWith<FinancialAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FinancialAccountCopyWith<$Res> {
  factory $FinancialAccountCopyWith(
          FinancialAccount value, $Res Function(FinancialAccount) then) =
      _$FinancialAccountCopyWithImpl<$Res, FinancialAccount>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      AccountType type,
      double balance,
      bool isDefault,
      String? colorHex,
      String? iconEmoji,
      String? lastFourDigits,
      String? cardholderName,
      String? expiryDate,
      String? iban,
      String? accountNumber,
      String? bankName,
      String? phoneNumber,
      String? walletProvider,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class _$FinancialAccountCopyWithImpl<$Res, $Val extends FinancialAccount>
    implements $FinancialAccountCopyWith<$Res> {
  _$FinancialAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? type = null,
    Object? balance = null,
    Object? isDefault = null,
    Object? colorHex = freezed,
    Object? iconEmoji = freezed,
    Object? lastFourDigits = freezed,
    Object? cardholderName = freezed,
    Object? expiryDate = freezed,
    Object? iban = freezed,
    Object? accountNumber = freezed,
    Object? bankName = freezed,
    Object? phoneNumber = freezed,
    Object? walletProvider = freezed,
    Object? notes = freezed,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AccountType,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      colorHex: freezed == colorHex
          ? _value.colorHex
          : colorHex // ignore: cast_nullable_to_non_nullable
              as String?,
      iconEmoji: freezed == iconEmoji
          ? _value.iconEmoji
          : iconEmoji // ignore: cast_nullable_to_non_nullable
              as String?,
      lastFourDigits: freezed == lastFourDigits
          ? _value.lastFourDigits
          : lastFourDigits // ignore: cast_nullable_to_non_nullable
              as String?,
      cardholderName: freezed == cardholderName
          ? _value.cardholderName
          : cardholderName // ignore: cast_nullable_to_non_nullable
              as String?,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as String?,
      iban: freezed == iban
          ? _value.iban
          : iban // ignore: cast_nullable_to_non_nullable
              as String?,
      accountNumber: freezed == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      bankName: freezed == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      walletProvider: freezed == walletProvider
          ? _value.walletProvider
          : walletProvider // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FinancialAccountImplCopyWith<$Res>
    implements $FinancialAccountCopyWith<$Res> {
  factory _$$FinancialAccountImplCopyWith(_$FinancialAccountImpl value,
          $Res Function(_$FinancialAccountImpl) then) =
      __$$FinancialAccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      AccountType type,
      double balance,
      bool isDefault,
      String? colorHex,
      String? iconEmoji,
      String? lastFourDigits,
      String? cardholderName,
      String? expiryDate,
      String? iban,
      String? accountNumber,
      String? bankName,
      String? phoneNumber,
      String? walletProvider,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class __$$FinancialAccountImplCopyWithImpl<$Res>
    extends _$FinancialAccountCopyWithImpl<$Res, _$FinancialAccountImpl>
    implements _$$FinancialAccountImplCopyWith<$Res> {
  __$$FinancialAccountImplCopyWithImpl(_$FinancialAccountImpl _value,
      $Res Function(_$FinancialAccountImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? type = null,
    Object? balance = null,
    Object? isDefault = null,
    Object? colorHex = freezed,
    Object? iconEmoji = freezed,
    Object? lastFourDigits = freezed,
    Object? cardholderName = freezed,
    Object? expiryDate = freezed,
    Object? iban = freezed,
    Object? accountNumber = freezed,
    Object? bankName = freezed,
    Object? phoneNumber = freezed,
    Object? walletProvider = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$FinancialAccountImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AccountType,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      colorHex: freezed == colorHex
          ? _value.colorHex
          : colorHex // ignore: cast_nullable_to_non_nullable
              as String?,
      iconEmoji: freezed == iconEmoji
          ? _value.iconEmoji
          : iconEmoji // ignore: cast_nullable_to_non_nullable
              as String?,
      lastFourDigits: freezed == lastFourDigits
          ? _value.lastFourDigits
          : lastFourDigits // ignore: cast_nullable_to_non_nullable
              as String?,
      cardholderName: freezed == cardholderName
          ? _value.cardholderName
          : cardholderName // ignore: cast_nullable_to_non_nullable
              as String?,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as String?,
      iban: freezed == iban
          ? _value.iban
          : iban // ignore: cast_nullable_to_non_nullable
              as String?,
      accountNumber: freezed == accountNumber
          ? _value.accountNumber
          : accountNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      bankName: freezed == bankName
          ? _value.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      walletProvider: freezed == walletProvider
          ? _value.walletProvider
          : walletProvider // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FinancialAccountImpl implements _FinancialAccount {
  const _$FinancialAccountImpl(
      {required this.id,
      required this.userId,
      required this.name,
      required this.type,
      required this.balance,
      this.isDefault = false,
      this.colorHex,
      this.iconEmoji,
      this.lastFourDigits,
      this.cardholderName,
      this.expiryDate,
      this.iban,
      this.accountNumber,
      this.bankName,
      this.phoneNumber,
      this.walletProvider,
      this.notes,
      required this.createdAt});

  factory _$FinancialAccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$FinancialAccountImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final AccountType type;
  @override
  final double balance;
  @override
  @JsonKey()
  final bool isDefault;
// Visual customization
  @override
  final String? colorHex;
  @override
  final String? iconEmoji;
// Optional metadata — card details
  @override
  final String? lastFourDigits;
  @override
  final String? cardholderName;
  @override
  final String? expiryDate;
// Optional metadata — bank details
  @override
  final String? iban;
  @override
  final String? accountNumber;
  @override
  final String? bankName;
// Optional metadata — e-wallet details
  @override
  final String? phoneNumber;
  @override
  final String? walletProvider;
// Notes
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'FinancialAccount(id: $id, userId: $userId, name: $name, type: $type, balance: $balance, isDefault: $isDefault, colorHex: $colorHex, iconEmoji: $iconEmoji, lastFourDigits: $lastFourDigits, cardholderName: $cardholderName, expiryDate: $expiryDate, iban: $iban, accountNumber: $accountNumber, bankName: $bankName, phoneNumber: $phoneNumber, walletProvider: $walletProvider, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FinancialAccountImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.iconEmoji, iconEmoji) ||
                other.iconEmoji == iconEmoji) &&
            (identical(other.lastFourDigits, lastFourDigits) ||
                other.lastFourDigits == lastFourDigits) &&
            (identical(other.cardholderName, cardholderName) ||
                other.cardholderName == cardholderName) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.iban, iban) || other.iban == iban) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.bankName, bankName) ||
                other.bankName == bankName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.walletProvider, walletProvider) ||
                other.walletProvider == walletProvider) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      type,
      balance,
      isDefault,
      colorHex,
      iconEmoji,
      lastFourDigits,
      cardholderName,
      expiryDate,
      iban,
      accountNumber,
      bankName,
      phoneNumber,
      walletProvider,
      notes,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FinancialAccountImplCopyWith<_$FinancialAccountImpl> get copyWith =>
      __$$FinancialAccountImplCopyWithImpl<_$FinancialAccountImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FinancialAccountImplToJson(
      this,
    );
  }
}

abstract class _FinancialAccount implements FinancialAccount {
  const factory _FinancialAccount(
      {required final String id,
      required final String userId,
      required final String name,
      required final AccountType type,
      required final double balance,
      final bool isDefault,
      final String? colorHex,
      final String? iconEmoji,
      final String? lastFourDigits,
      final String? cardholderName,
      final String? expiryDate,
      final String? iban,
      final String? accountNumber,
      final String? bankName,
      final String? phoneNumber,
      final String? walletProvider,
      final String? notes,
      required final DateTime createdAt}) = _$FinancialAccountImpl;

  factory _FinancialAccount.fromJson(Map<String, dynamic> json) =
      _$FinancialAccountImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  AccountType get type;
  @override
  double get balance;
  @override
  bool get isDefault;
  @override // Visual customization
  String? get colorHex;
  @override
  String? get iconEmoji;
  @override // Optional metadata — card details
  String? get lastFourDigits;
  @override
  String? get cardholderName;
  @override
  String? get expiryDate;
  @override // Optional metadata — bank details
  String? get iban;
  @override
  String? get accountNumber;
  @override
  String? get bankName;
  @override // Optional metadata — e-wallet details
  String? get phoneNumber;
  @override
  String? get walletProvider;
  @override // Notes
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$FinancialAccountImplCopyWith<_$FinancialAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
