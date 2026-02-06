/// Admin Guard
///
/// Checks if the current user is an admin.

import 'package:firebase_auth/firebase_auth.dart';

/// List of admin email addresses
const List<String> adminEmails = [
  // Add your admin email here
  'thariqhamad6@gmail.com',
];

/// Check if the current user is an admin
bool isAdmin(User? user) {
  if (user == null || user.email == null) return false;
  return adminEmails.contains(user.email!.toLowerCase());
}

/// Check if the current authenticated user is an admin
bool isCurrentUserAdmin() {
  final user = FirebaseAuth.instance.currentUser;
  return isAdmin(user);
}
