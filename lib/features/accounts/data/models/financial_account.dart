import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_account.freezed.dart';
part 'financial_account.g.dart';

enum AccountType {
  cash,
  bankAccount,
  eWallet,
  prepaidCard,
  savingsAccount,
  other,
}

extension AccountTypeExtension on AccountType {
  String get displayName {
    switch (this) {
      case AccountType.cash:
        return 'Cash on Hand';
      case AccountType.bankAccount:
        return 'Bank Account';
      case AccountType.eWallet:
        return 'E-Wallet';
      case AccountType.prepaidCard:
        return 'Prepaid Card';
      case AccountType.savingsAccount:
        return 'Savings Account';
      case AccountType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case AccountType.cash:
        return '💵';
      case AccountType.bankAccount:
        return '🏦';
      case AccountType.eWallet:
        return '📱';
      case AccountType.prepaidCard:
        return '💳';
      case AccountType.savingsAccount:
        return '🐷';
      case AccountType.other:
        return '🗂️';
    }
  }
}

@freezed
class FinancialAccount with _$FinancialAccount {
  const factory FinancialAccount({
    required String id,
    required String userId,
    required String name,
    required AccountType type,
    required double balance,
    @Default(false) bool isDefault,

    // Visual customization
    String? colorHex,
    String? iconEmoji,

    // Optional metadata — card details
    String? lastFourDigits,
    String? cardholderName,
    String? expiryDate,

    // Optional metadata — bank details
    String? iban,
    String? accountNumber,
    String? bankName,

    // Optional metadata — e-wallet details
    String? phoneNumber,
    String? walletProvider,

    // Notes
    String? notes,

    required DateTime createdAt,
  }) = _FinancialAccount;

  factory FinancialAccount.fromJson(Map<String, dynamic> json) =>
      _$FinancialAccountFromJson(json);
}
