import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/features/commitments/presentation/providers/commitments_provider.dart';
import 'package:planzy/core/providers/settings_provider.dart';
import 'package:planzy/core/widgets/neo_dialog.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commitmentsAsync = ref.watch(commitmentsProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final currency = settingsAsync.when(data: (s) => s.currency, loading: () => '', error: (_, __) => '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('TIMELINE'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(LucideIcons.calendar, size: 20),
            ),
          ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
        ],
      ),
      body: commitmentsAsync.when(
        data: (commitments) {
          if (commitments.isEmpty) {
            return Center(
              child: const NeoCard(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('NO EVENTS FOUND', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textLight)),
                ),
              ).animate().fadeIn(delay: 200.ms),
            );
          }

          // Sort by date closest first
          final sortedCommitments = List.of(commitments)..sort((a, b) => a.startDate.compareTo(b.startDate));
          
          final now = DateTime.now();
          final currentMonthName = DateFormat('MMMM yyyy').format(now).toUpperCase();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border, width: 2),
                      boxShadow: const [
                        BoxShadow(color: AppColors.border, offset: Offset(3, 3)),
                      ]
                    ),
                    child: Text(
                      currentMonthName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ).animate().slideX(begin: -0.2, curve: Curves.easeOutBack),
                ],
              ),
              const Gap(24),
              Container(
                margin: const EdgeInsets.only(left: 20, bottom: 24),
                padding: const EdgeInsets.only(left: 24),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.textDark, width: 4),
                  ),
                ),
                child: Column(
                  children: sortedCommitments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: -40,
                            top: 20,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.cardYellow,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border, width: 3),
                              ),
                            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                             .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 1.seconds),
                          ),
                          GestureDetector(
                            onLongPress: () => NeoDialog.show(
                              context: context,
                              title: 'DELETE EVENT?',
                              message: 'Are you sure you want to remove "${item.title}" from timeline?',
                              confirmText: 'YES, DELETE',
                              cancelText: 'NO, KEEP IT',
                              isDestructive: true,
                              onConfirm: () {
                                ref.read(commitmentsProvider.notifier).removeCommitment(item.id);
                              },
                            ),
                            child: NeoCard(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardBlue,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.border, width: 2),
                                    ),
                                    child: const Icon(LucideIcons.repeat, color: AppColors.textDark),
                                  ),
                                  const Gap(16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title.toUpperCase(),
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5),
                                        ),
                                        const Gap(4),
                                        Text(
                                          DateFormat('dd MMM yyyy').format(item.startDate).toUpperCase(),
                                          style: const TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                       Text(
                                          NumberFormat.compact().format(item.amount),
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                                        ),
                                        Text(currency, style: const TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ).animate().slideY(begin: 0.5, curve: Curves.easeOutBack, delay: (100 * index).ms).fadeIn(),
                    );
                  }).toList(),
                ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
