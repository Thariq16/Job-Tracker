import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'job_model.dart';
import 'job_repository.dart';

final jobsStreamProvider = StreamProvider<List<JobModel>>((ref) {
  final repository = ref.watch(jobRepositoryProvider);
  return repository.getJobs();
});

final jobsControllerProvider = StateNotifierProvider<JobsController, AsyncValue<void>>((ref) {
  return JobsController(ref.read(jobRepositoryProvider));
});

class JobsController extends StateNotifier<AsyncValue<void>> {
  final JobRepository _repository;

  JobsController(this._repository) : super(const AsyncValue.data(null));

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
        id: '', // Firestore will assign
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
      // Upload new CV if provided
      if (cvBytes != null && cvFileName != null) {
        cvUrl = await _repository.uploadCV(cvFileName, cvBytes);
      }

      final job = JobModel(
        id: jobId, 
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
      // Handle error potentially
    }
  }
}
