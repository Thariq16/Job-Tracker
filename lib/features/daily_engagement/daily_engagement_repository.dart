/// Daily Engagement Repository
///
/// Handles Firebase persistence for daily engagement progress.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'daily_engagement_model.dart';

final dailyEngagementRepositoryProvider = Provider<DailyEngagementRepository>((ref) {
  return DailyEngagementRepository();
});

class DailyEngagementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _engagementCollection {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(_userId).collection('daily_engagement');
  }

  /// Get today's engagement document reference
  DocumentReference<Map<String, dynamic>> get _todayDoc {
    return _engagementCollection.doc(DailyEngagement.todayId());
  }

  /// Stream of today's engagement progress
  Stream<DailyEngagement?> getTodayStream() {
    if (_userId == null) {
      return Stream.value(null);
    }

    return _todayDoc.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return DailyEngagement.empty(_userId ?? '');
      }
      return DailyEngagement.fromSnapshot(snapshot);
    });
  }

  /// Get today's engagement (one-time fetch)
  Future<DailyEngagement> getToday() async {
    if (_userId == null) return DailyEngagement.empty('');

    final doc = await _todayDoc.get();
    if (!doc.exists) {
      return DailyEngagement.empty(_userId ?? '');
    }
    return DailyEngagement.fromSnapshot(doc);
  }

  /// Toggle a task's completion status
  Future<void> toggleTask(EngagementTaskType taskType, bool isComplete) async {
    if (_userId == null) return;

    // Get current tasks first
    final doc = await _todayDoc.get();
    Map<String, bool> currentTasks = {};
    
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['completedTasks'] != null) {
        final tasksData = data['completedTasks'] as Map<String, dynamic>;
        currentTasks = tasksData.map((key, value) => MapEntry(key, value as bool));
      }
    }
    
    // Update the task
    currentTasks[taskType.name] = isComplete;

    await _todayDoc.set({
      'oderId': _userId,
      'completedTasks': currentTasks,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get engagement history (for potential future use)
  Future<List<DailyEngagement>> getHistory({int days = 7}) async {
    if (_userId == null) return [];

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final startId = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';

    final snapshot = await _engagementCollection
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startId)
        .orderBy(FieldPath.documentId, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => DailyEngagement.fromSnapshot(doc))
        .toList();
  }

  /// Reset today's progress (for testing)
  Future<void> resetToday() async {
    if (_userId == null) return;
    await _todayDoc.delete();
  }
}
