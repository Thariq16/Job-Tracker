/// Target Companies Repository
///
/// Handles Firebase persistence for target companies.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'target_company_model.dart';

final targetCompaniesRepositoryProvider = Provider<TargetCompaniesRepository>((ref) {
  return TargetCompaniesRepository();
});

class TargetCompaniesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _companiesCollection {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(_userId).collection('target_companies');
  }

  /// Stream of all target companies for the user
  Stream<List<TargetCompany>> getCompaniesStream() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _companiesCollection
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TargetCompany.fromSnapshot(doc))
            .toList());
  }

  /// Get all companies (one-time fetch)
  Future<List<TargetCompany>> getCompanies() async {
    if (_userId == null) return [];

    final snapshot = await _companiesCollection
        .orderBy('addedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TargetCompany.fromSnapshot(doc))
        .toList();
  }

  /// Get a single company by ID
  Future<TargetCompany?> getCompany(String companyId) async {
    if (_userId == null) return null;

    final doc = await _companiesCollection.doc(companyId).get();
    if (!doc.exists) return null;
    return TargetCompany.fromSnapshot(doc);
  }

  /// Check if a company with this name already exists
  Future<bool> companyExists(String companyName) async {
    if (_userId == null) return false;

    final snapshot = await _companiesCollection
        .where('companyName', isEqualTo: companyName)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Add a new target company
  Future<String> addCompany(TargetCompany company) async {
    if (_userId == null) throw Exception('User not authenticated');

    final docRef = await _companiesCollection.add(company.toMap());
    return docRef.id;
  }

  /// Update an existing company
  Future<void> updateCompany(TargetCompany company) async {
    if (_userId == null) return;

    await _companiesCollection.doc(company.id).update(company.toMap());
  }

  /// Delete a company
  Future<void> deleteCompany(String companyId) async {
    if (_userId == null) return;

    await _companiesCollection.doc(companyId).delete();
  }

  /// Get unique custom industries used by the user
  Future<List<String>> getCustomIndustries() async {
    if (_userId == null) return [];

    final snapshot = await _companiesCollection
        .where('industry', isEqualTo: 'other')
        .get();

    final customIndustries = snapshot.docs
        .map((doc) => doc.data()['customIndustry'] as String?)
        .where((industry) => industry != null && industry.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    return customIndustries..sort();
  }
}
