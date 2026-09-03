import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/features/accounts/data/models/financial_account.dart';
import 'package:planzy/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  final PageController _cardController = PageController(viewportFraction: 0.85);

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final currency = ref.watch(settingsProvider).when(
          data: (s) => s.currency,
          loading: () => '',
          error: (error, stack) => '',
        );
    final totalBal = ref.watch(totalBalanceProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════ Top Bar ═══════
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColors.border, width: 1.r),
                      ),
                      child: Icon(LucideIcons.arrowLeft, size: 18.r, color: AppColors.textDark),
                    ),
                  ),
                  Gap(14.w),
                  Expanded(
                    child: Text(
                      'My Vault',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  // Privacy toggle
                  GestureDetector(
                    onTap: () => ref.read(privacyModeProvider.notifier).state = !isPrivate,
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: isPrivate ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(10.r),
                        border: isPrivate
                            ? null
                            : Border.all(color: AppColors.border, width: 1.r),
                      ),
                      child: Icon(
                        isPrivate ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 18.r,
                        color: isPrivate ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            Gap(16.h),

            // ═══════ Total Balance (Obsidian Bento Card) ═══════
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                padding: EdgeInsets.all(22.r),
                decoration: BoxDecoration(
                  color: AppColors.zinc950,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.zinc800,
                    width: 1.r,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Gap(8.w),
                        Text(
                          'TOTAL NET WORTH',
                          style: TextStyle(
                            color: AppColors.zinc400,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Gap(10.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              isPrivate ? '• • • • • •' : NumberFormat.decimalPattern().format(totalBal),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                        ),
                        if (!isPrivate) ...[
                          Gap(8.w),
                          Text(
                            currency,
                            style: TextStyle(
                              color: AppColors.zinc400,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().slideY(begin: 0.05).fadeIn(),

            Gap(20.h),

            // ═══════ Account Cards Carousel ═══════
            accountsAsync.when(
              data: (accounts) {
                if (accounts.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(20.r),
                            decoration: BoxDecoration(
                              color: AppColors.zinc100,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border, width: 1.r),
                            ),
                            child: Icon(LucideIcons.wallet, size: 36.r, color: AppColors.zinc500),
                          ),
                          Gap(16.h),
                          Text(
                            'No accounts yet',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                              color: AppColors.textDark,
                            ),
                          ),
                          Gap(4.h),
                          Text(
                            'Add your first wallet, bank, or card',
                            style: TextStyle(color: AppColors.textLight, fontSize: 13.sp),
                          ),
                          Gap(24.h),
                          SizedBox(
                            width: 180.w,
                            child: NeoButton(
                              text: 'Add Account',
                              height: 44.h,
                              onPressed: () => context.push('/add-account'),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 150.ms),
                  );
                }

                return Expanded(
                  child: Column(
                    children: [
                      // Cards header row
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            Text(
                              'Cards & Accounts',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                                color: AppColors.textDark,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppColors.zinc100,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                '${accounts.length}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(12.h),

                      // Carousel
                      SizedBox(
                        height: 175.h,
                        child: PageView.builder(
                          controller: _cardController,
                          itemCount: accounts.length,
                          itemBuilder: (context, index) {
                            final account = accounts[index];
                            return _AccountCard(
                              account: account,
                              currency: currency,
                              isPrivate: isPrivate,
                              onTap: () => context.push('/account-detail', extra: account),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 100.ms),

                      Gap(16.h),

                      // Action buttons row
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: LucideIcons.plus,
                                label: 'Add Account',
                                isPrimary: true,
                                onTap: () => context.push('/add-account'),
                              ),
                            ),
                            Gap(10.w),
                            Expanded(
                              child: _ActionButton(
                                icon: LucideIcons.arrowLeftRight,
                                label: 'Transfer',
                                isPrimary: false,
                                onTap: () => context.push('/transfer'),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 150.ms),

                      Gap(16.h),

                      // Quick list of all accounts
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: accounts.length,
                          separatorBuilder: (context, index) => Gap(8.h),
                          itemBuilder: (context, index) {
                            final account = accounts[index];
                            return _AccountListTile(
                              account: account,
                              currency: currency,
                              isPrivate: isPrivate,
                              onTap: () => context.push('/account-detail', extra: account),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Expanded(
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              error: (err, _) => Expanded(child: Center(child: Text('Error: $err'))),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// ACCOUNT CARD — Visual Credit/Debit Card Style
// ═══════════════════════════════════════════════════════
class _AccountCard extends StatelessWidget {
  final FinancialAccount account;
  final String currency;
  final bool isPrivate;
  final VoidCallback onTap;

  const _AccountCard({
    required this.account,
    required this.currency,
    required this.isPrivate,
    required this.onTap,
  });

  Color get _cardColor {
    if (account.colorHex != null) {
      return Color(int.parse('FF${account.colorHex}', radix: 16));
    }
    switch (account.type) {
      case AccountType.cash:
        return const Color(0xFF2E7D32);
      case AccountType.bankAccount:
        return const Color(0xFF1565C0);
      case AccountType.eWallet:
        return const Color(0xFF6A1B9A);
      case AccountType.prepaidCard:
        return const Color(0xFFE65100);
      case AccountType.savingsAccount:
        return const Color(0xFF00838F);
      case AccountType.other:
        return AppColors.textDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.r,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: type + default badge
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    account.type.displayName.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(),
                if (account.isDefault)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'DEFAULT',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            // Account name
            Text(
              account.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            Gap(2.h),
            // Balance
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  isPrivate ? '• • • •' : NumberFormat.decimalPattern().format(account.balance),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Gap(6.w),
                if (!isPrivate)
                  Text(
                    currency,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            // Last 4 digits if card
            if (account.lastFourDigits != null) ...[
              Gap(4.h),
              Text(
                '•••• •••• •••• ${account.lastFourDigits}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// ACTION BUTTON
// ═══════════════════════════════════════════════════════
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.zinc100,
          borderRadius: BorderRadius.circular(10.r),
          border: isPrimary
              ? null
              : Border.all(color: AppColors.border, width: 1.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.r,
              color: isPrimary ? Colors.white : AppColors.textDark,
            ),
            Gap(8.w),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                letterSpacing: -0.2,
                color: isPrimary ? Colors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// ACCOUNT LIST TILE — Compact version for list view
// ═══════════════════════════════════════════════════════
class _AccountListTile extends StatelessWidget {
  final FinancialAccount account;
  final String currency;
  final bool isPrivate;
  final VoidCallback onTap;

  const _AccountListTile({
    required this.account,
    required this.currency,
    required this.isPrivate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border, width: 1.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: AppColors.zinc100,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Text(
                  account.iconEmoji ?? account.type.icon,
                  style: TextStyle(fontSize: 18.sp),
                ),
              ),
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: AppColors.textDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    account.type.displayName,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              isPrivate ? '• • •' : '${NumberFormat.compact().format(account.balance)} $currency',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                color: AppColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
