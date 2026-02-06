/// NPS Provider
///
/// State management for NPS feature using Riverpod.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'nps_repository.dart';

export 'nps_repository.dart' show NpsRepository;

/// Provider to check if NPS should be shown
final shouldShowNpsProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(npsRepositoryProvider);
  return repo.shouldShowNps();
});
