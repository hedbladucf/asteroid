import 'package:flutter/material.dart';

extension DialogExt on BuildContext {
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_rounded),
              const SizedBox(width: 5),
              Text(message),
            ],
          ),
        ),
      );
  }

  Future<DateTimeRange?> showDateRange(DateTimeRange initial) async {
    final now = DateTime.now();
    final lastDate = now.subtract(const Duration(days: 365));

    return await showDateRangePicker(
      context: this,
      firstDate: lastDate,
      lastDate: now,
      initialDateRange: initial,
      helpText: 'Max Range is 7 days.',
    );
  }
}
