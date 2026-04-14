import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/features/commitments/presentation/providers/commitments_provider.dart';
import 'package:planzy/features/goals/presentation/providers/goals_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final commitmentsAsync = ref.watch(commitmentsProvider);
    final goalsAsync = ref.watch(goalsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: settingsAsync.when(
          data: (settings) {
            final userName = settings.userName.isNotEmpty
                ? settings.userName
                : 'Planner';
            final userEmail = currentUser?.email ?? settings.userEmail;
            final userBio = settings.userBio;
            final currency = settings.currency;
            final profileImagePath = settings.profileImagePath;

            // Stats
            final totalCommitments = commitmentsAsync.when(
              data: (list) => list.fold<double>(0, (sum, i) => sum + i.amount),
              loading: () => 0.0,
              error: (_, _) => 0.0,
            );
            final totalSaved = goalsAsync.when(
              data: (list) => list.fold<double>(0, (sum, i) => sum + i.savedAmount),
              loading: () => 0.0,
              error: (_, _) => 0.0,
            );
            final goalsCount = goalsAsync.when(
              data: (list) => list.length,
              loading: () => 0,
              error: (_, _) => 0,
            );

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                // Top bar with settings icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PROFILE',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/settings'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardYellow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 3),
                          boxShadow: const [
                            BoxShadow(color: AppColors.border, offset: Offset(4, 4)),
                          ],
                        ),
                        child: const Icon(LucideIcons.settings, color: AppColors.textDark, size: 22),
                      ),
                    ).animate().slideX(begin: 1, curve: Curves.easeOutBack),
                  ],
                ),
                const Gap(32),

                // Profile Card — big hero section
                SizedBox(
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      NeoCard(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              children: [
                                // Avatar
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 4,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: AppColors.border,
                                        offset: Offset(4, 4),
                                      ),
                                    ],
                                    image:
                                        (profileImagePath != null &&
                                            File(profileImagePath).existsSync())
                                        ? DecorationImage(
                                            image: FileImage(
                                              File(profileImagePath),
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child:
                                      (profileImagePath == null ||
                                          !File(profileImagePath).existsSync())
                                      ? Center(
                                          child: Text(
                                            userName.isNotEmpty
                                                ? userName[0].toUpperCase()
                                                : 'P',
                                            style: const TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                        )
                                      : null,
                                ).animate().scale(curve: Curves.easeOutBack),
                                const Gap(20),

                                // Name
                                Text(
                                  userName.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ).animate().fadeIn(delay: 100.ms),

                                if (userBio.isNotEmpty) ...[
                                  const Gap(8),
                                  Text(
                                    userBio,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                    textAlign: TextAlign.center,
                                  ).animate().fadeIn(delay: 150.ms),
                                ],

                                if (userEmail.isNotEmpty) ...[
                                  const Gap(8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      userEmail,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                  ).animate().fadeIn(delay: 200.ms),
                                ],
                              ],
                            ),
                          )
                          .animate()
                          .slideY(begin: 0.15, curve: Curves.easeOutBack)
                          .fadeIn(),

                      // Edit button - top left corner
                      Positioned(
                        top: 12,
                        left: 12,
                        child:
                            GestureDetector(
                                  onTap: () => context.push('/edit-profile'),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.border,
                                        width: 3,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: AppColors.border,
                                          offset: Offset(3, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      LucideIcons.pencil,
                                      color: AppColors.textDark,
                                      size: 18,
                                    ),
                                  ),
                                )
                                .animate()
                                .slideX(
                                  begin: -1,
                                  curve: Curves.easeOutBack,
                                  delay: const Duration(milliseconds: 150),
                                )
                                .fadeIn(),
                      ),
                    ],
                  ),
                ),

                const Gap(32),

                // MY VAULT - Quick Action
                _QuickActionTile(
                      icon: LucideIcons.wallet,
                      title: 'MY VAULT',
                      subtitle: 'Manage all your accounts & cards',
                      color: AppColors.cardYellow,
                      onTap: () => context.push('/accounts'),
                      delay: 300,
                    )
                    .animate()
                    .slideY(
                      begin: 0.15,
                      curve: Curves.easeOutBack,
                      delay: const Duration(milliseconds: 300),
                    )
                    .fadeIn(),

                const Gap(32),

                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'MONTHLY BURN',
                        value: '${NumberFormat.compact().format(totalCommitments)} $currency',
                        icon: LucideIcons.flame,
                        color: AppColors.cardYellow,
                        delay: 0,
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: _StatCard(
                        label: 'SAVED',
                        value: '${NumberFormat.compact().format(totalSaved)} $currency',
                        icon: LucideIcons.piggyBank,
                        color: AppColors.cardBlue,
                        delay: 100,
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'GOALS',
                        value: '$goalsCount',
                        icon: LucideIcons.target,
                        color: AppColors.secondary,
                        delay: 200,
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: _StatCard(
                        label: 'CURRENCY',
                        value: currency,
                        icon: LucideIcons.coins,
                        color: AppColors.white,
                        delay: 300,
                      ),
                    ),
                  ],
                ),

                const Gap(40),

                // Quick Actions
                const Text(
                  'QUICK ACTIONS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
                ).animate().fadeIn(delay: 400.ms),
                const Gap(16),

                _QuickActionTile(
                  icon: LucideIcons.receipt,
                  title: 'TRANSACTION HISTORY',
                  subtitle: 'View all your transactions',
                  color: AppColors.cardBlue,
                  onTap: () => context.push('/transaction-history'),
                  delay: 500,
                ),

                const Gap(32),

                // ABOUT section
                const Text(
                  'ABOUT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 700.ms),
                const Gap(16),

                NeoCard(
                      backgroundColor: AppColors.white,
                      padding: EdgeInsets.zero,
                      isInteractive: true,
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                LucideIcons.sparkles,
                                color: AppColors.textDark,
                                size: 20,
                              ),
                            ),
                            const Gap(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PLANZY',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const Gap(2),
                                  const Text(
                                    'VERSION 1.0.0',
                                    style: TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .slideX(
                      begin: 0.15,
                      curve: Curves.easeOutBack,
                      delay: const Duration(milliseconds: 750),
                    )
                    .fadeIn(),

                const Gap(12),

                NeoCard(
                      backgroundColor: AppColors.white,
                      padding: EdgeInsets.zero,
                      isInteractive: true,
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.cardYellow,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                LucideIcons.helpCircle,
                                color: AppColors.textDark,
                                size: 20,
                              ),
                            ),
                            const Gap(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'HELP & SUPPORT',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const Gap(2),
                                  const Text(
                                    'Get help or contact us',
                                    style: TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              LucideIcons.chevronRight,
                              color: AppColors.textLight,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .slideX(
                      begin: 0.15,
                      curve: Curves.easeOutBack,
                      delay: const Duration(milliseconds: 800),
                    )
                    .fadeIn(),

                const Gap(12),

                NeoCard(
                      backgroundColor: AppColors.white,
                      padding: EdgeInsets.zero,
                      isInteractive: true,
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.cardBlue,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                LucideIcons.shield,
                                color: AppColors.textDark,
                                size: 20,
                              ),
                            ),
                            const Gap(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PRIVACY POLICY',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const Gap(2),
                                  const Text(
                                    'Read our privacy policy',
                                    style: TextStyle(
                                      color: AppColors.textLight,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              LucideIcons.chevronRight,
                              color: AppColors.textLight,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .slideX(
                      begin: 0.15,
                      curve: Curves.easeOutBack,
                      delay: const Duration(milliseconds: 850),
                    )
                    .fadeIn(),

                const Gap(100),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      backgroundColor: color,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: Icon(icon, color: AppColors.textDark, size: 18),
          ),
          const Gap(12),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark, letterSpacing: 1)),
          const Gap(4),
          FittedBox(
            child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -1)),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, curve: Curves.easeOutBack, delay: Duration(milliseconds: delay)).fadeIn();
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final int delay;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      backgroundColor: AppColors.white,
      padding: EdgeInsets.zero,
      isInteractive: true,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: Icon(icon, color: AppColors.textDark, size: 20),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5)),
                  const Gap(2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: AppColors.textLight, size: 20),
          ],
        ),
      ),
    ).animate().slideX(begin: 0.15, curve: Curves.easeOutBack, delay: Duration(milliseconds: delay)).fadeIn();
  }
}
