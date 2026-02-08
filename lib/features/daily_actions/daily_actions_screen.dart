// Daily Actions Screen
//
// UI for displaying and managing today's smart daily actions.
// Users can view, complete, and track their action progress.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'daily_action_model.dart';
import 'daily_action_provider.dart';

class DailyActionsScreen extends ConsumerStatefulWidget {
  const DailyActionsScreen({super.key});

  @override
  ConsumerState<DailyActionsScreen> createState() => _DailyActionsScreenState();
}

class _DailyActionsScreenState extends ConsumerState<DailyActionsScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger action generation on first load
    Future.microtask(() {
      ref.read(dailyActionsInitProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final actionsAsync = ref.watch(dailyActionsProvider);
    final statsAsync = ref.watch(dailyActionsStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Today\'s Actions',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Regenerate actions',
            onPressed: () => _regenerateActions(),
          ),
        ],
      ),
      body: actionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading actions: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _regenerateActions(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
        data: (doc) {
          if (doc == null || doc.actions.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return Column(
            children: [
              // Progress Header
              _buildProgressHeader(statsAsync, isDark),
              
              // Actions List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: doc.actions.length,
                  itemBuilder: (context, index) {
                    return _buildActionCard(
                      context,
                      doc.actions[index],
                      index,
                      isDark,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressHeader(AsyncValue<DailyActionsStats> statsAsync, bool isDark) {
    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (stats) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Progress Ring
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: stats.completionPercentage,
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(
                      stats.isFullyComplete ? Colors.greenAccent : Colors.white,
                    ),
                  ),
                  Text(
                    stats.progressText,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Progress',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
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
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    DailyAction action,
    int index,
    bool isDark,
  ) {
    final colors = _getActionColors(action.type, isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: action.isCompleted
              ? Colors.green.withValues(alpha: 0.3)
              : colors.borderColor,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: action.jobId != null
              ? () => context.push('/job/${action.jobId}')
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: action.isCompleted
                        ? Colors.green.withValues(alpha: 0.15)
                        : colors.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: action.isCompleted
                      ? const Icon(Icons.check, color: Colors.green, size: 24)
                      : Text(
                          action.type.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: action.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: action.isCompleted
                              ? (isDark ? Colors.grey[500] : Colors.grey[400])
                              : null,
                        ),
                      ),
                      if (action.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          action.subtitle!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                      if (action.jobId != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.work_outline,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${action.jobTitle} at ${action.companyName}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Checkbox
                Checkbox(
                  value: action.isCompleted,
                  onChanged: (value) {
                    ref
                        .read(dailyActionsControllerProvider.notifier)
                        .toggleAction(index, value ?? false);
                  },
                  activeColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No actions yet',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Actions will be generated based on your job applications and activity.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _regenerateActions(),
              icon: const Icon(Icons.refresh),
              label: const Text('Generate Actions'),
            ),
          ],
        ),
      ),
    );
  }

  ActionColors _getActionColors(ActionType type, bool isDark) {
    switch (type) {
      case ActionType.sendFollowUp:
        return ActionColors(
          bgColor: Colors.orange.withValues(alpha: 0.15),
          borderColor: Colors.orange.withValues(alpha: 0.2),
        );
      case ActionType.recruiterOutreach:
        return ActionColors(
          bgColor: Colors.blue.withValues(alpha: 0.15),
          borderColor: Colors.blue.withValues(alpha: 0.2),
        );
      case ActionType.cvImprovement:
        return ActionColors(
          bgColor: Colors.purple.withValues(alpha: 0.15),
          borderColor: Colors.purple.withValues(alpha: 0.2),
        );
    }
  }

  void _regenerateActions() {
    ref.read(dailyActionsControllerProvider.notifier).regenerateActions();
  }
}

class ActionColors {
  final Color bgColor;
  final Color borderColor;

  ActionColors({required this.bgColor, required this.borderColor});
}
