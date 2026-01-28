import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_tracker/features/jobs/job_model.dart';
import 'package:job_tracker/features/jobs/jobs_provider.dart';
import '../dashboard/job_card.dart';
import 'package:go_router/go_router.dart';

class KanbanBoard extends ConsumerWidget {
  const KanbanBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsStreamProvider);

    return jobsAsync.when(
      data: (jobs) {
        // Group jobs by status
        final Map<String, List<JobModel>> columns = {
          'applied': [],
          'cv_viewed': [], // Grouped?
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
             // Map some statuses to close ones or add new keys if we want all columns
             // MVP: Let's map cv_downloaded to cv_viewed for simplicity? Or add key.
             if (status == 'cv_downloaded') { 
                if (!columns.containsKey('cv_viewed')) columns['cv_viewed'] = [];
                columns['cv_viewed']!.add(job);
             } else {
                if (!columns.containsKey(status)) columns[status] = [];
                columns[status]!.add(job);
             }
           } else {
              // Catch all
              if (!columns.containsKey('other')) columns['other'] = [];
              columns['other']!.add(job);
           }
        }
        
        // Define Column Order
        final orderedKeys = ['applied', 'cv_viewed', 'interviewing', 'offer', 'rejected', 'ghosted'];

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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
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
      onWillAccept: (data) => true,
      onAccept: (job) {
         if (job.status != statusId) {
            ref.read(jobsControllerProvider.notifier).updateStatus(job.id, statusId);
         }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 300,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.5),
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
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                        // onStatusChanged: Removed or kept? Can keep for quick access
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
