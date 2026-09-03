import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:planzy/core/widgets/neo_date_picker.dart';
import 'package:planzy/features/subscriptions/data/models/subscription.dart';
import 'package:planzy/features/subscriptions/presentation/providers/subscriptions_provider.dart';
import 'package:planzy/features/subscriptions/services/subscription_notification_service.dart';
import 'package:planzy/features/accounts/data/models/financial_account.dart';
import 'package:planzy/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddSubscriptionSheet extends ConsumerStatefulWidget {
  final Subscription? existing;

  const AddSubscriptionSheet({super.key, this.existing});

  @override
  ConsumerState<AddSubscriptionSheet> createState() =>
      _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends ConsumerState<AddSubscriptionSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  int _currentStep = 0;
  SubscriptionCategory _selectedCategory = SubscriptionCategory.entertainment;
  String _selectedEmoji = '🎬';
  SubscriptionCycle _selectedCycle = SubscriptionCycle.monthly;
  DateTime _nextRenewalDate = DateTime.now().add(const Duration(days: 30));
  int _reminderDaysBefore = 3;
  bool _autoDeduct = false;
  String? _linkedAccountId;
  String _currency = 'EGP';
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _nameController.text = e.name;
      _amountController.text = e.amount.toString();
      _notesController.text = e.notes ?? '';
      _selectedCategory = e.category;
      _selectedEmoji = e.iconEmoji ?? e.category.emoji;
      _selectedCycle = e.cycle;
      _nextRenewalDate = e.nextRenewalDate;
      _reminderDaysBefore = e.reminderDaysBefore;
      _autoDeduct = e.autoDeduct;
      _linkedAccountId = e.linkedAccountId;
      _currency = e.currency;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      _goToStep(0);
      return;
    }
    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null) {
      _goToStep(1);
      return;
    }

    setState(() => _saving = true);

    try {
      final userId =
          ref.read(subscriptionsProvider).valueOrNull?.firstOrNull?.userId ??
          'local';

      final sub = Subscription(
        id: widget.existing?.id ?? const Uuid().v4(),
        userId: userId,
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text),
        currency: _currency,
        cycle: _selectedCycle,
        category: _selectedCategory,
        nextRenewalDate: _nextRenewalDate,
        reminderDaysBefore: _reminderDaysBefore,
        autoDeduct: _autoDeduct,
        linkedAccountId: _linkedAccountId,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        iconEmoji: _selectedEmoji,
        colorHex: '#09090b',
        isActive: widget.existing?.isActive ?? true,
        createdAt: widget.existing?.createdAt ?? DateTime.now(),
      );

      if (_isEditing) {
        await ref.read(subscriptionsProvider.notifier).updateSubscription(sub);
      } else {
        await ref.read(subscriptionsProvider.notifier).add(sub);
      }

      // Schedule notification if reminder > 0
      if (sub.reminderDaysBefore > 0 && sub.isActive) {
        await SubscriptionNotificationService.scheduleRenewalReminder(sub);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _goToStep(int step) {
    if (step < 0 || step > 2) return;
    if (step > 0 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name first')),
      );
      return;
    }
    if (step > 1 &&
        (_amountController.text.isEmpty ||
            double.tryParse(_amountController.text) == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    setState(() => _currentStep = step);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: AppColors.border, width: 1.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Gap(12.h),
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.zinc300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
            child: Row(
              children: [
                Text(
                  _isEditing ? 'Edit Subscription' : 'New Subscription',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                // Step indicators
                Row(
                  children: List.generate(3, (i) {
                    final isCurrent = i == _currentStep;
                    final isPast = i < _currentStep;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isCurrent ? 24.w : 8.w,
                      height: 4.h,
                      margin: EdgeInsets.only(left: 4.w),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primary
                            : isPast
                                ? AppColors.zinc700
                                : AppColors.zinc200,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                bottom: bottomInset + 24.h,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _currentStep == 0
                    ? _StepOne(
                        key: const ValueKey('step0'),
                        nameController: _nameController,
                        selectedCategory: _selectedCategory,
                        selectedEmoji: _selectedEmoji,
                        onCategoryChanged: (c) => setState(() {
                          _selectedCategory = c;
                          _selectedEmoji = c.emoji;
                        }),
                        onEmojiChanged: (e) =>
                            setState(() => _selectedEmoji = e),
                        onNext: () => _goToStep(1),
                      )
                    : _currentStep == 1
                    ? _StepTwo(
                        key: const ValueKey('step1'),
                        amountController: _amountController,
                        currency: _currency,
                        selectedCycle: _selectedCycle,
                        onCurrencyChanged: (c) => setState(() => _currency = c),
                        onCycleChanged: (c) =>
                            setState(() => _selectedCycle = c),
                        onNext: () => _goToStep(2),
                        onBack: () => _goToStep(0),
                      )
                    : _StepThree(
                        key: const ValueKey('step2'),
                        nextRenewalDate: _nextRenewalDate,
                        reminderDaysBefore: _reminderDaysBefore,
                        autoDeduct: _autoDeduct,
                        linkedAccountId: _linkedAccountId,
                        notesController: _notesController,
                        onDateChanged: (d) =>
                            setState(() => _nextRenewalDate = d),
                        onReminderChanged: (v) =>
                            setState(() => _reminderDaysBefore = v),
                        onAutoDeductChanged: (v) =>
                            setState(() => _autoDeduct = v),
                        onAccountChanged: (id) =>
                            setState(() => _linkedAccountId = id),
                        onBack: () => _goToStep(1),
                        onSave: _save,
                        saving: _saving,
                        isEditing: _isEditing,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━ STEP 1: What is it? ━━━━━━━━━━━━━━━━━━━━━
class _StepOne extends StatelessWidget {
  final TextEditingController nameController;
  final SubscriptionCategory selectedCategory;
  final String selectedEmoji;
  final ValueChanged<SubscriptionCategory> onCategoryChanged;
  final ValueChanged<String> onEmojiChanged;
  final VoidCallback onNext;

  const _StepOne({
    super.key,
    required this.nameController,
    required this.selectedCategory,
    required this.selectedEmoji,
    required this.onCategoryChanged,
    required this.onEmojiChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is it?',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        Gap(10.h),

        // Name field
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border, width: 1.r),
          ),
          child: TextField(
            controller: nameController,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'e.g. Netflix, Spotify, Gym...',
              hintStyle: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(LucideIcons.tag, color: AppColors.zinc400, size: 18.r),
            ),
          ),
        ),
        Gap(20.h),

        // Category picker
        Text(
          'Category',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        Gap(10.h),
        SizedBox(
          height: 40.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: SubscriptionCategory.values.map((cat) {
              final isSelected = cat == selectedCategory;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => onCategoryChanged(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.zinc100,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Text(cat.emoji, style: TextStyle(fontSize: 15.sp)),
                        Gap(6.w),
                        Text(
                          cat.displayName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        Gap(20.h),

        // Emoji icon picker
        Text(
          'Icon',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        Gap(10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children:
              [
                '🎬',
                '💪',
                '📚',
                '🎵',
                '☁️',
                '🎮',
                '🍕',
                '🛍️',
                '🚗',
                '🗂️',
                '📺',
                '🏋️',
                '🎧',
                '💊',
                '📱',
                '💻',
                '🎯',
                '🏠',
                '⚡',
                '🔔',
              ].map((emoji) {
                final isSelected = emoji == selectedEmoji;
                return GestureDetector(
                  onTap: () => onEmojiChanged(emoji),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.zinc200 : AppColors.zinc100,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: isSelected ? 1.5.r : 1.r,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji, style: TextStyle(fontSize: 20.sp)),
                    ),
                  ),
                );
              }).toList(),
        ),

        Gap(28.h),

        // Next button
        NeoButton(
          text: 'Next',
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          onPressed: onNext,
        ),

        Gap(12.h),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━ STEP 2: How much? ━━━━━━━━━━━━━━━━━━━━━
class _StepTwo extends StatelessWidget {
  final TextEditingController amountController;
  final String currency;
  final SubscriptionCycle selectedCycle;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<SubscriptionCycle> onCycleChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _StepTwo({
    super.key,
    required this.amountController,
    required this.currency,
    required this.selectedCycle,
    required this.onCurrencyChanged,
    required this.onCycleChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How much?',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        Gap(10.h),

        // Amount input — big and centered
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border, width: 1.r),
          ),
          child: Column(
            children: [
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 36.sp,
                  letterSpacing: -1,
                  color: AppColors.textDark,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    color: AppColors.zinc300,
                    fontWeight: FontWeight.w700,
                    fontSize: 36.sp,
                  ),
                  border: InputBorder.none,
                ),
              ),
              Gap(8.h),
              _CurrencyDropdown(
                currency: currency,
                onChanged: onCurrencyChanged,
              ),
            ],
          ),
        ),

        Gap(20.h),

        // Cycle selector
        Text(
          'Billing Cycle',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        Gap(10.h),
        SizedBox(
          height: 44.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: SubscriptionCycle.values.map((cycle) {
              final isSelected = cycle == selectedCycle;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => onCycleChanged(cycle),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.zinc100,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Text(cycle.emoji, style: TextStyle(fontSize: 15.sp)),
                        Gap(6.w),
                        Text(
                          cycle.displayName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        Gap(28.h),

        // Navigation buttons
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.zinc100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Gap(12.w),
            Expanded(
              flex: 2,
              child: NeoButton(
                text: 'Next',
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                onPressed: onNext,
              ),
            ),
          ],
        ),

        Gap(12.h),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━ STEP 3: When & Reminders ━━━━━━━━━━━━━━━━
class _StepThree extends ConsumerWidget {
  final DateTime nextRenewalDate;
  final int reminderDaysBefore;
  final bool autoDeduct;
  final String? linkedAccountId;
  final TextEditingController notesController;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<int> onReminderChanged;
  final ValueChanged<bool> onAutoDeductChanged;
  final ValueChanged<String?> onAccountChanged;
  final VoidCallback onBack;
  final VoidCallback onSave;
  final bool saving;
  final bool isEditing;

  const _StepThree({
    super.key,
    required this.nextRenewalDate,
    required this.reminderDaysBefore,
    required this.autoDeduct,
    required this.linkedAccountId,
    required this.notesController,
    required this.onDateChanged,
    required this.onReminderChanged,
    required this.onAutoDeductChanged,
    required this.onAccountChanged,
    required this.onBack,
    required this.onSave,
    required this.saving,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final accounts = accountsAsync.valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule & Reminders',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        Gap(10.h),

        // Next renewal date
        GestureDetector(
          onTap: () async {
            final date = await NeoDatePicker.show(
              context: context,
              initialDate: nextRenewalDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 3650)),
            );
            if (date != null) onDateChanged(date);
          },
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.border, width: 1.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.zinc100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    LucideIcons.calendar,
                    color: AppColors.textDark,
                    size: 18.r,
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Renewal',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textLight,
                        ),
                      ),
                      Gap(2.h),
                      Text(
                        DateFormat('dd MMMM yyyy').format(nextRenewalDate),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.zinc400,
                  size: 16.r,
                ),
              ],
            ),
          ),
        ),
        Gap(12.h),

        // Reminder slider
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border, width: 1.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.zinc100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      LucideIcons.bell,
                      color: AppColors.textDark,
                      size: 18.r,
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reminder',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textLight,
                          ),
                        ),
                        Gap(2.h),
                        Text(
                          '$reminderDaysBefore ${reminderDaysBefore == 1 ? 'day' : 'days'} before',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gap(8.h),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.zinc200,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withValues(alpha: 0.1),
                  trackHeight: 4.r,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: 8.r,
                  ),
                ),
                child: Slider(
                  value: reminderDaysBefore.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  onChanged: (v) => onReminderChanged(v.round()),
                ),
              ),
            ],
          ),
        ),
        Gap(12.h),

        // Auto-deduct toggle
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border, width: 1.r),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppColors.zinc100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      LucideIcons.zap,
                      color: AppColors.textDark,
                      size: 18.r,
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto-deduct',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        Gap(2.h),
                        Text(
                          'Deduct from account on renewal',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 11.sp,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: autoDeduct,
                    onChanged: onAutoDeductChanged,
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),

              // Account picker (shows when auto-deduct is on)
              if (autoDeduct && accounts.isNotEmpty) ...[
                Gap(10.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.zinc50,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1.r,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: linkedAccountId,
                      hint: Text(
                        'Select account',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textLight,
                          fontSize: 13.sp,
                        ),
                      ),
                      items: accounts.map((acc) {
                        return DropdownMenuItem<String>(
                          value: acc.id,
                          child: Row(
                            children: [
                              Text(
                                acc.type.icon,
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              Gap(8.w),
                              Expanded(
                                child: Text(
                                  acc.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.sp,
                                    color: AppColors.textDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => onAccountChanged(val),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        Gap(12.h),

        // Notes
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border, width: 1.r),
          ),
          child: TextField(
            controller: notesController,
            maxLines: 2,
            minLines: 1,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Notes (optional)...',
              hintStyle: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w400,
                fontSize: 13.sp,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                LucideIcons.stickyNote,
                color: AppColors.zinc400,
                size: 16.r,
              ),
            ),
          ),
        ),

        Gap(28.h),

        // Navigation buttons
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.zinc100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Gap(12.w),
            Expanded(
              flex: 2,
              child: saving
                  ? Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                  : NeoButton(
                      text: isEditing ? 'Update' : 'Save',
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                      onPressed: onSave,
                    ),
            ),
          ],
        ),

        Gap(12.h),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━ Currency Dropdown ━━━━━━━━━━━━━━━━━━━━━
class _CurrencyDropdown extends StatelessWidget {
  final String currency;
  final ValueChanged<String> onChanged;

  const _CurrencyDropdown({required this.currency, required this.onChanged});

  static const _currencies = [
    'EGP',
    'USD',
    'EUR',
    'GBP',
    'SAR',
    'AED',
    'KWD',
    'QAR',
    'BHD',
    'OMR',
    'JOD',
    'TRY',
    'INR',
    'JPY',
    'CNY',
    'CAD',
    'AUD',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.zinc100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currency,
          items: _currencies.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(
                c,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                  color: AppColors.textDark,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}
