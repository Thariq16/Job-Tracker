import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../jobs/add_job_modal.dart';
import '../jobs/jobs_provider.dart';
import '../jobs/job_model.dart';
import '../linkedin_setup/linkedin_setup_provider.dart';
import '../daily_actions/daily_action_provider.dart';
import 'package:job_tracker/core/app_drawer.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Scaffold(
      drawer: const AppDrawer(selectedIndex: 0),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Dashboard',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (jobs) {
          // --- CALCULATIONS ---
          final totalJobs = jobs.length;
          
          final todayJobs = jobs.where((j) {
            final appliedDate = DateTime(j.appliedDate.year, j.appliedDate.month, j.appliedDate.day);
            return appliedDate.isAtSameMomentAs(today);
          }).toList();
          final todayCount = todayJobs.length;
          const dailyGoal = 10;

          // Pipeline Counts
          final appliedCount = jobs.where((j) => j.status == 'applied').length;
          final interviewingCount = jobs.where((j) => j.status == 'interviewing').length;
          final offerCount = jobs.where((j) => j.status == 'offer').length;
          final rejectedCount = jobs.where((j) => j.status == 'rejected').length;

          // Response Rate: (Interviewing + Offer) / Total * 100
          final responseRate = totalJobs > 0 
              ? ((interviewingCount + offerCount) / totalJobs * 100).toStringAsFixed(1) 
              : '0.0';

          // Weekly Activity
          Map<int, int> weeklyActivity = {}; // weekday -> count
          for (int i = 0; i < 7; i++) {
            final date = today.subtract(Duration(days: i));
            final count = jobs.where((j) {
              return j.appliedDate.year == date.year && 
                     j.appliedDate.month == date.month && 
                     j.appliedDate.day == date.day;
            }).length;
             weeklyActivity[i] = count;
          }

          // Full Calendar Activity
          Map<DateTime, int> activityMap = {};
          for (var job in jobs) {
            final dateKey = DateTime(job.appliedDate.year, job.appliedDate.month, job.appliedDate.day);
            activityMap[dateKey] = (activityMap[dateKey] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  'Overview',
                  style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('EEEE, MMMM d').format(now),
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500]),
                ),
                
                const SizedBox(height: 24),

                // --- TOP STATS ROW ---
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(context, 'Applied Today', '$todayCount', Icons.today, Colors.blue, isDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(context, 'Total Applied', '$totalJobs', Icons.folder_copy_outlined, Colors.purple, isDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(context, 'Response Rate', '$responseRate%', Icons.trending_up, Colors.green, isDark),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- PIPELINE BREAKDOWN ---
                Text('Pipeline Health', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildPipelineCard(context, 'Applied', appliedCount, Colors.blue, isDark),
                    const SizedBox(width: 8),
                    _buildPipelineCard(context, 'Interviewing', interviewingCount, Colors.orange, isDark),
                    const SizedBox(width: 8),
                    _buildPipelineCard(context, 'Offers', offerCount, Colors.green, isDark),
                    const SizedBox(width: 8),
                    _buildPipelineCard(context, 'Rejected', rejectedCount, Colors.red, isDark),
                  ],
                ),

                const SizedBox(height: 24),

                // --- GOAL & WEEKLY CHART ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Goal
                    Expanded(
                      flex: 4,
                      child: _buildDailyGoalCard(context, todayCount, dailyGoal, isDark),
                    ),
                    const SizedBox(width: 16),
                    // Weekly Chart
                    Expanded(
                      flex: 6,
                      child: _buildWeeklyChart(context, weeklyActivity, isDark),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- DAILY ACTIONS CARD ---
                _buildDailyActionsCard(context, ref, isDark),

                const SizedBox(height: 24),

                // --- LINKEDIN SETUP CARD (hidden when complete) ---
                _buildLinkedInSetupCard(context, ref, isDark),

                const SizedBox(height: 24),

                // --- RECENT APPLICATIONS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Today\'s Applications', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (todayJobs.isNotEmpty)
                      Text('${todayJobs.length} jobs', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                if (todayJobs.isEmpty)
                  _buildEmptyState(isDark)
                else
                  ...todayJobs.take(5).map((job) => _buildJobRow(context, job, isDark)),
                  
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (context) => const AddJobModal(),
          );
        },
        label: const Text('Add Job'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          if (!isDark) BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPipelineCard(BuildContext context, String status, int count, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Text('$count', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(status, style: GoogleFonts.inter(fontSize: 10, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyGoalCard(BuildContext context, int current, int goal, bool isDark) {
    final progress = (current / goal).clamp(0.0, 1.0);
    final isComplete = current >= goal;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Daily Goal', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[500])),
              Icon(Icons.emoji_events, size: 16, color: Colors.amber[600]),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(isComplete ? Colors.green : Theme.of(context).colorScheme.primary),
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('$current / $goal applied', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, Map<int, int> weeklyData, bool isDark) {
    int maxVal = 1;
    for (var v in weeklyData.values) {
      if (v > maxVal) maxVal = v;
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      height: 190, 
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last 7 Days', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[500])),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final dataIndex = 6 - index;
                final count = weeklyData[dataIndex] ?? 0;
                final heightFactor = (count / maxVal).clamp(0.0, 1.0);
                
                final isToday = dataIndex == 0;
                final barColor = isToday ? Theme.of(context).colorScheme.primary : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey[300]!);

                final date = DateTime.now().subtract(Duration(days: dataIndex));
                final dayLabel = DateFormat('E').format(date)[0]; 

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 8,
                      height: 80 * heightFactor + 4,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(dayLabel, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[500])),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCalendar(BuildContext context, Map<DateTime, int> activityMap, bool isDark) {
    final now = DateTime.now();
    final weeks = 12; 
    final days = <DateTime>[];
    for (int i = weeks * 7 - 1; i >= 0; i--) {
      days.add(DateTime(now.year, now.month, now.day).subtract(Duration(days: i)));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
      ),
      child: Column(
        children: [
           SizedBox(
            height: 7 * 14.0, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(weeks, (weekIndex) {
                 return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (dayIndex) {
                    final index = weekIndex * 7 + dayIndex;
                    if (index >= days.length) return const SizedBox(width: 10, height: 10);
                    
                    final date = days[index];
                    final count = activityMap[date] ?? 0;
                    
                    return Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        color: _getActivityColor(count, isDark),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                 );
              }),
            ),
           ),
        ],
      ),
    );
  }
   
  Color _getActivityColor(int count, bool isDark) {
    if (count == 0) return isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200]!;
    if (count <= 2) return Colors.green.withValues(alpha: 0.3);
    if (count <= 5) return Colors.green.withValues(alpha: 0.6);
    return Colors.green;
  }

  Widget _buildDailyActionsCard(BuildContext context, WidgetRef ref, bool isDark) {
    final actionsAsync = ref.watch(dailyActionsProvider);
    
    return actionsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (doc) {
        if (doc == null || doc.actions.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final actions = doc.actions;
        final completedCount = actions.where((a) => a.isCompleted).length;
        final totalCount = actions.length;
        final allComplete = completedCount == totalCount;
        
        return GestureDetector(
          onTap: () => context.push('/daily-actions'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF2D1B4E), const Color(0xFF1A1A2E)]
                    : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.task_alt, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Actions',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        allComplete ? 'All done for today! 🎉' : 'Focus on what matters most',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: allComplete
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (allComplete) ...[
                        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Done',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ] else ...[
                        Text(
                          '$completedCount/$totalCount',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLinkedInSetupCard(BuildContext context, WidgetRef ref, bool isDark) {
    final statsAsync = ref.watch(linkedInProgressStatsProvider);
    
    // Hide when fully complete
    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        if (stats.isFullyComplete) {
          return const SizedBox.shrink();
        }
        
        return GestureDetector(
          onTap: () => context.push('/linkedin-setup'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1A2D4A), const Color(0xFF0D1B2A)]
                    : [const Color(0xFF0077B5), const Color(0xFF00A0DC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0077B5).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.badge_outlined, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LinkedIn Setup',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Optimize your profile for job hunting',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    stats.progressText,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 32, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('No applications yet today', style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildJobRow(BuildContext context, JobModel job, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(job.company.isNotEmpty ? job.company[0].toUpperCase() : '?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 14))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.role, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1),
                Text(job.company, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          _buildStatusChip(job.status),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final colors = {
      'applied': const Color(0xFF3B82F6),
      'interviewing': const Color(0xFFF59E0B),
      'offer': const Color(0xFF10B981),
      'rejected': const Color(0xFFEF4444),
    };
    final color = colors[status.toLowerCase()] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
