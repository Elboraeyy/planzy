import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    final currency = settingsAsync.when(
      data: (s) => s.currency,
      loading: () => '',
      error: (error, stack) => '',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('TIMELINE', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900)),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 2.r),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(LucideIcons.calendar, size: 20.r),
            ),
          ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
        ],
      ),
      body: commitmentsAsync.when(
        data: (commitments) {
          if (commitments.isEmpty) {
            return Center(
              child: NeoCard(
                child: Padding(
                  padding: EdgeInsets.all(32.r),
                  child: Text('NO EVENTS FOUND', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textLight, fontSize: 16.sp)),
                ),
              ).animate().fadeIn(delay: 200.ms),
            );
          }

          // Sort by date closest first
          final sortedCommitments = List.of(commitments)..sort((a, b) => a.startDate.compareTo(b.startDate));
          
          final now = DateTime.now();
          final currentMonthName = DateFormat('MMMM yyyy').format(now).toUpperCase();

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.border, width: 2.r),
                      boxShadow: [
                        BoxShadow(color: AppColors.border, offset: Offset(3.w, 3.h)),
                      ]
                    ),
                    child: Text(
                      currentMonthName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ).animate().slideX(begin: -0.2, curve: Curves.easeOutBack),
                ],
              ),
              Gap(24.h),
              Container(
                margin: EdgeInsets.only(left: 20.w, bottom: 24.h),
                padding: EdgeInsets.only(left: 24.w),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: AppColors.textDark, width: 4.w),
                  ),
                ),
                child: Column(
                  children: sortedCommitments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: -40.r, // Position based on ScreenUtil radius for consistency
                            top: 20.h,
                            child: Container(
                              width: 24.r,
                              height: 24.r,
                              decoration: BoxDecoration(
                                color: AppColors.cardYellow,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border, width: 3.r),
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
                              padding: EdgeInsets.all(16.r),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12.r),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardBlue,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(color: AppColors.border, width: 2.r),
                                    ),
                                    child: Icon(LucideIcons.repeat, color: AppColors.textDark, size: 24.r),
                                  ),
                                  Gap(16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title.toUpperCase(),
                                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, letterSpacing: -0.5),
                                        ),
                                        Gap(4.h),
                                        Text(
                                          DateFormat('dd MMM yyyy').format(item.startDate).toUpperCase(),
                                          style: TextStyle(color: AppColors.textLight, fontSize: 12.sp, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                       Text(
                                          NumberFormat.compact().format(item.amount),
                                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp),
                                        ),
                                        Text(currency, style: TextStyle(color: AppColors.textLight, fontSize: 10.sp, fontWeight: FontWeight.bold)),
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
