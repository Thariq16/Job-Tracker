import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../jobs/add_job_modal.dart';
import 'package:job_tracker/features/kanban/kanban_board.dart';
import 'package:job_tracker/core/app_drawer.dart';

class JobTrackerScreen extends ConsumerWidget {
  const JobTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: const AppDrawer(selectedIndex: 1),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Applyd',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: const KanbanBoard(),
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
