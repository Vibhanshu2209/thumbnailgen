import 'package:intl/intl.dart';

class DateTimeUtils {
  /// Format DateTime to readable string
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
  }

  /// Get time elapsed since a DateTime
  static String getTimeElapsed(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class StringUtils {
  /// Format style name from snake_case to Title Case
  static String formatStyleName(String styleName) {
    return styleName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Truncate string to specified length
  static String truncate(String text, int length) {
    if (text.length <= length) return text;
    return '${text.substring(0, length)}...';
  }

  /// Format job ID to show first 8 characters
  static String formatJobId(String jobId) {
    if (jobId.length <= 8) return jobId;
    return '${jobId.substring(0, 8)}...';
  }
}

class ValidationUtils {
  /// Validate image file size
  static bool isValidImageSize(int fileSizeInBytes, int maxSizeInMB) {
    return fileSizeInBytes <= (maxSizeInMB * 1024 * 1024);
  }

  /// Validate prompt text
  static bool isValidPrompt(String prompt) {
    return prompt.trim().isNotEmpty && prompt.trim().length <= 500;
  }

  /// Validate number of thumbnails
  static bool isValidThumbnailCount(int count) {
    return count >= 1 && count <= 3;
  }
}
