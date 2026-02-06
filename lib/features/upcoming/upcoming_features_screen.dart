import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpcomingFeaturesScreen extends StatelessWidget {
  const UpcomingFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final features = [
      // Completed Features
      _FeatureItem(
        icon: Icons.checklist,
        title: 'LinkedIn Setup Guide',
        description: 'Step-by-step checklist to optimize your LinkedIn profile',
        status: FeatureStatus.completed,
        category: 'Guides',
      ),
      _FeatureItem(
        icon: Icons.trending_up,
        title: 'Daily LinkedIn Engagement',
        description: 'Track and complete daily LinkedIn networking tasks',
        status: FeatureStatus.completed,
        category: 'Networking',
      ),
      _FeatureItem(
        icon: Icons.business,
        title: 'Target Companies',
        description: 'Track and manage your list of target companies',
        status: FeatureStatus.completed,
        category: 'Networking',
      ),
      _FeatureItem(
        icon: Icons.lightbulb,
        title: 'Feature Requests',
        description: 'Submit ideas for new features you\'d like to see',
        status: FeatureStatus.completed,
        category: 'Feedback',
      ),
      _FeatureItem(
        icon: Icons.bug_report,
        title: 'Bug Reports',
        description: 'Report issues with severity levels to help us improve',
        status: FeatureStatus.completed,
        category: 'Feedback',
      ),
      // Removed: Admin Dashboard (internal feature)
      
      // In Progress
      _FeatureItem(
        icon: Icons.link,
        title: 'LinkedIn Integration',
        description: 'Find hiring managers and connect directly',
        status: FeatureStatus.inProgress,
        category: 'Networking',
      ),
      // Removed: NPS (internal feature)
      _FeatureItem(
        icon: Icons.person_add,
        title: 'Invite a Friend',
        description: 'Share the app with friends and earn rewards',
        status: FeatureStatus.completed,
        category: 'Growth',
      ),
      
      // Planned Features
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
      _FeatureItem(
        icon: Icons.extension,
        title: 'Chrome Extension',
        description: 'One-click job saving from any job board',
        status: FeatureStatus.planned,
        category: 'Productivity',
      ),
      _FeatureItem(
        icon: Icons.edit_document,
        title: 'Resume Builder',
        description: 'AI-powered resume builder with job-specific tailoring',
        status: FeatureStatus.planned,
        category: 'AI Tools',
      ),
      _FeatureItem(
        icon: Icons.bar_chart,
        title: 'Analytics Dashboard',
        description: 'Visual insights on application patterns and response rates',
        status: FeatureStatus.planned,
        category: 'Insights',
      ),
      _FeatureItem(
        icon: Icons.verified,
        title: 'ATS Score Integration',
        description: 'Check how well your resume matches job requirements',
        status: FeatureStatus.planned,
        category: 'AI Tools',
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
                      'Feature Roadmap',
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
                  'Track our progress on new features. Completed features are ready to use!',
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
              _buildStatusLegend('Completed', FeatureStatus.completed, isDark),
              const SizedBox(width: 16),
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
                    'Have a feature idea? Go to Settings → Request New Feature!',
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
    Color dotColor;
    switch (status) {
      case FeatureStatus.completed:
        dotColor = Colors.green;
        break;
      case FeatureStatus.inProgress:
        dotColor = Colors.amber;
        break;
      case FeatureStatus.planned:
        dotColor = Colors.grey;
        break;
    }
    
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor,
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
              color: feature.status == FeatureStatus.completed
                  ? Colors.green.withValues(alpha: 0.15)
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              feature.icon,
              size: 22,
              color: feature.status == FeatureStatus.completed
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
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
    String label;
    Color bgColor;
    Color textColor;
    
    switch (status) {
      case FeatureStatus.completed:
        label = 'COMPLETED';
        bgColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green[700]!;
        break;
      case FeatureStatus.inProgress:
        label = 'IN PROGRESS';
        bgColor = Colors.amber.withValues(alpha: 0.15);
        textColor = Colors.amber[700]!;
        break;
      case FeatureStatus.planned:
        label = 'PLANNED';
        bgColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey[600]!;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

enum FeatureStatus { completed, inProgress, planned }

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

