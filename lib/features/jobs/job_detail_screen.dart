import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_tracker/features/jobs/job_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'jobs_provider.dart';
import 'add_job_modal.dart';
import '../networking/networking_provider.dart';
import '../networking/networking_model.dart';

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
              final job = jobs.firstWhere((j) => j.id == jobId, orElse: () => JobModel(id: '', userId: '', company: '', role: '', status: '', url: '', appliedDate: DateTime.now()));
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
            error: (_, _) => const SizedBox(),
          )
        ],
      ),
      body: jobsAsync.when(
        data: (jobs) {
          final job = jobs.firstWhere(
            (j) => j.id == jobId, 
            orElse: () => JobModel(id: 'notFound', userId: '', company: 'Not Found', role: '', status: '', url: '', appliedDate: DateTime.now())
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
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
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
                         backgroundColor: Colors.indigo.withValues(alpha: 0.05),
                       )).toList(),
                     )
                  ]
                ],

                const SizedBox(height: 32),

                // Networking Section
                _buildNetworkingSection(context, ref, job),

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
                    gradient: LinearGradient(colors: [Colors.indigo.withValues(alpha: 0.05), Colors.purple.withValues(alpha: 0.05)]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.indigo.withValues(alpha: 0.1)),
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

  Widget _buildNetworkingSection(BuildContext context, WidgetRef ref, JobModel job) {
    final activitiesAsync = ref.watch(networkingForJobProvider(job.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Networking", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Log Activity"),
              onPressed: () => _showAddActivityDialog(context, ref, job),
            ),
          ],
        ),
        const SizedBox(height: 12),
        activitiesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text("Error loading activities: $e"),
          data: (activities) {
            if (activities.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.connect_without_contact, size: 32, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text("No networking activities yet", style: GoogleFonts.inter(color: Colors.grey[500])),
                      const SizedBox(height: 4),
                      Text("Log follow-ups and recruiter messages here", style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ),
              );
            }
            
            return Column(
              children: activities.map((activity) => _buildActivityCard(context, ref, activity, isDark)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityCard(BuildContext context, WidgetRef ref, NetworkingActivity activity, bool isDark) {
    final icon = _getActivityIcon(activity.type);
    final color = _getActivityColor(activity.type);
    
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.type.displayName,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                if (activity.contactName != null)
                  Text(
                    activity.contactName!,
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                  ),
                Text(
                  DateFormat.yMMMd().format(activity.createdAt),
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // Reply toggle
          Column(
            children: [
              IconButton(
                icon: Icon(
                  activity.replyReceived ? Icons.mark_email_read : Icons.mark_email_unread,
                  color: activity.replyReceived ? Colors.green : Colors.grey,
                  size: 22,
                ),
                onPressed: () {
                  ref.read(networkingControllerProvider.notifier)
                      .toggleReply(activity.id, !activity.replyReceived);
                },
                tooltip: activity.replyReceived ? "Reply received" : "No reply yet",
              ),
              Text(
                activity.replyReceived ? "Replied" : "Pending",
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: activity.replyReceived ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(NetworkingType type) {
    switch (type) {
      case NetworkingType.followUp:
        return Icons.email_outlined;
      case NetworkingType.recruiterMessage:
        return Icons.person_search;
      case NetworkingType.connectionRequest:
        return Icons.person_add_outlined;
      case NetworkingType.informationalChat:
        return Icons.coffee_outlined;
      case NetworkingType.referralRequest:
        return Icons.recommend;
      case NetworkingType.thankYou:
        return Icons.favorite_outline;
    }
  }

  Color _getActivityColor(NetworkingType type) {
    switch (type) {
      case NetworkingType.followUp:
        return Colors.blue;
      case NetworkingType.recruiterMessage:
        return Colors.purple;
      case NetworkingType.connectionRequest:
        return Colors.orange;
      case NetworkingType.informationalChat:
        return Colors.brown;
      case NetworkingType.referralRequest:
        return Colors.teal;
      case NetworkingType.thankYou:
        return Colors.pink;
    }
  }

  void _showAddActivityDialog(BuildContext context, WidgetRef ref, JobModel job) {
    NetworkingType selectedType = NetworkingType.followUp;
    final contactController = TextEditingController();
    final notesController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Log Networking Activity",
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "For: ${job.role} at ${job.company}",
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                
                // Activity Type
                Text("Activity Type", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: NetworkingType.values.map((type) {
                    final isSelected = selectedType == type;
                    return ChoiceChip(
                      label: Text(type.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setModalState(() => selectedType = type);
                        }
                      },
                      selectedColor: Colors.indigo.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.indigo : null,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                // Contact Name
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(
                    labelText: "Contact Name (optional)",
                    hintText: "e.g., John Smith, Recruiter",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Notes
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Notes (optional)",
                    hintText: "Any additional details...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(networkingControllerProvider.notifier).addActivity(
                        type: selectedType,
                        jobId: job.id,
                        jobTitle: job.role,
                        companyName: job.company,
                        contactName: contactController.text.isNotEmpty ? contactController.text : null,
                        notes: notesController.text.isNotEmpty ? notesController.text : null,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Log Activity", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
