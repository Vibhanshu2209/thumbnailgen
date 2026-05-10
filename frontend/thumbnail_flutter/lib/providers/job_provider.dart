import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';

import 'package:thumbnail_flutter/models/models.dart';
import 'package:thumbnail_flutter/services/api_service.dart';


class JobProvider extends ChangeNotifier {
  List<JobResponse> _jobs = [];
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;

  List<JobResponse> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _jobs = await ApiService.listJobs();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> uploadImageAndCreateJob({
    required File imageFile,
    required String prompt,
    required int numThumbnails,
    required String? style,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Upload image first
      final uploadResponse = await ApiService.uploadImage(imageFile);

      // Create job with uploaded image URL
      final jobRequest = CreateJobRequest(
        prompt: prompt,
        numThumbnails: numThumbnails,
        originalImageUrl: uploadResponse.url,
        style: style,
      );

      final jobResponse = await ApiService.createJob(jobRequest);

      // Reload jobs after creating new one
      await loadJobs();

      return jobResponse.jobId;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      await ApiService.deleteJob(jobId);
      _jobs.removeWhere((job) => job.id == jobId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> retryJob(String jobId) async {
    try {
      await ApiService.retryJob(jobId);
      await loadJobs(); // Reload to get updated status
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<JobResponse> getJobDetails(String jobId) async {
    try {
      return await ApiService.getJob(jobId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 300)}) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) {
      loadJobs();
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
