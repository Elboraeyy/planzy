import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _handleLogin() async {
    // For a local-first app, login is essentially finding/setting the profile.
    // We'll mark the profile as complete if they provide a name we already have,
    // or just let them "log in" by completing the registration flag.
    
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    // Simulate login by updating the settings
    await ref.read(settingsProvider.notifier).completeProfile(
      name: name,
      currency: 'EGP', // Default for login for now
      monthlyIncome: 0,
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
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WELCOME BACK',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, height: 1.0),
              ).animate().fadeIn().slideX(begin: -0.2),
              const Gap(8),
              const Text(
                'ENTER YOUR NAME TO CONTINUE',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1, color: AppColors.textLight),
              ).animate().fadeIn(delay: 200.ms),
              
              const Gap(60),
              
              TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                decoration: const InputDecoration(
                  hintText: 'Your name...',
                  contentPadding: EdgeInsets.all(24),
                ),
              ).animate().scale(delay: 400.ms, curve: Curves.elasticOut, duration: 800.ms),
              
              const Gap(40),
              
              NeoButton(
                onPressed: _handleLogin,
                text: 'LET\'S GO',
              ).animate().fadeIn(delay: 600.ms),
              
              const Gap(24),
              
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'GO BACK',
                    style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900, decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
