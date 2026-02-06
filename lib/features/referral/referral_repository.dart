/// Referral Repository
///
/// Handles referral code generation, storage, and tracking.

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final referralRepositoryProvider = Provider<ReferralRepository>((ref) {
  return ReferralRepository();
});

class ReferralRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  DocumentReference get _userDoc => _firestore.collection('users').doc(_userId);

  /// Generate a unique 6-character referral code
  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Removed ambiguous chars
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Get or create referral code for current user
  Future<String> getOrCreateReferralCode() async {
    if (_userId == null) throw Exception('User not logged in');

    final doc = await _userDoc.get();
    final data = doc.data() as Map<String, dynamic>?;

    if (data != null && data['referralCode'] != null) {
      return data['referralCode'] as String;
    }

    // Generate new code
    String code = _generateCode();
    
    // Ensure uniqueness
    bool isUnique = false;
    int attempts = 0;
    while (!isUnique && attempts < 10) {
      final existing = await _firestore
          .collection('referral_codes')
          .doc(code)
          .get();
      if (!existing.exists) {
        isUnique = true;
      } else {
        code = _generateCode();
        attempts++;
      }
    }

    // Save to user and referral_codes collection
    await _userDoc.set({
      'referralCode': code,
    }, SetOptions(merge: true));

    await _firestore.collection('referral_codes').doc(code).set({
      'ownerId': _userId,
      'createdAt': FieldValue.serverTimestamp(),
      'usedCount': 0,
    });

    return code;
  }

  /// Get referral stats for current user
  Future<ReferralStats> getReferralStats() async {
    if (_userId == null) return ReferralStats.empty();

    final code = await getOrCreateReferralCode();
    
    final codeDoc = await _firestore.collection('referral_codes').doc(code).get();
    final codeData = codeDoc.data();
    
    final usedCount = codeData?['usedCount'] as int? ?? 0;

    return ReferralStats(
      referralCode: code,
      invitesSent: usedCount, // We track successful signups
      friendsJoined: usedCount,
    );
  }

  /// Apply referral code during signup
  Future<bool> applyReferralCode(String code) async {
    if (_userId == null) return false;

    final codeDoc = await _firestore.collection('referral_codes').doc(code.toUpperCase()).get();
    
    if (!codeDoc.exists) return false;

    final codeData = codeDoc.data()!;
    final ownerId = codeData['ownerId'] as String;

    // Don't allow self-referral
    if (ownerId == _userId) return false;

    // Save referrer to user profile
    await _userDoc.set({
      'referredBy': code.toUpperCase(),
      'referredAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Increment used count
    await _firestore.collection('referral_codes').doc(code.toUpperCase()).update({
      'usedCount': FieldValue.increment(1),
    });

    // Increment referral count on owner
    await _firestore.collection('users').doc(ownerId).update({
      'referralCount': FieldValue.increment(1),
    });

    return true;
  }

  /// Check if current user was referred
  Future<String?> getReferrer() async {
    if (_userId == null) return null;

    final doc = await _userDoc.get();
    final data = doc.data() as Map<String, dynamic>?;
    
    return data?['referredBy'] as String?;
  }
}

class ReferralStats {
  final String referralCode;
  final int invitesSent;
  final int friendsJoined;

  ReferralStats({
    required this.referralCode,
    required this.invitesSent,
    required this.friendsJoined,
  });

  factory ReferralStats.empty() => ReferralStats(
    referralCode: '',
    invitesSent: 0,
    friendsJoined: 0,
  );
}
