/// Admin Repository
///
/// Handles Firestore queries for admin dashboard statistics.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get total user count
  Future<int> getTotalUsers() async {
    final snapshot = await _firestore.collection('users').count().get();
    return snapshot.count ?? 0;
  }

  /// Get users active in the last N days
  Future<int> getActiveUsers(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final snapshot = await _firestore
        .collection('users')
        .where('lastActive', isGreaterThan: Timestamp.fromDate(cutoff))
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Get inactive users (last active more than N days ago)
  Future<int> getInactiveUsers(int days) async {
    final totalUsers = await getTotalUsers();
    final activeUsers = await getActiveUsers(days);
    return totalUsers - activeUsers;
  }

  /// Get users created in the last N days (signups)
  Future<int> getNewUsers(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final snapshot = await _firestore
        .collection('users')
        .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoff))
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Get total job count across all users
  Future<int> getTotalJobs() async {
    final snapshot = await _firestore.collection('jobs').count().get();
    return snapshot.count ?? 0;
  }

  /// Get all jobs for analysis (unique companies, etc.)
  Future<List<Map<String, dynamic>>> getAllJobs() async {
    final snapshot = await _firestore.collection('jobs').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  /// Get unique company names and their counts
  Future<Map<String, int>> getCompanyStats() async {
    final jobs = await getAllJobs();
    final Map<String, int> companyCounts = {};
    
    for (final job in jobs) {
      final company = (job['company'] as String?)?.trim().toLowerCase() ?? '';
      if (company.isNotEmpty) {
        companyCounts[company] = (companyCounts[company] ?? 0) + 1;
      }
    }
    
    return companyCounts;
  }

  /// Get feature requests
  Future<List<Map<String, dynamic>>> getFeatureRequests({int limit = 10}) async {
    final snapshot = await _firestore
        .collection('feature_requests')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs.map((doc) => {
      ...doc.data(),
      'id': doc.id,
    }).toList();
  }

  /// Get total feature request count
  Future<int> getFeatureRequestCount() async {
    final snapshot = await _firestore.collection('feature_requests').count().get();
    return snapshot.count ?? 0;
  }
}

/// Stats data class for user statistics
class UserStats {
  final int totalUsers;
  final int activeUsers7d;
  final int inactiveUsers7d;
  final int newUsers30d;

  UserStats({
    required this.totalUsers,
    required this.activeUsers7d,
    required this.inactiveUsers7d,
    required this.newUsers30d,
  });
}

/// Stats data class for job statistics
class JobStats {
  final int totalJobs;
  final int uniqueCompanies;
  final double avgJobsPerUser;
  final Map<String, int> topCompanies;

  JobStats({
    required this.totalJobs,
    required this.uniqueCompanies,
    required this.avgJobsPerUser,
    required this.topCompanies,
  });
}
