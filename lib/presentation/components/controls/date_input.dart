import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';

class DateInput extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool isLast;
  final String? errorText;
  final bool readOnly;
  final ValueNotifier<DateTime?> selectedDateNotifier;

  const DateInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isLast,
    required this.selectedDateNotifier,
    this.errorText,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: GestureDetector(
          onTap: readOnly
              ? null
              : () async {
            final DateTime? selectedDate = await showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              lastDate: DateTime.now().subtract(Duration(days: 18 * 365)),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.colorPrimaryLight, // Header background color
                      onPrimary: Colors.white, // Header text color
                      onSurface: Colors.black, // Body text color
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.colorPrimaryLight, // Button text color
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (selectedDate != null) {
              selectedDateNotifier.value = selectedDate; // Retain the DateTime object
              controller?.text = _formatDate(selectedDate); // Display the formatted date
            }
          },
          child: AbsorbPointer(
            absorbing: true,
            child: TextField(
              style: const TextStyle(color: Colors.white),
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: BorderSide(
                    color: AppColors.colorPrimaryLight,
                  ),
                ),
                errorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: BorderSide(
                    color: Colors.redAccent,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: BorderSide(
                    color: AppColors.colorPrimaryLight,
                  ),
                ),
                filled: true,
                fillColor: const Color(0x45454545),
                label: Text(
                  hintText,
                  style: const TextStyle(
                    color: AppColors.colorPrimaryLight,
                  ),
                ),
                hintText: hintText,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                errorText: errorText,
                hintStyle: const TextStyle(color: Color(0xFF878787)),
              ),
              onEditingComplete: () {
                if (isLast) {
                  FocusScope.of(context).unfocus();
                } else {
                  FocusScope.of(context).nextFocus();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day;
    final suffix = _getDaySuffix(day);
    final month = _monthNames[date.month - 1];
    final year = date.year;

    return "$day$suffix $month $year";
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return "th";
    }
    switch (day % 10) {
      case 1:
        return "st";
      case 2:
        return "nd";
      case 3:
        return "rd";
      default:
        return "th";
    }
  }

  static const List<String> _monthNames = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
}
