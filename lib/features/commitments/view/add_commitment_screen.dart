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
      error: (error, stack) => '',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('ADD COMMITMENT', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900)),
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
            Text('What is it for?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, letterSpacing: 1)),
            Gap(12.h),
            TextFormField(
              controller: _titleController,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'e.g., Gym, Netflix, Rent',
                prefixIcon: Icon(LucideIcons.tag, size: 20.r),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            Gap(24.h),
            Text('Amount', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, letterSpacing: 1)),
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
            Text('Repeat', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, letterSpacing: 1)),
            Gap(12.h),
            DropdownButtonFormField<RepeatType>(
              decoration: InputDecoration(
                prefixIcon: Icon(LucideIcons.repeat, size: 20.r),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              ),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textDark),
              initialValue: _selectedRepeat,
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
            Gap(24.h),
            Text('Start Date', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, letterSpacing: 1)),
            Gap(12.h),
            TextFormField(
              readOnly: true,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                prefixIcon: Icon(LucideIcons.calendar, size: 20.r),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
            Gap(40.h),
            NeoButton(
              text: 'SAVE COMMITMENT',
              onPressed: _save,
            ).animate().slideY(begin: 1, curve: Curves.easeOutBack),
          ].animate(interval: 50.ms).slideX(begin: 0.1).fadeIn(),
        ),
      ),
    );
  }
}
