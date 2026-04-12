import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:planzy/core/widgets/neo_card.dart';
import 'package:planzy/features/commitments/presentation/providers/commitments_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commitmentsAsync = ref.watch(commitmentsProvider);

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
            return const Center(child: Text('NO DATA', style: TextStyle(fontWeight: FontWeight.w900)));
          }

          final now = DateTime.now();
          final currentMonthName = DateFormat('MMMM').format(now).toUpperCase();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        left: BorderSide(
                          color: AppColors.border,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Column(
                      children: commitments.map((item) {
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
                                onLongPress: () => _confirmDeletion(context, 'PAYMENT', item.title, () {
                                  ref.read(commitmentsProvider.notifier).removeCommitment(item.id);
                                }),
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
                                        child: const Icon(
                                          LucideIcons.repeat,
                                          color: AppColors.textDark,
                                        ),
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
                                      Text(
                                        NumberFormat.compact().format(item.amount),
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ).animate().slideY(begin: 0.5, curve: Curves.easeOutBack, delay: 100.ms).fadeIn(),
                        );
                      }).toList(),
                    ),
                  )
                ],
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _confirmDeletion(BuildContext context, String type, String title, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border, width: 3)),
        title: Text('DELETE $type?', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: Text('Are you sure you want to remove "$title"?', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO', style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900)),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.border, width: 2)),
            ),
            child: const Text('YES, DELETE', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
