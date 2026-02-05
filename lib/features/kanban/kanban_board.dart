import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_tracker/features/jobs/job_model.dart';
import 'package:job_tracker/features/jobs/jobs_provider.dart';
import 'package:job_tracker/core/skeleton_loader.dart';
import '../dashboard/job_card.dart';
import 'package:go_router/go_router.dart';

class KanbanBoard extends ConsumerWidget {
  const KanbanBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsStreamProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return jobsAsync.when(
      data: (jobs) {
        // Group jobs by status
        final Map<String, List<JobModel>> columns = {
          'applied': [],
          'cv_viewed': [],
          'interviewing': [],
          'offer': [],
          'rejected': [],
        };
        
        // Populate columns
        for (var job in jobs) {
           final status = job.status.toLowerCase();
           if (columns.containsKey(status)) {
             columns[status]!.add(job);
           } else if (status == 'cv_downloaded' || status == 'ghosted') {
             if (status == 'cv_downloaded') { 
                if (!columns.containsKey('cv_viewed')) columns['cv_viewed'] = [];
                columns['cv_viewed']!.add(job);
             } else {
                if (!columns.containsKey(status)) columns[status] = [];
                columns[status]!.add(job);
             }
           } else {
              if (!columns.containsKey('other')) columns['other'] = [];
              columns['other']!.add(job);
           }
        }
        
        final orderedKeys = ['applied', 'cv_viewed', 'interviewing', 'offer', 'rejected', 'ghosted'];

        // Mobile: Vertical tabs layout
        if (isMobile) {
          return DefaultTabController(
            length: orderedKeys.length,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  tabs: orderedKeys.map((status) => Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(status.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${columns[status]?.length ?? 0}', style: const TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: orderedKeys.map((status) {
                      final columnJobs = columns[status] ?? [];
                      return _MobileColumnView(statusId: status, jobs: columnJobs);
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }

        // Desktop: Horizontal scroll
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: orderedKeys.map((status) {
              final columnJobs = columns[status] ?? [];
              return _KanbanColumn(
                title: status.replaceAll('_', ' ').toUpperCase(),
                statusId: status,
                jobs: columnJobs,
              );
            }).toList(),
          ),
        );
      },
      loading: () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: List.generate(4, (_) => const SkeletonKanbanColumn()),
        ),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

// Mobile view for a single column
class _MobileColumnView extends ConsumerWidget {
  final String statusId;
  final List<JobModel> jobs;

  const _MobileColumnView({required this.statusId, required this.jobs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('No jobs here yet', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final job = jobs[index];
        return JobCard(
          company: job.company,
          role: job.role,
          status: job.status,
          appliedDate: job.appliedDate,
          source: job.source,
          country: job.country,
          workMode: job.workMode,
          onTap: () => context.push('/job/${job.id}'),
          onStatusChanged: (newStatus) => _handleStatusChange(context, ref, job, newStatus),
        );
      },
    );
  }

  void _handleStatusChange(BuildContext context, WidgetRef ref, JobModel job, String newStatus) {
    final oldStatus = job.status;
    ref.read(jobsControllerProvider.notifier).updateStatus(job.id, newStatus);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Moved to ${newStatus.replaceAll('_', ' ').toUpperCase()}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref.read(jobsControllerProvider.notifier).updateStatus(job.id, oldStatus);
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

class _KanbanColumn extends ConsumerWidget {
  final String title;

  final String statusId;
  final List<JobModel> jobs;

  const _KanbanColumn({required this.title, required this.statusId, required this.jobs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<JobModel>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (details) {
         if (details.data.status != statusId) {
            ref.read(jobsControllerProvider.notifier).updateStatus(details.data.id, statusId);
         }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 300,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.indigo : Colors.transparent,
              width: 2
            )
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                   color: Theme.of(context).colorScheme.surface,
                   borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                      child: Text("${jobs.length}", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                    )
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: jobs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return Draggable<JobModel>(
                      data: job,
                      feedback: SizedBox(
                        width: 280,
                        child: Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(16),
                          child: Opacity(opacity: 0.9, child: JobCard(
                            company: job.company,
                            role: job.role,
                            status: job.status,
                            appliedDate: job.appliedDate,
                          )), // Minimal content for feedback
                        ),
                      ),
                      childWhenDragging: Opacity(opacity: 0.3, child: JobCard(
                            company: job.company,
                            role: job.role,
                            status: job.status,
                            appliedDate: job.appliedDate,
                      )),
                      child: JobCard(
                        company: job.company,
                        role: job.role,
                        status: job.status,
                        appliedDate: job.appliedDate,
                        source: job.source,
                        hiringManagerName: job.hiringManagerName,
                        hiringManagerUrl: job.hiringManagerUrl,
                        country: job.country,
                        workMode: job.workMode,
                        onTap: () => context.push('/job/${job.id}'),
                        onStatusChanged: (newStatus) {
                          final oldStatus = job.status;
                          ref.read(jobsControllerProvider.notifier).updateStatus(job.id, newStatus);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Moved to ${newStatus.replaceAll('_', ' ').toUpperCase()}'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  ref.read(jobsControllerProvider.notifier).updateStatus(job.id, oldStatus);
                                },
                              ),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
