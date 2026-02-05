/// Target Companies Provider
///
/// Riverpod providers for target companies state management.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'target_company_model.dart';
import 'target_companies_repository.dart';

/// Stream provider for real-time company list updates
final targetCompaniesProvider = StreamProvider<List<TargetCompany>>((ref) {
  final repository = ref.watch(targetCompaniesRepositoryProvider);
  return repository.getCompaniesStream();
});

/// Provider for custom industries the user has added
final customIndustriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.read(targetCompaniesRepositoryProvider);
  return repository.getCustomIndustries();
});

/// Controller for managing target companies
final targetCompaniesControllerProvider = NotifierProvider<TargetCompaniesController, AsyncValue<void>>(() {
  return TargetCompaniesController();
});

class TargetCompaniesController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  TargetCompaniesRepository get _repository => ref.read(targetCompaniesRepositoryProvider);

  /// Add a new company
  Future<String?> addCompany({
    required String companyName,
    String? websiteUrl,
    String? linkedInUrl,
    required Industry industry,
    String? customIndustry,
    String? notes,
    String? sourceJobId,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Check if already exists
      final exists = await _repository.companyExists(companyName);
      if (exists) {
        state = AsyncValue.error('Company already exists', StackTrace.current);
        return null;
      }

      final company = TargetCompany(
        id: '', // Will be set by Firestore
        companyName: companyName.trim(),
        websiteUrl: websiteUrl?.trim(),
        linkedInUrl: linkedInUrl?.trim(),
        industry: industry,
        customIndustry: industry == Industry.other ? customIndustry?.trim() : null,
        addedAt: DateTime.now(),
        notes: notes?.trim(),
        sourceJobId: sourceJobId,
      );

      final id = await _repository.addCompany(company);
      state = const AsyncValue.data(null);
      
      // Invalidate custom industries if we added a new one
      if (industry == Industry.other) {
        ref.invalidate(customIndustriesProvider);
      }
      
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Update an existing company
  Future<bool> updateCompany(TargetCompany company) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateCompany(company);
      state = const AsyncValue.data(null);
      
      // Invalidate custom industries if we updated to/from other
      ref.invalidate(customIndustriesProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Delete a company
  Future<bool> deleteCompany(String companyId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteCompany(companyId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

/// Stats about target companies
final targetCompanyStatsProvider = Provider<AsyncValue<CompanyStats>>((ref) {
  final companiesAsync = ref.watch(targetCompaniesProvider);

  return companiesAsync.when(
    data: (companies) {
      final industryBreakdown = <String, int>{};
      for (final company in companies) {
        final industry = company.industryDisplayName;
        industryBreakdown[industry] = (industryBreakdown[industry] ?? 0) + 1;
      }

      return AsyncValue.data(CompanyStats(
        totalCount: companies.length,
        industryBreakdown: industryBreakdown,
      ));
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

class CompanyStats {
  final int totalCount;
  final Map<String, int> industryBreakdown;

  CompanyStats({
    required this.totalCount,
    required this.industryBreakdown,
  });
}
