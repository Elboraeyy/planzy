import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:planzy/features/goals/data/models/goal.dart';
import 'package:planzy/features/goals/presentation/providers/goals_provider.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Goal'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Goal Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Gap(8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'e.g., New iPhone 15, Vacation',
                prefixIcon: Icon(LucideIcons.target),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const Gap(24),
            const Text('Target Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Gap(8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixIcon: Icon(LucideIcons.banknote),
                suffixText: 'EGP',
              ),
              validator: (val) => val == null || double.tryParse(val) == null ? 'Invalid amount' : null,
            ),
            const Gap(24),
            const Text('Target Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Gap(8),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                prefixIcon: const Icon(LucideIcons.calendar),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _targetDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) setState(() => _targetDate = date);
              },
            ),
             const Gap(24),
            const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Gap(8),
            DropdownButtonFormField<GoalPriority>(
              decoration: const InputDecoration(
                prefixIcon: Icon(LucideIcons.flame),
              ),
              initialValue: GoalPriority.medium,
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
            const Gap(40),
            NeoButton(
              text: 'Save Goal',
              onPressed: _save,
            ).animate().slideY(begin: 1, curve: Curves.easeOutBack),
          ].animate(interval: 50.ms).slideX(begin: 0.1).fadeIn(),
        ),
      ),
    );
  }
}
