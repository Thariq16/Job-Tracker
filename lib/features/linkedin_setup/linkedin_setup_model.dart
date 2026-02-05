/// LinkedIn Setup Checklist - Data Models
/// 
/// This feature helps users optimize their LinkedIn profile with a
/// step-by-step checklist before starting their job hunt.

import 'package:cloud_firestore/cloud_firestore.dart';

/// A sub-step for complex tasks
class TaskSubStep {
  final String id;
  final String title;

  const TaskSubStep({
    required this.id,
    required this.title,
  });
}

/// A single task in the LinkedIn setup checklist
class LinkedInSetupTask {
  final String id;
  final String title;
  final String description;
  final String phase;
  final int order;
  final String? tip;
  final String? linkedInUrl;  // Direct link to LinkedIn settings
  final String icon;  // Material icon name
  final int estimatedMinutes;  // Time estimate in minutes
  final List<TaskSubStep>? subSteps;  // Optional sub-steps for complex tasks

  const LinkedInSetupTask({
    required this.id,
    required this.title,
    required this.description,
    required this.phase,
    required this.order,
    this.tip,
    this.linkedInUrl,
    this.icon = 'check_circle',
    this.estimatedMinutes = 5,
    this.subSteps,
  });
}

/// User's progress on the LinkedIn setup checklist
class LinkedInSetupProgress {
  final String id;
  final Map<String, DateTime> completedTasks;  // taskId -> completedAt
  final Map<String, List<String>> completedSubSteps;  // taskId -> list of completed subStep ids
  final DateTime startedAt;
  final DateTime? completedAt;  // When all tasks are done
  final String? earnedBadge;  // Badge earned for completion

  LinkedInSetupProgress({
    required this.id,
    required this.completedTasks,
    this.completedSubSteps = const {},
    required this.startedAt,
    this.completedAt,
    this.earnedBadge,
  });

  factory LinkedInSetupProgress.empty(String id) {
    return LinkedInSetupProgress(
      id: id,
      completedTasks: {},
      completedSubSteps: {},
      startedAt: DateTime.now(),
    );
  }

  bool isTaskCompleted(String taskId) => completedTasks.containsKey(taskId);
  
  bool isSubStepCompleted(String taskId, String subStepId) {
    return completedSubSteps[taskId]?.contains(subStepId) ?? false;
  }

  int get completedCount => completedTasks.length;

  double getProgressPercent(int totalTasks) {
    if (totalTasks == 0) return 0;
    return completedCount / totalTasks;
  }

  Map<String, dynamic> toMap() {
    return {
      'completedTasks': completedTasks.map((k, v) => MapEntry(k, Timestamp.fromDate(v))),
      'completedSubSteps': completedSubSteps,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'earnedBadge': earnedBadge,
    };
  }

