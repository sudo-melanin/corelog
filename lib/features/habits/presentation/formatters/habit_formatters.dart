import 'package:flutter/material.dart';

String formatHabitTime(BuildContext context, TimeOfDay? time) {
  if (time == null) {
    return 'Not set';
  }

  return time.format(context);
}

String formatHabitDuration(int minutes) {
  if (minutes < 60) {
    return '$minutes min';
  }

  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (remainingMinutes == 0) {
    return hours == 1 ? '1 hour' : '$hours hours';
  }

  return '${hours}h ${remainingMinutes}m';
}
