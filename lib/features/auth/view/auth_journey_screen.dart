import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';
import 'package:planzy/core/widgets/neo_card.dart';

class AuthJourneyScreen extends ConsumerStatefulWidget {
  const AuthJourneyScreen({super.key});

  @override
  ConsumerState<AuthJourneyScreen> createState() => _AuthJourneyScreenState();
}

class _AuthJourneyScreenState extends ConsumerState<AuthJourneyScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Controllers for inputs
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  String _selectedCurrency = 'EGP';

  final List<String> _currencies = ['EGP', 'USD', 'EUR', 'GBP', 'SAR', 'AED'];

  void _onNext() {
    if (_currentStep < 2) {
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeOutBack);
    } else {
      _finalizeJourney();
    }
  }

  Future<void> _finalizeJourney() async {
    final name = _nameController.text.trim().isEmpty ? 'Planner' : _nameController.text.trim();
    final income = double.tryParse(_incomeController.text) ?? 0.0;

    await ref.read(settingsProvider.notifier).completeProfile(
          name: name,
          currency: _selectedCurrency,
          monthlyIncome: income,
        );

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Progress / Title
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  ...List.generate(3, (index) {
                    final isActive = index <= _currentStep;
                    return Expanded(
                      child: Container(
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : AppColors.border.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (val) => setState(() => _currentStep = val),
                children: [
                  _buildNameStep(),
                  _buildCurrencyStep(),
                  _buildIncomeStep(),
                ],
              ),
            ),

            // Next Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: NeoButton(
                onPressed: _onNext,
                text: _currentStep == 2 ? 'FINISH JOURNEY' : 'NEXT STEP',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FIRST THINGS FIRST...',
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textLight, letterSpacing: 1),
          ).animate().fadeIn().slideY(begin: 0.2),
          const Gap(8),
          const Text(
            'WHAT SHOULD WE CALL YOU?',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
          const Gap(40),
          TextField(
            controller: _nameController,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            decoration: const InputDecoration(
              hintText: 'Enter your name...',
              contentPadding: EdgeInsets.all(24),
            ),
          ).animate().scale(delay: 300.ms, curve: Curves.elasticOut, duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildCurrencyStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SELECT YOUR VIBE',
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textLight, letterSpacing: 1),
          ).animate().fadeIn(),
          const Gap(8),
          const Text(
            'WHICH CURRENCY DO YOU USE?',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1),
          ).animate().fadeIn(delay: 100.ms),
          const Gap(40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: _currencies.length,
            itemBuilder: (context, index) {
              final curr = _currencies[index];
              final isSelected = _selectedCurrency == curr;
              return GestureDetector(
                onTap: () => setState(() => _selectedCurrency = curr),
                child: NeoCard(
                  backgroundColor: isSelected ? AppColors.secondary : AppColors.white,
                  child: Center(
                    child: Text(
                      curr,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ),
                ),
              ).animate().scale(delay: (index * 50).ms, curve: Curves.elasticOut);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THE MONTHLY FUEL',
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textLight, letterSpacing: 1),
          ).animate().fadeIn(),
          const Gap(8),
          const Text(
             'WHAT IS YOUR AVERAGE MONTHLY REVENUE?',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1),
          ).animate().fadeIn(delay: 100.ms),
          const Gap(40),
          TextField(
            controller: _incomeController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              hintText: '0.00',
              suffixText: _selectedCurrency,
              contentPadding: const EdgeInsets.all(24),
            ),
          ).animate().scale(delay: 300.ms, curve: Curves.elasticOut, duration: 800.ms),
        ],
      ),
    );
  }
}
