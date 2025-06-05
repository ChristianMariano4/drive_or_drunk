import 'package:drive_or_drunk_app/core/constants/app_colors.dart';
import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:drive_or_drunk_app/core/theme/theme_provider.dart';
import 'package:drive_or_drunk_app/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DateRangePicker extends StatefulWidget {
  final IconData icon;
  final String labelText;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTimeRange?> onChanged;

  const DateRangePicker({
    super.key,
    required this.icon,
    required this.labelText,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  @override
  State<DateRangePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DateRangePicker> {
  DateTimeRange? selectedRange;
  final DateTime now = DateTime.now();

  Future<void> _selectDate() async {
    // Show a custom dialog containing the date range picker
    final result = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 80.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg * 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: DateRangePickerDialog(
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            initialDateRange: selectedRange ??
                DateTimeRange(
                  start: now,
                  end: now.add(const Duration(days: 1)),
                ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedRange = result;
      });
      // Call the onChanged callback when a date range is selected
      widget.onChanged.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = context.watch<ThemeProvider>().themeMode == ThemeMode.light;
    final fillColor = Theme.of(context).inputDecorationTheme.fillColor;

    String displayText = '';
    if (selectedRange != null) {
      final startDate = selectedRange!.start;
      final endDate = selectedRange!.end;

      final startMonth = getMonthString(startDate.month);
      final endMonth = getMonthString(endDate.month);
      final startDay = getDayString(startDate.day);
      final endDay = getDayString(endDate.day);

      if (startDate.year == endDate.year) {
        if (startDate.month == endDate.month) {
          displayText = "$startDay/$startMonth -$endDay";
        } else {
          displayText = "$startDay/$startMonth - $endDay/$endMonth ";
        }
      } else {
        displayText = "$startDay/$startMonth - $endDay/$endMonth";
      }
    }

    return TextField(
      readOnly: true,
      onTap: _selectDate,
      controller: TextEditingController(text: displayText),
      decoration: InputDecoration(
        hintText: "Pick a date",
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: selectedRange != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    selectedRange = null;
                    widget.onChanged(null);
                  });
                },
              )
            : null,
        filled: true,
        fillColor: isLight ? AppColors.grey : fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
