import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'job_card.dart';
import '../jobs/add_job_modal.dart';
import '../jobs/jobs_provider.dart';

import 'package:job_tracker/features/profile/profile_screen.dart'; // Import Profile Screen
import 'package:google_fonts/google_fonts.dart';
import 'package:job_tracker/features/kanban/kanban_board.dart'; // Import Kanban

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We don't need to watch jobs here anymore if KanbanBoard handles it,
    // but we can keep it if we want summary stats later.
    final jobsAsync = ref.watch(jobsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Job Tracker',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: const KanbanBoard(), // Switch to Kanban
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => const AddJobModal(),
           );
        },
        label: const Text('Add Job'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
