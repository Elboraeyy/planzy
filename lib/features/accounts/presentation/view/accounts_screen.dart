import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';
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
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.border, width: 2.r),
                        boxShadow: [BoxShadow(color: AppColors.border, offset: Offset(3.w, 3.h))],
                      ),
                      child: Icon(LucideIcons.arrowLeft, size: 20.r),
                    ),
                  ),
                  Gap(16.w),
                  Expanded(
                    child: Text(
                      'MY VAULT',
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                  ),
                  // Privacy toggle
                  GestureDetector(
                    onTap: () => ref.read(privacyModeProvider.notifier).state = !isPrivate,
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: isPrivate ? AppColors.primary : AppColors.cardYellow,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.border, width: 2.r),
                        boxShadow: [BoxShadow(color: AppColors.border, offset: Offset(3.w, 3.h))],
                      ),
                      child: Icon(
                        isPrivate ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 20.r,
                        color: isPrivate ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: -0.3, curve: Curves.easeOutBack).fadeIn(),

            Gap(24.h),

            // ═══════ Total Balance ═══════
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: NeoCard(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL NET WORTH',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    Gap(8.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              isPrivate ? '• • • • •' : NumberFormat.decimalPattern().format(totalBal),
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 38.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -2,
                              ),
                            ),
                          ),
                        ),
                        if (!isPrivate) ...[
                          Gap(8.w),
                          Text(
                            currency,
                            style: TextStyle(color: AppColors.cardYellow, fontSize: 20.sp, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().slideY(begin: 0.15, curve: Curves.easeOutBack).fadeIn(),

            Gap(24.h),

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
                            padding: EdgeInsets.all(24.r),
                            decoration: BoxDecoration(
                              color: AppColors.cardYellow,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border, width: 3.r),
                              boxShadow: [BoxShadow(color: AppColors.border, offset: Offset(4.w, 4.h))],
                            ),
                            child: Icon(LucideIcons.wallet, size: 40.r, color: AppColors.textDark),
                          ),
                          Gap(24.h),
                          Text(
                            'NO ACCOUNTS YET',
                            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                          Gap(8.h),
                          Text(
                            'Add your first wallet, bank, or card',
                            style: TextStyle(color: AppColors.textLight, fontSize: 14.sp, fontWeight: FontWeight.w600),
                          ),
                          Gap(32.h),
                          NeoButton(
                            text: 'ADD ACCOUNT',
                            onPressed: () => context.push('/add-account'),
                            backgroundColor: AppColors.secondary,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, curve: Curves.easeOutBack),
                  );
                }

                return Expanded(
                  child: Column(
                    children: [
                      // Cards header row
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Row(
                          children: [
                            Text(
                              'ACCOUNTS',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                            const Spacer(),
                            Text(
                              '${accounts.length}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(16.h),

                      // Carousel
                      SizedBox(
                        height: 200.h,
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
                      ).animate().slideX(begin: 0.15, curve: Curves.easeOutBack).fadeIn(delay: 100.ms),

                      Gap(24.h),

                      // Action buttons row
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: LucideIcons.plus,
                                label: 'ADD',
                                color: AppColors.secondary,
                                onTap: () => context.push('/add-account'),
                              ),
                            ),
                            Gap(12.w),
                            Expanded(
                              child: _ActionButton(
                                icon: LucideIcons.arrowLeftRight,
                                label: 'TRANSFER',
                                color: AppColors.cardBlue,
                                onTap: () => context.push('/transfer'),
                              ),
                            ),
                          ],
                        ),
                      ).animate().slideY(begin: 0.2, curve: Curves.easeOutBack, delay: 200.ms).fadeIn(),

                      Gap(24.h),

                      // Quick list of all accounts
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
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
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.border, width: 3.r),
          boxShadow: [BoxShadow(color: AppColors.border, offset: Offset(5.w, 5.h))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: type + default badge
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    account.type.displayName.toUpperCase(),
                    style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
                const Spacer(),
                if (account.isDefault)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.cardYellow,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: AppColors.border, width: 2.r),
                    ),
                    child: Text(
                      'DEFAULT',
                      style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            // Account name
            Text(
              account.name.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            Gap(4.h),
            // Balance
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  isPrivate ? '• • • •' : NumberFormat.decimalPattern().format(account.balance),
                  style: TextStyle(color: Colors.white70, fontSize: 28.sp, fontWeight: FontWeight.w900),
                ),
                Gap(6.w),
                if (!isPrivate)
                  Text(
                    currency,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16.sp, fontWeight: FontWeight.w900),
                  ),
              ],
            ),
            // Last 4 digits if card
            if (account.lastFourDigits != null) ...[
              Gap(4.h),
              Text(
                '•••• •••• •••• ${account.lastFourDigits}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13.sp, fontWeight: FontWeight.w700, letterSpacing: 2),
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
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      backgroundColor: color,
      isInteractive: true,
      onTap: onTap,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20.r, color: AppColors.textDark),
          Gap(8.w),
          Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp, letterSpacing: 1)),
        ],
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
    return NeoCard(
      backgroundColor: AppColors.white,
      isInteractive: true,
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.border, width: 2.r),
            ),
            child: Text(
              account.iconEmoji ?? account.type.icon,
              style: TextStyle(fontSize: 20.sp),
            ),
          ),
          Gap(14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.sp),
                ),
                Text(
                  account.type.displayName,
                  style: TextStyle(color: AppColors.textLight, fontSize: 11.sp, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Text(
            isPrivate ? '• • •' : '${NumberFormat.compact().format(account.balance)} $currency',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
}
