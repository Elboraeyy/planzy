import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/core/widgets/neo_date_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  String _selectedColor = '#FFD600';

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
    '🚗',
    '🏖️',
    '💻',
    '📱',
    '🏠',
    '🎓',
    '🏥',
    '🎮',
    '💍',
    '💰',
  ];
  final List<String> _colors = [
    '#FFD600',
    '#FF90E8',
    '#90E8FF',
    '#B4F8C8',
    '#FFB7B2',
    '#FFFFFF',
    '#FF8383',
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
      if (_titleController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please name your goal first!')),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_amountController.text.isEmpty ||
          double.tryParse(_amountController.text) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid target amount!')),
        );
        return;
      }
      if (_hasExistingSaves) {
        if (_existingSavesController.text.isEmpty ||
            double.tryParse(_existingSavesController.text) == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter existing saved amount!'),
            ),
          );
          return;
        }
        if (_syncWithAccount && _linkedAccountId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Select an account to sync the existing saves from!',
              ),
            ),
          );
          return;
        }
      }
    }

    if (_currentStep < 2) {
      _pageController.nextPage(duration: 300.ms, curve: Curves.easeOutBack);
      setState(() => _currentStep++);
    } else {
      _save();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: 300.ms, curve: Curves.easeOutBack);
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
      title: _titleController.text,
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
        title: Text(
          'STEP ${_currentStep + 1} OF 3',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.textLight,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.textDark, size: 24.r),
          onPressed: _prevStep,
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.h),
          child: Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child:
                    Container(
                          height: 4.h,
                          color: index <= _currentStep
                              ? AppColors.primary
                              : AppColors.border,
                        )
                        .animate(target: index <= _currentStep ? 1 : 0)
                        .tint(color: AppColors.primary),
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
              padding: EdgeInsets.all(24.r),
              child:
                  NeoButton(
                    text: _currentStep == 2 ? 'LAUNCH GOAL 🚀' : 'NEXT STEP',
                    onPressed: _nextStep,
                  ).animate().slideY(
                    begin: 1,
                    curve: Curves.easeOutBack,
                    delay: 200.ms,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Identity() {
    return ListView(
      padding: EdgeInsets.all(24.r),
      children: [
        Text(
          "WHAT'S THE DREAM?",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 32.sp,
            letterSpacing: -1,
          ),
        ),
        Gap(32.h),
        TextFormField(
          controller: _titleController,
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
          decoration: InputDecoration(
            hintText: 'e.g., Summer Trip, MacBook..',
            hintStyle: TextStyle(
              color: AppColors.textLight.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 20.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppColors.border, width: 3.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppColors.border, width: 3.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppColors.primary, width: 3.r),
            ),
          ),
        ).animate().slideX(begin: 0.1),
        Gap(40.h),
        Text(
          'PICK AN ICON',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.sp,
            letterSpacing: 1,
          ),
        ),
        Gap(16.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: _emojis
              .map(
                (e) => GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = e),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: _selectedEmoji == e
                          ? AppColors.primary
                          : AppColors.white,
                      border: Border.all(
                        color: AppColors.border,
                        width: _selectedEmoji == e ? 3.r : 2.r,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: _selectedEmoji == e
                          ? [
                              BoxShadow(
                                color: AppColors.border,
                                offset: Offset(4.w, 4.h),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(e, style: TextStyle(fontSize: 32.sp)),
                  ),
                ),
              )
              .toList(),
        ).animate().slideX(begin: 0.2, delay: 100.ms),
        Gap(40.h),
        Text(
          'CHOOSE A VIBE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.sp,
            letterSpacing: 1,
          ),
        ),
        Gap(16.h),
        Wrap(
          spacing: 16.w,
          runSpacing: 16.h,
          children: _colors
              .map(
                (c) => GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    width: 56.r,
                    height: 56.r,
                    decoration: BoxDecoration(
                      color: Color(int.parse(c.replaceAll('#', '0xFF'))),
                      border: Border.all(
                        color: AppColors.border,
                        width: _selectedColor == c ? 4.r : 2.r,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: _selectedColor == c
                          ? [
                              BoxShadow(
                                color: AppColors.border,
                                offset: Offset(4.w, 4.h),
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
              )
              .toList(),
        ).animate().slideX(begin: 0.3, delay: 200.ms),
      ],
    );
  }

  Widget _buildStep2Numbers(String currency, List<FinancialAccount> accounts) {
    return ListView(
      padding: EdgeInsets.all(24.r),
      children: [
        Text(
          "THE BIG NUMBER",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 32.sp,
            letterSpacing: -1,
          ),
        ),
        Gap(8.h),
        Text(
          'How much do you need to hit this goal?',
          style: TextStyle(color: AppColors.textLight, fontSize: 16.sp),
        ),
        Gap(40.h),
        Center(
          child: IntrinsicWidth(
            child: TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 56.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  color: AppColors.textLight.withValues(alpha: 0.3),
                ),
                suffixText: currency,
                suffixStyle: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),

        Gap(60.h),
        Text(
          'WHERE ARE YOU STARTING?',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.sp,
            letterSpacing: 1,
          ),
        ),
        Gap(16.h),
        Row(
          children: [
            _buildPathButton(false, 'FRESH START', 'Zero saved'),
            Gap(16.w),
            _buildPathButton(true, 'HEAD START', 'I have funds'),
          ],
        ),

        if (_hasExistingSaves) ...[
          Gap(40.h),
          Text(
            'HOW MUCH ALREADY SAVED?',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16.sp,
              letterSpacing: 1,
            ),
          ),
          Gap(16.h),
          TextFormField(
            controller: _existingSavesController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              hintText: '0.00',
              suffixText: currency,
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: AppColors.border, width: 3.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: AppColors.border, width: 3.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: AppColors.primary, width: 3.r),
              ),
            ),
          ).animate().slideY(begin: 0.1),
          Gap(16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _syncWithAccount,
                onChanged: (val) =>
                    setState(() => _syncWithAccount = val ?? false),
                activeColor: AppColors.primary,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Text(
                    'Deduct this amount from an account and log as transaction?',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ],
          ).animate().slideY(begin: 0.1),
        ],

        Gap(40.h),
        Text(
          _hasExistingSaves && _syncWithAccount
              ? 'SOURCE ACCOUNT TO SYNC WITH'
              : 'LINK ACCOUNT (OPTIONAL)',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.sp,
            letterSpacing: 1,
          ),
        ),
        Gap(8.h),
        Text(
          _hasExistingSaves && _syncWithAccount
              ? 'The amount you saved will be withdrawn from this account to balance Planzy.'
              : 'Link an account to easily transfer future savings from.',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        Gap(16.h),
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
          duration: 200.ms,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : AppColors.white,
            border: Border.all(
              color: AppColors.border,
              width: isSelected ? 3.r : 2.r,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.border, offset: Offset(4.w, 4.h))]
                : [],
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp),
              ),
              Gap(4.h),
              Text(
                sub,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11.sp,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountPicker(List<FinancialAccount> accounts) {
    if (accounts.isEmpty) return const Text('No accounts created yet.');

    return SizedBox(
      height: 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: accounts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _linkedAccountId == null;
            return GestureDetector(
              onTap: () => setState(() => _linkedAccountId = null),
              child: AnimatedContainer(
                duration: 200.ms,
                width: 100.w,
                margin: EdgeInsets.only(right: 12.w, bottom: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.textDark : AppColors.white,
                  border: Border.all(color: AppColors.border, width: 2.r),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.border,
                            offset: Offset(2.w, 2.h),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    'NONE',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: isSelected ? AppColors.white : AppColors.textLight,
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
              duration: 200.ms,
              width: 140.w,
              margin: EdgeInsets.only(right: 12.w, bottom: 8.h),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.cardYellow : AppColors.white,
                border: Border.all(color: AppColors.border, width: 2.r),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.border,
                          offset: Offset(4.w, 4.h),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    acc.iconEmoji ?? '🏦',
                    style: TextStyle(fontSize: 24.sp),
                  ),
                  Gap(4.h),
                  Text(
                    acc.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().slideX(begin: 0.1);
  }

  Widget _buildStep3Logistics() {
    return ListView(
      padding: EdgeInsets.all(24.r),
      children: [
        Text(
          "THE MASTER PLAN",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 32.sp,
            letterSpacing: -1,
          ),
        ),
        Gap(40.h),

        Text(
          'TARGET DATE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.sp,
            letterSpacing: 1,
          ),
        ),
        Gap(16.h),
        NeoCard(
          backgroundColor: AppColors.white,
          isInteractive: true,
          onTap: () async {
            final date = await NeoDatePicker.show(
              context: context,
              initialDate: _targetDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 3650)),
            );
            if (date != null) setState(() => _targetDate = date);
          },
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Row(
            children: [
              Icon(
                LucideIcons.calendarClock,
                size: 28.r,
                color: AppColors.primary,
              ),
              Gap(16.w),
              Expanded(
                child: Text(
                  DateFormat('MMMM d, yyyy').format(_targetDate),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18.sp,
                  ),
                ),
              ),
              Icon(LucideIcons.chevronRight, color: AppColors.textLight),
            ],
          ),
        ).animate().slideX(begin: -0.1),

        Gap(32.h),
        Text(
          'PRIORITY LEVEL',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.sp,
            letterSpacing: 1,
          ),
        ),
        Gap(16.h),
        Row(
          children: [
            _buildPriorityButton(GoalPriority.low, 'CHILL', AppColors.cardBlue),
            Gap(12.w),
            _buildPriorityButton(
              GoalPriority.medium,
              'NORMAL',
              AppColors.cardYellow,
            ),
            Gap(12.w),
            _buildPriorityButton(
              GoalPriority.high,
              'URGENT',
              AppColors.primary,
            ),
          ],
        ).animate().slideX(begin: -0.2, delay: 100.ms),

        Gap(32.h),
        Text(
          'REMIND ME TO SAVE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.sp,
            letterSpacing: 1,
          ),
        ),
        Gap(16.h),
        Column(
          children: [
            _buildReminderTile(
              GoalReminderInterval.none,
              'No Reminders',
              'I got this myself',
              LucideIcons.bellOff,
            ),
            Gap(12.h),
            _buildReminderTile(
              GoalReminderInterval.weekly,
              'Weekly',
              'Keep me on my toes',
              LucideIcons.calendar,
            ),
            Gap(12.h),
            _buildReminderTile(
              GoalReminderInterval.monthly,
              'Monthly',
              'Salary day check-in',
              LucideIcons.calendarDays,
            ),
          ],
        ).animate().slideX(begin: -0.3, delay: 200.ms),
      ],
    );
  }

  Widget _buildPriorityButton(
    GoalPriority priority,
    String label,
    Color color,
  ) {
    final isSelected = _selectedPriority == priority;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPriority = priority),
        child: AnimatedContainer(
          duration: 200.ms,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.white,
            border: Border.all(
              color: AppColors.border,
              width: isSelected ? 3.r : 2.r,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.border, offset: Offset(4.w, 4.h))]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14.sp,
                color:
                    isSelected &&
                        color != AppColors.cardYellow &&
                        color != AppColors.cardBlue
                    ? AppColors.white
                    : AppColors.textDark,
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
        duration: 200.ms,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.white,
          border: Border.all(
            color: AppColors.border,
            width: isSelected ? 3.r : 2.r,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.border, offset: Offset(4.w, 4.h))]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 24.r, color: AppColors.textDark),
            Gap(16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16.sp,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: AppColors.textDark.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.checkCircle2, color: AppColors.textDark),
          ],
        ),
      ),
    );
  }
}
