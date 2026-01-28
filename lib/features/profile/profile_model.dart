import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String? fullName;
  final String? photoUrl;
  final String? cvUrl;
  final String? cvName;
  final String? jobTitle;
  final String? phoneCode;
  final String? phoneNumber;
  final List<String>? targetRoles;
  final String? currentCountry;
  final String? targetCountry;
  final bool? willingToRelocate;

  UserProfile({
    required this.id,
    this.fullName,
    this.photoUrl,
    this.cvUrl,
    this.cvName,
    this.jobTitle,
    this.phoneCode,
    this.phoneNumber,
    this.targetRoles,
    this.currentCountry,
    this.targetCountry,
    this.willingToRelocate,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'photoUrl': photoUrl,
      'cvUrl': cvUrl,
      'cvName': cvName,
      'jobTitle': jobTitle,
      'phoneCode': phoneCode,
      'phoneNumber': phoneNumber,
      'targetRoles': targetRoles,
      'currentCountry': currentCountry,
      'targetCountry': targetCountry,
      'willingToRelocate': willingToRelocate,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserProfile.fromSnapshot(DocumentSnapshot doc) {
    if (!doc.exists) return UserProfile(id: doc.id);
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      fullName: data['fullName'],
      photoUrl: data['photoUrl'],
      cvUrl: data['cvUrl'],
      cvName: data['cvName'],
      jobTitle: data['jobTitle'],
      phoneCode: data['phoneCode'],
      phoneNumber: data['phoneNumber'],
      targetRoles: data['targetRoles'] != null 
          ? List<String>.from(data['targetRoles']) 
          : (data['targetRole'] != null ? [data['targetRole']] : null),
      currentCountry: data['currentCountry'],
      targetCountry: data['targetCountry'],
      willingToRelocate: data['willingToRelocate'],
    );
  }
}
