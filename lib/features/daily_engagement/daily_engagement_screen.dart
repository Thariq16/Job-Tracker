/// Daily Engagement Screen
///
/// Interactive checklist for daily LinkedIn engagement routine (~10-15 min).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'daily_engagement_model.dart';
import 'daily_engagement_provider.dart';

class DailyEngagementScreen extends ConsumerStatefulWidget {
  const DailyEngagementScreen({super.key});

  @override
  ConsumerState<DailyEngagementScreen> createState() => _DailyEngagementScreenState();
}

class _DailyEngagementScreenState extends ConsumerState<DailyEngagementScreen> {
  bool _showCommentingTips = false;
  bool _showWhereTips = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final engagementAsync = ref.watch(dailyEngagementProvider);
    final statsAsync = ref.watch(engagementStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Engagement', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: engagementAsync.when(
        data: (engagement) => _buildContent(context, engagement, statsAsync, isDark),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DailyEngagement? engagement,
    AsyncValue<EngagementStats> statsAsync,
    bool isDark,
  ) {
    final stats = statsAsync.hasValue ? statsAsync.value! : const EngagementStats(
      completedCount: 0,
      totalCount: 9,
      commentingDone: 0,
      commentingTotal: 4,
      likingDone: 0,
      likingTotal: 3,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header card
        _buildHeaderCard(stats, isDark),
        const SizedBox(height: 20),

        // Commenting section
        _buildSectionHeader('🗣️', 'COMMENTING', '8-10 min', isDark),
        const SizedBox(height: 8),
        ...EngagementTaskType.values
            .where((t) => t.category == 'commenting')
            .map((task) => _buildTaskItem(task, engagement, isDark)),

        // Commenting tips (expandable)
        _buildExpandableTip(
          title: 'How to comment well',
          isExpanded: _showCommentingTips,
          onTap: () => setState(() => _showCommentingTips = !_showCommentingTips),
          content: _buildCommentingTipsContent(isDark),
          isDark: isDark,
        ),

        const SizedBox(height: 20),

        // Liking section
        _buildSectionHeader('👍', 'LIKING', '3-4 min', isDark),
        const SizedBox(height: 8),
        ...EngagementTaskType.values
            .where((t) => t.category == 'liking')
            .map((task) => _buildTaskItem(task, engagement, isDark)),

        const SizedBox(height: 20),

        // Posting section
        _buildSectionHeader('✍️', 'POSTING', 'Optional', isDark),
        const SizedBox(height: 8),
        ...EngagementTaskType.values
            .where((t) => t.category == 'posting')
            .map((task) => _buildTaskItem(task, engagement, isDark)),

        const SizedBox(height: 20),

        // Connections section
        _buildSectionHeader('🤝', 'CONNECTIONS', 'Weekly', isDark),
        const SizedBox(height: 8),
        ...EngagementTaskType.values
            .where((t) => t.category == 'connections')
            .map((task) => _buildTaskItem(task, engagement, isDark)),

        // Where to find posts (expandable)
        _buildExpandableTip(
          title: 'Where to find posts',
          isExpanded: _showWhereTips,
          onTap: () => setState(() => _showWhereTips = !_showWhereTips),
          content: _buildWhereTipsContent(isDark),
          isDark: isDark,
        ),

        const SizedBox(height: 24),

        // Target Companies link
        _buildTargetCompaniesLink(isDark),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeaderCard(EngagementStats stats, bool isDark) {
    final isComplete = stats.completedCount == stats.totalCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isComplete
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : isDark
                  ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                  : [const Color(0xFF0077B5), const Color(0xFF00A0DC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isComplete ? Icons.check_circle : Icons.today,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isComplete ? 'All Done! 🎉' : "Today's LinkedIn Session",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      isComplete 
                          ? 'Great work on your networking today!'
                          : '~${stats.timeEstimate} remaining',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stats.completionPercentage,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${stats.completedCount}/${stats.totalCount} tasks completed',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String emoji, String title, String time, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(EngagementTaskType task, DailyEngagement? engagement, bool isDark) {
    final isCompleted = engagement?.isTaskCompleted(task) ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? (isDark ? Colors.green.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.1))
            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.3)
              : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(dailyEngagementControllerProvider.notifier)
                .toggleTask(task, !isCompleted);
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? Colors.green
                        : (isDark ? Colors.grey[700] : Colors.grey[300]),
                    border: isCompleted
                        ? null
                        : Border.all(
                            color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
                            width: 1.5,
                          ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.displayName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted
                          ? (isDark ? Colors.grey[500] : Colors.grey[600])
                          : (isDark ? Colors.grey[200] : Colors.grey[800]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableTip({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget content,
    required bool isDark,
  }) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.blue.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: isDark ? Colors.blue[300] : Colors.blue[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.blue[300] : Colors.blue[700],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: isDark ? Colors.blue[300] : Colors.blue[600],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          content,
        ],
      ],
    );
  }

  Widget _buildCommentingTipsContent(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avoid section
          Row(
            children: [
              const Text('❌', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'Avoid:',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...['Great post!', 'Thanks for sharing', 'Agree 100%'].map((text) =>
            Padding(
              padding: const EdgeInsets.only(left: 22, bottom: 2),
              child: Text(
                '• "$text"',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Instead section
          Row(
            children: [
              const Text('✅', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'Instead:',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...[
            'Share your experience with the topic',
            'Ask a thoughtful question',
            'Add a relevant insight',
          ].map((text) =>
            Padding(
              padding: const EdgeInsets.only(left: 22, bottom: 2),
              child: Text(
                '• $text',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Example
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Example:',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.blue[300] : Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  EngagementGuidance.exampleComment,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhereTipsContent(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: EngagementGuidance.whereToFindPosts.map((tip) =>
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildTargetCompaniesLink(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/target-companies'),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0077B5).withValues(alpha: 0.15) : const Color(0xFF0077B5).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF0077B5).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.business,
                color: Color(0xFF0077B5),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'View My Target Companies',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0077B5),
                      ),
                    ),
                    Text(
                      'Find posts from companies you\'re targeting',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF0077B5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.today, color: Color(0xFF0077B5)),
            const SizedBox(width: 8),
            Text('Daily Engagement', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'A 10-15 minute daily routine to build your LinkedIn presence:\n\n'
          '• Comment on posts from recruiters, companies, and industry experts\n'
          '• Like relevant content from your target companies\n'
          '• Send a few strategic connection requests weekly\n\n'
          'Progress resets each day at midnight.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
