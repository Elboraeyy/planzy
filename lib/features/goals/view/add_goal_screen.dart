import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:planzy/core/widgets/neo_date_picker.dart';
import 'package:planzy/features/goals/data/models/goal.dart';
import 'package:planzy/features/goals/presentation/providers/goals_provider.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:planzy/features/accounts/data/models/financial_account.dart';
import 'package:planzy/features/transactions/data/models/transaction.dart';
import 'package:planzy/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:planzy/features/goals/services/goal_notification_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Identity
  final _titleController = TextEditingController();
  String _selectedEmoji = '🚗';
  String _selectedColor = '#09090b';

  // Step 2: Numbers & Existing Progress
  final _amountController = TextEditingController();
  bool _hasExistingSaves = false;
  bool _syncWithAccount = false;
  final _existingSavesController = TextEditingController();
  String? _linkedAccountId;

  // Step 3: Logistics
  DateTime _targetDate = DateTime.now().add(const Duration(days: 90));
  GoalPriority _selectedPriority = GoalPriority.medium;
  GoalReminderInterval _selectedReminder = GoalReminderInterval.none;

  final List<String> _emojis = [
    '🚗', '🏖️', '💻', '📱', '🏠', '🎓', '🏥', '🎮', '💍', '💰', '✈️', '⚡'
  ];
  final List<String> _colors = [
    '#09090b', '#2563eb', '#16a34a', '#d97706', '#dc2626', '#7c3aed', '#0891b2', '#4b5563'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _existingSavesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please name your goal first')),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_amountController.text.isEmpty ||
          double.tryParse(_amountController.text) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid target amount')),
        );
        return;
      }
      if (_hasExistingSaves) {
        if (_existingSavesController.text.isEmpty ||
            double.tryParse(_existingSavesController.text) == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter existing saved amount')),
          );
          return;
        }
        if (_syncWithAccount && _linkedAccountId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Select an account to sync the existing saves from')),
          );
          return;
        }
      }
    }

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep++);
    } else {
      _save();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final targetAm = double.parse(_amountController.text);
    final initialSaves = _hasExistingSaves
        ? double.parse(_existingSavesController.text)
        : 0.0;

    final goal = Goal(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      targetAmount: targetAm,
      savedAmount: initialSaves,
      targetDate: _targetDate,
      priority: _selectedPriority,
      iconEmoji: _selectedEmoji,
      themeColor: _selectedColor,
      linkedAccountId: _linkedAccountId,
      reminderInterval: _selectedReminder,
    );

    // Save Goal
    await ref.read(goalsProvider.notifier).addGoal(goal);
    await GoalNotificationService.scheduleGoalReminder(goal);

    // Synced Transaction if initial savings exists
    if (_hasExistingSaves &&
        _syncWithAccount &&
        _linkedAccountId != null &&
        initialSaves > 0) {
      final txn = Transaction(
        id: const Uuid().v4(),
        userId: user.uid,
        type: TransactionType.expense,
        amount: initialSaves,
        date: DateTime.now(),
        accountId: _linkedAccountId,
        expenseCategory: ExpenseCategory.other,
        notes: 'Funded new goal: ${goal.title}',
        createdAt: DateTime.now(),
      );
      await ref.read(transactionsProvider.notifier).add(txn);
      await ref
          .read(accountsProvider.notifier)
          .adjustBalance(_linkedAccountId!, -initialSaves);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final currency = settingsAsync.when(
      data: (s) => s.currency,
      loading: () => '',
      error: (err, stack) => '',
    );
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Step ${_currentStep + 1} of 3',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.textDark, size: 20.r),
          onPressed: _prevStep,
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(3.h),
          child: Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  height: 3.h,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? AppColors.primary
                        : AppColors.zinc200,
                    borderRadius: BorderRadius.circular(1.5.r),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1Identity(),
                  _buildStep2Numbers(currency, accountsAsync.valueOrNull ?? []),
                  _buildStep3Logistics(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
              child: NeoButton(
                text: _currentStep == 2 ? 'Create Goal' : 'Continue',
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                onPressed: _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Identity() {
    return ListView(
      padding: EdgeInsets.all(20.r),
      children: [
        Text(
          "What are you saving for?",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22.sp,
            letterSpacing: -0.4,
            color: AppColors.textDark,
          ),
        ),
        Gap(4.h),
        Text(
          'Give your goal a memorable name and visual identity.',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.textLight,
            fontWeight: FontWeight.w400,
          ),
        ),
        Gap(24.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border, width: 1.r),
          ),
          child: TextField(
            controller: _titleController,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'e.g., Summer Trip, MacBook Pro..',
              hintStyle: TextStyle(
                color: AppColors.textLight,
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        Gap(28.h),
        Text(
          'Select Icon',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        Gap(12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: _emojis.map((e) {
            final isSelected = _selectedEmoji == e;
            return GestureDetector(
              onTap: () => setState(() => _selectedEmoji = e),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.zinc200 : AppColors.zinc100,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: isSelected ? 1.5.r : 1.r,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(e, style: TextStyle(fontSize: 22.sp)),
                ),
              ),
            );
          }).toList(),
        ),
        Gap(28.h),
        Text(
          'Accent Color',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        Gap(12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: _colors.map((c) {
            final isSelected = _selectedColor == c;
            final color = Color(int.parse(c.replaceAll('#', '0xFF')));
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: isSelected ? 3.r : 0,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2Numbers(String currency, List<FinancialAccount> accounts) {
    return ListView(
      padding: EdgeInsets.all(20.r),
      children: [
        Text(
          "Target Amount",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22.sp,
            letterSpacing: -0.4,
            color: AppColors.textDark,
          ),
        ),
        Gap(4.h),
        Text(
          'How much do you need to hit this goal?',
          style: TextStyle(color: AppColors.textLight, fontSize: 13.sp, fontWeight: FontWeight.w400),
        ),
        Gap(24.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border, width: 1.r),
          ),
          child: Column(
            children: [
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: AppColors.zinc300,
                  ),
                  suffixText: currency,
                  suffixStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),

        Gap(28.h),
        Text(
          'Where are you starting?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        Gap(12.h),
        Row(
          children: [
            _buildPathButton(false, 'Fresh Start', 'Start from zero'),
            Gap(12.w),
            _buildPathButton(true, 'Head Start', 'I have savings already'),
          ],
        ),

        if (_hasExistingSaves) ...[
          Gap(24.h),
          Text(
            'Already Saved Amount',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: AppColors.textDark,
              letterSpacing: -0.2,
            ),
          ),
          Gap(10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.border, width: 1.r),
            ),
            child: TextField(
              controller: _existingSavesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: '0.00',
                suffixText: currency,
                border: InputBorder.none,
              ),
            ),
          ),
          Gap(14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Switch.adaptive(
                value: _syncWithAccount,
                onChanged: (val) => setState(() => _syncWithAccount = val),
                activeTrackColor: AppColors.primary,
              ),
              Gap(8.w),
              Expanded(
                child: Text(
                  'Deduct from an account to balance Planzy',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ],

        Gap(28.h),
        Text(
          _hasExistingSaves && _syncWithAccount
              ? 'Source Account'
              : 'Linked Account (Optional)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        Gap(4.h),
        Text(
          _hasExistingSaves && _syncWithAccount
              ? 'The starting amount will be withdrawn from this account.'
              : 'Link an account to easily allocate future savings.',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        Gap(12.h),
        _buildAccountPicker(accounts),
      ],
    );
  }

  Widget _buildPathButton(bool state, String label, String sub) {
    final isSelected = _hasExistingSaves == state;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _hasExistingSaves = state),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.r,
            ),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
              ),
              Gap(2.h),
              Text(
                sub,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 11.sp,
                  color: isSelected ? AppColors.zinc400 : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountPicker(List<FinancialAccount> accounts) {
    if (accounts.isEmpty) {
      return Text('No accounts created yet.', style: TextStyle(color: AppColors.textLight, fontSize: 13.sp));
    }

    return SizedBox(
      height: 72.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: accounts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _linkedAccountId == null;
            return GestureDetector(
              onTap: () => setState(() => _linkedAccountId = null),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 90.w,
                margin: EdgeInsets.only(right: 10.w),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1.r,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    'None',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                      color: isSelected ? Colors.white : AppColors.textLight,
                    ),
                  ),
                ),
              ),
            );
          }
          final acc = accounts[index - 1];
          final isSelected = _linkedAccountId == acc.id;
          return GestureDetector(
            onTap: () => setState(() => _linkedAccountId = acc.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 130.w,
              margin: EdgeInsets.only(right: 10.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1.r,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Text(acc.type.icon, style: TextStyle(fontSize: 18.sp)),
                  Gap(8.w),
                  Expanded(
                    child: Text(
                      acc.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildStep3Logistics() {
    return ListView(
      padding: EdgeInsets.all(20.r),
      children: [
        Text(
          "Schedule & Priority",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22.sp,
            letterSpacing: -0.4,
            color: AppColors.textDark,
          ),
        ),
        Gap(4.h),
        Text(
          'Set a deadline and how often you want to be reminded.',
          style: TextStyle(color: AppColors.textLight, fontSize: 13.sp, fontWeight: FontWeight.w400),
        ),
        Gap(24.h),

        Text(
          'Target Date',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        Gap(10.h),
        GestureDetector(
          onTap: () async {
            final date = await NeoDatePicker.show(
              context: context,
              initialDate: _targetDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 3650)),
            );
            if (date != null) setState(() => _targetDate = date);
          },
          child: Container(
            padding: EdgeInsets.all(16.r),
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
                    LucideIcons.calendarClock,
                    size: 20.r,
                    color: AppColors.textDark,
                  ),
                ),
                Gap(14.w),
                Expanded(
                  child: Text(
                    DateFormat('MMMM d, yyyy').format(_targetDate),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Icon(LucideIcons.chevronRight, color: AppColors.zinc400, size: 16.r),
              ],
            ),
          ),
        ),

        Gap(24.h),
        Text(
          'Priority Level',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        Gap(10.h),
        Row(
          children: [
            _buildPriorityButton(GoalPriority.low, 'Low'),
            Gap(10.w),
            _buildPriorityButton(GoalPriority.medium, 'Medium'),
            Gap(10.w),
            _buildPriorityButton(GoalPriority.high, 'High'),
          ],
        ),

        Gap(24.h),
        Text(
          'Reminders',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        Gap(10.h),
        Column(
          children: [
            _buildReminderTile(
              GoalReminderInterval.none,
              'No Reminders',
              'I will track it on my own',
              LucideIcons.bellOff,
            ),
            Gap(8.h),
            _buildReminderTile(
              GoalReminderInterval.weekly,
              'Weekly',
              'A gentle nudge every week',
              LucideIcons.calendar,
            ),
            Gap(8.h),
            _buildReminderTile(
              GoalReminderInterval.monthly,
              'Monthly',
              'Check in on salary day',
              LucideIcons.calendarDays,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityButton(GoalPriority priority, String label) {
    final isSelected = _selectedPriority == priority;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = priority),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.r,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderTile(
    GoalReminderInterval interval,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _selectedReminder == interval;
    return GestureDetector(
      onTap: () => setState(() => _selectedReminder = interval),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.zinc100 : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.r,
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.r, color: isSelected ? AppColors.primary : AppColors.textLight),
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
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 11.sp,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.check, size: 18.r, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
