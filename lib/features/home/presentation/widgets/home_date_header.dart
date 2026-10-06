import 'package:flutter/material.dart';

class HomeDateHeader extends StatelessWidget {
  const HomeDateHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          weekdays[now.weekday - 1],
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          '${now.day} ${months[now.month - 1]} ${now.year}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}