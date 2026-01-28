import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'job_model.dart';

final jobRepositoryProvider = Provider((ref) => JobRepository(FirebaseFirestore.instance, FirebaseStorage.instance));

class JobRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  JobRepository(this._firestore, this._storage);

  CollectionReference get _jobs => _firestore.collection('jobs');

  // Create
  Future<void> addJob(JobModel job) async {
    await _jobs.add(job.toMap());
  }
  
  // Upload CV
  Future<String> uploadCV(String fileName, Uint8List fileBytes) async {
    final ref = _storage.ref().child('cvs/${DateTime.now().millisecondsSinceEpoch}_$fileName');
    final uploadTask = ref.putData(fileBytes);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Read
  Stream<List<JobModel>> getJobs() {
    return _jobs.orderBy('appliedDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => JobModel.fromSnapshot(doc)).toList();
    });
  }

  // Update
  Future<void> updateJobStatus(String id, String status) async {
    await _jobs.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateJob(JobModel job) async {
     await _jobs.doc(job.id).update(job.toMap());
  }

  // Delete
  Future<void> deleteJob(String id) async {
    await _jobs.doc(id).delete();
  }
}
