import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:corelog/core/theme/theme.dart';
import 'package:corelog/features/time_blocks/presentation/providers/providers.dart';
import 'package:corelog/features/time_blocks/presentation/widgets/widgets.dart';
import 'package:corelog/features/time_blocks/domain/entities/time_block.dart';

class DailyTimelineScreen extends ConsumerStatefulWidget {
  const DailyTimelineScreen({super.key});

  @override
  ConsumerState<DailyTimelineScreen> createState() =>
      _DailyTimelineScreenState();
}

class _DailyTimelineScreenState extends ConsumerState<DailyTimelineScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timeline')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _DateNavigator(
                selectedDate: _selectedDate,
                onPrevious: _selectPreviousDay,
                onNext: _selectNextDay,
                onToday: _selectToday,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: FutureBuilder(
                  future: ref
                      .read(timeBlockNotifierProvider.notifier)
                      .loadTimeline(_selectedDate),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const TimelineLoadingState();
                    }

                    if (snapshot.hasError) {
                      return TimelineErrorState(
                        message: _errorMessage(snapshot.error),
                        onRetry: () {
                          setState(() {});
                        },
                      );
                    }

                    final items = snapshot.data ?? [];

                    if (items.isEmpty) {
                      return TimelineEmptyState(date: _selectedDate);
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {});
                        await Future<void>.delayed(
                          const Duration(milliseconds: 100),
                        );
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return TimelineCard(
                            item: item,
                            onTap: () =>
                                showTimeBlockDetailsSheet(context, item: item),

                            onStart: () => _startTimeBlock(item.timeBlock),
                            onComplete: () =>
                                _completeTimeBlock(item.timeBlock),
                            onSkip: () => _skipTimeBlock(item.timeBlock),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showCreateTimeBlockDialog(
            context,
            ref,
            selectedDate: _selectedDate,
          );

          if (mounted) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _selectPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _selectNextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  void _selectToday() {
    setState(() {
      _selectedDate = _dateOnly(DateTime.now());
    });
  }

  Future<void> _startTimeBlock(TimeBlock item) async {
    final success = await ref
        .read(timeBlockNotifierProvider.notifier)
        .startTimeBlock(item);

    if (!mounted) return;

    _showActionFeedback(
      success ? 'Time block started.' : 'Could not start time block.',
    );

    setState(() {});
  }

  Future<void> _completeTimeBlock(TimeBlock item) async {
    final success = await ref
        .read(timeBlockNotifierProvider.notifier)
        .completeTimeBlock(item);

    if (!mounted) return;

    _showActionFeedback(
      success ? 'Time block completed.' : 'Could not complete time block.',
    );

    setState(() {});
  }

  Future<void> _skipTimeBlock(TimeBlock item) async {
    final success = await ref
        .read(timeBlockNotifierProvider.notifier)
        .skipTimeBlock(item);

    if (!mounted) return;

    _showActionFeedback(
      success ? 'Time block skipped.' : 'Could not skip time block.',
    );

    setState(() {});
  }

  void _showActionFeedback(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _errorMessage(Object? error) {
    return 'We could not load the timeline. Please try again.';
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday =
        selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          tooltip: 'Previous day',
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                _weekdayLabel(selectedDate),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _dateLabel(selectedDate),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNext,
          tooltip: 'Next day',
          icon: const Icon(Icons.chevron_right),
        ),
        if (!isToday)
          TextButton(onPressed: onToday, child: const Text('Today')),
      ],
    );
  }

  String _weekdayLabel(DateTime date) {
    return switch (date.weekday) {
      DateTime.monday => 'Monday',
      DateTime.tuesday => 'Tuesday',
      DateTime.wednesday => 'Wednesday',
      DateTime.thursday => 'Thursday',
      DateTime.friday => 'Friday',
      DateTime.saturday => 'Saturday',
      DateTime.sunday => 'Sunday',
      _ => '',
    };
  }

  String _dateLabel(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
