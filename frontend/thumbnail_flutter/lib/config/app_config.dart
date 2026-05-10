// Configuration for the thumbnail generator app
class AppConfig {
  // Backend API base URL - Change this if your backend is running on a different host/port
  static const String apiBaseUrl = 'http://localhost:8000/api';

  // Request timeout duration in seconds
  static const int requestTimeoutSeconds = 30;

  // Auto-refresh interval for jobs (in seconds)
  static const int autoRefreshIntervalSeconds = 3;

  // Image picker constraints
  static const int maxImageSizeMB = 10;
  static const int imageQuality = 90;

  // Job constraints
  static const int minThumbnails = 1;
  static const int maxThumbnails = 3;
}
