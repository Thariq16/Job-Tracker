/// Admin Provider
///
/// State management for admin dashboard using Riverpod.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_repository.dart';
export 'admin_repository.dart' show UserStats, JobStats;

/// Provider for user statistics
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  
  final results = await Future.wait([
    repo.getTotalUsers(),
    repo.getActiveUsers(7),
    repo.getNewUsers(30),
  ]);

  return UserStats(
    totalUsers: results[0],
    activeUsers7d: results[1],
    newUsers30d: results[2],
  );
});

/// Provider for job statistics
final jobStatsProvider = FutureProvider<JobStats>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  
  final totalJobs = await repo.getTotalJobs();
  final companyStats = await repo.getCompanyStats();
  final totalUsers = await repo.getTotalUsers();
  
  // Sort companies by count and get top 5
  final sortedCompanies = companyStats.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  final topCompanies = Map.fromEntries(
    sortedCompanies.take(5).map((e) => MapEntry(_capitalize(e.key), e.value))
  );

  return JobStats(
    totalJobs: totalJobs,
    uniqueCompanies: companyStats.length,
    avgJobsPerUser: totalUsers > 0 ? totalJobs / totalUsers : 0,
    topCompanies: topCompanies,
  );
});

/// Provider for feature requests
final featureRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getFeatureRequests(limit: 5);
});

/// Provider for feature request count
final featureRequestCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getFeatureRequestCount();
});

/// Capitalize first letter of each word
String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}
