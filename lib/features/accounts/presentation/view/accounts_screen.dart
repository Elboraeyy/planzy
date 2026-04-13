import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          error: (_, __) => '',
        );
    final totalBal = ref.watch(totalBalanceProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════ Top Bar ═══════
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 2),
                        boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(3, 3))],
                      ),
                      child: const Icon(LucideIcons.arrowLeft, size: 20),
                    ),
                  ),
                  const Gap(16),
                  const Expanded(
                    child: Text(
                      'MY VAULT',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                  ),
                  // Privacy toggle
                  GestureDetector(
                    onTap: () => ref.read(privacyModeProvider.notifier).state = !isPrivate,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isPrivate ? AppColors.primary : AppColors.cardYellow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 2),
                        boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(3, 3))],
                      ),
                      child: Icon(
                        isPrivate ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 20,
                        color: isPrivate ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: -0.3, curve: Curves.easeOutBack).fadeIn(),

            const Gap(24),

            // ═══════ Total Balance ═══════
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: NeoCard(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL NET WORTH',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const Gap(8),
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
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -2,
                              ),
                            ),
                          ),
                        ),
                        if (!isPrivate) ...[
                          const Gap(8),
                          Text(
                            currency,
                            style: const TextStyle(color: AppColors.cardYellow, fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().slideY(begin: 0.15, curve: Curves.easeOutBack).fadeIn(),

            const Gap(24),

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
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.cardYellow,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border, width: 3),
                              boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(4, 4))],
                            ),
                            child: const Icon(LucideIcons.wallet, size: 40, color: AppColors.textDark),
                          ),
                          const Gap(24),
                          const Text(
                            'NO ACCOUNTS YET',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                          const Gap(8),
                          const Text(
                            'Add your first wallet, bank, or card',
                            style: TextStyle(color: AppColors.textLight, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const Gap(32),
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
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            const Text(
                              'ACCOUNTS',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                            const Spacer(),
                            Text(
                              '${accounts.length}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),

                      // Carousel
                      SizedBox(
                        height: 200,
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

                      const Gap(24),

                      // Action buttons row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
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
                            const Gap(12),
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

                      const Gap(24),

                      // Quick list of all accounts
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: accounts.length,
                          separatorBuilder: (_, __) => const Gap(8),
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
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 3),
          boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(5, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: type + default badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    account.type.displayName.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
                const Spacer(),
                if (account.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cardYellow,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    child: const Text(
                      'DEFAULT',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            // Account name
            Text(
              account.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const Gap(4),
            // Balance
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  isPrivate ? '• • • •' : NumberFormat.decimalPattern().format(account.balance),
                  style: const TextStyle(color: Colors.white70, fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const Gap(6),
                if (!isPrivate)
                  Text(
                    currency,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16, fontWeight: FontWeight.w900),
                  ),
              ],
            ),
            // Last 4 digits if card
            if (account.lastFourDigits != null) ...[
              const Gap(4),
              Text(
                '•••• •••• •••• ${account.lastFourDigits}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 2),
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.textDark),
          const Gap(8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: Text(
              account.iconEmoji ?? account.type.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
                Text(
                  account.type.displayName,
                  style: const TextStyle(color: AppColors.textLight, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Text(
            isPrivate ? '• • •' : '${NumberFormat.compact().format(account.balance)} $currency',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
