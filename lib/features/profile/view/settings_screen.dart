import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/core/widgets/neo_dialog.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      body: SafeArea(
        child: settingsAsync.when(
          data: (settings) => ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.border, width: 3.r),
                      ),
                      child: Icon(LucideIcons.arrowLeft, color: AppColors.textDark, size: 20.r),
                    ),
                  ),
                  Gap(16.w),
                  Text(
                    'SETTINGS',
                    style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, letterSpacing: -1),
                  ),
                ],
              ).animate().fadeIn(),
              Gap(40.h),

              // ACCOUNT section
              Text('ACCOUNT', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: AppColors.textLight, letterSpacing: 2)),
              Gap(16.h),
              NeoCard(
                backgroundColor: AppColors.white,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: LucideIcons.banknote,
                      title: 'MONTHLY INCOME',
                      subtitle:
                          '${NumberFormat.decimalPattern().format(settings.monthlyIncome)} ${settings.currency}',
                      iconColor: AppColors.cardYellow,
                      onTap: () => _editIncomeDialog(
                        context,
                        ref,
                        settings.monthlyIncome,
                        settings.currency,
                      ),
                    ),
                    _divider(),
                    _SettingsTile(
                      icon: LucideIcons.coins,
                      title: 'CURRENCY',
                      subtitle: settings.currency,
                      iconColor: AppColors.cardBlue,
                      onTap: () => _changeCurrencyDialog(context, ref, settings.currency),
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.15, curve: Curves.easeOutBack, delay: 100.ms).fadeIn(),

              Gap(32.h),

              // PREFERENCES section
              Text('PREFERENCES', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: AppColors.textLight, letterSpacing: 2)),
              Gap(16.h),
              NeoCard(
                backgroundColor: AppColors.white,
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: LucideIcons.bell,
                      title: 'NOTIFICATIONS',
                      subtitle: settings.notificationsEnabled ? 'ENABLED' : 'DISABLED',
                      iconColor: AppColors.secondary,
                      trailing: Switch(
                        value: settings.notificationsEnabled,
                        onChanged: (val) => ref.read(settingsProvider.notifier).toggleNotifications(val),
                        activeThumbColor: AppColors.primary,
                        activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    _divider(),
                    _SettingsTile(
                      icon: LucideIcons.globe,
                      title: 'LANGUAGE',
                      subtitle: 'ENGLISH',
                      iconColor: AppColors.cardBlue,
                      onTap: () {},
                    ),
                    _divider(),
                    _SettingsTile(
                      icon: LucideIcons.moon,
                      title: 'THEME',
                      subtitle: 'LIGHT',
                      iconColor: AppColors.cardYellow,
                      onTap: () {},
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.15, curve: Curves.easeOutBack, delay: 200.ms).fadeIn(),

              Gap(40.h),

              // DANGER ZONE
              Text('DANGER ZONE', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.red, letterSpacing: 2)),
              Gap(16.h),
              NeoCard(
                backgroundColor: Colors.red.withValues(alpha: 0.05),
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: LucideIcons.trash2,
                      title: 'DELETE ALL DATA',
                      subtitle: 'Erase everything locally',
                      iconColor: Colors.red,
                      titleColor: Colors.red,
                      onTap: () => NeoDialog.show(
                        context: context,
                        title: 'WIPE ALL DATA?',
                        message: 'This action cannot be undone. All your local data (settings, goals) will be permanently deleted.',
                        confirmText: 'YES, DELETE EVERYTHING',
                        cancelText: 'NO, KEEP MY DATA',
                        isDestructive: true,
                        onConfirm: () {
                          ref.read(settingsProvider.notifier).clearAllData();
                        },
                      ),
                    ),
                    _divider(),
                    _SettingsTile(
                      icon: LucideIcons.logOut,
                      title: 'SIGN OUT',
                      subtitle: 'Log out of your account',
                      iconColor: Colors.red,
                      titleColor: Colors.red,
                      onTap: () => NeoDialog.show(
                        context: context,
                        title: 'SIGN OUT?',
                        message: 'Are you sure you want to sign out? You can always sign back in.',
                        confirmText: 'YES, SIGN OUT',
                        cancelText: 'CANCEL',
                        isDestructive: true,
                        onConfirm: () async {
                          await ref.read(authNotifierProvider.notifier).signOut();
                        },
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.15, curve: Curves.easeOutBack, delay: 400.ms).fadeIn(),

              Gap(40.h),

              // Branding footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'MADE WITH ❤️',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: AppColors.textLight, letterSpacing: 2),
                    ),
                    Gap(4.h),
                    Text(
                      'PLANZY • 2026',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.textLight),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms),

              Gap(60.h),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(height: 2.h, color: AppColors.border.withValues(alpha: 0.08));
  }

  void _editIncomeDialog(BuildContext context, WidgetRef ref, double currentIncome, String currency) {
    final controller = TextEditingController(text: currentIncome > 0 ? currentIncome.toStringAsFixed(0) : '');

    NeoDialog.show(
      context: context,
      title: 'EDIT MONTHLY INCOME',
      message: '',
      confirmText: 'SAVE',
      cancelText: 'CANCEL',
      customContent: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, letterSpacing: -1),
        decoration: InputDecoration(
          hintText: '0',
          suffixText: currency,
          suffixStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
      ),
      onConfirm: () {
        final val = double.tryParse(controller.text) ?? 0;
        ref.read(settingsProvider.notifier).updateIncome(val);
      },
    );
  }

  void _changeCurrencyDialog(BuildContext context, WidgetRef ref, String currentCurrency) {
    const currencies = ['EGP', 'USD', 'EUR', 'GBP', 'SAR', 'AED'];

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, _, _) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: NeoCard(
                backgroundColor: AppColors.background,
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('CHOOSE CURRENCY', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900)),
                    Gap(24.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: currencies.length,
                      itemBuilder: (context, index) {
                        final curr = currencies[index];
                        final isSelected = currentCurrency == curr;
                        return GestureDetector(
                          onTap: () {
                            ref.read(settingsProvider.notifier).updateCurrency(curr);
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.secondary : AppColors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: AppColors.border, width: isSelected ? 3.r : 2.r),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: AppColors.border, offset: Offset(3.w, 3.h))]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                curr,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16.sp,
                                  color: isSelected ? AppColors.textDark : AppColors.textLight,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).animate().scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack).fadeIn(),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color? titleColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    this.titleColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.1), width: 2.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.r),
            ),
            Gap(16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp, color: titleColor ?? AppColors.textDark)),
                  Gap(2.h),
                  Text(subtitle, style: TextStyle(color: AppColors.textLight, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            trailing ?? Icon(LucideIcons.chevronRight, color: AppColors.textLight, size: 18.r),
          ],
        ),
      ),
    );
  }
}
