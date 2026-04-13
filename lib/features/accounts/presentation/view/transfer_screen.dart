import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/core/widgets/planzy_notification.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/features/accounts/data/models/financial_account.dart';
import 'package:planzy/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _amountController = TextEditingController();
  final _feeController = TextEditingController(text: '0');
  String? _fromAccountId;
  String? _toAccountId;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _transfer() async {
    if (_fromAccountId == null || _toAccountId == null) {
      PlanzyNotification.show(context, message: 'Select both accounts', type: NotificationType.warning);
      return;
    }
    if (_fromAccountId == _toAccountId) {
      PlanzyNotification.show(context, message: 'Cannot transfer to the same account', type: NotificationType.warning);
      return;
    }
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      PlanzyNotification.show(context, message: 'Enter a valid amount', type: NotificationType.warning);
      return;
    }
    final fee = double.tryParse(_feeController.text) ?? 0;

    setState(() => _isLoading = true);

    try {
      await ref.read(accountsProvider.notifier).transfer(
            fromAccountId: _fromAccountId!,
            toAccountId: _toAccountId!,
            amount: amount,
            fee: fee,
          );

      if (mounted) {
        PlanzyNotification.show(context, message: 'Transfer complete!', type: NotificationType.success);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        PlanzyNotification.show(context, message: '$e', type: NotificationType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final currency = ref.watch(settingsProvider).when(
          data: (s) => s.currency,
          loading: () => '',
          error: (_, __) => '',
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.length < 2) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('You need at least 2 accounts to make a transfer.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const Gap(24),
                    NeoButton(
                      text: 'ADD ACCOUNT',
                      onPressed: () => context.push('/add-account'),
                      backgroundColor: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            );
          }

          final fromAccount = accounts.where((a) => a.id == _fromAccountId).firstOrNull;
          final toAccount = accounts.where((a) => a.id == _toAccountId).firstOrNull;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // ═══════ FROM ═══════
              const Text('FROM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const Gap(12),
              _AccountSelector(
                accounts: accounts,
                selectedId: _fromAccountId,
                excludeId: _toAccountId,
                currency: currency,
                onSelected: (id) => setState(() => _fromAccountId = id),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),

              const Gap(8),

              // Arrow indicator
              Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardYellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 2),
                    boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))],
                  ),
                  child: const Icon(LucideIcons.arrowDown, size: 20, color: AppColors.textDark),
                ),
              ).animate().fadeIn(delay: 200.ms).scale(curve: Curves.easeOutBack),

              const Gap(8),

              // ═══════ TO ═══════
              const Text('TO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const Gap(12),
              _AccountSelector(
                accounts: accounts,
                selectedId: _toAccountId,
                excludeId: _fromAccountId,
                currency: currency,
                onSelected: (id) => setState(() => _toAccountId = id),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),

              const Gap(32),

              // ═══════ Amount ═══════
              const Text('AMOUNT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const Gap(12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 3),
                  boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(4, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        border: Border(right: BorderSide(color: AppColors.border, width: 3)),
                      ),
                      child: Text(currency, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

              const Gap(24),

              // ═══════ Fee (optional) ═══════
              const Text('TRANSFER FEE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const Gap(4),
              const Text('Deducted from source account', style: TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.w600)),
              const Gap(12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 2),
                  boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))],
                ),
                child: TextField(
                  controller: _feeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixIcon: const Icon(LucideIcons.percent, color: AppColors.textLight),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixText: currency,
                    suffixStyle: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textLight),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),

              // Summary preview
              if (fromAccount != null && toAccount != null && _amountController.text.isNotEmpty) ...[
                const Gap(24),
                NeoCard(
                  backgroundColor: AppColors.background,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${fromAccount.name}:', style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(
                            NumberFormat.decimalPattern().format(fromAccount.balance),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const Gap(4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${toAccount.name}:', style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(
                            NumberFormat.decimalPattern().format(toAccount.balance),
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const Gap(40),

              // ═══════ Transfer Button ═══════
              NeoButton(
                text: _isLoading ? 'TRANSFERRING...' : 'TRANSFER FUNDS',
                onPressed: _isLoading ? () {} : _transfer,
                backgroundColor: AppColors.cardBlue,
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

              const Gap(100),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// ACCOUNT SELECTOR — horizontally scrollable chips
// ═══════════════════════════════════════════════════════
class _AccountSelector extends StatelessWidget {
  final List<FinancialAccount> accounts;
  final String? selectedId;
  final String? excludeId;
  final String currency;
  final Function(String) onSelected;

  const _AccountSelector({
    required this.accounts,
    required this.selectedId,
    required this.excludeId,
    required this.currency,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filteredAccounts = accounts.where((a) => a.id != excludeId).toList();

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filteredAccounts.length,
        separatorBuilder: (_, __) => const Gap(10),
        itemBuilder: (context, index) {
          final account = filteredAccounts[index];
          final isSelected = account.id == selectedId;

          return GestureDetector(
            onTap: () => onSelected(account.id),
            child: AnimatedContainer(
              duration: 200.ms,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: isSelected ? const [BoxShadow(color: AppColors.border, offset: Offset(3, 3))] : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    account.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: isSelected ? AppColors.white : AppColors.textDark,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '${NumberFormat.compact().format(account.balance)} $currency',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
