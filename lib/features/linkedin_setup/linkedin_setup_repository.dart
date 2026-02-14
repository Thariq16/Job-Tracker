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
        return LinkedInSetupProgress.empty(_userId ?? '');
      }
      return LinkedInSetupProgress.fromSnapshot(snapshot);
    });
  }

  /// Get current progress (one-time fetch)
  Future<LinkedInSetupProgress> getProgress() async {
    if (_userId == null) return LinkedInSetupProgress.empty('');
    
    final snapshot = await _progressDoc.get();
    if (!snapshot.exists) {
      return LinkedInSetupProgress.empty(_userId ?? '');
    }
    return LinkedInSetupProgress.fromSnapshot(snapshot);
  }

  /// Mark a task as complete
  Future<void> markTaskComplete(String taskId) async {
    if (_userId == null) return;

    // Get current data first
    final doc = await _progressDoc.get();
    Map<String, Timestamp> currentTasks = {};
    
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['completedTasks'] != null) {
        final tasksData = data['completedTasks'] as Map<String, dynamic>;
        currentTasks = tasksData.map((key, value) => MapEntry(key, value as Timestamp));
      }
    }
    
    // Add the new task
    currentTasks[taskId] = Timestamp.now();

    await _progressDoc.set({
      'completedTasks': currentTasks,
      'startedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Check if all tasks are complete
    await _checkAndAwardBadges();
  }

  /// Mark a task as incomplete
  Future<void> markTaskIncomplete(String taskId) async {
    if (_userId == null) return;

    // Get current data first
    final doc = await _progressDoc.get();
    if (!doc.exists) return;
    
    final data = doc.data();
    if (data == null) return;

    Map<String, Timestamp> currentTasks = {};
    if (data['completedTasks'] != null) {
      final tasksData = data['completedTasks'] as Map<String, dynamic>;
      currentTasks = tasksData.map((key, value) => MapEntry(key, value as Timestamp));
    }
    
    // Remove the task
    currentTasks.remove(taskId);

    // Also remove sub-steps for this task
    Map<String, dynamic> currentSubSteps = {};
    if (data['completedSubSteps'] != null) {
      currentSubSteps = Map<String, dynamic>.from(data['completedSubSteps'] as Map);
      currentSubSteps.remove(taskId);
    }

    await _progressDoc.set({
      'completedTasks': currentTasks,
      'completedSubSteps': currentSubSteps,
      'completedAt': null,
    }, SetOptions(merge: true));
  }

  /// Toggle task completion status
  Future<void> toggleTask(String taskId, bool isComplete) async {
    if (isComplete) {
      await markTaskComplete(taskId);
    } else {
      await markTaskIncomplete(taskId);
    }
  }

  /// Toggle a sub-step completion status
  Future<void> toggleSubStep(String taskId, String subStepId, bool isComplete) async {
    if (_userId == null) return;

    // Get current data first
    final doc = await _progressDoc.get();
    Map<String, List<String>> currentSubSteps = {};
    
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['completedSubSteps'] != null) {
        final subStepsData = data['completedSubSteps'] as Map<String, dynamic>;
        currentSubSteps = subStepsData.map((key, value) => 
          MapEntry(key, List<String>.from(value as List)));
      }
    }
    
    // Update the sub-steps for this task
    if (isComplete) {
      currentSubSteps.putIfAbsent(taskId, () => []);
      if (!currentSubSteps[taskId]!.contains(subStepId)) {
        currentSubSteps[taskId]!.add(subStepId);
      }
    } else {
      currentSubSteps[taskId]?.remove(subStepId);
    }

    await _progressDoc.set({
      'completedSubSteps': currentSubSteps,
      'startedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
            case 'Quick Wins':
              badgeToAward = 'quick_wins';
              break;
            case 'Profile Content':
              badgeToAward = 'content_creator';
              break;
            case 'Credibility Builders':
              badgeToAward = 'credibility_king';
              break;
            case 'Visibility & Engagement':
              badgeToAward = 'visibility_master';
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
