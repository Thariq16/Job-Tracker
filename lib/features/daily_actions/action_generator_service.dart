// Action Generator Service
//
// Core logic to generate 3-5 smart daily actions based on:
// - Jobs applied 5+ days ago with no status change → sendFollowUp
// - No networking activity in 3+ days → recruiterOutreach
// - Low response rate (<10%) → cvImprovement

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../jobs/job_model.dart';
import '../jobs/jobs_provider.dart';
import '../daily_engagement/daily_engagement_repository.dart';
import 'daily_action_model.dart';
import 'daily_action_repository.dart';

final actionGeneratorProvider = Provider<ActionGeneratorService>((ref) {
  return ActionGeneratorService(ref);
});

class ActionGeneratorService {
  final Ref _ref;

  ActionGeneratorService(this._ref);

  /// Generate daily actions based on user's job data
  Future<List<DailyAction>> generateActions() async {
    final actions = <DailyAction>[];
    final now = DateTime.now();

    // Get current jobs
    final jobsAsync = _ref.read(jobsStreamProvider);
    final jobs = jobsAsync.when(
      data: (data) => data,
      loading: () => <JobModel>[],
      error: (e, st) => <JobModel>[],
    );

    // 1. Check for jobs needing follow-up (applied 5+ days ago, still "applied")
    final followUpActions = _generateFollowUpActions(jobs, now);
    actions.addAll(followUpActions);

    // 2. Check networking activity
    final outreachActions = await _generateOutreachActions(now);
    actions.addAll(outreachActions);

    // 3. Check response rate for CV improvement suggestion
    final cvActions = _generateCvImprovementActions(jobs);
    actions.addAll(cvActions);

    // Limit to 5 actions max, prioritizing follow-ups
    if (actions.length > 5) {
      return actions.take(5).toList();
    }

    // If we have fewer than 3 actions, add general suggestions
    if (actions.isEmpty) {
      actions.add(_createGeneralAction());
    }

    return actions;
  }

  /// Generate follow-up actions for stale applications
  List<DailyAction> _generateFollowUpActions(List<JobModel> jobs, DateTime now) {
    final actions = <DailyAction>[];
    final fiveDaysAgo = now.subtract(const Duration(days: 5));
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // Find jobs applied 5-7+ days ago still in "applied" status
    final staleJobs = jobs.where((job) {
      if (job.status.toLowerCase() != 'applied') return false;
      final appliedDate = DateTime(
        job.appliedDate.year,
        job.appliedDate.month,
        job.appliedDate.day,
      );
      return appliedDate.isBefore(fiveDaysAgo);
    }).toList();

    // Sort by oldest first
    staleJobs.sort((a, b) => a.appliedDate.compareTo(b.appliedDate));

    // Create actions for up to 3 stale jobs
    for (var i = 0; i < staleJobs.length && i < 3; i++) {
      final job = staleJobs[i];
      final daysAgo = now.difference(job.appliedDate).inDays;
      final isUrgent = job.appliedDate.isBefore(sevenDaysAgo);

      actions.add(DailyAction(
        id: 'followup_${job.id}',
        type: ActionType.sendFollowUp,
        title: 'Follow up with ${job.company}',
        subtitle: isUrgent 
            ? '🔴 $daysAgo days since application - urgent!'
            : '$daysAgo days since application',
        jobId: job.id,
        jobTitle: job.role,
        companyName: job.company,
        generatedAt: DateTime.now(),
      ));
    }

    return actions;
  }

  /// Generate recruiter outreach actions based on networking activity
  Future<List<DailyAction>> _generateOutreachActions(DateTime now) async {
    final actions = <DailyAction>[];

    try {
      final engagementRepo = _ref.read(dailyEngagementRepositoryProvider);
      final history = await engagementRepo.getHistory(days: 3);

      // Check if any meaningful engagement in last 3 days
      final hasRecentEngagement = history.any((day) => day.completedCount >= 3);

      if (!hasRecentEngagement) {
        actions.add(DailyAction(
          id: 'outreach_${now.millisecondsSinceEpoch}',
          type: ActionType.recruiterOutreach,
          title: 'Connect with a recruiter',
          subtitle: 'No networking activity in the past 3 days',
          generatedAt: DateTime.now(),
        ));
      }
    } catch (e) {
      // If engagement data unavailable, add a gentle prompt
      actions.add(DailyAction(
        id: 'outreach_${now.millisecondsSinceEpoch}',
        type: ActionType.recruiterOutreach,
        title: 'Reach out to a recruiter today',
        subtitle: 'Build your network with strategic connections',
        generatedAt: DateTime.now(),
      ));
    }

    return actions;
  }

  /// Generate CV improvement action if response rate is low
  List<DailyAction> _generateCvImprovementActions(List<JobModel> jobs) {
    final actions = <DailyAction>[];

    if (jobs.length < 10) {
      // Not enough data to calculate meaningful response rate
      return actions;
    }

    final totalApps = jobs.length;
    final responses = jobs.where((j) {
      final status = j.status.toLowerCase();
      return status == 'interviewing' || status == 'offer';
    }).length;

    final responseRate = responses / totalApps;

    // If response rate is below 10%, suggest CV improvement
    if (responseRate < 0.10) {
      final percentage = (responseRate * 100).toStringAsFixed(1);
      actions.add(DailyAction(
        id: 'cv_${DateTime.now().millisecondsSinceEpoch}',
        type: ActionType.cvImprovement,
        title: 'Consider updating your CV',
        subtitle: 'Response rate is $percentage% - tailoring could help',
        generatedAt: DateTime.now(),
      ));
    }

    return actions;
  }

  /// Create a general fallback action
  DailyAction _createGeneralAction() {
    return DailyAction(
      id: 'general_${DateTime.now().millisecondsSinceEpoch}',
      type: ActionType.recruiterOutreach,
      title: 'Explore new opportunities',
      subtitle: 'Keep your job search momentum going!',
      generatedAt: DateTime.now(),
    );
  }

  /// Check if generation is needed and generate if so
  Future<void> checkAndGenerate() async {
    final repository = _ref.read(dailyActionRepositoryProvider);
    
    final wasGenerated = await repository.wasGeneratedToday();
    if (wasGenerated) {
      // Already generated today, check if document exists
      final existing = await repository.getToday();
      if (existing != null && existing.actions.isNotEmpty) {
        return; // Already have actions for today
      }
    }

    // Generate new actions
    final actions = await generateActions();
    await repository.saveActions(actions);
  }
}
