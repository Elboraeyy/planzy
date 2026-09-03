import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:planzy/core/widgets/planzy_notification.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/features/accounts/data/models/financial_account.dart';
import 'package:planzy/features/accounts/presentation/providers/accounts_provider.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Transfer Funds',
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
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.length < 2) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.zinc100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.arrowLeftRight, size: 32.r, color: AppColors.textLight),
                    ),
                    Gap(16.h),
                    Text(
                      'You need at least 2 accounts to make a transfer.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    Gap(20.h),
                    NeoButton(
                      text: 'Add Account',
                      onPressed: () => context.push('/add-account'),
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          }

          final fromAccount = accounts.where((a) => a.id == _fromAccountId).firstOrNull;
          final toAccount = accounts.where((a) => a.id == _toAccountId).firstOrNull;

          return ListView(
            padding: EdgeInsets.all(20.r),
            children: [
              // FROM
              Text(
                'From Account',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              Gap(10.h),
              _AccountSelector(
                accounts: accounts,
                selectedId: _fromAccountId,
                excludeId: _toAccountId,
                currency: currency,
                onSelected: (id) => setState(() => _fromAccountId = id),
              ),

              Gap(12.h),

              // Arrow indicator
              Center(
                child: Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: AppColors.zinc100,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1.r),
                  ),
                  child: Icon(LucideIcons.arrowDown, size: 18.r, color: AppColors.textDark),
                ),
              ),

              Gap(12.h),

              // TO
              Text(
                'To Account',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              Gap(10.h),
              _AccountSelector(
                accounts: accounts,
                selectedId: _toAccountId,
                excludeId: _fromAccountId,
                currency: currency,
                onSelected: (id) => setState(() => _toAccountId = id),
              ),

              Gap(24.h),

              // Amount
              Text(
                'Transfer Amount',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              Gap(10.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.border, width: 1.r),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: AppColors.zinc100,
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(13.r)),
                      ),
                      child: Text(
                        currency,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(color: AppColors.zinc300),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Gap(20.h),

              // Fee (optional)
              Text(
                'Transfer Fee (Optional)',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              Gap(2.h),
              Text(
                'Deducted directly from source account',
                style: TextStyle(color: AppColors.textLight, fontSize: 11.sp, fontWeight: FontWeight.w400),
              ),
              Gap(10.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border, width: 1.r),
                ),
                child: TextField(
                  controller: _feeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixIcon: Icon(LucideIcons.percent, color: AppColors.zinc400, size: 18.r),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    suffixText: currency,
                    suffixStyle: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textLight, fontSize: 13.sp),
                  ),
                ),
              ),

              // Summary preview
              if (fromAccount != null && toAccount != null && _amountController.text.isNotEmpty) ...[
                Gap(20.h),
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: AppColors.zinc50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border, width: 1.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('From ${fromAccount.name}:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp, color: AppColors.textDark)),
                          Text(
                            '${NumberFormat.decimalPattern().format(fromAccount.balance)} $currency',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      Gap(6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('To ${toAccount.name}:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp, color: AppColors.textDark)),
                          Text(
                            '${NumberFormat.decimalPattern().format(toAccount.balance)} $currency',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp, color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              Gap(32.h),

              // Transfer Button
              NeoButton(
                text: _isLoading ? 'Transferring...' : 'Transfer Funds',
                onPressed: _isLoading ? () {} : _transfer,
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
              ),

              Gap(40.h),
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
      height: 72.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filteredAccounts.length,
        separatorBuilder: (context, index) => Gap(10.w),
        itemBuilder: (context, index) {
          final account = filteredAccounts[index];
          final isSelected = account.id == selectedId;

          return GestureDetector(
            onTap: () => onSelected(account.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1.r,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(account.type.icon, style: TextStyle(fontSize: 14.sp)),
                      Gap(6.w),
                      Text(
                        account.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  Gap(4.h),
                  Text(
                    '${NumberFormat.compact().format(account.balance)} $currency',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
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
