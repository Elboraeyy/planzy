import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:planzy/core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// View mode for the picker
enum _PickerMode { calendar, monthGrid, yearGrid }

/// A custom Neo-Brutalist date picker dialog.
class NeoDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const NeoDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  /// Show the Neo-Brutalist date picker and return the selected date.
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
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: NeoDatePicker(
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
          ),
        );
      },
    );
  }

  @override
  State<NeoDatePicker> createState() => _NeoDatePickerState();
}

class _NeoDatePickerState extends State<NeoDatePicker> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  _PickerMode _mode = _PickerMode.calendar;
  final ScrollController _yearScrollController = ScrollController();
  bool _yearScrolled = false;

  final List<String> _weekDays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
  final List<String> _monthNames = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];
  final List<String> _monthFullNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
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

  bool _isDateSelectable(DateTime date) {
    return !date.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month, widget.firstDate.day)) &&
        !date.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month, widget.lastDate.day));
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

  List<DateTime?> _generateCalendarDays() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_displayedMonth.year, _displayedMonth.month);
    int startWeekday = firstDayOfMonth.weekday - 1;

    final List<DateTime?> days = [];
    for (int i = 0; i < startWeekday; i++) {
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
        width: 340,
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 3),
          boxShadow: const [
            BoxShadow(color: AppColors.border, offset: Offset(6, 6)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ──── Header ────
            _buildHeader(),

            // ──── Month/Year Navigation ────
            _buildNavigation(),

            // ──── Body (Calendar / Month Grid / Year Grid) ────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              child: _mode == _PickerMode.calendar
                  ? _buildCalendarView()
                  : _mode == _PickerMode.monthGrid
                      ? _buildMonthGridView()
                      : _buildYearGridView(),
            ),

            const Gap(8),

            // ──── Action Buttons ────
            _buildActions(),
          ],
        ),
      ).animate().fadeIn(duration: 200.ms),
    );
  }

  // ═══════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(17),
          topRight: Radius.circular(17),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PICK A DATE',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const Gap(6),
          Text(
            DateFormat('EEEE').format(_selectedDate).toUpperCase(),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const Gap(2),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: Text(
                  DateFormat('d MMM').format(_selectedDate).toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cardYellow,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: Text(
                  '${_selectedDate.year}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // NAVIGATION — Tappable month + year labels
  // ═══════════════════════════════════════════════════════
  Widget _buildNavigation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Prev arrow
          GestureDetector(
            onTap: _previousMonth,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))],
              ),
              child: const Icon(
                LucideIcons.chevronLeft,
                size: 18,
                color: AppColors.textDark,
              ),
            ),
          ),

          const Spacer(),

          // Month label — tap to pick month
          GestureDetector(
            onTap: () {
              setState(() {
                _mode = _mode == _PickerMode.monthGrid ? _PickerMode.calendar : _PickerMode.monthGrid;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _mode == _PickerMode.monthGrid ? AppColors.secondary : AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMMM').format(_displayedMonth).toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: AppColors.textDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Gap(4),
                  Icon(
                    _mode == _PickerMode.monthGrid ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 14,
                    color: AppColors.textDark,
                  ),
                ],
              ),
            ),
          ),

          const Gap(8),

          // Year label — tap to pick year
          GestureDetector(
            onTap: () {
              setState(() {
                _mode = _mode == _PickerMode.yearGrid ? _PickerMode.calendar : _PickerMode.yearGrid;
                _yearScrolled = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _mode == _PickerMode.yearGrid ? AppColors.cardYellow : AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_displayedMonth.year}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Gap(4),
                  Icon(
                    _mode == _PickerMode.yearGrid ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 14,
                    color: AppColors.textDark,
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Next arrow
          GestureDetector(
            onTap: _nextMonth,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))],
              ),
              child: const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // CALENDAR VIEW (Days)
  // ═══════════════════════════════════════════════════════
  Widget _buildCalendarView() {
    final days = _generateCalendarDays();
    final rows = (days.length / 7).ceil();

    return Column(
      key: const ValueKey('calendar'),
      children: [
        // Weekday labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _weekDays.map((d) {
              final isWeekend = d == 'SA' || d == 'SU';
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isWeekend ? AppColors.primary.withValues(alpha: 0.5) : AppColors.textLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const Gap(4),
        // Day grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: List.generate(rows, (rowIndex) {
              return Row(
                children: List.generate(7, (colIndex) {
                  final dayIndex = rowIndex * 7 + colIndex;
                  if (dayIndex >= days.length || days[dayIndex] == null) {
                    return const Expanded(child: SizedBox(height: 44));
                  }

                  final date = days[dayIndex]!;
                  final selected = _isSelected(date);
                  final today = _isToday(date);
                  final selectable = _isDateSelectable(date);

                  return Expanded(
                    child: GestureDetector(
                      onTap: selectable ? () => setState(() => _selectedDate = date) : null,
                      child: Container(
                        height: 44,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : today
                                  ? AppColors.secondary.withValues(alpha: 0.3)
                                  : null,
                          borderRadius: BorderRadius.circular(10),
                          border: selected
                              ? Border.all(color: AppColors.border, width: 2)
                              : today
                                  ? Border.all(color: AppColors.border.withValues(alpha: 0.2), width: 2)
                                  : null,
                          boxShadow: selected
                              ? const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: selected || today ? FontWeight.w900 : FontWeight.w700,
                              color: selected
                                  ? AppColors.white
                                  : !selectable
                                      ? AppColors.textLight.withValues(alpha: 0.25)
                                      : today
                                          ? AppColors.primary
                                          : AppColors.textDark,
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

  // ═══════════════════════════════════════════════════════
  // MONTH GRID VIEW
  // ═══════════════════════════════════════════════════════
  Widget _buildMonthGridView() {
    return Padding(
      key: const ValueKey('months'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Title
          Text(
            'SELECT MONTH',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.textLight,
              letterSpacing: 2,
            ),
          ),
          const Gap(12),
          // 4 rows of 3
          ...List.generate(4, (rowIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: List.generate(3, (colIndex) {
                  final monthIndex = rowIndex * 3 + colIndex;
                  final month = monthIndex + 1;
                  final isSelected = _displayedMonth.month == month;
                  final isCurrentMonth = DateTime.now().month == month && _displayedMonth.year == DateTime.now().year;

                  // Check if this month is within the selectable range
                  final monthDate = DateTime(_displayedMonth.year, month);
                  final isSelectable = !monthDate.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month)) &&
                      !monthDate.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month));

                  return Expanded(
                    child: GestureDetector(
                      onTap: isSelectable
                          ? () {
                              setState(() {
                                _displayedMonth = DateTime(_displayedMonth.year, month);
                                _mode = _PickerMode.calendar;
                              });
                            }
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : isCurrentMonth
                                  ? AppColors.secondary.withValues(alpha: 0.3)
                                  : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected || isCurrentMonth
                                ? AppColors.border
                                : isSelectable
                                    ? AppColors.border.withValues(alpha: 0.2)
                                    : AppColors.border.withValues(alpha: 0.08),
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Text(
                              _monthNames[monthIndex],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                                color: isSelected
                                    ? AppColors.white
                                    : !isSelectable
                                        ? AppColors.textLight.withValues(alpha: 0.25)
                                        : AppColors.textDark,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              _monthFullNames[monthIndex].substring(0, 3),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.white.withValues(alpha: 0.6)
                                    : AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // YEAR GRID VIEW
  // ═══════════════════════════════════════════════════════
  Widget _buildYearGridView() {
    const int startYear = 2000;
    const int endYear = 2099;
    final years = List.generate(endYear - startYear + 1, (i) => startYear + i);
    final rowCount = (years.length / 3).ceil();

    // Auto-scroll to selected year row on first open
    if (!_yearScrolled) {
      _yearScrolled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_yearScrollController.hasClients) return;
        final selectedRow = (_displayedMonth.year - startYear) ~/ 3;
        final target = (selectedRow * 60.0) - 100; // center-ish
        _yearScrollController.animateTo(
          target.clamp(0.0, _yearScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
        );
      });
    }

    return Padding(
      key: const ValueKey('years'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const Text(
            'SELECT YEAR',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.textLight,
              letterSpacing: 2,
            ),
          ),
          const Gap(12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: SingleChildScrollView(
              controller: _yearScrollController,
              child: Column(
                children: List.generate(rowCount, (rowIndex) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: List.generate(3, (colIndex) {
                        final yearIndex = rowIndex * 3 + colIndex;
                        if (yearIndex >= years.length) return const Expanded(child: SizedBox());

                        final year = years[yearIndex];
                        final isSelected = _displayedMonth.year == year;
                        final isCurrentYear = DateTime.now().year == year;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _displayedMonth = DateTime(year, _displayedMonth.month);
                                _mode = _PickerMode.calendar;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : isCurrentYear
                                        ? AppColors.cardYellow.withValues(alpha: 0.4)
                                        : AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected || isCurrentYear
                                      ? AppColors.border
                                      : AppColors.border.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                                boxShadow: isSelected
                                    ? const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '$year',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected
                                        ? AppColors.white
                                        : AppColors.textDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ACTION BUTTONS
  // ═══════════════════════════════════════════════════════
  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          // Today shortcut
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardYellow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))],
              ),
              child: const Text(
                'TODAY',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
              ),
            ),
          ),
          const Spacer(),
          // Cancel
          GestureDetector(
            onTap: () => Navigator.of(context).pop(null),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))],
              ),
              child: const Text(
                'CANCEL',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: AppColors.textLight),
              ),
            ),
          ),
          const Gap(10),
          // Confirm
          GestureDetector(
            onTap: () => Navigator.of(context).pop(_selectedDate),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 2),
                boxShadow: const [BoxShadow(color: AppColors.border, offset: Offset(2, 2))],
              ),
              child: const Text(
                'DONE',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
