/// LinkedIn Setup Checklist - Data Models
/// 
/// This feature helps users optimize their LinkedIn profile with a
/// step-by-step checklist before starting their job hunt.

import 'package:cloud_firestore/cloud_firestore.dart';

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

  const LinkedInSetupTask({
    required this.id,
    required this.title,
    required this.description,
    required this.phase,
    required this.order,
    this.tip,
    this.linkedInUrl,
    this.icon = 'check_circle',
  });
}

/// User's progress on the LinkedIn setup checklist
class LinkedInSetupProgress {
  final String id;
  final Map<String, DateTime> completedTasks;  // taskId -> completedAt
  final DateTime startedAt;
  final DateTime? completedAt;  // When all tasks are done
  final String? earnedBadge;  // Badge earned for completion

  LinkedInSetupProgress({
    required this.id,
    required this.completedTasks,
    required this.startedAt,
    this.completedAt,
    this.earnedBadge,
  });

  factory LinkedInSetupProgress.empty(String id) {
    return LinkedInSetupProgress(
      id: id,
      completedTasks: {},
      startedAt: DateTime.now(),
    );
  }

  bool isTaskCompleted(String taskId) => completedTasks.containsKey(taskId);

  int get completedCount => completedTasks.length;

  double getProgressPercent(int totalTasks) {
    if (totalTasks == 0) return 0;
    return completedCount / totalTasks;
  }

