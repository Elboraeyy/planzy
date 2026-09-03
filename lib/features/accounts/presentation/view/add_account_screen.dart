import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:planzy/core/widgets/planzy_notification.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/features/accounts/data/models/financial_account.dart';
import 'package:planzy/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:uuid/uuid.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  final FinancialAccount? existingAccount;

  const AddAccountScreen({super.key, this.existingAccount});

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  // Optional metadata controllers
  final _lastFourController = TextEditingController();
  final _cardholderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _ibanController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _walletProviderController = TextEditingController();
  final _notesController = TextEditingController();

  AccountType _selectedType = AccountType.cash;
  bool _isDefault = false;
  bool _showDetails = false;
  bool _isLoading = false;

  static const _colorChoices = [
    null, // Auto-based on type
    '2E7D32', // Green
    '1565C0', // Blue
    '6A1B9A', // Purple
    'E65100', // Orange
    '00838F', // Teal
    'C62828', // Red
    '283593', // Indigo
    '4E342E', // Brown
    '37474F', // Blue Grey
    '111111', // Black
  ];
  String? _selectedColor;

  @override
  void initState() {
    super.initState();
    if (widget.existingAccount != null) {
      final a = widget.existingAccount!;
      _nameController.text = a.name;
      _balanceController.text = a.balance.toString();
      _selectedType = a.type;
      _isDefault = a.isDefault;
      _selectedColor = a.colorHex;
      _lastFourController.text = a.lastFourDigits ?? '';
      _cardholderController.text = a.cardholderName ?? '';
      _expiryController.text = a.expiryDate ?? '';
      _ibanController.text = a.iban ?? '';
      _accountNumberController.text = a.accountNumber ?? '';
      _bankNameController.text = a.bankName ?? '';
      _phoneController.text = a.phoneNumber ?? '';
      _walletProviderController.text = a.walletProvider ?? '';
      _notesController.text = a.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _lastFourController.dispose();
    _cardholderController.dispose();
    _expiryController.dispose();
    _ibanController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _phoneController.dispose();
    _walletProviderController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      PlanzyNotification.show(context, message: 'Please sign in first', type: NotificationType.warning);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final account = FinancialAccount(
        id: widget.existingAccount?.id ?? const Uuid().v4(),
        userId: user.uid,
        name: _nameController.text.trim(),
        type: _selectedType,
        balance: double.parse(_balanceController.text),
        isDefault: _isDefault,
        colorHex: _selectedColor,
        lastFourDigits: _lastFourController.text.isNotEmpty ? _lastFourController.text : null,
        cardholderName: _cardholderController.text.isNotEmpty ? _cardholderController.text : null,
        expiryDate: _expiryController.text.isNotEmpty ? _expiryController.text : null,
        iban: _ibanController.text.isNotEmpty ? _ibanController.text : null,
        accountNumber: _accountNumberController.text.isNotEmpty ? _accountNumberController.text : null,
        bankName: _bankNameController.text.isNotEmpty ? _bankNameController.text : null,
        phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        walletProvider: _walletProviderController.text.isNotEmpty ? _walletProviderController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: widget.existingAccount?.createdAt ?? DateTime.now(),
      );

      await ref.read(accountsProvider.notifier).add(account);

      if (_isDefault) {
        await ref.read(accountsProvider.notifier).setDefault(account.id);
      }

      if (mounted) {
        PlanzyNotification.show(
          context,
          message: widget.existingAccount != null ? 'Account updated!' : 'Account added!',
          type: NotificationType.success,
        );
        context.pop();
      }
    } catch (e) {
      debugPrint('Error saving account: $e');
      if (mounted) {
        PlanzyNotification.show(
          context,
          message: 'Error: ${e.toString()}',
          type: NotificationType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAccount != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Account' : 'Add Account',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.3,
          ),
        ),
        leading: Center(
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: AppColors.zinc100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(LucideIcons.arrowLeft, color: AppColors.textDark, size: 18.r),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20.r),
          children: [
            // Account Type Selector
            Text(
              'Account Type',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
            Gap(10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: AccountType.values.map((type) {
                final isSelected = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 1.r,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(type.icon, style: TextStyle(fontSize: 16.sp)),
                        Gap(6.w),
                        Text(
                          type.displayName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            Gap(24.h),

            // Account Name
            Text(
              'Account Name',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
            Gap(10.h),
            _ShadTextField(
              controller: _nameController,
              hint: 'e.g. Vodafone Cash, NBE Visa',
              icon: LucideIcons.tag,
              validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
            ),

            Gap(24.h),

            // Balance
            Text(
              'Current Balance',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
            Gap(10.h),
            _ShadTextField(
              controller: _balanceController,
              hint: '0.00',
              icon: LucideIcons.coins,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Required';
                if (double.tryParse(val) == null) return 'Invalid amount';
                return null;
              },
            ),

            Gap(24.h),

            // Card Color
            Text(
              'Card Color',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
            Gap(10.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: _colorChoices.map((hex) {
                final isSelected = _selectedColor == hex;
                final color = hex != null
                    ? Color(int.parse('FF$hex', radix: 16))
                    : AppColors.textLight;

                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 34.r,
                    height: 34.r,
                    decoration: BoxDecoration(
                      color: hex != null ? color : null,
                      gradient: hex == null
                          ? const LinearGradient(colors: [Colors.red, Colors.blue, Colors.green])
                          : null,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: isSelected ? 3.r : 0,
                      ),
                    ),
                    child: hex == null
                        ? Center(child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11.sp)))
                        : null,
                  ),
                );
              }).toList(),
            ),

            Gap(24.h),

            // Default Toggle
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.border, width: 1.r),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.zinc100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(LucideIcons.star, size: 18.r, color: AppColors.textDark),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set as Default Account',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            color: AppColors.textDark,
                          ),
                        ),
                        Gap(2.h),
                        Text(
                          'Used for quick transactions and balance overview',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isDefault,
                    onChanged: (val) => setState(() => _isDefault = val),
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            Gap(24.h),

            // Optional Details Toggle
            GestureDetector(
              onTap: () => setState(() => _showDetails = !_showDetails),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.border, width: 1.r),
                ),
                child: Row(
                  children: [
                    Text(
                      'Account Details',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Gap(8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.zinc100,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'Optional',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _showDetails ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                      size: 18.r,
                      color: AppColors.zinc400,
                    ),
                  ],
                ),
              ),
            ),

            if (_showDetails) ...[
              Gap(12.h),
              ..._buildDetailFields(),
            ],

            Gap(36.h),

            // Save Button
            NeoButton(
              text: _isLoading ? 'Saving...' : (isEditing ? 'Update Account' : 'Create Account'),
              onPressed: _isLoading ? () {} : _save,
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
            ),

            Gap(40.h),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetailFields() {
    switch (_selectedType) {
      case AccountType.prepaidCard:
        return [
          _ShadTextField(controller: _lastFourController, hint: 'Last 4 digits', icon: LucideIcons.creditCard),
          Gap(10.h),
          _ShadTextField(controller: _cardholderController, hint: 'Cardholder name', icon: LucideIcons.user),
          Gap(10.h),
          _ShadTextField(controller: _expiryController, hint: 'Expiry (MM/YY)', icon: LucideIcons.calendar),
        ];
      case AccountType.bankAccount:
      case AccountType.savingsAccount:
        return [
          _ShadTextField(controller: _bankNameController, hint: 'Bank name', icon: LucideIcons.building2),
          Gap(10.h),
          _ShadTextField(controller: _accountNumberController, hint: 'Account number', icon: LucideIcons.hash),
          Gap(10.h),
          _ShadTextField(controller: _ibanController, hint: 'IBAN', icon: LucideIcons.globe),
        ];
      case AccountType.eWallet:
        return [
          _ShadTextField(controller: _walletProviderController, hint: 'Provider (e.g. Vodafone Cash)', icon: LucideIcons.smartphone),
          Gap(10.h),
          _ShadTextField(controller: _phoneController, hint: 'Phone number', icon: LucideIcons.phone),
        ];
      default:
        return [
          _ShadTextField(controller: _notesController, hint: 'Notes', icon: LucideIcons.fileText),
        ];
    }
  }
}

class _ShadTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ShadTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border, width: 1.r),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.textLight,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: AppColors.zinc400, size: 18.r),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        ),
      ),
    );
  }
}
