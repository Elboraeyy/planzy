import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('PROFILE')),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          children: [
            // User Header
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 4),
                      boxShadow: const [
                         BoxShadow(color: AppColors.border, offset: Offset(4, 4)),
                      ]
                    ),
                    child: const Icon(LucideIcons.user, size: 50, color: AppColors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 2),
                    ),
                    child: const Icon(LucideIcons.pencil, size: 16, color: AppColors.textDark),
                  ),
                ],
              ).animate().scale(curve: Curves.easeOutBack),
            ),
            const Gap(24),
            const Center(
              child: Text(
                'PLANNER ✌️',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
              ),
            ),
            const Gap(40),

            // Financial Info Section
            const Text('FINANCES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
            const Gap(16),
            NeoCard(
              backgroundColor: AppColors.white,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                   _buildProfileTile(
                    icon: LucideIcons.banknote,
                    title: 'MONTHLY INCOME',
                    trailing: '${NumberFormat.decimalPattern().format(settings.monthlyIncome ?? 0)} EGP',
                    onTap: () => _updateIncomeDialog(context, ref, settings.monthlyIncome ?? 0),
                  ),
                  _buildDivider(),
                  _buildProfileTile(
                    icon: LucideIcons.coins,
                    title: 'CURRENCY',
                    trailing: settings.currency,
                    onTap: () {},
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.2, curve: Curves.easeOutBack),

            const Gap(32),
            const Text('SYSTEM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
            const Gap(16),
            NeoCard(
              backgroundColor: AppColors.cardYellow,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: LucideIcons.bell,
                    title: 'NOTIFICATIONS',
                    trailingWidget: Switch(
                      value: settings.notificationsEnabled,
                      onChanged: (val) => ref.read(settingsProvider.notifier).toggleNotifications(val),
                      activeColor: AppColors.primary,
                      activeTrackColor: AppColors.border.withValues(alpha: 0.2),
                    ),
                  ),
                   _buildDivider(),
                  _buildProfileTile(
                    icon: LucideIcons.info,
                    title: 'ABOUT PLANZY',
                    onTap: () {},
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.3, curve: Curves.easeOutBack, delay: 100.ms),

            const Gap(40),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('DELETE ALL DATA', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ),
            const Gap(100),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    String? trailing,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textDark),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
      trailing: trailingWidget ?? (trailing != null ? Text(trailing, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)) : const Icon(LucideIcons.chevronRight, size: 20)),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 2,
      color: AppColors.border.withValues(alpha: 0.1),
    );
  }

  void _updateIncomeDialog(BuildContext context, WidgetRef ref, double currentIncome) {
    final controller = TextEditingController(text: currentIncome.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border, width: 3)),
        title: const Text('EDIT INCOME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 'EGP'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 0;
              ref.read(settingsProvider.notifier).updateIncome(val);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.border, width: 2)),
            ),
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
