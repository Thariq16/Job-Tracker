/// Referral Provider
///
/// State management for referral feature using Riverpod.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'referral_repository.dart';

export 'referral_repository.dart' show ReferralStats;

/// Provider for referral stats
final referralStatsProvider = FutureProvider<ReferralStats>((ref) async {
  final repo = ref.watch(referralRepositoryProvider);
  return repo.getReferralStats();
});

/// Provider for just the referral code
final referralCodeProvider = FutureProvider<String>((ref) async {
  final repo = ref.watch(referralRepositoryProvider);
  return repo.getOrCreateReferralCode();
});
