import 'package:flutter/material.dart';
import '../utils/date_utils.dart';

class MonthGrid extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final List<Color> Function(DateTime date) dotColors;
  final ValueChanged<DateTime> onDaySelected;

  const MonthGrid({
    super.key,
    required this.visibleMonth,
    required this.selectedDate,
    required this.dotColors,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final year = visibleMonth.year;
    final month = visibleMonth.month;
    final firstWeekday = DateTime(year, month, 1).weekday;
    final leadingEmpty = firstWeekday - 1;
    final totalDays = daysInMonth(year, month);
    final rowsCount = ((leadingEmpty + totalDays) / 7).ceil();
    final today = dateOnly(DateTime.now());

    final rows = <Widget>[];
    for (int row = 0; row < rowsCount; row++) {
      final cells = <Widget>[];
      for (int col = 0; col < 7; col++) {
        final index = row * 7 + col;
        final day = index - leadingEmpty + 1;

        if (day < 1 || day > totalDays) {
          cells.add(const Expanded(child: SizedBox(height: 48)));
        } else {
          final date = DateTime(year, month, day);
          cells.add(
            Expanded(
              child: _DayCell(
                day: day,
                isSelected: isSameDay(date, selectedDate),
                isToday: isSameDay(date, today),
                dots: dotColors(date),
                onTap: () => onDaySelected(date),
              ),
            ),
          );
        }
      }
      rows.add(Row(children: cells));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _WeekdayHeader(),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final name in weekdayShort)
          Expanded(
            child: Center(
              child: Text(
                name,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool isToday;
  final List<Color> dots;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.dots,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colors.primary : null,
                border: isToday && !isSelected
                    ? Border.all(color: colors.primary, width: 1.5)
                    : null,
              ),
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? colors.onPrimary
                      : (isToday ? colors.primary : null),
                ),
              ),
            ),
            SizedBox(
              height: 5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final color in dots)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}