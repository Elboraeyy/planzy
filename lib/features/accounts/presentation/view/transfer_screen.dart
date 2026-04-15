import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          error: (error, stack) => '',
        );

    return Scaffold(
      appBar: AppBar(
        title: Text('TRANSFER', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900)),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.textDark, size: 24.r),
          onPressed: () => context.pop(),
        ),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.length < 2) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('You need at least 2 accounts to make a transfer.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                    Gap(24.h),
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
            padding: EdgeInsets.all(24.r),
            children: [
              // ═══════ FROM ═══════
              Text('FROM', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
              Gap(12.h),
              _AccountSelector(
                accounts: accounts,
                selectedId: _fromAccountId,
                excludeId: _toAccountId,
                currency: currency,
                onSelected: (id) => setState(() => _fromAccountId = id),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),

              Gap(8.h),

              // Arrow indicator
              Center(
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.cardYellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 2.r),
                    boxShadow: [BoxShadow(color: AppColors.border, offset: Offset(2.w, 2.h))],
                  ),
                  child: Icon(LucideIcons.arrowDown, size: 20.r, color: AppColors.textDark),
                ),
              ).animate().fadeIn(delay: 200.ms).scale(curve: Curves.easeOutBack),

              Gap(8.h),

              // ═══════ TO ═══════
              Text('TO', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
              Gap(12.h),
              _AccountSelector(
                accounts: accounts,
                selectedId: _toAccountId,
                excludeId: _fromAccountId,
                currency: currency,
                onSelected: (id) => setState(() => _toAccountId = id),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),

              Gap(32.h),

              // ═══════ Amount ═══════
              Text('AMOUNT', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
              Gap(12.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border, width: 3.r),
                  boxShadow: [BoxShadow(color: AppColors.border, offset: Offset(4.w, 4.h))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        border: Border(right: BorderSide(color: AppColors.border, width: 3.r)),
                      ),
                      child: Text(currency, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

              Gap(24.h),

              // ═══════ Fee (optional) ═══════
              Text('TRANSFER FEE', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, letterSpacing: 1)),
              Gap(4.h),
              Text('Deducted from source account', style: TextStyle(color: AppColors.textLight, fontSize: 12.sp, fontWeight: FontWeight.w600)),
              Gap(12.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border, width: 2.r),
                  boxShadow: [BoxShadow(color: AppColors.border, offset: Offset(2.w, 2.h))],
                ),
                child: TextField(
                  controller: _feeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixIcon: Icon(LucideIcons.percent, color: AppColors.textLight, size: 20.r),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    suffixText: currency,
                    suffixStyle: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textLight, fontSize: 14.sp),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),

              // Summary preview
              if (fromAccount != null && toAccount != null && _amountController.text.isNotEmpty) ...[
                Gap(24.h),
                NeoCard(
                  backgroundColor: AppColors.background,
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${fromAccount.name}:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp)),
                          Text(
                            NumberFormat.decimalPattern().format(fromAccount.balance),
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp),
                          ),
                        ],
                      ),
                      Gap(4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${toAccount.name}:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp)),
                          Text(
                            NumberFormat.decimalPattern().format(toAccount.balance),
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              Gap(40.h),

              // ═══════ Transfer Button ═══════
              NeoButton(
                text: _isLoading ? 'TRANSFERRING...' : 'TRANSFER FUNDS',
                onPressed: _isLoading ? () {} : _transfer,
                backgroundColor: AppColors.cardBlue,
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

              Gap(100.h),
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
      height: 84.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filteredAccounts.length,
        separatorBuilder: (context, index) => Gap(12.w),
        itemBuilder: (context, index) {
          final account = filteredAccounts[index];
          final isSelected = account.id == selectedId;

          return GestureDetector(
            onTap: () => onSelected(account.id),
            child: AnimatedContainer(
              duration: 200.ms,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.border, width: 2.r),
                boxShadow: isSelected ? [BoxShadow(color: AppColors.border, offset: Offset(3.w, 3.h))] : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    account.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14.sp,
                      color: isSelected ? AppColors.white : AppColors.textDark,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    '${NumberFormat.compact().format(account.balance)} $currency',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
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