  Map<String, dynamic> toMap() {
    return {
      'completedTasks': completedTasks.map((k, v) => MapEntry(k, Timestamp.fromDate(v))),
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

    return LinkedInSetupProgress(
      id: doc.id,
      completedTasks: completedTasks,
      startedAt: (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      earnedBadge: data['earnedBadge'],
    );
  }

  LinkedInSetupProgress copyWith({
    Map<String, DateTime>? completedTasks,
    DateTime? completedAt,
    String? earnedBadge,
  }) {
    return LinkedInSetupProgress(
      id: id,
      completedTasks: completedTasks ?? this.completedTasks,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      earnedBadge: earnedBadge ?? this.earnedBadge,
    );
  }
}

/// All available tasks - defined statically
/// Order determines display order within each phase
class LinkedInSetupTasks {
  static const List<LinkedInSetupTask> all = [
    // Phase 1: Profile Basics
    LinkedInSetupTask(
      id: 'professional_photo',
      title: 'Professional Photo',
      description: 'Upload a clear, professional headshot',
      phase: 'Profile Basics',
      order: 1,
      icon: 'photo_camera',
      tip: 'Use a recent photo where your face takes up 60% of the frame. Smile and wear professional attire. A plain background works best.',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/photo/',
    ),
    LinkedInSetupTask(
      id: 'custom_headline',
      title: 'Custom Headline',
      description: 'Write a headline beyond just your job title',
      phase: 'Profile Basics',
      order: 2,
      icon: 'title',
      tip: 'Go beyond "Job Title at Company". Try: "Product Manager | Helping teams build user-centric products | Ex-Google"',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/intro/',
    ),
    LinkedInSetupTask(
      id: 'about_section',
      title: 'About Section',
      description: 'Write a compelling 3-5 paragraph summary',
      phase: 'Profile Basics',
      order: 3,
      icon: 'person',
      tip: 'Start with a hook, highlight your key achievements, mention your expertise, and end with what you\'re looking for. Use first person.',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/summary/',
    ),
    LinkedInSetupTask(
      id: 'custom_url',
      title: 'Custom URL',
      description: 'Create a personalized LinkedIn URL',
      phase: 'Profile Basics',
      order: 4,
      icon: 'link',
      tip: 'Change linkedin.com/in/random123 to linkedin.com/in/yourname. Makes your profile easier to share on resumes and business cards.',
      linkedInUrl: 'https://www.linkedin.com/public-profile/settings',
    ),
    LinkedInSetupTask(
      id: 'contact_info',
      title: 'Contact Info',
      description: 'Add email and phone for recruiter outreach',
      phase: 'Profile Basics',
      order: 5,
      icon: 'contact_mail',
      tip: 'Add a professional email address. Recruiters often want to reach you outside of LinkedIn messaging.',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/contact-info/',
    ),

    // Phase 2: Experience & Skills
    LinkedInSetupTask(
      id: 'work_experience',
      title: 'Work Experience',
      description: 'Add all relevant positions with achievements',
      phase: 'Experience & Skills',
      order: 6,
      icon: 'work',
      tip: 'Use bullet points with quantifiable achievements. Start bullets with action verbs. Include 3-5 bullets per role.',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/position/new/',
    ),
    LinkedInSetupTask(
      id: 'add_keywords',
      title: 'Add Keywords',
      description: 'Include industry keywords for search visibility',
      phase: 'Experience & Skills',
      order: 7,
      icon: 'search',
      tip: 'Look at job postings you want and include those keywords naturally in your headline, about, and experience sections.',
    ),
    LinkedInSetupTask(
      id: 'skills_section',
      title: 'Skills Section',
      description: 'Add at least 10 relevant skills',
      phase: 'Experience & Skills',
      order: 8,
      icon: 'psychology',
      tip: 'Add your most important skills first - they get more visibility. Mix technical and soft skills.',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/skills/',
    ),
    LinkedInSetupTask(
      id: 'get_endorsements',
      title: 'Get Endorsements',
      description: 'Request endorsements for top 3 skills',
      phase: 'Experience & Skills',
      order: 9,
      icon: 'thumb_up',
      tip: 'Message colleagues: "Would you mind endorsing me for [skill] on LinkedIn? Happy to return the favor!"',
    ),
    LinkedInSetupTask(
      id: 'education',
      title: 'Education',
      description: 'Add degrees, certifications, and courses',
      phase: 'Experience & Skills',
      order: 10,
      icon: 'school',
      tip: 'Include relevant coursework, projects, and extracurriculars. Add certifications from LinkedIn Learning, Coursera, etc.',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/education/new/',
    ),

    // Phase 3: Credibility Boosters
    LinkedInSetupTask(
      id: 'get_recommendations',
      title: 'Get Recommendations',
      description: 'Request 2-3 recommendations from colleagues',
      phase: 'Credibility Boosters',
      order: 11,
      icon: 'rate_review',
      tip: 'Reach out to former managers or colleagues. Offer to write one for them first. Be specific about what you\'d like highlighted.',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/forms/recommendation/ask/',
    ),
    LinkedInSetupTask(
      id: 'featured_section',
      title: 'Featured Section',
      description: 'Add projects, articles, or media',
      phase: 'Credibility Boosters',
      order: 12,
      icon: 'star',
      tip: 'Showcase your best work: presentations, articles, portfolio pieces, or notable achievements. Visual content stands out.',
      linkedInUrl: 'https://www.linkedin.com/in/me/edit/featured/',
    ),
    LinkedInSetupTask(
      id: 'open_to_work',
      title: 'Open to Work',
      description: 'Enable "Open to Work" (visible to recruiters)',
      phase: 'Credibility Boosters',
      order: 13,
      icon: 'work_outline',
      tip: 'Choose "Recruiters only" if you don\'t want your current employer to see. Increases profile visibility to recruiters by 40%.',
      linkedInUrl: 'https://www.linkedin.com/jobs/application-settings/',
    ),
    LinkedInSetupTask(
      id: 'job_preferences',
      title: 'Job Preferences',
      description: 'Set job titles, locations, and work type',
      phase: 'Credibility Boosters',
      order: 14,
      icon: 'tune',
      tip: 'Be specific about your target roles. Add multiple locations if you\'re flexible. Select remote if applicable.',
      linkedInUrl: 'https://www.linkedin.com/jobs/application-settings/',
    ),

    // Phase 4: Networking Ready
    LinkedInSetupTask(
      id: 'connect_50',
      title: 'Connect with 50+ Professionals',
      description: 'Build your network with industry connections',
      phase: 'Networking Ready',
      order: 15,
      icon: 'people',
      tip: 'Connect with colleagues, classmates, industry peers. Always add a personal note: "Hi [Name], I saw your work on [X] and would love to connect!"',
      linkedInUrl: 'https://www.linkedin.com/mynetwork/grow/',
    ),
    LinkedInSetupTask(
      id: 'follow_companies',
      title: 'Follow Target Companies',
      description: 'Follow companies you want to work for',
      phase: 'Networking Ready',
      order: 16,
      icon: 'business',
      tip: 'Following companies helps you see their job posts first and shows interest when recruiters check your profile.',
      linkedInUrl: 'https://www.linkedin.com/feed/following/',
    ),
    LinkedInSetupTask(
      id: 'join_groups',
      title: 'Join Industry Groups',
      description: 'Join 3-5 relevant LinkedIn groups',
      phase: 'Networking Ready',
      order: 17,
      icon: 'groups',
      tip: 'Active groups help you network and learn. Participate in discussions to increase your visibility.',
      linkedInUrl: 'https://www.linkedin.com/groups/',
    ),
  ];

  static List<String> get phases => [
    'Profile Basics',
    'Experience & Skills', 
    'Credibility Boosters',
    'Networking Ready',
  ];

  static List<LinkedInSetupTask> getTasksForPhase(String phase) {
    return all.where((t) => t.phase == phase).toList();
  }

  static int get totalCount => all.length;
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
      id: 'profile_basics',
      name: 'Profile Pro',
      description: 'Complete all Profile Basics tasks',
      emoji: '📸',
    ),
    LinkedInBadge(
      id: 'experience_master',
      name: 'Experience Master',
      description: 'Complete all Experience & Skills tasks',
      emoji: '💼',
    ),
    LinkedInBadge(
      id: 'credibility_king',
      name: 'Credibility King',
      description: 'Complete all Credibility Boosters tasks',
      emoji: '👑',
    ),
    LinkedInBadge(
      id: 'network_ninja',
      name: 'Network Ninja',
      description: 'Complete all Networking Ready tasks',
      emoji: '🥷',
    ),
    LinkedInBadge(
      id: 'linkedin_legend',
      name: 'LinkedIn Legend',
      description: 'Complete all 17 tasks!',
      emoji: '🏆',
    ),
  ];
}
