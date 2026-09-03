import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum _PickerMode { calendar, monthGrid, yearGrid }

/// A sleek shadcn-styled date picker dialog with zero overflow issues.
class AppDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const AppDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showGeneralDialog<DateTime?>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DatePicker',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: AppDatePicker(
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
          ),
        );
      },
    );
  }

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  _PickerMode _mode = _PickerMode.calendar;
  final ScrollController _yearScrollController = ScrollController();
  bool _yearScrolled = false;

  final List<String> _weekDays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  final List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  @override
  void dispose() {
    _yearScrollController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isSelected(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  bool _isDateSelectable(DateTime date) {
    return !date.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month, widget.firstDate.day)) &&
        !date.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month, widget.lastDate.day));
  }

  List<DateTime?> _generateCalendarDays() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    int leadingEmpty = firstDayOfMonth.weekday - 1;

    final days = <DateTime?>[];
    for (int i = 0; i < leadingEmpty; i++) {
      days.add(null);
    }
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_displayedMonth.year, _displayedMonth.month, i));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 330,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Navigation
            _buildNavigation(),

            // Body
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _mode == _PickerMode.calendar
                  ? _buildCalendarView()
                  : _mode == _PickerMode.monthGrid
                      ? _buildMonthGridView()
                      : _buildYearGridView(),
            ),

            const Gap(10),

            // Actions
            _buildActions(),
          ],
        ),
      ).animate().fadeIn(duration: 150.ms),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: const BoxDecoration(
        color: AppColors.zinc950,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(19),
          topRight: Radius.circular(19),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SELECT DATE',
            style: TextStyle(
              color: AppColors.zinc400,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const Gap(4),
          Text(
            DateFormat('EEEE, MMM d').format(_selectedDate),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const Gap(4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.zinc800,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${_selectedDate.year}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: AppColors.zinc300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Prev arrow
          GestureDetector(
            onTap: _previousMonth,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.zinc100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: const Icon(
                LucideIcons.chevronLeft,
                size: 16,
                color: AppColors.textDark,
              ),
            ),
          ),

          // Month & Year pills
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _mode = _mode == _PickerMode.monthGrid ? _PickerMode.calendar : _PickerMode.monthGrid;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _mode == _PickerMode.monthGrid ? AppColors.primary : AppColors.zinc100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('MMMM').format(_displayedMonth),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: _mode == _PickerMode.monthGrid ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const Gap(4),
                      Icon(
                        _mode == _PickerMode.monthGrid ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                        size: 13,
                        color: _mode == _PickerMode.monthGrid ? Colors.white : AppColors.zinc500,
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(6),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _mode = _mode == _PickerMode.yearGrid ? _PickerMode.calendar : _PickerMode.yearGrid;
                    _yearScrolled = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _mode == _PickerMode.yearGrid ? AppColors.primary : AppColors.zinc100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_displayedMonth.year}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: _mode == _PickerMode.yearGrid ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const Gap(4),
                      Icon(
                        _mode == _PickerMode.yearGrid ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                        size: 13,
                        color: _mode == _PickerMode.yearGrid ? Colors.white : AppColors.zinc500,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Next arrow
          GestureDetector(
            onTap: _nextMonth,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.zinc100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: const Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    final days = _generateCalendarDays();
    final rows = (days.length / 7).ceil();

    return Column(
      key: const ValueKey('calendar'),
      children: [
        // Weekday labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: _weekDays.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Gap(6),
        // Day grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: List.generate(rows, (rowIndex) {
              return Row(
                children: List.generate(7, (colIndex) {
                  final dayIndex = rowIndex * 7 + colIndex;
                  if (dayIndex >= days.length || days[dayIndex] == null) {
                    return const Expanded(child: SizedBox(height: 36));
                  }

                  final date = days[dayIndex]!;
                  final selected = _isSelected(date);
                  final today = _isToday(date);
                  final selectable = _isDateSelectable(date);

                  return Expanded(
                    child: GestureDetector(
                      onTap: selectable ? () => setState(() => _selectedDate = date) : null,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 36,
                        margin: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : today
                                  ? AppColors.zinc100
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w700 : (today ? FontWeight.w600 : FontWeight.w400),
                              color: selected
                                  ? Colors.white
                                  : selectable
                                      ? AppColors.textDark
                                      : AppColors.zinc300,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthGridView() {
    return Container(
      key: const ValueKey('monthGrid'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 200,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.1,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final isSelected = _displayedMonth.month == index + 1;
          return GestureDetector(
            onTap: () {
              setState(() {
                _displayedMonth = DateTime(_displayedMonth.year, index + 1);
                _mode = _PickerMode.calendar;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.zinc100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _monthNames[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildYearGridView() {
    final startYear = widget.firstDate.year;
    final endYear = widget.lastDate.year;
    final totalYears = endYear - startYear + 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_yearScrolled && _yearScrollController.hasClients) {
        final currentYearIndex = _displayedMonth.year - startYear;
        final rowIndex = currentYearIndex ~/ 3;
        final offset = rowIndex * 48.0;
        _yearScrollController.jumpTo(
          offset.clamp(0.0, _yearScrollController.position.maxScrollExtent),
        );
        _yearScrolled = true;
      }
    });

    return Container(
      key: const ValueKey('yearGrid'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 200,
      child: GridView.builder(
        controller: _yearScrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.1,
        ),
        itemCount: totalYears,
        itemBuilder: (context, index) {
          final year = startYear + index;
          final isSelected = _displayedMonth.year == year;
          return GestureDetector(
            onTap: () {
              setState(() {
                _displayedMonth = DateTime(year, _displayedMonth.month);
                _mode = _PickerMode.calendar;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.zinc100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$year',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        children: [
          // Today button
          GestureDetector(
            onTap: () {
              final today = DateTime.now();
              if (_isDateSelectable(today)) {
                setState(() {
                  _selectedDate = today;
                  _displayedMonth = DateTime(today.year, today.month);
                  _mode = _PickerMode.calendar;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.zinc100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Today',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textDark),
              ),
            ),
          ),
          const Spacer(),
          // Cancel
          GestureDetector(
            onTap: () => Navigator.of(context).pop(null),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppColors.textLight),
              ),
            ),
          ),
          const Gap(6),
          // Done
          GestureDetector(
            onTap: () => Navigator.of(context).pop(_selectedDate),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