  factory LinkedInSetupProgress.fromSnapshot(DocumentSnapshot doc) {
    if (!doc.exists) return LinkedInSetupProgress.empty(doc.id);
    
    final data = doc.data() as Map<String, dynamic>;
    
    final completedTasksRaw = data['completedTasks'] as Map<String, dynamic>? ?? {};
    final completedTasks = completedTasksRaw.map((k, v) => 
      MapEntry(k, (v as Timestamp).toDate())
    );

    final completedSubStepsRaw = data['completedSubSteps'] as Map<String, dynamic>? ?? {};
    final completedSubSteps = completedSubStepsRaw.map((k, v) => 
      MapEntry(k, List<String>.from(v as List))
    );

    return LinkedInSetupProgress(
      id: doc.id,
      completedTasks: completedTasks,
      completedSubSteps: completedSubSteps,
      startedAt: (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      earnedBadge: data['earnedBadge'],
    );
  }

  LinkedInSetupProgress copyWith({
    Map<String, DateTime>? completedTasks,
    Map<String, List<String>>? completedSubSteps,
    DateTime? completedAt,
    String? earnedBadge,
  }) {
    return LinkedInSetupProgress(
      id: id,
      completedTasks: completedTasks ?? this.completedTasks,
      completedSubSteps: completedSubSteps ?? this.completedSubSteps,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      earnedBadge: earnedBadge ?? this.earnedBadge,
    );
  }
}

/// All available tasks - defined statically
/// Reorganized into 4 phases: Quick Wins, Profile Content, Credibility Builders, Visibility & Engagement
class LinkedInSetupTasks {
  static const List<LinkedInSetupTask> all = [
    // Phase 1: Quick Wins (5 tasks, ~20 min total)
    LinkedInSetupTask(
      id: 'professional_photo',
      title: 'Professional Photo',
      description: 'Upload a clear, professional headshot',
      phase: 'Quick Wins',
      order: 1,
      icon: 'photo_camera',
      estimatedMinutes: 5,
      tip: 'Use a recent photo where your face takes up 60% of the frame. Smile and wear professional attire. A plain background works best.',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/photo/',
    ),
    LinkedInSetupTask(
      id: 'banner_image',
      title: 'Banner Image',
      description: 'Add a professional background banner',
      phase: 'Quick Wins',
      order: 2,
      icon: 'image',
      estimatedMinutes: 5,
      tip: 'Use a clean banner related to your industry. Canva has free LinkedIn banner templates. Avoid busy patterns.',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/background-image/',
    ),
    LinkedInSetupTask(
      id: 'custom_url',
      title: 'Custom URL',
      description: 'Create a personalized LinkedIn URL',
      phase: 'Quick Wins',
      order: 3,
      icon: 'link',
      estimatedMinutes: 2,
      tip: 'Change linkedin.com/in/random123 to linkedin.com/in/yourname. Makes your profile easier to share on resumes and business cards.',
      linkedInUrl: 'https://www.linkedin.com/public-profile/settings',
    ),
    LinkedInSetupTask(
      id: 'open_to_work',
      title: 'Enable Open to Work',
      description: 'Let recruiters know you\'re available',
      phase: 'Quick Wins',
      order: 4,
      icon: 'work_outline',
      estimatedMinutes: 3,
      tip: 'Choose "Recruiters only" if you don\'t want your current employer to see. Increases profile visibility to recruiters by 40%.',
      linkedInUrl: 'https://www.linkedin.com/jobs/application-settings/',
      subSteps: [
        TaskSubStep(id: 'open_visibility', title: 'Choose visibility (Recruiters only recommended)'),
        TaskSubStep(id: 'open_titles', title: 'Set target job titles'),
        TaskSubStep(id: 'open_locations', title: 'Set preferred locations'),
      ],
    ),
    LinkedInSetupTask(
      id: 'job_preferences',
      title: 'Set Job Preferences',
      description: 'Define your ideal role criteria',
      phase: 'Quick Wins',
      order: 5,
      icon: 'tune',
      estimatedMinutes: 5,
      tip: 'Be specific about your target roles. Add multiple locations if you\'re flexible. Select remote if applicable.',
      linkedInUrl: 'https://www.linkedin.com/jobs/application-settings/',
      subSteps: [
        TaskSubStep(id: 'pref_titles', title: 'Add 3-5 target job titles'),
        TaskSubStep(id: 'pref_locations', title: 'Set preferred locations'),
        TaskSubStep(id: 'pref_worktype', title: 'Choose work type (remote/hybrid/onsite)'),
      ],
    ),

    // Phase 2: Profile Content (5 tasks, ~85 min total)
    LinkedInSetupTask(
      id: 'custom_headline',
      title: 'Keyword-Rich Headline',
      description: 'Write a headline with industry keywords',
      phase: 'Profile Content',
      order: 6,
      icon: 'title',
      estimatedMinutes: 15,
      tip: 'Go beyond "Job Title at Company". Include keywords recruiters search for. Example: "Product Manager | Fintech | User-Centric Design | Ex-Google"',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/intro/',
      subSteps: [
        TaskSubStep(id: 'headline_research', title: 'Research 5 target job descriptions'),
        TaskSubStep(id: 'headline_keywords', title: 'Extract top 5 keywords'),
        TaskSubStep(id: 'headline_craft', title: 'Craft headline using keywords'),
      ],
    ),
    LinkedInSetupTask(
      id: 'about_section',
      title: 'Compelling About Section',
      description: 'Write a 3-5 paragraph summary that stands out',
      phase: 'Profile Content',
      order: 7,
      icon: 'person',
      estimatedMinutes: 20,
      tip: 'Start with a hook, highlight 3 key achievements, mention your expertise, and end with what you\'re looking for. Use first person.',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/summary/',
      subSteps: [
        TaskSubStep(id: 'about_hook', title: 'Write attention-grabbing opening line'),
        TaskSubStep(id: 'about_achievements', title: 'List 3 key achievements'),
        TaskSubStep(id: 'about_goals', title: 'State what you\'re looking for'),
        TaskSubStep(id: 'about_keywords', title: 'Include keywords naturally'),
      ],
    ),
    LinkedInSetupTask(
      id: 'work_experience',
      title: 'Experience with Metrics',
      description: 'Add positions with quantified achievements',
      phase: 'Profile Content',
      order: 8,
      icon: 'work',
      estimatedMinutes: 30,
      tip: 'Use bullet points with numbers. "Increased sales by 40%" is better than "Improved sales". Include 3-5 bullets per role.',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/position/new/',
      subSteps: [
        TaskSubStep(id: 'exp_positions', title: 'Add all relevant positions'),
        TaskSubStep(id: 'exp_bullets', title: 'Write 3-5 bullets per role'),
        TaskSubStep(id: 'exp_metrics', title: 'Add quantified results (%, \$, numbers)'),
      ],
    ),
    LinkedInSetupTask(
      id: 'skills_section',
      title: '10+ Relevant Skills',
      description: 'Add your most searchable skills',
      phase: 'Profile Content',
      order: 9,
      icon: 'psychology',
      estimatedMinutes: 10,
      tip: 'Add your most important skills first - they get more visibility. Include skills from job descriptions you\'re targeting.',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/skills/',
      subSteps: [
        TaskSubStep(id: 'skills_add', title: 'Add industry-specific hard skills'),
        TaskSubStep(id: 'skills_prioritize', title: 'Prioritize top 3 most searchable'),
        TaskSubStep(id: 'skills_order', title: 'Order by relevance'),
      ],
    ),
    LinkedInSetupTask(
      id: 'education',
      title: 'Complete Education',
      description: 'Add degrees, certifications, and courses',
      phase: 'Profile Content',
      order: 10,
      icon: 'school',
      estimatedMinutes: 10,
      tip: 'Include relevant coursework, projects, and extracurriculars. Add certifications from LinkedIn Learning, Coursera, etc.',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/education/new/',
      subSteps: [
        TaskSubStep(id: 'edu_degrees', title: 'Add degrees/certifications'),
        TaskSubStep(id: 'edu_coursework', title: 'Include relevant coursework'),
      ],
    ),

    // Phase 3: Credibility Builders (3 tasks)
    LinkedInSetupTask(
      id: 'skill_assessments',
      title: 'Take Skill Assessments',
      description: 'Complete LinkedIn skill tests for badges',
      phase: 'Credibility Builders',
      order: 11,
      icon: 'quiz',
      estimatedMinutes: 30,
      tip: 'Passing assessments gives you a badge that shows on your profile. Focus on skills relevant to your target roles.',
      linkedInUrl: 'https://www.linkedin.com/skill-assessments/',
      subSteps: [
        TaskSubStep(id: 'assess_identify', title: 'Identify 3 most relevant skills'),
        TaskSubStep(id: 'assess_complete', title: 'Complete assessments'),
        TaskSubStep(id: 'assess_display', title: 'Display badges on profile'),
      ],
    ),
    LinkedInSetupTask(
      id: 'featured_section',
      title: 'Add Featured Content',
      description: 'Showcase your best work samples',
      phase: 'Credibility Builders',
      order: 12,
      icon: 'star',
      estimatedMinutes: 20,
      tip: 'Add 2-3 best work samples: presentations, articles, portfolio pieces. Visual content stands out and proves your expertise.',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/featured/',
      subSteps: [
        TaskSubStep(id: 'featured_select', title: 'Select 2-3 best work samples'),
        TaskSubStep(id: 'featured_describe', title: 'Add project descriptions'),
        TaskSubStep(id: 'featured_visuals', title: 'Include visuals if available'),
      ],
    ),
    LinkedInSetupTask(
      id: 'get_recommendations',
      title: 'Request Recommendations',
      description: 'Get 2-3 written recommendations',
      phase: 'Credibility Builders',
      order: 13,
      icon: 'rate_review',
      estimatedMinutes: 15,
      tip: 'Reach out to former managers or colleagues. Offer to write one for them first. Be specific about what you\'d like highlighted.',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/forms/recommendation/ask/',
      subSteps: [
        TaskSubStep(id: 'rec_identify', title: 'Identify 3 people to ask (managers/colleagues)'),
        TaskSubStep(id: 'rec_draft', title: 'Draft personalized request message'),
        TaskSubStep(id: 'rec_send', title: 'Send requests'),
        TaskSubStep(id: 'rec_followup', title: 'Follow up after 1 week if no response'),
      ],
    ),

    // Phase 4: Visibility & Engagement (5 tasks)
    LinkedInSetupTask(
      id: 'follow_companies',
      title: 'Follow Target Companies',
      description: 'Follow 10+ companies you want to work for',
      phase: 'Visibility & Engagement',
      order: 14,
      icon: 'business',
      estimatedMinutes: 10,
      tip: 'Following companies helps you see their job posts first and shows interest when recruiters check your profile.',
      linkedInUrl: 'https://www.linkedin.com/feed/following/',
      subSteps: [
        TaskSubStep(id: 'follow_list', title: 'List 10 target companies'),
        TaskSubStep(id: 'follow_pages', title: 'Follow company pages'),
        TaskSubStep(id: 'follow_alerts', title: 'Turn on job alerts'),
      ],
    ),
    LinkedInSetupTask(
      id: 'strategic_connections',
      title: 'Strategic Connections',
      description: 'Connect with 15-20 quality professionals weekly',
      phase: 'Visibility & Engagement',
      order: 15,
      icon: 'people',
      estimatedMinutes: 15,
      tip: 'Focus on: target company employees (5-7), recruiters (3-5), domain experts (3-5), hiring managers (2-3). Always personalize requests.',
      linkedInUrl: 'https://www.linkedin.com/mynetwork/grow/',
    ),
    LinkedInSetupTask(
      id: 'privacy_settings',
      title: 'Review Privacy Settings',
      description: 'Ensure your profile is visible to recruiters',
      phase: 'Visibility & Engagement',
      order: 16,
      icon: 'visibility',
      estimatedMinutes: 5,
      tip: 'Make sure your profile is public and your activity is visible. This helps recruiters find and learn about you.',
      linkedInUrl: 'https://www.linkedin.com/mypreferences/d/visibility',
      subSteps: [
        TaskSubStep(id: 'privacy_public', title: 'Ensure profile is public'),
        TaskSubStep(id: 'privacy_activity', title: 'Enable "Show activity"'),
        TaskSubStep(id: 'privacy_visibility', title: 'Check visibility settings'),
      ],
    ),
    LinkedInSetupTask(
      id: 'daily_engagement',
      title: 'Daily Engagement Habit',
      description: 'Commit to 10-15 min daily LinkedIn activity',
      phase: 'Visibility & Engagement',
      order: 17,
      icon: 'schedule',
      estimatedMinutes: 5,
      tip: 'Use the Daily Engagement feature to build a consistent habit. Focus on commenting > liking > posting.',
    ),
    LinkedInSetupTask(
      id: 'achievement_post',
      title: 'Plan Achievement Post',
      description: 'Plan your first LinkedIn post about an achievement',
      phase: 'Visibility & Engagement',
      order: 18,
      icon: 'create',
      estimatedMinutes: 10,
      tip: 'Share a real achievement from your career. Focus on learnings, not bragging. Quality posts > frequent filler content.',
    ),
  ];

