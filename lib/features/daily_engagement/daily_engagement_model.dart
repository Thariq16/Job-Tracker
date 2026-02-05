/// Daily Engagement - Data Models
///
/// This feature guides users through a daily 10-15 minute LinkedIn engagement routine.
/// Progress is persisted per calendar day and resets at midnight.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Individual engagement task types
enum EngagementTaskType {
  // Commenting tasks (8-10 min)
  commentOnRecruiter('Comment on recruiter/headhunter post', 'commenting'),
  commentOnTargetCompany('Comment on target company employee', 'commenting'),
  commentOnExpert('Comment on industry expert post', 'commenting'),
  commentOnHiringManager('Comment on hiring manager post', 'commenting'),

  // Liking tasks (3-4 min)
  likeTargetCompany('Like posts from target companies', 'liking'),
  likeIndustry('Like industry-relevant content', 'liking'),
  likeTargetCountry('Like posts from target country', 'liking'),

  // Posting (optional)
  draftAchievementPost('Draft achievement post (monthly)', 'posting'),

  // Connections (weekly)
  sendConnections('Send 3-4 strategic connection requests', 'connections');

  final String displayName;
  final String category;

  const EngagementTaskType(this.displayName, this.category);

  String get icon {
    switch (category) {
      case 'commenting':
        return '🗣️';
      case 'liking':
        return '👍';
      case 'posting':
        return '✍️';
      case 'connections':
        return '🤝';
      default:
        return '✓';
    }
  }
}

/// Represents a single day's engagement progress
class DailyEngagement {
  final String id; // Format: "YYYY-MM-DD"
  final String oderId;
  final Map<String, bool> completedTasks; // taskType.name -> completed
  final DateTime lastUpdated;

  DailyEngagement({
    required this.id,
    required this.oderId,
    required this.completedTasks,
    required this.lastUpdated,
  });

  /// Check if a specific task is completed
  bool isTaskCompleted(EngagementTaskType taskType) {
    return completedTasks[taskType.name] ?? false;
  }

  /// Get count of completed tasks
  int get completedCount => completedTasks.values.where((v) => v).length;

  /// Get total tasks count
  int get totalCount => EngagementTaskType.values.length;

  /// Get completion percentage
  double get completionPercentage => totalCount > 0 ? completedCount / totalCount : 0;

  factory DailyEngagement.empty(String oderId) {
    final today = DateTime.now();
    return DailyEngagement(
      id: _dateToId(today),
      oderId: oderId,
      completedTasks: {},
      lastUpdated: today,
    );
  }

  factory DailyEngagement.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Convert completedTasks from dynamic to Map<String, bool>
    final tasksData = data['completedTasks'] as Map<String, dynamic>? ?? {};
    final tasks = tasksData.map((key, value) => MapEntry(key, value as bool));

    return DailyEngagement(
      id: doc.id,
      oderId: data['oderId'] ?? '',
      completedTasks: tasks,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'oderId': oderId,
      'completedTasks': completedTasks,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  DailyEngagement copyWith({
    String? id,
    String? oderId,
    Map<String, bool>? completedTasks,
    DateTime? lastUpdated,
  }) {
    return DailyEngagement(
      id: id ?? this.id,
      oderId: oderId ?? this.oderId,
      completedTasks: completedTasks ?? this.completedTasks,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  static String _dateToId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String todayId() => _dateToId(DateTime.now());
}

/// Guidance content for engagement tasks
class EngagementGuidance {
  static const commentingTips = [
    GuidanceTip(
      title: 'Avoid Generic Comments',
      examples: ['"Great post!"', '"Thanks for sharing"', '"Agree 100%"'],
      isGood: false,
    ),
    GuidanceTip(
      title: 'Write Insightful Comments',
      examples: [
        'Share your experience with the topic',
        'Ask a thoughtful question',
        'Add a relevant insight or perspective',
      ],
      isGood: true,
    ),
  ];

  static const exampleComment = 
      '"We saw similar results when [doing X]. For us, the key was [specific insight]."';

  static const whereToFindPosts = [
    'Visit your Target Companies\' LinkedIn pages',
    'Check employee posts from target companies',
    'Follow 3-5 industry hashtags',
    'Search: "[industry] hiring manager"',
    'Search: "[target company] recruiter"',
    'Filter by: Posts, Past week',
  ];
}

class GuidanceTip {
  final String title;
  final List<String> examples;
  final bool isGood;

  const GuidanceTip({
    required this.title,
    required this.examples,
    required this.isGood,
  });
}
