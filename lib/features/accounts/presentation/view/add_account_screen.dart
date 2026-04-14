import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/core/widgets/planzy_notification.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/features/accounts/data/models/financial_account.dart';
import 'package:planzy/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

  // Card color choices
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

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        if (mounted) {
          PlanzyNotification.show(
            context,
            message: 'User not authenticated',
            type: NotificationType.error,
          );
        }
        return;
      }

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
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Account' : 'Add Account'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // ═══════ Account Type Selector ═══════
            const Text('TYPE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const Gap(12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AccountType.values.map((type) {
                final isSelected = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 2),
                      boxShadow: isSelected ? const [BoxShadow(color: AppColors.border, offset: Offset(3, 3))] : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(type.icon, style: const TextStyle(fontSize: 18)),
                        const Gap(6),
                        Text(
                          type.displayName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isSelected ? AppColors.white : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),

            const Gap(28),

            // ═══════ Account Name ═══════
            const Text('NAME', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const Gap(12),
            _NeoTextField(
              controller: _nameController,
              hint: 'e.g. Vodafone Cash, NBE Visa',
              icon: LucideIcons.tag,
              validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
            ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),

            const Gap(28),

            // ═══════ Balance ═══════
            const Text('CURRENT BALANCE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const Gap(12),
            _NeoTextField(
              controller: _balanceController,
              hint: '0.00',
              icon: LucideIcons.coins,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Required';
                if (double.tryParse(val) == null) return 'Invalid amount';
                return null;
              },
            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),

            const Gap(28),

            // ═══════ Card Color ═══════
            const Text('CARD COLOR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const Gap(12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colorChoices.map((hex) {
                final isSelected = _selectedColor == hex;
                final color = hex != null
                    ? Color(int.parse('FF$hex', radix: 16))
                    : AppColors.textLight;

                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: hex != null ? color : null,
                      gradient: hex == null
                          ? const LinearGradient(colors: [Colors.red, Colors.blue, Colors.green])
                          : null,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.cardYellow : AppColors.border,
                        width: isSelected ? 4 : 2,
                      ),
                      boxShadow: isSelected ? const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))] : null,
                    ),
                    child: hex == null
                        ? const Center(child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)))
                        : null,
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 400.ms),

            const Gap(28),

            // ═══════ Default Toggle ═══════
            GestureDetector(
              onTap: () => setState(() => _isDefault = !_isDefault),
              child: NeoCard(
                backgroundColor: _isDefault ? AppColors.cardYellow : AppColors.white,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(LucideIcons.star, size: 20, color: AppColors.textDark),
                    const Gap(12),
                    const Expanded(
                      child: Text('SET AS DEFAULT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
                    ),
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: _isDefault ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: _isDefault
                          ? const Icon(Icons.check, size: 16, color: AppColors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),

            const Gap(28),

            // ═══════ Optional Details Toggle ═══════
            GestureDetector(
              onTap: () => setState(() => _showDetails = !_showDetails),
              child: Row(
                children: [
                  const Text('ACCOUNT DETAILS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const Gap(8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('OPTIONAL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                  const Spacer(),
                  Icon(_showDetails ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 20),
                ],
              ),
            ),

            if (_showDetails) ...[
              const Gap(16),
              ..._buildDetailFields(),
            ],

            const Gap(40),

            // ═══════ Save Button ═══════
            NeoButton(
              text: _isLoading ? 'SAVING...' : (isEditing ? 'UPDATE ACCOUNT' : 'CREATE ACCOUNT'),
              onPressed: _isLoading ? () {} : _save,
              backgroundColor: AppColors.primary,
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

            const Gap(100),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDetailFields() {
    switch (_selectedType) {
      case AccountType.prepaidCard:
        return [
          _NeoTextField(controller: _lastFourController, hint: 'Last 4 digits', icon: LucideIcons.creditCard),
          const Gap(12),
          _NeoTextField(controller: _cardholderController, hint: 'Cardholder name', icon: LucideIcons.user),
          const Gap(12),
          _NeoTextField(controller: _expiryController, hint: 'Expiry (MM/YY)', icon: LucideIcons.calendar),
        ];
      case AccountType.bankAccount:
      case AccountType.savingsAccount:
        return [
          _NeoTextField(controller: _bankNameController, hint: 'Bank name', icon: LucideIcons.building2),
          const Gap(12),
          _NeoTextField(controller: _accountNumberController, hint: 'Account number', icon: LucideIcons.hash),
          const Gap(12),
          _NeoTextField(controller: _ibanController, hint: 'IBAN', icon: LucideIcons.globe),
        ];
      case AccountType.eWallet:
        return [
          _NeoTextField(controller: _walletProviderController, hint: 'Provider (e.g. Vodafone Cash)', icon: LucideIcons.smartphone),
          const Gap(12),
          _NeoTextField(controller: _phoneController, hint: 'Phone number', icon: LucideIcons.phone),
        ];
      default:
        return [
          _NeoTextField(controller: _notesController, hint: 'Notes', icon: LucideIcons.fileText),
        ];
    }
  }
}

// ═══════════════════════════════════════════════════════
// REUSABLE NEO TEXT FIELD
// ═══════════════════════════════════════════════════════
class _NeoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _NeoTextField({
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 3),
        boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(3, 3))],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.textLight),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
