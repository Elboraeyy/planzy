import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:planzy/core/widgets/neo_date_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/providers/auth_provider.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/services/storage_service.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:planzy/core/widgets/planzy_notification.dart';
import 'package:planzy/features/transactions/data/models/transaction.dart';
import 'package:planzy/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:planzy/features/transactions/presentation/widgets/category_selector.dart';
import 'package:planzy/features/transactions/presentation/widgets/receipt_picker.dart';
import 'package:planzy/features/transactions/presentation/widgets/transaction_type_toggle.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:planzy/features/accounts/data/models/financial_account.dart';
import 'package:planzy/features/accounts/presentation/providers/accounts_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  ExpenseCategory? _selectedExpenseCategory;
  IncomeSource? _selectedIncomeSource;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;

  File? _receiptImage;
  String? _receiptUrl;
  String? _receiptLocalPath;

  bool _isLoading = false;
  String? _selectedAccountId;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate category based on type
    if (_selectedType == TransactionType.expense && _selectedExpenseCategory == null) {
      PlanzyNotification.show(
        context,
        message: 'Please select a category',
        type: NotificationType.warning,
      );
      return;
    }

    if (_selectedType == TransactionType.income && _selectedIncomeSource == null) {
      PlanzyNotification.show(
        context,
        message: 'Please select a source',
        type: NotificationType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      // Upload receipt if exists
      if (_receiptImage != null) {
        final storage = ref.read(storageServiceProvider);

        // Save locally first
        _receiptLocalPath = await storage.saveLocally(_receiptImage!);

        // Upload to Firebase
        _receiptUrl = await storage.uploadReceipt(_receiptImage!, user.uid);
      }

      final transaction = Transaction(
        id: const Uuid().v4(),
        userId: user.uid,
        type: _selectedType,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        accountId: _selectedAccountId,
        expenseCategory: _selectedType == TransactionType.expense
            ? _selectedExpenseCategory
            : null,
        incomeSource: _selectedType == TransactionType.income
            ? _selectedIncomeSource
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        receiptUrl: _receiptUrl,
        receiptLocalPath: _receiptLocalPath,
        isRecurring: _selectedType == TransactionType.expense ? _isRecurring : null,
        createdAt: DateTime.now(),
      );

      await ref.read(transactionsProvider.notifier).add(transaction);

      // Auto-adjust account balance
      if (_selectedAccountId != null) {
        final delta = _selectedType == TransactionType.income
            ? double.parse(_amountController.text)
            : -double.parse(_amountController.text);
        await ref.read(accountsProvider.notifier).adjustBalance(_selectedAccountId!, delta);
      }

      if (mounted) {
        PlanzyNotification.show(
          context,
          message: _selectedType == TransactionType.expense
              ? 'Expense added successfully!'
              : 'Income added successfully!',
          type: NotificationType.success,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        PlanzyNotification.show(
          context,
          message: 'Error: $e',
          type: NotificationType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final date = await NeoDatePicker.show(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
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
        title: Text(
          _selectedType == TransactionType.expense
              ? 'Add Expense'
              : 'Add Income',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.4,
          ),
        ),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.textDark, size: 20.r),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          children: [
            // Type Toggle
            TransactionTypeToggle(
              selectedType: _selectedType,
              onTypeChanged: (type) {
                setState(() {
                  _selectedType = type;
                  _selectedExpenseCategory = null;
                  _selectedIncomeSource = null;
                });
              },
            ).animate().fadeIn(duration: 150.ms),

            Gap(24.h),

            // Amount Input
            Text(
              'Amount',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: AppColors.textDark,
              ),
            ),
            Gap(8.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border, width: 1.r),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppColors.zinc100,
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(11.r)),
                      border: Border(
                        right: BorderSide(color: AppColors.border, width: 1.r),
                      ),
                    ),
                    child: Text(
                      currency,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: AppColors.textDark,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: AppColors.zinc300, fontSize: 24.sp),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (double.tryParse(val) == null) return 'Invalid amount';
                        if (double.parse(val) <= 0) return 'Amount must be positive';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 150.ms, delay: 50.ms),

            Gap(24.h),

            // Date Picker
            Text(
              'Date',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: AppColors.textDark,
              ),
            ),
            Gap(8.h),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border, width: 1.r),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.calendar, color: AppColors.zinc500, size: 18.r),
                    Gap(10.w),
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.zinc100,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: AppColors.border, width: 1.r),
                      ),
                      child: Text(
                        _selectedDate.day == DateTime.now().day ? 'Today' : 'Change',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 150.ms, delay: 100.ms),

            Gap(20.h),

            // Account Selector
            _buildAccountSelector(),

            Gap(20.h),

            // Category Selector
            CategorySelector(
              type: _selectedType,
              selectedCategory: _selectedType == TransactionType.expense
                  ? _selectedExpenseCategory
                  : _selectedIncomeSource,
              onCategorySelected: (category) {
                setState(() {
                  if (_selectedType == TransactionType.expense) {
                    _selectedExpenseCategory = category as ExpenseCategory;
                  } else {
                    _selectedIncomeSource = category as IncomeSource;
                  }
                });
              },
            ).animate().fadeIn(duration: 150.ms, delay: 150.ms),

            Gap(20.h),

            // Notes Input
            Text(
              'Notes',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: AppColors.textDark,
              ),
            ),
            Gap(8.h),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                hintStyle: TextStyle(color: AppColors.textLight, fontSize: 13.sp),
                prefixIcon: Icon(LucideIcons.fileText, size: 18.r, color: AppColors.zinc500),
              ),
            ).animate().fadeIn(duration: 150.ms, delay: 200.ms),

            Gap(20.h),

            // Receipt Picker (for expenses only)
            if (_selectedType == TransactionType.expense) ...[
              Text(
                'Receipt',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: AppColors.textDark,
                ),
              ),
              Gap(8.h),
              ReceiptPicker(
                localImage: _receiptImage,
                remoteUrl: _receiptUrl,
                onImageSelected: (image) {
                  setState(() => _receiptImage = image);
                },
                onImageRemoved: () {
                  setState(() {
                    _receiptImage = null;
                    _receiptUrl = null;
                  });
                },
              ).animate().fadeIn(duration: 150.ms, delay: 250.ms),
              Gap(20.h),
            ],

            // Recurring Toggle (for expenses only)
            if (_selectedType == TransactionType.expense) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1.r,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.repeat,
                      color: AppColors.zinc500,
                      size: 20.r,
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recurring Expense',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Repeats every month automatically',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _isRecurring,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isRecurring = val),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 150.ms, delay: 300.ms),
              Gap(28.h),
            ],

            // Save Button
            NeoButton(
              text: _isLoading ? 'Saving...' : 'Save Transaction',
              isLoading: _isLoading,
              height: 48.h,
              onPressed: _isLoading ? () {} : _saveTransaction,
            ).animate().fadeIn(duration: 150.ms, delay: 350.ms),
            Gap(32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelector() {
    final accountsAsync = ref.watch(accountsProvider);

    return accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) return const SizedBox.shrink();

        // Auto-select default on first load
        if (_selectedAccountId == null) {
          final defaultAcc = accounts.where((a) => a.isDefault).firstOrNull ?? accounts.first;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedAccountId = defaultAcc.id);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedType == TransactionType.income ? 'Deposit Into' : 'Pay From',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: AppColors.textDark,
              ),
            ),
            Gap(8.h),
            SizedBox(
              height: 52.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: accounts.length,
                separatorBuilder: (context, index) => Gap(10.w),
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  final isSelected = account.id == _selectedAccountId;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedAccountId = account.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(10.r),
                        border: isSelected
                            ? null
                            : Border.all(color: AppColors.border, width: 1.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            account.iconEmoji ?? account.type.icon,
                            style: TextStyle(fontSize: 18.sp),
                          ),
                          Gap(8.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                account.name,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  fontSize: 12.sp,
                                  color: isSelected ? Colors.white : AppColors.textDark,
                                ),
                              ),
                              Text(
                                account.type.displayName,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w400,
                                  color: isSelected ? Colors.white70 : AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(duration: 150.ms, delay: 100.ms),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
