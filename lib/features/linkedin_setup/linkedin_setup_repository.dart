/// LinkedIn Setup Repository
/// 
/// Handles Firebase persistence for LinkedIn setup progress.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'linkedin_setup_model.dart';

final linkedInSetupRepositoryProvider = Provider<LinkedInSetupRepository>((ref) {
  return LinkedInSetupRepository();
});

class LinkedInSetupRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> get _progressDoc {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(_userId).collection('features').doc('linkedin_setup');
  }

  /// Stream of user's LinkedIn setup progress
  Stream<LinkedInSetupProgress> getProgressStream() {
    if (_userId == null) {
      return Stream.value(LinkedInSetupProgress.empty(''));
    }
    
    return _progressDoc.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return LinkedInSetupProgress.empty(_userId!);
      }
      return LinkedInSetupProgress.fromSnapshot(snapshot);
    });
  }

  /// Get current progress (one-time fetch)
  Future<LinkedInSetupProgress> getProgress() async {
    if (_userId == null) return LinkedInSetupProgress.empty('');
    
    final snapshot = await _progressDoc.get();
    if (!snapshot.exists) {
      return LinkedInSetupProgress.empty(_userId!);
    }
    return LinkedInSetupProgress.fromSnapshot(snapshot);
  }

  /// Mark a task as complete
  Future<void> markTaskComplete(String taskId) async {
    if (_userId == null) return;

    await _progressDoc.set({
      'completedTasks.$taskId': Timestamp.now(),
      'startedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Check if all tasks are complete
    await _checkAndAwardBadges();
  }

  /// Mark a task as incomplete
  Future<void> markTaskIncomplete(String taskId) async {
    if (_userId == null) return;

    await _progressDoc.update({
      'completedTasks.$taskId': FieldValue.delete(),
      'completedAt': null,  // Reset completion if any task is unchecked
    });
  }

  /// Toggle task completion status
  Future<void> toggleTask(String taskId, bool isComplete) async {
    if (isComplete) {
      await markTaskComplete(taskId);
    } else {
      await markTaskIncomplete(taskId);
    }
  }

  /// Check badges and award if earned
  Future<void> _checkAndAwardBadges() async {
    final progress = await getProgress();
    final completedTasks = progress.completedTasks.keys.toSet();
    
    String? badgeToAward;
    
    // Check for LinkedIn Legend (all tasks complete)
    if (completedTasks.length == LinkedInSetupTasks.totalCount) {
      badgeToAward = 'linkedin_legend';
      await _progressDoc.update({
        'completedAt': Timestamp.now(),
        'earnedBadge': badgeToAward,
      });
    }
    // Check phase-specific badges
    else {
      for (final phase in LinkedInSetupTasks.phases) {
        final phaseTasks = LinkedInSetupTasks.getTasksForPhase(phase);
        final phaseTaskIds = phaseTasks.map((t) => t.id).toSet();
        
        if (phaseTaskIds.difference(completedTasks).isEmpty) {
          // All tasks in this phase are complete
          switch (phase) {
            case 'Profile Basics':
              badgeToAward = 'profile_basics';
              break;
            case 'Experience & Skills':
              badgeToAward = 'experience_master';
              break;
            case 'Credibility Boosters':
              badgeToAward = 'credibility_king';
              break;
            case 'Networking Ready':
              badgeToAward = 'network_ninja';
              break;
          }
        }
      }
    }

    // Award "Getting Started" badge for first completion
    if (completedTasks.length == 1 && badgeToAward == null) {
      badgeToAward = 'getting_started';
    }

    // We store the latest badge earned
    // In a full implementation, you might want to store all earned badges
  }

  /// Reset all progress (for testing or user request)
  Future<void> resetProgress() async {
    if (_userId == null) return;
    await _progressDoc.delete();
  }
}
