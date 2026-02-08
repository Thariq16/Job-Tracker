/// Networking Model
///
/// Data models for tracking networking activities related to job applications.
/// Includes follow-ups, recruiter messages, and connection requests.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of networking activities
enum NetworkingType {
  followUp,           // Follow-up email after application
  recruiterMessage,   // Message to recruiter
  connectionRequest,  // LinkedIn connection request
  informationalChat,  // Coffee chat / informational interview
  referralRequest,    // Asking for referral
  thankYou,           // Thank you note after interview
}

/// Extension for display text and icons
extension NetworkingTypeExtension on NetworkingType {
  String get displayName {
    switch (this) {
      case NetworkingType.followUp:
        return 'Follow-up Email';
      case NetworkingType.recruiterMessage:
        return 'Recruiter Message';
      case NetworkingType.connectionRequest:
        return 'Connection Request';
      case NetworkingType.informationalChat:
        return 'Informational Chat';
      case NetworkingType.referralRequest:
        return 'Referral Request';
      case NetworkingType.thankYou:
        return 'Thank You Note';
    }
  }

  String get iconName {
    switch (this) {
      case NetworkingType.followUp:
        return 'email';
      case NetworkingType.recruiterMessage:
        return 'person_search';
      case NetworkingType.connectionRequest:
        return 'person_add';
      case NetworkingType.informationalChat:
        return 'coffee';
      case NetworkingType.referralRequest:
        return 'recommend';
      case NetworkingType.thankYou:
        return 'favorite';
    }
  }
}

/// A single networking activity
class NetworkingActivity {
  final String id;
  final NetworkingType type;
  final String? jobId;         // Optional linked job
  final String? jobTitle;      // Denormalized for display
  final String? companyName;   // Denormalized for display
  final String? contactName;   // Person contacted
  final String? contactRole;   // Their role (e.g., "Recruiter", "Hiring Manager")
  final String? notes;         // Additional notes
  final bool replyReceived;    // Did they respond?
  final DateTime createdAt;
  final DateTime? repliedAt;   // When they replied

  NetworkingActivity({
    required this.id,
    required this.type,
    this.jobId,
    this.jobTitle,
    this.companyName,
    this.contactName,
    this.contactRole,
    this.notes,
    this.replyReceived = false,
    required this.createdAt,
    this.repliedAt,
  });

  /// Create from Firestore document
  factory NetworkingActivity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NetworkingActivity(
      id: doc.id,
      type: NetworkingType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => NetworkingType.followUp,
      ),
      jobId: data['jobId'],
      jobTitle: data['jobTitle'],
      companyName: data['companyName'],
      contactName: data['contactName'],
      contactRole: data['contactRole'],
      notes: data['notes'],
      replyReceived: data['replyReceived'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      repliedAt: (data['repliedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'contactName': contactName,
      'contactRole': contactRole,
      'notes': notes,
      'replyReceived': replyReceived,
      'createdAt': Timestamp.fromDate(createdAt),
      'repliedAt': repliedAt != null ? Timestamp.fromDate(repliedAt!) : null,
    };
  }

  /// Create a copy with optional field updates
  NetworkingActivity copyWith({
    String? id,
    NetworkingType? type,
    String? jobId,
    String? jobTitle,
    String? companyName,
    String? contactName,
    String? contactRole,
    String? notes,
    bool? replyReceived,
    DateTime? createdAt,
    DateTime? repliedAt,
  }) {
    return NetworkingActivity(
      id: id ?? this.id,
      type: type ?? this.type,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      contactName: contactName ?? this.contactName,
      contactRole: contactRole ?? this.contactRole,
      notes: notes ?? this.notes,
      replyReceived: replyReceived ?? this.replyReceived,
      createdAt: createdAt ?? this.createdAt,
      repliedAt: repliedAt ?? this.repliedAt,
    );
  }
}

/// Stats for networking activities
class NetworkingStats {
  final int totalActivities;
  final int repliesReceived;
  final int followUpsSent;
  final int recruiterMessages;
  final DateTime? lastActivityDate;

  const NetworkingStats({
    this.totalActivities = 0,
    this.repliesReceived = 0,
    this.followUpsSent = 0,
    this.recruiterMessages = 0,
    this.lastActivityDate,
  });

  double get replyRate => totalActivities > 0 ? repliesReceived / totalActivities : 0;

  int get daysSinceLastActivity {
    if (lastActivityDate == null) return -1;
    return DateTime.now().difference(lastActivityDate!).inDays;
  }

  bool get needsNetworking => daysSinceLastActivity < 0 || daysSinceLastActivity >= 3;
}
