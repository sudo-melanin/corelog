class TaskTimeFormatter {
  const TaskTimeFormatter._();

  static String time(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  static String duration(Duration duration) {
    final totalSeconds = duration.inSeconds;

    if (totalSeconds < 60) {
      return '${totalSeconds}s';
    }

    final totalMinutes = duration.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      if (minutes == 0) {
        return '${hours}h';
      }

      return '${hours}h ${minutes}m';
    }

    return '${minutes}m';
  }

  static String startDeviation(
  DateTime plannedStart,
  DateTime actualStart,
) {
  final difference = actualStart.difference(plannedStart);

  if (difference == Duration.zero) {
    return 'On time';
  }

  final absoluteDifference = difference.abs();
  final formattedDuration = duration(absoluteDifference);

  return difference.isNegative
      ? '$formattedDuration early'
      : '$formattedDuration late';
}
}