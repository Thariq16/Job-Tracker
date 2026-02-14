import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'job_model.dart';
import 'job_repository.dart';
import '../auth/auth_repository.dart';

final jobsStreamProvider = StreamProvider<List<JobModel>>((ref) {
  // Watch auth state so the stream re-creates when user changes
  final authState = ref.watch(authStateChangesProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      final repository = ref.watch(jobRepositoryProvider);
      return repository.getJobs();
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final jobsControllerProvider = NotifierProvider<JobsController, AsyncValue<void>>(() {
  return JobsController();
});

class JobsController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  JobRepository get _repository => ref.read(jobRepositoryProvider);

  Future<void> addJob({
    required String company, 
    required String role, 
    required String url,
    String? source,
    String? hiringManagerName,
    String? hiringManagerUrl,
    String? country,
    String? workMode,
    String? description,
    List<String>? keywords,
    List<String>? responsibilities,
    List<String>? qualifications,
    List<String>? benefits,
    Uint8List? cvBytes,
    String? cvFileName,
  }) async {
    state = const AsyncValue.loading();
    try {
      String? cvUrl;
      if (cvBytes != null && cvFileName != null) {
        cvUrl = await _repository.uploadCV(cvFileName, cvBytes);
      }

      final job = JobModel(
        id: '',
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        company: company,
        role: role,
        status: 'applied',
        url: url,
        source: source,
        hiringManagerName: hiringManagerName,
        hiringManagerUrl: hiringManagerUrl,
        country: country,
        workMode: workMode,
        description: description,
        keywords: keywords,
        responsibilities: responsibilities,
        qualifications: qualifications,
        benefits: benefits,
        cvUrl: cvUrl,
        appliedDate: DateTime.now(),
      );
      await _repository.addJob(job);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(String id, String newStatus) async {
    try {
      await _repository.updateJobStatus(id, newStatus);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> editJob({
    required String jobId,
    required String company, 
    required String role, 
    required String url,
    required String status,
    required DateTime appliedDate,
    String? source,
    String? hiringManagerName,
    String? hiringManagerUrl,
    String? country,
    String? workMode,
    String? description,
    List<String>? keywords,
    List<String>? responsibilities,
    List<String>? qualifications,
    List<String>? benefits,
    Uint8List? cvBytes,
    String? cvFileName,
    String? existingCvUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      String? cvUrl = existingCvUrl;
      if (cvBytes != null && cvFileName != null) {
        cvUrl = await _repository.uploadCV(cvFileName, cvBytes);
      }

      final job = JobModel(
        id: jobId, 
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        company: company,
        role: role,
        status: status,
        url: url,
        source: source,
        hiringManagerName: hiringManagerName,
        hiringManagerUrl: hiringManagerUrl,
        country: country,
        workMode: workMode,
        description: description,
        keywords: keywords,
        responsibilities: responsibilities,
        qualifications: qualifications,
        benefits: benefits,
        cvUrl: cvUrl,
        appliedDate: appliedDate,
        updatedAt: DateTime.now(),
      );
      await _repository.updateJob(job);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteJob(String id) async {
     try {
      await _repository.deleteJob(id);
    } catch (e) {
      // Handle error
    }
  }
}
