/// Networking Repository
///
/// Firestore persistence layer for networking activities.
/// Handles CRUD operations and queries for networking data.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'networking_model.dart';

/// Repository provider
final networkingRepositoryProvider = Provider<NetworkingRepository>((ref) {
  return NetworkingRepository();
});

class NetworkingRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Get the user's networking collection reference
  CollectionReference<Map<String, dynamic>> get _collection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('networking');
  }

  /// Stream all networking activities (most recent first)
  Stream<List<NetworkingActivity>> getActivitiesStream() {
    if (_auth.currentUser?.uid == null) return Stream.value([]);
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NetworkingActivity.fromFirestore(doc))
            .toList());
  }

  /// Stream activities for a specific job
  Stream<List<NetworkingActivity>> getActivitiesForJobStream(String jobId) {
    if (_auth.currentUser?.uid == null) return Stream.value([]);
    return _collection
        .where('jobId', isEqualTo: jobId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NetworkingActivity.fromFirestore(doc))
            .toList());
  }

  /// Get activities for a specific job (one-time fetch)
  Future<List<NetworkingActivity>> getActivitiesForJob(String jobId) async {
    final snapshot = await _collection
        .where('jobId', isEqualTo: jobId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => NetworkingActivity.fromFirestore(doc))
        .toList();
  }

  /// Add a new networking activity
  Future<String> addActivity(NetworkingActivity activity) async {
    final docRef = await _collection.add(activity.toFirestore());
    return docRef.id;
  }

  /// Update an existing activity
  Future<void> updateActivity(NetworkingActivity activity) async {
    await _collection.doc(activity.id).update(activity.toFirestore());
  }

  /// Toggle reply received status
  Future<void> toggleReplyReceived(String activityId, bool received) async {
    await _collection.doc(activityId).update({
      'replyReceived': received,
      'repliedAt': received ? Timestamp.now() : null,
    });
  }

  /// Delete an activity
  Future<void> deleteActivity(String activityId) async {
    await _collection.doc(activityId).delete();
  }

  /// Get networking stats
  Future<NetworkingStats> getStats() async {
    final snapshot = await _collection.get();
    final activities = snapshot.docs
        .map((doc) => NetworkingActivity.fromFirestore(doc))
        .toList();

    if (activities.isEmpty) {
      return const NetworkingStats();
    }

    final repliesReceived = activities.where((a) => a.replyReceived).length;
    final followUps = activities.where((a) => a.type == NetworkingType.followUp).length;
    final recruiterMessages = activities.where((a) => a.type == NetworkingType.recruiterMessage).length;

    // Sort by date to find most recent
    activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final lastActivityDate = activities.first.createdAt;

    return NetworkingStats(
      totalActivities: activities.length,
      repliesReceived: repliesReceived,
      followUpsSent: followUps,
      recruiterMessages: recruiterMessages,
      lastActivityDate: lastActivityDate,
    );
  }

  /// Stream networking stats
  Stream<NetworkingStats> getStatsStream() {
    return _collection.snapshots().map((snapshot) {
      final activities = snapshot.docs
          .map((doc) => NetworkingActivity.fromFirestore(doc))
          .toList();

      if (activities.isEmpty) {
        return const NetworkingStats();
      }

      final repliesReceived = activities.where((a) => a.replyReceived).length;
      final followUps = activities.where((a) => a.type == NetworkingType.followUp).length;
      final recruiterMessages = activities.where((a) => a.type == NetworkingType.recruiterMessage).length;

      // Sort by date to find most recent
      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final lastActivityDate = activities.first.createdAt;

      return NetworkingStats(
        totalActivities: activities.length,
        repliesReceived: repliesReceived,
        followUpsSent: followUps,
        recruiterMessages: recruiterMessages,
        lastActivityDate: lastActivityDate,
      );
    });
  }

  /// Get recent activities (last N days)
  Future<List<NetworkingActivity>> getRecentActivities({int days = 7}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final snapshot = await _collection
        .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffDate))
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => NetworkingActivity.fromFirestore(doc))
        .toList();
  }
}
