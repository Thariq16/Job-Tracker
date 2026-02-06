/// NPS Repository
///
/// Handles NPS submission, storage, and trigger logic.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final npsRepositoryProvider = Provider<NpsRepository>((ref) {
  return NpsRepository();
});

class NpsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  DocumentReference get _userDoc => _firestore.collection('users').doc(_userId);

  /// Check if NPS should be shown based on triggers and cooldown
  Future<bool> shouldShowNps() async {
    if (_userId == null) return false;

    // Check cooldown (90 days)
    final meta = await _getNpsMeta();
    if (meta != null && meta['lastShownAt'] != null) {
      final lastShown = (meta['lastShownAt'] as Timestamp).toDate();
      final daysSinceShown = DateTime.now().difference(lastShown).inDays;
      if (daysSinceShown < 90) return false;
    }

    // Check triggers
    return await _checkTriggers();
  }

  /// Check if any trigger conditions are met
  Future<bool> _checkTriggers() async {
    if (_userId == null) return false;

    // Trigger 1: User has added 5+ jobs
    final jobsCount = await _getJobsCount();
    if (jobsCount >= 5) return true;

    // Trigger 2: User has completed LinkedIn checklist
    final linkedInComplete = await _isLinkedInChecklistComplete();
    if (linkedInComplete) return true;

    return false;
  }

  Future<int> _getJobsCount() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('jobs')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<bool> _isLinkedInChecklistComplete() async {
    try {
      final doc = await _userDoc.collection('linkedin_setup').doc('progress').get();
      final data = doc.data();
      if (data == null) return false;
      
      final completedTasks = data['completedTasks'] as List<dynamic>? ?? [];
      return completedTasks.length >= 10; // Assume 10+ tasks means mostly complete
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> _getNpsMeta() async {
    try {
      final doc = await _userDoc.collection('nps').doc('meta').get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  /// Submit NPS response
  Future<void> submitNps(int score, String? feedback, String trigger) async {
    if (_userId == null) return;

    final user = _auth.currentUser;

    // Save response
    await _firestore.collection('nps_responses').add({
      'userId': _userId,
      'userEmail': user?.email,
      'score': score,
      'feedback': feedback,
      'trigger': trigger,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update user meta
    await _userDoc.collection('nps').doc('meta').set({
      'lastShownAt': FieldValue.serverTimestamp(),
      'lastScore': score,
      'responseCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  /// Record that NPS was dismissed (for cooldown)
  Future<void> dismissNps() async {
    if (_userId == null) return;

    await _userDoc.collection('nps').doc('meta').set({
      'lastShownAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get NPS category
  static String getCategory(int score) {
    if (score >= 9) return 'promoter';
    if (score >= 7) return 'passive';
    return 'detractor';
  }
}
