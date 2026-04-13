import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      error: (_, __) => '',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedType == TransactionType.expense
              ? 'Add Expense'
              : 'Add Income',
        ),
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
            ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1),

            const Gap(32),

            // Amount Input
            const Text(
              'AMOUNT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const Gap(12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.border,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      border: Border(
                        right: BorderSide(color: AppColors.border, width: 3),
                      ),
                    ),
                    child: Text(
                      currency,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
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
            ).animate().fadeIn(duration: 200.ms, delay: 100.ms).slideX(begin: 0.1),

            const Gap(32),

            // Date Picker
            const Text(
              'DATE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const Gap(12),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.border,
                      offset: Offset(4, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.calendar, color: AppColors.textDark),
                    const Gap(12),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _selectedDate.day == DateTime.now().day
                            ? AppColors.secondary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border, width: 2),
                      ),
                      child: Text(
                        _selectedDate.day == DateTime.now().day ? 'TODAY' : 'CHANGE',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 200.ms, delay: 200.ms).slideX(begin: 0.1),

            const Gap(32),

            // Account Selector
            _buildAccountSelector(),

            const Gap(32),

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
            ).animate().fadeIn(duration: 200.ms, delay: 300.ms).slideX(begin: 0.1),

            const Gap(32),

            // Notes Input
            const Text(
              'NOTES',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const Gap(12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add a note (optional)',
                prefixIcon: Icon(LucideIcons.fileText),
              ),
            ).animate().fadeIn(duration: 200.ms, delay: 400.ms).slideX(begin: 0.1),

            const Gap(32),

            // Receipt Picker (for expenses only)
            if (_selectedType == TransactionType.expense) ...[
              const Text(
                'RECEIPT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const Gap(12),
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
              ).animate().fadeIn(duration: 200.ms, delay: 500.ms).slideX(begin: 0.1),
              const Gap(32),
            ],

            // Recurring Toggle (for expenses only)
            if (_selectedType == TransactionType.expense) ...[
              GestureDetector(
                onTap: () => setState(() => _isRecurring = !_isRecurring),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isRecurring ? AppColors.cardYellow : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                      width: 3,
                    ),
                    boxShadow: _isRecurring
                        ? const [
                            BoxShadow(
                              color: AppColors.border,
                              offset: Offset(4, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isRecurring ? LucideIcons.repeat : LucideIcons.repeat,
                        color: AppColors.textDark,
                      ),
                      const Gap(12),
                      const Expanded(
                        child: Text(
                          'RECURRING EXPENSE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _isRecurring ? AppColors.primary : AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: _isRecurring
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: AppColors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 200.ms, delay: 600.ms).slideX(begin: 0.1),
              const Gap(40),
            ],

            // Save Button
            NeoButton(
              text: _isLoading ? 'SAVING...' : 'SAVE TRANSACTION',
              onPressed: _isLoading ? () {} : _saveTransaction,
              backgroundColor: _selectedType == TransactionType.expense
                  ? AppColors.primary
                  : AppColors.secondary,
            ).animate().fadeIn(duration: 200.ms, delay: 700.ms).slideY(begin: 0.2),
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
              _selectedType == TransactionType.income ? 'RECEIVE INTO' : 'PAY FROM',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const Gap(12),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: accounts.length,
                separatorBuilder: (_, __) => const Gap(10),
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  final isSelected = account.id == _selectedAccountId;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedAccountId = account.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 2),
                        boxShadow: isSelected
                            ? const [BoxShadow(color: AppColors.border, offset: Offset(3, 3))]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            account.iconEmoji ?? account.type.icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const Gap(8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                account.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: isSelected ? AppColors.white : AppColors.textDark,
                                ),
                              ),
                              Text(
                                account.type.displayName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white60 : AppColors.textLight,
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
            ).animate().fadeIn(duration: 200.ms, delay: 250.ms).slideX(begin: 0.1),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