  static List<String> get phases => [
    'Quick Wins',
    'Profile Content', 
    'Credibility Builders',
    'Visibility & Engagement',
  ];

  static List<LinkedInSetupTask> getTasksForPhase(String phase) {
    return all.where((t) => t.phase == phase).toList();
  }

  static int get totalCount => all.length;
  
  static int get totalMinutes => all.fold(0, (sum, task) => sum + task.estimatedMinutes);
}

/// Badges for gamification
class LinkedInBadge {
  final String id;
  final String name;
  final String description;
  final String emoji;

  const LinkedInBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
  });

  static const List<LinkedInBadge> all = [
    LinkedInBadge(
      id: 'getting_started',
      name: 'Getting Started',
      description: 'Complete your first task',
      emoji: '🌱',
    ),
    LinkedInBadge(
      id: 'quick_wins',
      name: 'Quick Win Champion',
      description: 'Complete all Quick Wins tasks',
      emoji: '⚡',
    ),
    LinkedInBadge(
      id: 'content_creator',
      name: 'Content Creator',
      description: 'Complete all Profile Content tasks',
      emoji: '✍️',
    ),
    LinkedInBadge(
      id: 'credibility_king',
      name: 'Credibility King',
      description: 'Complete all Credibility Builders tasks',
      emoji: '👑',
    ),
    LinkedInBadge(
      id: 'visibility_master',
      name: 'Visibility Master',
      description: 'Complete all Visibility & Engagement tasks',
      emoji: '🔭',
    ),
    LinkedInBadge(
      id: 'linkedin_legend',
      name: 'LinkedIn Legend',
      description: 'Complete all 18 tasks!',
      emoji: '🏆',
    ),
  ];
}
