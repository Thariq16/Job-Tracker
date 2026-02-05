/// LinkedIn Setup Screen
/// 
/// Step-by-step checklist to optimize LinkedIn profile for job hunting.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'linkedin_setup_model.dart';
import 'linkedin_setup_provider.dart';

class LinkedInSetupScreen extends ConsumerStatefulWidget {
  const LinkedInSetupScreen({super.key});

  @override
  ConsumerState<LinkedInSetupScreen> createState() => _LinkedInSetupScreenState();
}

class _LinkedInSetupScreenState extends ConsumerState<LinkedInSetupScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;
  final Set<String> _expandedPhases = {'Profile Basics'};  // Start with first phase expanded
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _triggerCelebration() {
    setState(() => _showCelebration = true);
    _celebrationController.forward(from: 0).then((_) {
      if (mounted) setState(() => _showCelebration = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statsAsync = ref.watch(linkedInProgressStatsProvider);
    final tasksByPhaseAsync = ref.watch(linkedInTasksByPhaseProvider);
    
    // Listen for completion to trigger celebration
    ref.listen<AsyncValue<ProgressStats>>(linkedInProgressStatsProvider, (prev, next) {
      final nextValue = next.hasValue ? next.value : null;
      final prevValue = prev?.hasValue == true ? prev?.value : null;
      if (nextValue?.isFullyComplete == true && 
          prevValue?.isFullyComplete != true) {
        _triggerCelebration();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('LinkedIn Setup', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Progress Header
              _buildProgressHeader(context, statsAsync, isDark),
              
              const SizedBox(height: 20),
              
              // Badges Section
              _buildBadgesSection(context, statsAsync, isDark),
              
              const SizedBox(height: 20),
              
              // Phase Sections
              tasksByPhaseAsync.when(
                data: (tasksByPhase) => Column(
                  children: LinkedInSetupTasks.phases.map((phase) {
                    final tasks = tasksByPhase[phase] ?? [];
                    return _buildPhaseSection(context, phase, tasks, isDark);
                  }).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
          
          // Celebration Overlay
          if (_showCelebration) _buildCelebrationOverlay(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, AsyncValue<ProgressStats> statsAsync, bool isDark) {
    return statsAsync.when(
      data: (stats) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [const Color(0xFF0077B5), const Color(0xFF00A0DC)],  // LinkedIn colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : const Color(0xFF0077B5)).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.badge_outlined, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Progress',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        stats.motivationalMessage,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    stats.progressText,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: stats.percentComplete,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  stats.isFullyComplete ? Colors.greenAccent : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(stats.percentComplete * 100).toInt()}% complete',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildBadgesSection(BuildContext context, AsyncValue<ProgressStats> statsAsync, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, size: 20, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Badges',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: LinkedInBadge.all.length,
              itemBuilder: (context, index) {
                final badge = LinkedInBadge.all[index];
                // For now, show first badge as earned if any progress
                final stats = statsAsync.hasValue ? statsAsync.value : null;
                final isEarned = stats?.completedCount != null &&
                    stats!.completedCount > 0 &&
                    (badge.id == 'getting_started' || 
                     stats.earnedBadge == badge.id);
                
                return GestureDetector(
                  onTap: () => _showBadgeDialog(context, badge, isEarned),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isEarned
                                ? Colors.amber.withValues(alpha: 0.2)
                                : (isDark ? Colors.grey[800] : Colors.grey[200]),
                            shape: BoxShape.circle,
                            border: isEarned
                                ? Border.all(color: Colors.amber, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              isEarned ? badge.emoji : '🔒',
                              style: TextStyle(
                                fontSize: isEarned ? 22 : 18,
                                color: isEarned ? null : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          badge.name,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: isEarned
                                ? (isDark ? Colors.white : Colors.black87)
                                : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseSection(BuildContext context, String phase, List<TaskWithStatus> tasks, bool isDark) {
    final isExpanded = _expandedPhases.contains(phase);
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final totalCount = tasks.length;
    final isPhaseComplete = completedCount == totalCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPhaseComplete
              ? Colors.green.withValues(alpha: 0.5)
              : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
          width: isPhaseComplete ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Phase Header
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedPhases.remove(phase);
                } else {
                  _expandedPhases.add(phase);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phase,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$completedCount/$totalCount tasks',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isPhaseComplete)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Done',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // Mini progress bar
                    SizedBox(
                      width: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalCount > 0 ? completedCount / totalCount : 0,
                          minHeight: 6,
                          backgroundColor: isDark 
                              ? Colors.grey[700] 
                              : Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0077B5)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Tasks List (expandable)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: isExpanded
                ? Column(
                    children: [
                      const Divider(height: 1),
                      ...tasks.map((taskStatus) => _buildTaskItem(context, taskStatus, isDark)),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskWithStatus taskStatus, bool isDark) {
    final task = taskStatus.task;
    final isCompleted = taskStatus.isCompleted;

    return InkWell(
      onTap: () => _showTaskDetail(context, task, isCompleted, isDark),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Checkbox - Using Material + InkWell for proper tap isolation
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ref.read(linkedInSetupControllerProvider.notifier)
                      .toggleTask(task.id, !isCompleted);
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(4), // Larger touch target
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted ? const Color(0xFF0077B5) : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isCompleted 
                            ? const Color(0xFF0077B5) 
                            : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Task Icon
            Icon(
              _getIconData(task.icon),
              size: 20,
              color: isCompleted
                  ? Colors.green
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 12),
            // Task Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted
                          ? (isDark ? Colors.grey[500] : Colors.grey[400])
                          : null,
                    ),
                  ),
                  Text(
                    task.description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            // Arrow for detail
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetail(BuildContext context, LinkedInSetupTask task, bool isCompleted, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Task Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0077B5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(task.icon),
                    color: const Color(0xFF0077B5),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        task.phase,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Description
            Text(
              task.description,
              style: GoogleFonts.inter(fontSize: 15),
            ),
            
            // Tip
            if (task.tip != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        task.tip!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? Colors.amber[200] : Colors.amber[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // LinkedIn Link Button
            if (task.linkedInUrl != null)
              OutlinedButton.icon(
                onPressed: () => _launchUrl(task.linkedInUrl!),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Open in LinkedIn'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0077B5),
                  side: const BorderSide(color: Color(0xFF0077B5)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Mark Complete Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(linkedInSetupControllerProvider.notifier)
                      .toggleTask(task.id, !isCompleted);
                  Navigator.pop(context);
                },
                icon: Icon(isCompleted ? Icons.close : Icons.check),
                label: Text(isCompleted ? 'Mark as Incomplete' : 'Mark as Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? Colors.grey : const Color(0xFF0077B5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.7 * (1 - _celebrationController.value)),
          child: Center(
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _celebrationController,
                curve: Curves.elasticOut,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 16),
                  Text(
                    'LinkedIn Legend!',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You completed all tasks!',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBadgeDialog(BuildContext context, LinkedInBadge badge, bool isEarned) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(child: Text(badge.name)),
          ],
        ),
        content: Text(
          isEarned
              ? '${badge.description}\n\n✓ Badge earned!'
              : '${badge.description}\n\n🔒 Complete the required tasks to unlock.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About LinkedIn Setup'),
        content: const Text(
          'This checklist helps you optimize your LinkedIn profile for job hunting.\n\n'
          'Complete each task to increase your chances of being found by recruiters. '
          'Your progress is saved automatically.\n\n'
          'Tap any task to see tips and access LinkedIn settings directly.',
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'photo_camera': return Icons.photo_camera;
      case 'title': return Icons.title;
      case 'person': return Icons.person;
      case 'link': return Icons.link;
      case 'contact_mail': return Icons.contact_mail;
      case 'work': return Icons.work;
      case 'search': return Icons.search;
      case 'psychology': return Icons.psychology;
      case 'thumb_up': return Icons.thumb_up;
      case 'school': return Icons.school;
      case 'rate_review': return Icons.rate_review;
      case 'star': return Icons.star;
      case 'work_outline': return Icons.work_outline;
      case 'tune': return Icons.tune;
      case 'people': return Icons.people;
      case 'business': return Icons.business;
      case 'groups': return Icons.groups;
      default: return Icons.check_circle;
    }
  }
}
