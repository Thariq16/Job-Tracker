import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String userId;
  final String company;
  final String role;
  final String status; // 'applied', 'interviewing', 'offer', 'rejected'
  final String url;
  final String? source;
  final String? cvUrl;
  final String? hiringManagerName;
  final String? hiringManagerUrl;
  final String? description;
  final List<String>? keywords;
  final List<String>? responsibilities;
  final List<String>? qualifications;
  final List<String>? benefits;
  final String? country;
  final String? workMode; // 'remote', 'hybrid', 'onsite'
  final DateTime appliedDate;
  final DateTime? updatedAt;
  final DateTime? followUpDate; // For Stage 3 hook

  JobModel({
    required this.id,
    required this.userId,
    required this.company,
    required this.role,
    required this.status,
    required this.url,
    required this.appliedDate,
    this.source,
    this.cvUrl,
    this.hiringManagerName,
    this.hiringManagerUrl,
    this.description,
    this.keywords,
    this.responsibilities,
    this.qualifications,
    this.benefits,
    this.country,
    this.workMode,
    this.updatedAt,
    this.followUpDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'company': company,
      'role': role,
      'status': status,
      'url': url,
      'source': source,
      'cvUrl': cvUrl,
      'hiringManagerName': hiringManagerName,
      'hiringManagerUrl': hiringManagerUrl,
      'description': description,
      'keywords': keywords,
      'responsibilities': responsibilities,
      'qualifications': qualifications,
      'benefits': benefits,
      'country': country,
      'workMode': workMode,
      'appliedDate': Timestamp.fromDate(appliedDate),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'followUpDate': followUpDate != null ? Timestamp.fromDate(followUpDate!) : null,
    };
  }

  factory JobModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      company: data['company'] ?? '',
      role: data['role'] ?? '',
      status: data['status'] ?? 'applied',
      url: data['url'] ?? '',
      source: data['source'],
      cvUrl: data['cvUrl'],
      hiringManagerName: data['hiringManagerName'],
      hiringManagerUrl: data['hiringManagerUrl'],
      description: data['description'],
      keywords: data['keywords'] != null ? List<String>.from(data['keywords']) : null,
      responsibilities: data['responsibilities'] != null ? List<String>.from(data['responsibilities']) : null,
      qualifications: data['qualifications'] != null ? List<String>.from(data['qualifications']) : null,
      benefits: data['benefits'] != null ? List<String>.from(data['benefits']) : null,
      country: data['country'],
      workMode: data['workMode'],
      appliedDate: (data['appliedDate'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      followUpDate: data['followUpDate'] != null ? (data['followUpDate'] as Timestamp).toDate() : null,
    );
  }
}
