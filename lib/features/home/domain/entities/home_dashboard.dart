import 'package:equatable/equatable.dart';

class HomeDashboard extends Equatable {
  const HomeDashboard({
    required this.completedTaskCount,
    required this.totalTaskCount,
    required this.plannedDuration,
    required this.actualDuration,
    required this.activityBreakdown,
    required this.recentCompletedTasks,
  });

  final int completedTaskCount;
  final int totalTaskCount;
  final Duration plannedDuration;
  final Duration actualDuration;
  final Map<String, Duration> activityBreakdown;
  final List<String> recentCompletedTasks;

  @override
  List<Object?> get props => [
        completedTaskCount,
        totalTaskCount,
        plannedDuration,
        actualDuration,
        activityBreakdown,
        recentCompletedTasks,
      ];
}