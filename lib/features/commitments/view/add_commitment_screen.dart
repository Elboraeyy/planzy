import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:planzy/core/widgets/neo_date_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:planzy/features/commitments/data/models/commitment.dart';
import 'package:planzy/features/commitments/presentation/providers/commitments_provider.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:uuid/uuid.dart';

class AddCommitmentScreen extends ConsumerStatefulWidget {
  const AddCommitmentScreen({super.key});

  @override
  ConsumerState<AddCommitmentScreen> createState() => _AddCommitmentScreenState();
}

class _AddCommitmentScreenState extends ConsumerState<AddCommitmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  RepeatType _selectedRepeat = RepeatType.monthly;
  DateTime _startDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final commitment = Commitment(
        id: const Uuid().v4(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        repeatType: _selectedRepeat,
        startDate: _startDate,
        category: 'General',
      );

      await ref.read(commitmentsProvider.notifier).addCommitment(commitment);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final currency = settingsAsync.when(
      data: (s) => s.currency,
      loading: () => '',
      error: (_, __) => '',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Commitment'),
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
            const Text('What is it for?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Gap(8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'e.g., Gym, Netflix, Rent',
                prefixIcon: Icon(LucideIcons.tag),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const Gap(24),
            const Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Gap(8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0.00',
                prefixIcon: const Icon(LucideIcons.banknote),
                suffixText: currency,
              ),
              validator: (val) => val == null || double.tryParse(val) == null ? 'Invalid amount' : null,
            ),
             const Gap(24),
            const Text('Repeat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Gap(8),
            DropdownButtonFormField<RepeatType>(
              decoration: const InputDecoration(
                prefixIcon: Icon(LucideIcons.repeat),
              ),
              initialValue: RepeatType.monthly,
              items: RepeatType.values.map((RepeatType type) {
                return DropdownMenuItem<RepeatType>(
                  value: type,
                  child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedRepeat = val);
              },
            ),
            const Gap(24),
            const Text('Start Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Gap(8),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                prefixIcon: const Icon(LucideIcons.calendar),
              ),
              onTap: () async {
                final date = await NeoDatePicker.show(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) setState(() => _startDate = date);
              },
            ),
            const Gap(40),
            NeoButton(
              text: 'Save Commitment',
              onPressed: _save,
            ).animate().slideY(begin: 1, curve: Curves.easeOutBack),
          ].animate(interval: 50.ms).slideX(begin: 0.1).fadeIn(),
        ),
      ),
    );
  }
}
