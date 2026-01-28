import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository(FirebaseFirestore.instance, FirebaseStorage.instance, FirebaseAuth.instance));

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  ProfileRepository(this._firestore, this._storage, this._auth);

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  DocumentReference get _profileDoc => _firestore.collection('users').doc(_userId);

  Stream<UserProfile> getProfile() {
    return _profileDoc.snapshots().map((doc) => UserProfile.fromSnapshot(doc));
  }

  Future<void> updateProfile({
    String? fullName,
    String? jobTitle,
    String? phoneNumber,
    String? targetRole,
    String? currentCountry,
    String? targetCountry,
    bool? willingToRelocate,
  }) async {
    final Map<String, dynamic> data = {};
    if (fullName != null) data['fullName'] = fullName;
    if (jobTitle != null) data['jobTitle'] = jobTitle;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (targetRole != null) data['targetRole'] = targetRole;
    if (currentCountry != null) data['currentCountry'] = currentCountry;
    if (targetCountry != null) data['targetCountry'] = targetCountry;
    if (willingToRelocate != null) data['willingToRelocate'] = willingToRelocate;

    await _profileDoc.set(data, SetOptions(merge: true));
  }

  Future<void> uploadCV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      final bytes = result.files.first.bytes;
      final name = result.files.first.name;
      
      if (bytes != null) {
         final ref = _storage.ref().child('users/$_userId/cv/$name');
         await ref.putData(bytes);
         final url = await ref.getDownloadURL();
         
         await _profileDoc.set({
           'cvUrl': url,
           'cvName': name,
         }, SetOptions(merge: true));
      }
    }
  }
}

final profileStreamProvider = StreamProvider<UserProfile>((ref) {
  return ref.watch(profileRepositoryProvider).getProfile();
});
