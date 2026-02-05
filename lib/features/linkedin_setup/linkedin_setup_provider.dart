/// LinkedIn Setup Provider
/// 
/// Riverpod providers for LinkedIn setup checklist state management.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'linkedin_setup_model.dart';
import 'linkedin_setup_repository.dart';

/// Stream provider for real-time progress updates
final linkedInSetupProgressProvider = StreamProvider<LinkedInSetupProgress>((ref) {
  final repository = ref.watch(linkedInSetupRepositoryProvider);
  return repository.getProgressStream();
});

/// Controller for managing task completions
final linkedInSetupControllerProvider = NotifierProvider<LinkedInSetupController, AsyncValue<void>>(() {
  return LinkedInSetupController();
});

class LinkedInSetupController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  LinkedInSetupRepository get _repository => ref.read(linkedInSetupRepositoryProvider);

  /// Toggle a task's completion status
  Future<void> toggleTask(String taskId, bool isComplete) async {
    state = const AsyncValue.loading();
    try {
      await _repository.toggleTask(taskId, isComplete);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Toggle a sub-step's completion status
  Future<void> toggleSubStep(String taskId, String subStepId, bool isComplete) async {
    state = const AsyncValue.loading();
    try {
      await _repository.toggleSubStep(taskId, subStepId, isComplete);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Mark a task as complete
  Future<void> completeTask(String taskId) async {
    await toggleTask(taskId, true);
  }

  /// Mark a task as incomplete
  Future<void> uncompleteTask(String taskId) async {
    await toggleTask(taskId, false);
  }

  /// Reset all progress
  Future<void> resetProgress() async {
    state = const AsyncValue.loading();
    try {
      await _repository.resetProgress();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for phase-based task grouping with completion status
final linkedInTasksByPhaseProvider = Provider<AsyncValue<Map<String, List<TaskWithStatus>>>>((ref) {
  final progressAsync = ref.watch(linkedInSetupProgressProvider);
  
  return progressAsync.when(
    data: (progress) {
      final result = <String, List<TaskWithStatus>>{};
      
      for (final phase in LinkedInSetupTasks.phases) {
        final tasks = LinkedInSetupTasks.getTasksForPhase(phase);
        result[phase] = tasks.map((task) => TaskWithStatus(
          task: task,
          isCompleted: progress.isTaskCompleted(task.id),
          completedAt: progress.completedTasks[task.id],
          completedSubSteps: progress.completedSubSteps[task.id] ?? [],
        )).toList();
      }
      
      return AsyncValue.data(result);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

/// Helper class combining task definition with user's completion status
class TaskWithStatus {
  final LinkedInSetupTask task;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<String> completedSubSteps;

  TaskWithStatus({
    required this.task,
    required this.isCompleted,
    this.completedAt,
    this.completedSubSteps = const [],
  });

  bool isSubStepCompleted(String subStepId) => completedSubSteps.contains(subStepId);
  
  int get completedSubStepCount => completedSubSteps.length;
  
  int get totalSubStepCount => task.subSteps?.length ?? 0;
  
  bool get hasSubSteps => task.subSteps != null && task.subSteps!.isNotEmpty;
  
  double get subStepProgress {
    if (!hasSubSteps) return 0;
    return completedSubStepCount / totalSubStepCount;
  }
}

/// Provider for overall progress stats
final linkedInProgressStatsProvider = Provider<AsyncValue<ProgressStats>>((ref) {
  final progressAsync = ref.watch(linkedInSetupProgressProvider);
  
  return progressAsync.when(
    data: (progress) {
      final total = LinkedInSetupTasks.totalCount;
      final completed = progress.completedCount;
      final percent = progress.getProgressPercent(total);
      final totalMinutes = LinkedInSetupTasks.totalMinutes;
      
      // Calculate remaining minutes based on incomplete tasks
      int remainingMinutes = 0;
      for (final task in LinkedInSetupTasks.all) {
        if (!progress.isTaskCompleted(task.id)) {
          remainingMinutes += task.estimatedMinutes;
        }
      }
      
      return AsyncValue.data(ProgressStats(
        completedCount: completed,
        totalCount: total,
        percentComplete: percent,
        isFullyComplete: completed == total,
        earnedBadge: progress.earnedBadge,
        totalMinutes: totalMinutes,
        remainingMinutes: remainingMinutes,
      ));
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

class ProgressStats {
  final int completedCount;
  final int totalCount;
  final double percentComplete;
  final bool isFullyComplete;
  final String? earnedBadge;
  final int totalMinutes;
  final int remainingMinutes;

  ProgressStats({
    required this.completedCount,
    required this.totalCount,
    required this.percentComplete,
    required this.isFullyComplete,
    this.earnedBadge,
    this.totalMinutes = 0,
    this.remainingMinutes = 0,
  });

  String get progressText => '$completedCount/$totalCount';
  
  String get timeEstimate {
    if (isFullyComplete) return 'Complete! 🎉';
    final hours = remainingMinutes ~/ 60;
    final mins = remainingMinutes % 60;
    if (hours > 0) {
      return '~${hours}h ${mins}m left';
    }
    return '~${mins}m left';
  }
  
  String get motivationalMessage {
    if (isFullyComplete) return '🏆 You\'re a LinkedIn Legend!';
    if (percentComplete >= 0.75) return '🔥 Almost there! Keep pushing!';
    if (percentComplete >= 0.50) return '💪 Halfway done! Great progress!';
    if (percentComplete >= 0.25) return '🚀 Good start! Keep going!';
    if (completedCount > 0) return '🌱 You\'ve begun your journey!';
    return '👋 Let\'s optimize your LinkedIn profile!';
  }
}
