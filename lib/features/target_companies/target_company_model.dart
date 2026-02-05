/// Target Companies - Data Models
///
/// This feature helps users track companies they're targeting for job applications.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Pre-defined industries with "Other" option for custom entries
enum Industry {
  technology('Technology'),
  finance('Finance'),
  healthcare('Healthcare'),
  retail('Retail'),
  manufacturing('Manufacturing'),
  consulting('Consulting'),
  media('Media & Entertainment'),
  education('Education'),
  energy('Energy'),
  realEstate('Real Estate'),
  transportation('Transportation'),
  hospitality('Hospitality'),
  telecommunications('Telecommunications'),
  government('Government'),
  nonprofit('Non-Profit'),
  other('Other');

  final String displayName;
  const Industry(this.displayName);

  static Industry fromString(String value) {
    return Industry.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Industry.other,
    );
  }
}

/// A company the user is targeting for job applications
class TargetCompany {
  final String id;
  final String companyName;
  final String? websiteUrl;
  final String? linkedInUrl;
  final Industry industry;
  final String? customIndustry; // Used when industry == other
  final DateTime addedAt;
  final String? notes;
  final String? sourceJobId; // Links to job that prompted this

  TargetCompany({
    required this.id,
    required this.companyName,
    this.websiteUrl,
    this.linkedInUrl,
    required this.industry,
    this.customIndustry,
    required this.addedAt,
    this.notes,
    this.sourceJobId,
  });

  /// Returns the display name for the industry, using customIndustry if "other"
  String get industryDisplayName {
    if (industry == Industry.other && customIndustry != null) {
      return customIndustry!;
    }
    return industry.displayName;
  }

  factory TargetCompany.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TargetCompany(
      id: doc.id,
      companyName: data['companyName'] ?? '',
      websiteUrl: data['websiteUrl'],
      linkedInUrl: data['linkedInUrl'],
      industry: Industry.fromString(data['industry'] ?? 'other'),
      customIndustry: data['customIndustry'],
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'],
      sourceJobId: data['sourceJobId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'websiteUrl': websiteUrl,
      'linkedInUrl': linkedInUrl,
      'industry': industry.name,
      'customIndustry': customIndustry,
      'addedAt': Timestamp.fromDate(addedAt),
      'notes': notes,
      'sourceJobId': sourceJobId,
    };
  }

  TargetCompany copyWith({
    String? id,
    String? companyName,
    String? websiteUrl,
    String? linkedInUrl,
    Industry? industry,
    String? customIndustry,
    DateTime? addedAt,
    String? notes,
    String? sourceJobId,
  }) {
    return TargetCompany(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      industry: industry ?? this.industry,
      customIndustry: customIndustry ?? this.customIndustry,
      addedAt: addedAt ?? this.addedAt,
      notes: notes ?? this.notes,
      sourceJobId: sourceJobId ?? this.sourceJobId,
    );
  }
}
