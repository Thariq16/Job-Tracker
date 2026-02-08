// Daily Action Engine - Data Models
//
// This feature generates smart daily actions based on job application data.
// Actions are generated automatically on first daily app open.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of actions the engine can generate
enum ActionType {
  sendFollowUp('Send Follow-up', 'Follow up on applications with no response'),
  recruiterOutreach('Recruiter Outreach', 'Reach out to recruiters for new opportunities'),
  cvImprovement('Improve CV', 'Update your CV to improve response rates');

  final String displayName;
  final String description;

  const ActionType(this.displayName, this.description);

  String get icon {
    switch (this) {
      case ActionType.sendFollowUp:
        return '📧';
      case ActionType.recruiterOutreach:
        return '🤝';
      case ActionType.cvImprovement:
        return '📄';
    }
  }
}

/// Represents a single daily action
class DailyAction {
  final String id;
  final ActionType type;
  final String title;
  final String? subtitle;
  final String? jobId;
  final String? jobTitle;
  final String? companyName;
  final bool isCompleted;
  final DateTime generatedAt;
  final DateTime? completedAt;

  DailyAction({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.jobId,
    this.jobTitle,
    this.companyName,
    this.isCompleted = false,
    required this.generatedAt,
    this.completedAt,
  });

  /// Create a copy with updated fields
  DailyAction copyWith({
    String? id,
    ActionType? type,
    String? title,
    String? subtitle,
    String? jobId,
    String? jobTitle,
    String? companyName,
    bool? isCompleted,
    DateTime? generatedAt,
    DateTime? completedAt,
  }) {
    return DailyAction(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      isCompleted: isCompleted ?? this.isCompleted,
      generatedAt: generatedAt ?? this.generatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'isCompleted': isCompleted,
      'generatedAt': Timestamp.fromDate(generatedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  /// Create from Firestore map
  factory DailyAction.fromMap(String id, Map<String, dynamic> map) {
    return DailyAction(
      id: id,
      type: ActionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ActionType.sendFollowUp,
      ),
      title: map['title'] ?? '',
      subtitle: map['subtitle'],
      jobId: map['jobId'],
      jobTitle: map['jobTitle'],
      companyName: map['companyName'],
      isCompleted: map['isCompleted'] ?? false,
      generatedAt: (map['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Container for a day's actions stored in Firestore
class DailyActionsDocument {
  final String dateId; // Format: "YYYY-MM-DD"
  final List<DailyAction> actions;
  final DateTime generatedAt;
  final DateTime? lastUpdated;

  DailyActionsDocument({
    required this.dateId,
    required this.actions,
    required this.generatedAt,
    this.lastUpdated,
  });

  /// Get count of completed actions
  int get completedCount => actions.where((a) => a.isCompleted).length;

  /// Get total actions count
  int get totalCount => actions.length;

  /// Get completion percentage
  double get completionPercentage => totalCount > 0 ? completedCount / totalCount : 0;

  /// Check if all actions are completed
  bool get isFullyComplete => completedCount == totalCount && totalCount > 0;

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'actions': actions.map((a) => a.toMap()).toList(),
      'generatedAt': Timestamp.fromDate(generatedAt),
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  /// Create from Firestore snapshot
  factory DailyActionsDocument.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final actionsList = (data['actions'] as List<dynamic>? ?? [])
        .asMap()
        .entries
        .map((entry) => DailyAction.fromMap(
              entry.key.toString(),
              entry.value as Map<String, dynamic>,
            ))
        .toList();

    return DailyActionsDocument(
      dateId: doc.id,
      actions: actionsList,
      generatedAt: (data['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  /// Create empty document for today
  factory DailyActionsDocument.empty() {
    return DailyActionsDocument(
      dateId: _dateToId(DateTime.now()),
      actions: [],
      generatedAt: DateTime.now(),
    );
  }

  static String _dateToId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String todayId() => _dateToId(DateTime.now());
}
