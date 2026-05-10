import 'package:intl/intl.dart';

class ThumbnailResponse {
  final String id;
  final String styleName;
  final String status;
  final DateTime? createdAt;
  final String? errorMessage;
  final String? imageUrl;
  final Map<String, dynamic>? variants;

  ThumbnailResponse({
    required this.id,
    required this.styleName,
    required this.status,
    this.createdAt,
    this.errorMessage,
    this.imageUrl,
    this.variants,
  });

  factory ThumbnailResponse.fromJson(Map<String, dynamic> json) {
    return ThumbnailResponse(
      id: json['id'] as String,
      styleName: json['style_name'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      errorMessage: json['error_message'] as String?,
      imageUrl: json['image_url'] as String?,
      variants: json['variants'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'style_name': styleName,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
        'error_message': errorMessage,
        'image_url': imageUrl,
        'variants': variants,
      };
}

class JobResponse {
  final String id;
  final String prompt;
  final int numThumbnails;
  final String imageUrl;
  final String status;
  final List<ThumbnailResponse>? thumbnails;

  JobResponse({
    required this.id,
    required this.prompt,
    required this.numThumbnails,
    required this.imageUrl,
    required this.status,
    this.thumbnails,
  });

  factory JobResponse.fromJson(Map<String, dynamic> json) {
    return JobResponse(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      numThumbnails: json['num_thumbnails'] as int,
      imageUrl: json['image_url'] as String,
      status: json['status'] as String,
      thumbnails: (json['thumbnails'] as List<dynamic>?)
          ?.map((e) => ThumbnailResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'num_thumbnails': numThumbnails,
        'image_url': imageUrl,
        'status': status,
        'thumbnails': thumbnails?.map((e) => e.toJson()).toList(),
      };

  bool get isProcessing => status == 'processing' || status == 'not started';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}

class CreateJobRequest {
  final String prompt;
  final int numThumbnails;
  final String originalImageUrl;
  final String? style;

  CreateJobRequest({
    required this.prompt,
    required this.numThumbnails,
    required this.originalImageUrl,
    this.style,
  });

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        'num_thumbnails': numThumbnails,
        'original_image_url': originalImageUrl,
        'style': style,
      };
}

class CreateJobResponse {
  final String jobId;
  final String style;

  CreateJobResponse({
    required this.jobId,
    required this.style,
  });

  factory CreateJobResponse.fromJson(Map<String, dynamic> json) {
    return CreateJobResponse(
      jobId: json['job_id'] as String,
      style: json['style'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'job_id': jobId,
        'style': style,
      };
}

class UploadImageResponse {
  final String url;

  UploadImageResponse({required this.url});

  factory UploadImageResponse.fromJson(Map<String, dynamic> json) {
    return UploadImageResponse(
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'url': url};
}
