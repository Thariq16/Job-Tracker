import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance);
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRepository(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User?> signInWithGoogle() async {
    try {
      User? user;
      if (kIsWeb) {
        // Use Firebase Auth popup for web
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        final userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
        user = userCredential.user;
      } else {
        // Use GoogleSignIn package for mobile
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _firebaseAuth.signInWithCredential(credential);
        user = userCredential.user;
      }

      // Sync user profile to Firestore for admin tracking
      if (user != null) {
        await _syncUserToFirestore(user);
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Writes user profile data to Firestore `users/{uid}`.
  /// - `createdAt` is only set on first sign-in (via merge)
  /// - `lastActive` is updated on every sign-in
  /// - `displayName`, `email`, `photoURL` are synced from Google Auth
  Future<void> _syncUserToFirestore(User user) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      
      final docSnapshot = await userDoc.get();
      final now = FieldValue.serverTimestamp();
      
      final data = <String, dynamic>{
        'lastActive': now,
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'photoURL': user.photoURL ?? '',
      };
      
      // Only set createdAt on first sign-in
      if (!docSnapshot.exists) {
        data['createdAt'] = now;
      }

      await userDoc.set(data, SetOptions(merge: true));
    } catch (_) {
      // Don't block sign-in if Firestore write fails
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _firebaseAuth.signOut();
  }
}
