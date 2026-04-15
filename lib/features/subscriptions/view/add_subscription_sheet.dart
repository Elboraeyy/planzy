import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/core/widgets/neo_date_picker.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/features/subscriptions/data/models/subscription.dart';
import 'package:planzy/features/subscriptions/presentation/providers/subscriptions_provider.dart';
import 'package:planzy/features/subscriptions/services/subscription_notification_service.dart';
import 'package:planzy/features/accounts/data/models/financial_account.dart';
import 'package:planzy/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        isActive: widget.existing?.isActive ?? true,
        reminderDaysBefore: _reminderDaysBefore,
        autoDeduct: _autoDeduct,
        linkedAccountId: _autoDeduct ? _linkedAccountId : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        iconEmoji: _selectedEmoji,
        createdAt: widget.existing?.createdAt ?? DateTime.now(),
      );

      if (_isEditing) {
        await ref.read(subscriptionsProvider.notifier).updateSubscription(sub);
      } else {
        await ref.read(subscriptionsProvider.notifier).add(sub);
      }

      // Schedule notification
      await SubscriptionNotificationService.scheduleRenewalReminder(sub);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final userCurrency = settingsAsync.when(
      data: (s) => s.currency,
      loading: () => 'EGP',
      error: (error, stack) => 'EGP',
    );
    if (_currency == 'EGP' && widget.existing == null) {
      _currency = userCurrency;
    }

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 4.r),
          left: BorderSide(color: AppColors.border, width: 4.r),
          right: BorderSide(color: AppColors.border, width: 4.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Container(
              width: 40.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(24.r),
            child: Row(
              children: [
                Text(
                  _isEditing ? 'EDIT SUB' : 'NEW SUB',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                // Step indicators
                Row(
                  children: List.generate(3, (i) {
                    return Container(
                      width: i == _currentStep ? 24.w : 8.w,
                      height: 8.h,
                      margin: EdgeInsets.only(left: 6.w),
                      decoration: BoxDecoration(
                        color: i == _currentStep
                            ? AppColors.primary
                            : i < _currentStep
                            ? AppColors.secondary
                            : AppColors.textLight.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4.r),
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
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
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
        // Section title
        Text(
          'WHAT IS IT?',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.textLight,
          ),
        ),
        Gap(16.h),

        // Name field
        NeoCard(
          backgroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: TextField(
            controller: nameController,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18.sp),
            decoration: InputDecoration(
              hintText: 'e.g. Netflix, Spotify, Gym...',
              hintStyle: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(LucideIcons.tag, color: AppColors.textLight, size: 20.r),
            ),
          ),
        ),
        Gap(24.h),

        // Category picker
        Text(
          'CATEGORY',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.textLight,
          ),
        ),
        Gap(12.h),
        SizedBox(
          height: 48.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: SubscriptionCategory.values.map((cat) {
              final isSelected = cat == selectedCategory;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => onCategoryChanged(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.cardYellow
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.border
                            : AppColors.textLight.withValues(alpha: 0.2),
                        width: isSelected ? 3.r : 2.r,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.border,
                                offset: Offset(3.w, 3.h),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Text(cat.emoji, style: TextStyle(fontSize: 16.sp)),
                        Gap(6.w),
                        Text(
                          cat.displayName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w900,
                            color: isSelected
                                ? AppColors.textDark
                                : AppColors.textLight,
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

        Gap(24.h),

        // Emoji icon picker
        Text(
          'ICON',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.textLight,
          ),
        ),
        Gap(12.h),
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
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondary : AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.border
                            : AppColors.textLight.withValues(alpha: 0.15),
                        width: isSelected ? 3.r : 2.r,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.border,
                                offset: Offset(2.w, 2.h),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(emoji, style: TextStyle(fontSize: 22.sp)),
                    ),
                  ),
                );
              }).toList(),
        ),

        Gap(32.h),

        // Next button
        NeoButton(
          text: 'NEXT →',
          backgroundColor: AppColors.secondary,
          onPressed: onNext,
        ).animate().slideY(
          begin: 0.3,
          curve: Curves.easeOutBack,
          delay: 100.ms,
        ),

        Gap(16.h),
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
          'HOW MUCH?',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.textLight,
          ),
        ),
        Gap(16.h),

        // Amount input — big and centered
        NeoCard(
          backgroundColor: AppColors.white,
          padding: EdgeInsets.all(24.r),
          child: Column(
            children: [
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 40.sp,
                  letterSpacing: -1,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    color: AppColors.textLight.withValues(alpha: 0.3),
                    fontWeight: FontWeight.w900,
                    fontSize: 40.sp,
                  ),
                  border: InputBorder.none,
                ),
              ),
              Gap(8.h),
              // Currency
              _CurrencyDropdown(
                currency: currency,
                onChanged: onCurrencyChanged,
              ),
            ],
          ),
        ),

        Gap(24.h),

        // Cycle selector
        Text(
          'BILLING CYCLE',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.textLight,
          ),
        ),
        Gap(12.h),
        SizedBox(
          height: 52.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: SubscriptionCycle.values.map((cycle) {
              final isSelected = cycle == selectedCycle;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => onCycleChanged(cycle),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.border
                            : AppColors.textLight.withValues(alpha: 0.2),
                        width: isSelected ? 3.r : 2.r,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.border,
                                offset: Offset(3.w, 3.h),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Text(cycle.emoji, style: TextStyle(fontSize: 16.sp)),
                        Gap(6.w),
                        Text(
                          cycle.displayName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w900,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textLight,
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

        Gap(32.h),

        // Navigation buttons
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 18.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border, width: 3.r),
                  ),
                  child: Center(
                    child: Text(
                      '← BACK',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16.sp,
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
                text: 'NEXT →',
                backgroundColor: AppColors.secondary,
                onPressed: onNext,
              ),
            ),
          ],
        ),

        Gap(16.h),
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
          'WHEN & REMINDERS',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: AppColors.textLight,
          ),
        ),
        Gap(16.h),

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
          child: NeoCard(
            backgroundColor: AppColors.white,
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.cardYellow,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.border, width: 2.r),
                  ),
                  child: Icon(
                    LucideIcons.calendar,
                    color: AppColors.textDark,
                    size: 20.r,
                  ),
                ),
                Gap(14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEXT RENEWAL',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textLight,
                          letterSpacing: 1,
                        ),
                      ),
                      Gap(4.h),
                      Text(
                        DateFormat('dd MMMM yyyy').format(nextRenewalDate),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.textLight,
                  size: 20.r,
                ),
              ],
            ),
          ),
        ),
        Gap(16.h),

        // Reminder slider
        NeoCard(
          backgroundColor: AppColors.white,
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AppColors.cardBlue,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.border, width: 2.r),
                    ),
                    child: Icon(
                      LucideIcons.bell,
                      color: AppColors.textDark,
                      size: 20.r,
                    ),
                  ),
                  Gap(14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REMIND ME',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textLight,
                            letterSpacing: 1,
                          ),
                        ),
                        Gap(2.h),
                        Text(
                          '$reminderDaysBefore ${reminderDaysBefore == 1 ? 'day' : 'days'} before',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gap(12.h),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.textLight.withValues(
                    alpha: 0.15,
                  ),
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withValues(alpha: 0.1),
                  trackHeight: 6.r,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: 10.r,
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
        Gap(16.h),

        // Auto-deduct toggle
        NeoCard(
          backgroundColor: AppColors.white,
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.border, width: 2.r),
                    ),
                    child: Icon(
                      LucideIcons.zap,
                      color: AppColors.textDark,
                      size: 20.r,
                    ),
                  ),
                  Gap(14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AUTO-DEDUCT',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textLight,
                            letterSpacing: 1,
                          ),
                        ),
                        Gap(2.h),
                        Text(
                          'Deduct from account on renewal',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: autoDeduct,
                    onChanged: onAutoDeductChanged,
                    activeThumbColor: AppColors.secondary,
                    activeTrackColor: AppColors.textDark,
                  ),
                ],
              ),

              // Account picker (shows when auto-deduct is on)
              if (autoDeduct && accounts.isNotEmpty) ...[
                Gap(12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: AppColors.textLight.withValues(alpha: 0.2),
                      width: 2.r,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: linkedAccountId,
                      hint: Text(
                        'Select account',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textLight,
                          fontSize: 14.sp,
                        ),
                      ),
                      items: accounts.map((acc) {
                        return DropdownMenuItem<String>(
                          value: acc.id,
                          child: Row(
                            children: [
                              Text(
                                acc.type.icon,
                                style: TextStyle(fontSize: 18.sp),
                              ),
                              Gap(8.w),
                              Expanded(
                                child: Text(
                                  acc.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.sp,
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

        Gap(16.h),

        // Notes
        NeoCard(
          backgroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: TextField(
            controller: notesController,
            maxLines: 3,
            minLines: 1,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Notes (optional)...',
              hintStyle: TextStyle(
                color: AppColors.textLight.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                LucideIcons.stickyNote,
                color: AppColors.textLight,
                size: 18.r,
              ),
            ),
          ),
        ),

        Gap(32.h),

        // Navigation buttons
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 18.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border, width: 3.r),
                  ),
                  child: Center(
                    child: Text(
                      '← BACK',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16.sp,
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
                  ? NeoCard(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Center(
                        child: SizedBox(
                          width: 24.r,
                          height: 24.r,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 3.r,
                          ),
                        ),
                      ),
                    )
                  : NeoButton(
                      text: isEditing ? '💾 UPDATE' : '🎉 SAVE',
                      backgroundColor: AppColors.primary,
                      textColor: AppColors.white,
                      onPressed: onSave,
                    ),
            ),
          ],
        ),

        Gap(16.h),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.textLight.withValues(alpha: 0.2),
          width: 2.r,
        ),
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
                  fontWeight: FontWeight.w900,
                  fontSize: 16.sp,
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
