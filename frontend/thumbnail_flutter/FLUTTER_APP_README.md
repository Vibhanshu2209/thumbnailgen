# Thumbnail Generator Flutter App

A modern, clean, and responsive Flutter application for generating AI-powered thumbnails using reference images and custom prompts.

## Features

- 📱 **Responsive UI**: Works seamlessly on mobile, tablet, and desktop devices
- 🎨 **Modern Design**: Clean and intuitive Material Design 3 interface
- 📸 **Image Upload**: Select reference images from your device gallery
- ✨ **Thumbnail Generation**: Create 1-3 thumbnails with AI-powered styling
- 🎯 **Style Selection**: Choose from preset styles (Bold Dramatic, Clean Minimal, Vibrant Energy)
- 📊 **Job Management**: View, track, and manage all your thumbnail generation jobs
- 🔄 **Auto-Refresh**: Real-time job status updates with automatic refresh
- ♻️ **Retry Failed Jobs**: Easily retry failed thumbnail generations
- 🗑️ **Job Deletion**: Delete jobs and all associated thumbnails
- 🖼️ **Image Caching**: Efficient image caching for better performance

## Project Structure

```
lib/
├── config/           # App configuration
├── models/           # Data models
├── providers/        # State management
├── screens/          # UI screens
├── services/         # API service
├── theme/            # Theme and styling
├── widgets/          # Reusable widgets
└── main.dart         # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (3.11.5 or later)
- Dart SDK
- Backend API running at `http://localhost:8000/api`

### Installation

1. **Install dependencies**:
```bash
flutter pub get
```

2. **Configure API Base URL** (if needed):
   Edit `lib/config/app_config.dart` and update `apiBaseUrl` to match your backend:
```dart
static const String apiBaseUrl = 'http://your-backend-url/api';
```

3. **Run the app**:
```bash
flutter run
```

For a specific device or platform:
```bash
# Web
flutter run -d chrome

# iOS
flutter run -d ios

# Android
flutter run -d android
```

## Usage

### Creating a Thumbnail Job

1. Tap the **"+"** button in the bottom right corner
2. **Select a reference image** from your gallery
3. **Enter a prompt** describing the desired thumbnail style
4. **Choose the number of thumbnails** (1-3)
5. **Optionally select a style**:
   - **Bold Dramatic**: High-contrast, cinematic, intense colors
   - **Clean Minimal**: Soft lighting, monochromatic, uncluttered
   - **Vibrant Energy**: Neon colors, motion blur, electric atmosphere
6. Tap **"Create Job"** to start generation

### Viewing Job Details

- Tap on any job card from the home screen to see:
  - Job status and details
  - Reference image
  - Generated thumbnails as they complete
  - Thumbnail status and any error messages

### Managing Jobs

- **Refresh**: Pull down on the jobs list to refresh
- **Retry**: On a failed job's details screen, tap "Retry" to restart generation
- **Delete**: Tap the delete icon to remove a job

## Architecture

### State Management

The app uses **Provider** for state management:

- **JobProvider**: Manages all job-related state
  - Load jobs
  - Create new jobs
  - Delete jobs
  - Retry failed jobs
  - Auto-refresh functionality

### API Service

**ApiService** handles all HTTP communication:

- Image upload to backend
- Job creation
- Job listing
- Job details retrieval
- Job deletion
- Job retry (placeholder for streaming)

### Data Models

Models represent API responses:

- `JobResponse`: Complete job information
- `ThumbnailResponse`: Individual thumbnail details
- `CreateJobRequest`: Job creation parameters
- `CreateJobResponse`: Job creation response
- `UploadImageResponse`: Image upload response

## Customization

### Changing API Base URL

Edit `lib/config/app_config.dart`:

```dart
static const String apiBaseUrl = 'http://your-server:8000/api';
```

### Modifying App Theme

The entire app theme is defined in `lib/theme/app_theme.dart`:

```dart
// Color scheme
static const primaryColor = Color(0xFF6366F1);
static const secondaryColor = Color(0xFF10B981);

// And more...
```

### Adjusting Auto-Refresh Rate

In `lib/config/app_config.dart`:

```dart
static const int autoRefreshIntervalSeconds = 3;
```

## Dependencies

- **http**: HTTP client for API communication
- **provider**: State management
- **image_picker**: Select images from device
- **cached_network_image**: Efficient image caching
- **shimmer**: Loading state animations
- **intl**: Date/time formatting

## Stream Endpoint

The stream endpoint (`/api/jobs/{job_id}/stream`) is currently a placeholder. To implement real-time updates:

1. Add `web_socket_channel` dependency to `pubspec.yaml`
2. Implement WebSocket connection in `ApiService.streamJob()`
3. Update `JobDetailsScreen` to listen to stream updates

## Troubleshooting

### App can't connect to backend

- Verify backend is running at the configured URL
- Check `AppConfig.apiBaseUrl` matches your backend
- On Android emulator, use `10.0.2.2` instead of `localhost`
- On iOS simulator, use your machine's IP address

### Images not loading

- Ensure image URLs are publicly accessible
- Check network connectivity
- Verify imagekit or storage service is functioning

### Jobs not updating

- Verify auto-refresh is enabled (should update every 3 seconds)
- Pull down to manually refresh
- Check backend API is responding

## Future Enhancements

- [ ] Implement WebSocket streaming for real-time progress
- [ ] Add image download functionality
- [ ] Export thumbnails as batch
- [ ] User authentication
- [ ] Job history and filtering
- [ ] Bulk job creation
- [ ] Dark theme support
- [ ] Offline mode with local caching

## License

This project is part of the Thumbnail Generator application suite.

## Support

For issues or questions, please refer to the main project documentation or contact the development team.
