// Daily Action Provider
//
// Riverpod providers for daily action state management.
// Handles real-time updates, action completion, and auto-generation.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'daily_action_model.dart';
import 'daily_action_repository.dart';
import 'action_generator_service.dart';

/// Stream provider for real-time today's actions
final dailyActionsProvider = StreamProvider<DailyActionsDocument?>((ref) {
  final repository = ref.watch(dailyActionRepositoryProvider);
  return repository.getTodayStream();
});

/// Provider to trigger action generation on first load
final dailyActionsInitProvider = FutureProvider<void>((ref) async {
  final generator = ref.read(actionGeneratorProvider);
  await generator.checkAndGenerate();
});

/// Controller for managing daily actions
final dailyActionsControllerProvider = NotifierProvider<DailyActionsController, AsyncValue<void>>(() {
  return DailyActionsController();
});

class DailyActionsController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  DailyActionRepository get _repository => ref.read(dailyActionRepositoryProvider);
  ActionGeneratorService get _generator => ref.read(actionGeneratorProvider);

  /// Mark an action as completed/uncompleted
  Future<void> toggleAction(int actionIndex, bool isComplete) async {
    state = const AsyncValue.loading();
    try {
      await _repository.markActionComplete(actionIndex, isComplete);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Regenerate today's actions
  Future<void> regenerateActions() async {
    state = const AsyncValue.loading();
    try {
      await _repository.clearToday();
      final actions = await _generator.generateActions();
      await _repository.saveActions(actions);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for action stats
final dailyActionsStatsProvider = Provider<AsyncValue<DailyActionsStats>>((ref) {
  final actionsAsync = ref.watch(dailyActionsProvider);

  return actionsAsync.when(
    data: (doc) {
      if (doc == null) {
        return const AsyncValue.data(DailyActionsStats(
          completedCount: 0,
          totalCount: 0,
        ));
      }

      return AsyncValue.data(DailyActionsStats(
        completedCount: doc.completedCount,
        totalCount: doc.totalCount,
      ));
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

class DailyActionsStats {
  final int completedCount;
  final int totalCount;

  const DailyActionsStats({
    required this.completedCount,
    required this.totalCount,
  });

  double get completionPercentage => totalCount > 0 ? completedCount / totalCount : 0;
  bool get isFullyComplete => completedCount == totalCount && totalCount > 0;
  
  String get progressText => '$completedCount/$totalCount';
  
  String get motivationalMessage {
    if (totalCount == 0) return 'No actions for today';
    if (isFullyComplete) return '🎉 All done for today!';
    if (completionPercentage >= 0.5) return 'Great progress! Keep going!';
    return 'Let\'s get started!';
  }
}
