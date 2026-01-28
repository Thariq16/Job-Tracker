import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpcomingFeaturesScreen extends StatelessWidget {
  const UpcomingFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final features = [
      _FeatureItem(
        icon: Icons.link,
        title: 'LinkedIn Integration',
        description: 'Find hiring managers and connect directly',
        status: FeatureStatus.inProgress,
        category: 'Networking',
      ),
      _FeatureItem(
        icon: Icons.trending_up,
        title: 'Daily LinkedIn Activity',
        description: 'Track and optimize your daily LinkedIn engagement',
        status: FeatureStatus.planned,
        category: 'Networking',
      ),
      _FeatureItem(
        icon: Icons.help_outline,
        title: 'LinkedIn Setup Guide',
        description: 'Step-by-step guide to optimize your LinkedIn profile',
        status: FeatureStatus.planned,
        category: 'Guides',
      ),
      _FeatureItem(
        icon: Icons.rate_review,
        title: 'CV Reviewer',
        description: 'AI-powered CV analysis with actionable feedback',
        status: FeatureStatus.planned,
        category: 'AI Tools',
      ),
      _FeatureItem(
        icon: Icons.record_voice_over,
        title: 'Mock Interviews',
        description: 'Practice interviews with AI and get instant feedback',
        status: FeatureStatus.planned,
        category: 'AI Tools',
      ),
      _FeatureItem(
        icon: Icons.description_outlined,
        title: 'CV Writer & Optimizer',
        description: 'AI-powered CV writing and tailoring for each job',
        status: FeatureStatus.planned,
        category: 'AI Tools',
      ),
      _FeatureItem(
        icon: Icons.search,
        title: 'Hiring Manager Finder',
        description: 'Automatically find and research hiring managers',
        status: FeatureStatus.planned,
        category: 'Networking',
      ),
      _FeatureItem(
        icon: Icons.newspaper,
        title: 'Job News Feed',
        description: 'Industry news and company updates for your targets',
        status: FeatureStatus.planned,
        category: 'Insights',
      ),
      _FeatureItem(
        icon: Icons.recommend,
        title: 'Related Job Finder',
        description: 'Discover similar jobs based on your applications',
        status: FeatureStatus.planned,
        category: 'Discovery',
      ),
      _FeatureItem(
        icon: Icons.analytics_outlined,
        title: 'Application Analytics',
        description: 'Track response rates, interview conversion, and trends',
        status: FeatureStatus.planned,
        category: 'Insights',
      ),
      _FeatureItem(
        icon: Icons.calendar_month,
        title: 'Interview Scheduler',
        description: 'Sync with calendar and set reminders',
        status: FeatureStatus.planned,
        category: 'Productivity',
      ),
      _FeatureItem(
        icon: Icons.auto_awesome,
        title: 'AI Cover Letter',
        description: 'Generate personalized cover letters instantly',
        status: FeatureStatus.planned,
        category: 'AI Tools',
      ),
      _FeatureItem(
        icon: Icons.email_outlined,
        title: 'Email Templates',
        description: 'Follow-up and thank you email templates',
        status: FeatureStatus.planned,
        category: 'Productivity',
      ),
      _FeatureItem(
        icon: Icons.notifications_active,
        title: 'Smart Notifications',
        description: 'Reminders to follow up on applications',
        status: FeatureStatus.planned,
        category: 'Productivity',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Features', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.rocket_launch, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Coming Soon',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'re building powerful features to supercharge your job search. Here\'s what\'s on our roadmap.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ), 

          const SizedBox(height: 24),

          // Legend
          Row(
            children: [
              _buildStatusLegend('In Progress', FeatureStatus.inProgress, isDark),
              const SizedBox(width: 16),
              _buildStatusLegend('Planned', FeatureStatus.planned, isDark),
            ],
          ),

          const SizedBox(height: 16),

          // Feature List
          ...features.map((feature) {
            return _buildFeatureCard(context, feature, isDark);
          }),

          const SizedBox(height: 24),

          // Feedback CTA
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Have a feature idea? We\'d love to hear from you!',
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatusLegend(String label, FeatureStatus status, bool isDark) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: status == FeatureStatus.inProgress ? Colors.amber : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, _FeatureItem feature, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              feature.icon,
              size: 22,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        feature.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildStatusBadge(feature.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    feature.category,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(FeatureStatus status) {
    final isInProgress = status == FeatureStatus.inProgress;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isInProgress ? Colors.amber.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isInProgress ? 'IN PROGRESS' : 'PLANNED',
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isInProgress ? Colors.amber[700] : Colors.grey[600],
        ),
      ),
    );
  }
}

enum FeatureStatus { inProgress, planned }

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final FeatureStatus status;
  final String category;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
  });
}
