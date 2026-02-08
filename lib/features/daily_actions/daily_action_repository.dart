// Daily Action Repository
//
// Handles Firebase persistence for daily actions.
// Actions are stored per calendar day and auto-generated on first daily open.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daily_action_model.dart';

final dailyActionRepositoryProvider = Provider<DailyActionRepository>((ref) {
  return DailyActionRepository();
});

class DailyActionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _lastGeneratedKey = 'daily_actions_last_generated';

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _actionsCollection {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(_userId).collection('daily_actions');
  }

  /// Get today's document reference
  DocumentReference<Map<String, dynamic>> get _todayDoc {
    return _actionsCollection.doc(DailyActionsDocument.todayId());
  }

  /// Stream of today's actions
  Stream<DailyActionsDocument?> getTodayStream() {
    if (_userId == null) {
      return Stream.value(null);
    }

    return _todayDoc.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return DailyActionsDocument.fromSnapshot(snapshot);
    });
  }

  /// Get today's actions (one-time fetch)
  Future<DailyActionsDocument?> getToday() async {
    if (_userId == null) return null;

    final doc = await _todayDoc.get();
    if (!doc.exists) {
      return null;
    }
    return DailyActionsDocument.fromSnapshot(doc);
  }

  /// Check if actions were already generated today
  Future<bool> wasGeneratedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastGenerated = prefs.getString(_lastGeneratedKey);
    return lastGenerated == DailyActionsDocument.todayId();
  }

  /// Mark today as generated
  Future<void> markAsGeneratedToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastGeneratedKey, DailyActionsDocument.todayId());
  }

  /// Save generated actions for today
  Future<void> saveActions(List<DailyAction> actions) async {
    if (_userId == null) return;

    final doc = DailyActionsDocument(
      dateId: DailyActionsDocument.todayId(),
      actions: actions,
      generatedAt: DateTime.now(),
    );

    await _todayDoc.set(doc.toMap());
    await markAsGeneratedToday();
  }

  /// Mark an action as completed
  Future<void> markActionComplete(int actionIndex, bool isComplete) async {
    if (_userId == null) return;

    final doc = await getToday();
    if (doc == null) return;

    final updatedActions = List<DailyAction>.from(doc.actions);
    if (actionIndex >= 0 && actionIndex < updatedActions.length) {
      updatedActions[actionIndex] = updatedActions[actionIndex].copyWith(
        isCompleted: isComplete,
        completedAt: isComplete ? DateTime.now() : null,
      );

      await _todayDoc.update({
        'actions': updatedActions.map((a) => a.toMap()).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Get history of daily actions (for analytics)
  Future<List<DailyActionsDocument>> getHistory({int days = 7}) async {
    if (_userId == null) return [];

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final startId = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';

    final snapshot = await _actionsCollection
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startId)
        .orderBy(FieldPath.documentId, descending: true)
        .get();

    return snapshot.docs
        .map((doc) => DailyActionsDocument.fromSnapshot(doc))
        .toList();
  }

  /// Clear today's actions (for regeneration)
  Future<void> clearToday() async {
    if (_userId == null) return;
    await _todayDoc.delete();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastGeneratedKey);
  }
}
