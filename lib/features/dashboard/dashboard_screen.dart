import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'job_card.dart';
import '../jobs/add_job_modal.dart';
import '../jobs/jobs_provider.dart';

import 'package:job_tracker/features/profile/profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_tracker/features/kanban/kanban_board.dart';
import 'package:job_tracker/core/theme_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsStreamProvider);
    final user = FirebaseAuth.instance.currentUser;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

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
          // Theme Toggle
          IconButton(
            onPressed: () => toggleTheme(ref),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
              ),
            ),
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          ),
          const SizedBox(width: 4),
          // Profile Avatar
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: user?.photoURL != null
                  ? CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(user!.photoURL!),
                    )
                  : CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        user?.displayName?.isNotEmpty == true
                            ? user!.displayName![0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
            ),
          ),
        ],
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
