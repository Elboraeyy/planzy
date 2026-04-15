import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:planzy/core/widgets/neo_date_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:planzy/features/goals/data/models/goal.dart';
import 'package:planzy/features/goals/presentation/providers/goals_provider.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:uuid/uuid.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  GoalPriority _selectedPriority = GoalPriority.medium;
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final goal = Goal(
        id: const Uuid().v4(),
        title: _titleController.text,
        targetAmount: double.parse(_amountController.text),
        savedAmount: 0.0,
        targetDate: _targetDate,
        priority: _selectedPriority,
      );

      await ref.read(goalsProvider.notifier).addGoal(goal);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final currency = settingsAsync.when(
      data: (s) => s.currency,
      loading: () => '',
      error: (error, stack) => '',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('ADD GOAL', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900)),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.textDark, size: 24.r),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(24.r),
          children: [
            Text('Goal Title', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, letterSpacing: 1)),
            Gap(12.h),
            TextFormField(
              controller: _titleController,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'e.g., New iPhone 15, Vacation',
                prefixIcon: Icon(LucideIcons.target, size: 20.r),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            Gap(24.h),
            Text('Target Amount', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, letterSpacing: 1)),
            Gap(12.h),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: '0.00',
                prefixIcon: Icon(LucideIcons.banknote, size: 20.r),
                suffixText: currency,
                suffixStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              ),
              validator: (val) => val == null || double.tryParse(val) == null ? 'Invalid amount' : null,
            ),
            Gap(24.h),
            Text('Target Date', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, letterSpacing: 1)),
            Gap(12.h),
            TextFormField(
              readOnly: true,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                prefixIcon: Icon(LucideIcons.calendar, size: 20.r),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              ),
              onTap: () async {
                final date = await NeoDatePicker.show(
                  context: context,
                  initialDate: _targetDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) setState(() => _targetDate = date);
              },
            ),
             Gap(24.h),
            Text('Priority', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, letterSpacing: 1)),
            Gap(12.h),
            DropdownButtonFormField<GoalPriority>(
              decoration: InputDecoration(
                prefixIcon: Icon(LucideIcons.flame, size: 20.r),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              ),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textDark),
              initialValue: _selectedPriority,
              items: GoalPriority.values.map((GoalPriority priority) {
                return DropdownMenuItem<GoalPriority>(
                  value: priority,
                  child: Text(priority.name[0].toUpperCase() + priority.name.substring(1)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedPriority = val);
              },
            ),
            Gap(40.h),
            NeoButton(
              text: 'SAVE GOAL',
              onPressed: _save,
            ).animate().slideY(begin: 1, curve: Curves.easeOutBack),
          ].animate(interval: 50.ms).slideX(begin: 0.1).fadeIn(),
        ),
      ),
    );
  }
}
