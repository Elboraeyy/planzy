import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_dialog.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/providers/auth_provider.dart';
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
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColors.border, width: 1.r),
                      ),
                      child: Icon(LucideIcons.arrowLeft, color: AppColors.textDark, size: 18.r),
                    ),
                  ),
                  Gap(14.w),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Gap(24.h),

              // ACCOUNT section
              Text(
                'Account',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: AppColors.textDark,
                ),
              ),
              Gap(10.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border, width: 1.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: LucideIcons.banknote,
                      title: 'Monthly Income',
                      subtitle:
                          '${NumberFormat.decimalPattern().format(settings.monthlyIncome)} ${settings.currency}',
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
                      title: 'Currency',
                      subtitle: settings.currency,
                      onTap: () => _changeCurrencyDialog(context, ref, settings.currency),
                    ),
                  ],
                ),
              ),

              Gap(24.h),

              // PREFERENCES section
              Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: AppColors.textDark,
                ),
              ),
              Gap(10.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border, width: 1.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: LucideIcons.bell,
                      title: 'Notifications',
                      subtitle: settings.notificationsEnabled ? 'Enabled' : 'Disabled',
                      trailing: Switch.adaptive(
                        value: settings.notificationsEnabled,
                        onChanged: (val) => ref.read(settingsProvider.notifier).toggleNotifications(val),
                        activeTrackColor: AppColors.primary,
                      ),
                    ),
                    _divider(),
                    _SettingsTile(
                      icon: LucideIcons.globe,
                      title: 'Language',
                      subtitle: 'English',
                      onTap: () {},
                    ),
                    _divider(),
                    _SettingsTile(
                      icon: LucideIcons.moon,
                      title: 'Theme',
                      subtitle: 'Light',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              Gap(24.h),

              // DANGER ZONE
              Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: AppColors.destructive,
                ),
              ),
              Gap(10.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border, width: 1.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: LucideIcons.trash2,
                      title: 'Delete All Data',
                      subtitle: 'Erase everything locally',
                      titleColor: AppColors.destructive,
                      iconColor: AppColors.destructive,
                      onTap: () => NeoDialog.show(
                        context: context,
                        title: 'Wipe all data?',
                        message: 'This action cannot be undone. All your local data (settings, goals) will be permanently deleted.',
                        confirmText: 'Yes, Delete Everything',
                        cancelText: 'Cancel',
                        isDestructive: true,
                        onConfirm: () {
                          ref.read(settingsProvider.notifier).clearAllData();
                        },
                      ),
                    ),
                    _divider(),
                    _SettingsTile(
                      icon: LucideIcons.logOut,
                      title: 'Sign Out',
                      subtitle: 'Log out of your account',
                      titleColor: AppColors.destructive,
                      iconColor: AppColors.destructive,
                      onTap: () => NeoDialog.show(
                        context: context,
                        title: 'Sign out?',
                        message: 'Are you sure you want to sign out? You can always sign back in.',
                        confirmText: 'Yes, Sign Out',
                        cancelText: 'Cancel',
                        isDestructive: true,
                        onConfirm: () async {
                          await ref.read(authNotifierProvider.notifier).signOut();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Gap(32.h),

              // Branding footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'Planzy',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Gap(2.h),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),

              Gap(40.h),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(height: 1.h, color: AppColors.border);
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
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, _, _) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.border, width: 1.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Choose Currency',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: AppColors.textDark,
                      ),
                    ),
                    Gap(16.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                        childAspectRatio: 1.5,
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
                              color: isSelected ? AppColors.primary : AppColors.zinc100,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Center(
                              child: Text(
                                curr,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                  color: isSelected ? Colors.white : AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
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
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.titleColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDestructive = titleColor == AppColors.destructive;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.r),
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.destructiveLight
                    : AppColors.zinc100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColors.destructive : AppColors.textDark,
                size: 18.r,
              ),
            ),
            Gap(14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: titleColor ?? AppColors.textDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(LucideIcons.chevronRight, color: AppColors.zinc400, size: 16.r),
          ],
        ),
      ),
    );
  }
}
