/// Networking Provider
///
/// Riverpod providers for networking state management.
/// Handles real-time updates, activity tracking, and stats.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'networking_model.dart';
import 'networking_repository.dart';

/// Stream provider for all networking activities
final networkingActivitiesProvider = StreamProvider<List<NetworkingActivity>>((ref) {
  final repository = ref.watch(networkingRepositoryProvider);
  return repository.getActivitiesStream();
});

/// Stream provider for activities related to a specific job
final networkingForJobProvider = StreamProvider.family<List<NetworkingActivity>, String>((ref, jobId) {
  final repository = ref.watch(networkingRepositoryProvider);
  return repository.getActivitiesForJobStream(jobId);
});

/// Stream provider for networking stats
final networkingStatsProvider = StreamProvider<NetworkingStats>((ref) {
  final repository = ref.watch(networkingRepositoryProvider);
  return repository.getStatsStream();
});

/// Controller for networking activities
final networkingControllerProvider = NotifierProvider<NetworkingController, AsyncValue<void>>(() {
  return NetworkingController();
});

class NetworkingController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  NetworkingRepository get _repository => ref.read(networkingRepositoryProvider);

  /// Add a new networking activity
  Future<String?> addActivity({
    required NetworkingType type,
    String? jobId,
    String? jobTitle,
    String? companyName,
    String? contactName,
    String? contactRole,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final activity = NetworkingActivity(
        id: '', // Will be set by Firestore
        type: type,
        jobId: jobId,
        jobTitle: jobTitle,
        companyName: companyName,
        contactName: contactName,
        contactRole: contactRole,
        notes: notes,
        createdAt: DateTime.now(),
      );
      final id = await _repository.addActivity(activity);
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Toggle reply received status
  Future<void> toggleReply(String activityId, bool received) async {
    state = const AsyncValue.loading();
    try {
      await _repository.toggleReplyReceived(activityId, received);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update an activity
  Future<void> updateActivity(NetworkingActivity activity) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateActivity(activity);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete an activity
  Future<void> deleteActivity(String activityId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteActivity(activityId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider to check if networking is needed (3+ days without activity)
final needsNetworkingProvider = Provider<AsyncValue<bool>>((ref) {
  final statsAsync = ref.watch(networkingStatsProvider);
  return statsAsync.when(
    data: (stats) => AsyncValue.data(stats.needsNetworking),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

/// Provider for activity count by type
final networkingCountByTypeProvider = Provider<AsyncValue<Map<NetworkingType, int>>>((ref) {
  final activitiesAsync = ref.watch(networkingActivitiesProvider);
  return activitiesAsync.when(
    data: (activities) {
      final counts = <NetworkingType, int>{};
      for (final type in NetworkingType.values) {
        counts[type] = activities.where((a) => a.type == type).length;
      }
      return AsyncValue.data(counts);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
