/// Analytics Service
///
/// Centralized Google Analytics 4 tracking via Firebase Analytics.

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ==================== SCREEN TRACKING ====================

  /// Log screen view
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // ==================== USER ACTIONS ====================

  /// Log job added
  Future<void> logJobAdded({
    required String company,
    required String status,
    String? source,
  }) async {
    await _analytics.logEvent(
      name: 'job_added',
      parameters: {
        'company': company,
        'status': status,
        if (source != null) 'source': source,
      },
    );
  }

  /// Log job status changed
  Future<void> logJobStatusChanged({
    required String fromStatus,
    required String toStatus,
  }) async {
    await _analytics.logEvent(
      name: 'job_status_changed',
      parameters: {
        'from_status': fromStatus,
        'to_status': toStatus,
      },
    );
  }

  /// Log feature used
  Future<void> logFeatureUsed(String featureName) async {
    await _analytics.logEvent(
      name: 'feature_used',
      parameters: {'feature': featureName},
    );
  }

  // ==================== NPS & FEEDBACK ====================

  /// Log NPS submitted
  Future<void> logNpsSubmitted({
    required int score,
    required String trigger,
  }) async {
    await _analytics.logEvent(
      name: 'nps_submitted',
      parameters: {
        'score': score,
        'trigger': trigger,
        'category': _getNpsCategory(score),
      },
    );
  }

  /// Log feature request submitted
  Future<void> logFeatureRequest() async {
    await _analytics.logEvent(name: 'feature_request_submitted');
  }

  /// Log bug report submitted
  Future<void> logBugReport({required String severity}) async {
    await _analytics.logEvent(
      name: 'bug_report_submitted',
      parameters: {'severity': severity},
    );
  }

  // ==================== REFERRAL ====================

  /// Log referral code shared
  Future<void> logReferralShared() async {
    await _analytics.logEvent(name: 'referral_shared');
  }

  /// Log referral code copied
  Future<void> logReferralCopied() async {
    await _analytics.logEvent(name: 'referral_copied');
  }

  // ==================== LINKEDIN ====================

  /// Log LinkedIn task completed
  Future<void> logLinkedInTaskCompleted(String taskId) async {
    await _analytics.logEvent(
      name: 'linkedin_task_completed',
      parameters: {'task_id': taskId},
    );
  }

  /// Log LinkedIn checklist progress
  Future<void> logLinkedInProgress(int completedCount, int totalCount) async {
    await _analytics.logEvent(
      name: 'linkedin_checklist_progress',
      parameters: {
        'completed': completedCount,
        'total': totalCount,
        'progress_percent': (completedCount / totalCount * 100).round(),
      },
    );
  }

  // ==================== USER PROPERTIES ====================

  /// Set user property
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  /// Set user ID (for linking across sessions)
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  // ==================== HELPERS ====================

  String _getNpsCategory(int score) {
    if (score >= 9) return 'promoter';
    if (score >= 7) return 'passive';
    return 'detractor';
  }
}
