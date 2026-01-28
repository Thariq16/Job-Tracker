import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_tracker/features/jobs/job_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'jobs_provider.dart';
import 'add_job_modal.dart';
import 'package:go_router/go_router.dart';

class JobDetailScreen extends ConsumerWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We could fetch single job by ID, but since we likely have the list, let's find it.
    // Ideally, Repository should have getJob(id), but MVP:
    final jobsAsync = ref.watch(jobsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Job Details', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          jobsAsync.when(
            data: (jobs) {
              final job = jobs.firstWhere((j) => j.id == jobId, orElse: () => JobModel(id: '', company: '', role: '', status: '', url: '', appliedDate: DateTime.now()));
              if (job.id.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                   showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) => AddJobModal(jobToEdit: job),
                  );
                },
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          )
        ],
      ),
      body: jobsAsync.when(
        data: (jobs) {
          final job = jobs.firstWhere(
            (j) => j.id == jobId, 
            orElse: () => JobModel(id: 'notFound', company: 'Not Found', role: '', status: '', url: '', appliedDate: DateTime.now())
          );

          if (job.id == 'notFound') return const Center(child: Text("Job not found"));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.center,
                      child: Text(job.company[0].toUpperCase(), style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job.role, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(job.company, style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Status Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text("Status", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                           const SizedBox(height: 4),
                           Text(job.status.toUpperCase().replaceAll('_', ' '), style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.indigo)),
                         ],
                       ),
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text("Applied On", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                           const SizedBox(height: 4),
                           Text(DateFormat.yMMMd().format(job.appliedDate), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                         ],
                       ),
                        Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text("Source", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                           const SizedBox(height: 4),
                           Text(job.source ?? 'Unknown', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                         ],
                       ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),



                const SizedBox(height: 32),

                // About Role Section
                if (job.description != null || (job.keywords != null && job.keywords!.isNotEmpty)) ...[
                  Text("About the Role", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  // Meta Badges
                  Wrap(
                    spacing: 8,
                    children: [
                       if (job.country != null) 
                         Chip(label: Text(job.country!), avatar: const Icon(Icons.public, size: 14)),
                       if (job.workMode != null) 
                         Chip(label: Text(job.workMode!), avatar: const Icon(Icons.work, size: 14)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (job.description != null)
                    Text(job.description!, style: GoogleFonts.inter(fontSize: 14, height: 1.5)),
                    
                  if (job.responsibilities != null && job.responsibilities!.isNotEmpty) ...[
                     const SizedBox(height: 16),
                     Text("Responsibilities", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                     const SizedBox(height: 8),
                     ...job.responsibilities!.map((r) => Padding(
                       padding: const EdgeInsets.only(bottom: 4),
                       child: Text(r, style: GoogleFonts.inter(fontSize: 14, height: 1.4)),
                     )),
                  ],

                  if (job.qualifications != null && job.qualifications!.isNotEmpty) ...[
                     const SizedBox(height: 16),
                     Text("Qualifications", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                     const SizedBox(height: 8),
                     ...job.qualifications!.map((q) => Padding(
                       padding: const EdgeInsets.only(bottom: 4),
                       child: Text(q, style: GoogleFonts.inter(fontSize: 14, height: 1.4)),
                     )),
                  ],

                  if (job.keywords != null && job.keywords!.isNotEmpty) ...[
                     const SizedBox(height: 16),
                     Text("Keywords", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                     const SizedBox(height: 8),
                     Wrap(
                       spacing: 8,
                       runSpacing: 8,
                       children: job.keywords!.map((k) => Chip(
                         label: Text(k, style: const TextStyle(fontSize: 12)),
                         backgroundColor: Colors.indigo.withOpacity(0.05),
                       )).toList(),
                     )
                  ]
                ],

                const SizedBox(height: 32),

                // Links Section
                Text("Links", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.link, size: 16),
                      label: const Text("Job Post"),
                      onPressed: () => launchUrl(Uri.parse(job.url)),
                    ),
                    if (job.hiringManagerUrl != null)
                      ActionChip(
                        avatar: const Icon(Icons.person, size: 16),
                        label: Text("Hiring Manager: ${job.hiringManagerName ?? 'Profile'}"),
                        onPressed: () => launchUrl(Uri.parse(job.hiringManagerUrl!)),
                      ),
                  ],
                ),

                const SizedBox(height: 32),

                // AI / Future Section Placeholder
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.indigo.withOpacity(0.05), Colors.purple.withOpacity(0.05)]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.indigo.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.indigo, size: 32),
                      const SizedBox(height: 12),
                      Text("AI Assistant (Coming Soon)", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.indigo)),
                      const SizedBox(height: 8),
                      Text("Use AI to generate follow-up emails, prepare for interviews, or find contacts.", textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                )

              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
