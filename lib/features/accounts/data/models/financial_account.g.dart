// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FinancialAccountImpl _$$FinancialAccountImplFromJson(
        Map<String, dynamic> json) =>
    _$FinancialAccountImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$AccountTypeEnumMap, json['type']),
      balance: (json['balance'] as num).toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
      colorHex: json['colorHex'] as String?,
      iconEmoji: json['iconEmoji'] as String?,
      lastFourDigits: json['lastFourDigits'] as String?,
      cardholderName: json['cardholderName'] as String?,
      expiryDate: json['expiryDate'] as String?,
      iban: json['iban'] as String?,
      accountNumber: json['accountNumber'] as String?,
      bankName: json['bankName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      walletProvider: json['walletProvider'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$FinancialAccountImplToJson(
        _$FinancialAccountImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'type': _$AccountTypeEnumMap[instance.type]!,
      'balance': instance.balance,
      'isDefault': instance.isDefault,
      'colorHex': instance.colorHex,
      'iconEmoji': instance.iconEmoji,
      'lastFourDigits': instance.lastFourDigits,
      'cardholderName': instance.cardholderName,
      'expiryDate': instance.expiryDate,
      'iban': instance.iban,
      'accountNumber': instance.accountNumber,
      'bankName': instance.bankName,
      'phoneNumber': instance.phoneNumber,
      'walletProvider': instance.walletProvider,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$AccountTypeEnumMap = {
  AccountType.cash: 'cash',
  AccountType.bankAccount: 'bankAccount',
  AccountType.eWallet: 'eWallet',
  AccountType.prepaidCard: 'prepaidCard',
  AccountType.savingsAccount: 'savingsAccount',
  AccountType.other: 'other',
};
