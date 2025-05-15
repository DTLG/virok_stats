import 'package:flutter/material.dart';

class DateFilterButtons extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime, DateTime) onDateRangeChanged;

  const DateFilterButtons({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday = startDate.year == today.year &&
        startDate.month == today.month &&
        startDate.day == today.day &&
        endDate.year == today.year &&
        endDate.month == today.month &&
        endDate.day == today.day;

    final last7Start = today.subtract(const Duration(days: 6));
    final isLast7 = startDate.year == last7Start.year &&
        startDate.month == last7Start.month &&
        startDate.day == last7Start.day &&
        endDate.year == today.year &&
        endDate.month == today.month &&
        endDate.day == today.day;

    String customLabel =
        "${startDate.day.toString().padLeft(2, '0')}.${startDate.month.toString().padLeft(2, '0')} - ${endDate.day.toString().padLeft(2, '0')}.${endDate.month.toString().padLeft(2, '0')}";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDateButton(
          context,
          'Сьогодні',
          () {
            final now = DateTime.now();
            onDateRangeChanged(
              DateTime(now.year, now.month, now.day),
              DateTime(now.year, now.month, now.day, 23, 59, 59),
            );
          },
          isToday,
        ),
        // _buildDateButton(
        //   context,
        //   'Вчора',
        //   () {
        //     final yesterday = DateTime.now().subtract(const Duration(days: 1));
        //     onDateRangeChanged(
        //       DateTime(yesterday.year, yesterday.month, yesterday.day),
        //       DateTime(
        //           yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
        //     );
        //   },
        // ),
        _buildDateButton(
          context,
          'Тиждень',
          () {
            final now = DateTime.now();
            final weekAgo = now.subtract(const Duration(days: 6));
            onDateRangeChanged(
              DateTime(weekAgo.year, weekAgo.month, weekAgo.day),
              DateTime(now.year, now.month, now.day, 23, 59, 59),
            );
          },
          isLast7,
        ),
        _buildDateButton(
          context,
          customLabel,
          () async {
            final DateTimeRange? picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDateRange: DateTimeRange(
                start: startDate,
                end: endDate,
              ),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onDateRangeChanged(
                DateTime(
                    picked.start.year, picked.start.month, picked.start.day),
                DateTime(picked.end.year, picked.end.month, picked.end.day, 23,
                    59, 59),
              );
            }
          },
          !isToday && !isLast7,
        ),
      ],
    );
  }

  Widget _buildDateButton(BuildContext context, String text,
      VoidCallback onPressed, bool isSelected) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.grey[400]!,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
