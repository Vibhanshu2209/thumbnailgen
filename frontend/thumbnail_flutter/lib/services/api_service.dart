import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as io;
import '../models/models.dart';
import '../config/app_config.dart';

class ApiService {
  static const Duration timeout = Duration(seconds: 30);

  /// Upload a reference image to the server
  /// Works on both native (mobile/desktop) and web platforms
  static Future<UploadImageResponse> uploadImage(dynamic imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.apiBaseUrl}/upload-image'),
      );

      // Handle both File (native) and web file types
      if (kIsWeb) {
        // For web: imageFile.readAsBytes() is available on web File objects
        try {
          final bytes = await imageFile.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              bytes,
              filename: imageFile.name ?? 'image.jpg',
            ),
          );
        } catch (e) {
          throw Exception('Failed to read file on web: $e');
        }
      } else {
        // For native platforms: use traditional File path approach
        request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );
      }

      final response = await request.send().timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData) as Map<String, dynamic>;
        return UploadImageResponse.fromJson(json);
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Upload image error: $e');
    }
  }

  /// Create a new thumbnail generation job
  static Future<CreateJobResponse> createJob(
    CreateJobRequest request,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.apiBaseUrl}/jobs'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return CreateJobResponse.fromJson(json);
      } else {
        throw Exception('Failed to create job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Create job error: $e');
    }
  }

  /// Get all jobs
  static Future<List<JobResponse>> listJobs() async {
    try {
      final response = await http
          .get(
            Uri.parse('${AppConfig.apiBaseUrl}/jobs'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body) as List<dynamic>;
        return jsonList
            .map((e) => JobResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('List jobs error: $e');
    }
  }

  /// Get a specific job by ID
  static Future<JobResponse> getJob(String jobId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${AppConfig.apiBaseUrl}/jobs/$jobId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return JobResponse.fromJson(json);
      } else {
        throw Exception('Failed to get job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get job error: $e');
    }
  }

  /// Delete a job
  static Future<void> deleteJob(String jobId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${AppConfig.apiBaseUrl}/jobs/$jobId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Delete job error: $e');
    }
  }

  /// Retry a failed job
  static Future<void> retryJob(String jobId) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.apiBaseUrl}/jobs/$jobId/retry'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to retry job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Retry job error: $e');
    }
  }

  /// Stream job progress (placeholder for now)
  static Future<void> streamJob(String jobId) async {
    // TODO: Implement streaming functionality
    throw UnimplementedError('Job streaming not yet implemented');
  }
}
