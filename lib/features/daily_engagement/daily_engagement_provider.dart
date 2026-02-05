/// Daily Engagement Provider
///
/// Riverpod providers for daily engagement state management.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'daily_engagement_model.dart';
import 'daily_engagement_repository.dart';

/// Stream provider for real-time today's engagement updates
final dailyEngagementProvider = StreamProvider<DailyEngagement?>((ref) {
  final repository = ref.watch(dailyEngagementRepositoryProvider);
  return repository.getTodayStream();
});

/// Controller for managing daily engagement
final dailyEngagementControllerProvider = NotifierProvider<DailyEngagementController, AsyncValue<void>>(() {
  return DailyEngagementController();
});

class DailyEngagementController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  DailyEngagementRepository get _repository => ref.read(dailyEngagementRepositoryProvider);

  /// Toggle a task's completion status
  Future<void> toggleTask(EngagementTaskType taskType, bool isComplete) async {
    state = const AsyncValue.loading();
    try {
      await _repository.toggleTask(taskType, isComplete);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Reset today's progress
  Future<void> resetToday() async {
    state = const AsyncValue.loading();
    try {
      await _repository.resetToday();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider that groups tasks by category
final engagementTasksByCategoryProvider = Provider<Map<String, List<EngagementTaskType>>>((ref) {
  final grouped = <String, List<EngagementTaskType>>{};
  
  for (final task in EngagementTaskType.values) {
    grouped.putIfAbsent(task.category, () => []).add(task);
  }
  
  return grouped;
});

/// Provider for engagement stats
final engagementStatsProvider = Provider<AsyncValue<EngagementStats>>((ref) {
  final engagementAsync = ref.watch(dailyEngagementProvider);

  return engagementAsync.when(
    data: (engagement) {
      if (engagement == null) {
        return const AsyncValue.data(EngagementStats(
          completedCount: 0,
          totalCount: 0,
          commentingDone: 0,
          commentingTotal: 4,
          likingDone: 0,
          likingTotal: 3,
        ));
      }

      // Count by category
      int commentingDone = 0;
      int likingDone = 0;

      for (final task in EngagementTaskType.values) {
        if (engagement.isTaskCompleted(task)) {
          if (task.category == 'commenting') commentingDone++;
          if (task.category == 'liking') likingDone++;
        }
      }

      return AsyncValue.data(EngagementStats(
        completedCount: engagement.completedCount,
        totalCount: engagement.totalCount,
        commentingDone: commentingDone,
        commentingTotal: 4,
        likingDone: likingDone,
        likingTotal: 3,
      ));
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

class EngagementStats {
  final int completedCount;
  final int totalCount;
  final int commentingDone;
  final int commentingTotal;
  final int likingDone;
  final int likingTotal;

  const EngagementStats({
    required this.completedCount,
    required this.totalCount,
    required this.commentingDone,
    required this.commentingTotal,
    required this.likingDone,
    required this.likingTotal,
  });

  double get completionPercentage => totalCount > 0 ? completedCount / totalCount : 0;
  
  String get timeEstimate {
    // Approximate time remaining based on uncompleted tasks
    final remaining = totalCount - completedCount;
    if (remaining == 0) return 'Done!';
    if (remaining <= 3) return '~5 min';
    if (remaining <= 6) return '~10 min';
    return '~15 min';
  }
}
