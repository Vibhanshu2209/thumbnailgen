# 🚀 Quick Start Guide - Thumbnail Generator Flutter App

## ⚡ 30-Second Setup

```bash
# Navigate to Flutter project
cd frontend/thumbnail_flutter

# Install dependencies
flutter pub get

# Run the app
flutter run
```

**Done!** 🎉

---

## 📋 Prerequisites

Before running, make sure you have:

1. **Flutter SDK** (3.11.5 or later)
   ```bash
   flutter --version
   ```

2. **Backend API Running**
   - Default: `http://localhost:8000`
   - Backend should be accessible before starting the app

3. **An IDE with Flutter support**
   - VS Code + Flutter extension
   - Android Studio + Flutter plugin
   - Or your preferred editor

---

## 🎯 First Time Setup

### Step 1: Install Flutter Dependencies
```bash
cd frontend/thumbnail_flutter
flutter pub get
```

### Step 2: (Optional) Configure Backend URL
If your backend isn't running on `localhost:8000`:

Edit `lib/config/app_config.dart` (line 2):
```dart
// Change this to your backend URL
static const String apiBaseUrl = 'http://your-backend:8000/api';
```

### Step 3: Run the App
```bash
# On default device/emulator
flutter run

# Or specify device
flutter run -d chrome      # Web
flutter run -d android     # Android emulator
flutter run -d ios         # iOS simulator
```

---

## 🆘 Troubleshooting First Run

### ❌ "Cannot connect to backend"
**Solution**: 
- Make sure backend API is running
- Check `AppConfig.apiBaseUrl` in `lib/config/app_config.dart`
- On Android emulator, use `10.0.2.2` instead of `localhost`

### ❌ "Pub get failed"
**Solution**:
```bash
flutter clean
flutter pub get
```

### ❌ "Device not found"
**Solution**:
```bash
# List available devices
flutter devices

# Or run without specifying device
flutter run
```

---

## 📱 Platform-Specific Instructions

### **Running on Web (Chrome)**
```bash
flutter run -d chrome
```

### **Running on Android**
```bash
# Requires Android emulator or physical device
flutter emulators --launch Pixel_7_API_33    # Or your emulator name
flutter run -d android
```

### **Running on iOS**
```bash
# Requires Mac and Xcode
flutter run -d ios
```

### **Running on Windows/Mac/Linux**
```bash
# Windows
flutter run -d windows

# Mac
flutter run -d macos

# Linux
flutter run -d linux
```

---

## 🎨 Using the App

### **Create Your First Thumbnail Job**

1. **Tap the "+" button** (bottom right)

2. **Select an image**
   - Tap the image upload area
   - Choose any image from your gallery

3. **Enter a prompt**
   - Example: "Professional business thumbnail with modern colors"

4. **Choose thumbnail count**
   - Select 1, 2, or 3 thumbnails

5. **Pick a style** (optional)
   - Bold Dramatic: Cinematic, high-contrast
   - Clean Minimal: Soft, minimalist aesthetic
   - Vibrant Energy: Dynamic, colorful

6. **Tap "Create Job"**
   - Image uploads
   - Job is created
   - Returns to home screen

7. **Watch progress**
   - Tap the job to see live updates
   - Thumbnails appear as they're generated

---

## 📚 Documentation Structure

Navigate to the appropriate doc based on your needs:

### **For Users**
→ Start with [`FLUTTER_APP_README.md`](./FLUTTER_APP_README.md)
- Features overview
- How to use the app
- Troubleshooting common issues

### **For Developers**
→ Read [`SETUP_AND_ARCHITECTURE.md`](./SETUP_AND_ARCHITECTURE.md)
- Complete technical architecture
- How to customize the app
- Performance optimization tips
- Testing guide

### **For Understanding the Code**
→ Check [`ARCHITECTURE_DIAGRAMS.md`](./ARCHITECTURE_DIAGRAMS.md)
- Visual diagrams of data flow
- Component relationships
- HTTP request/response patterns
- State management flow

### **Complete Summary**
→ See [`BUILD_SUMMARY.md`](./BUILD_SUMMARY.md)
- What's been built
- Complete feature list
- File structure
- Next steps

---

## 🔧 Common Commands

```bash
# Install dependencies
flutter pub get

# Run in debug mode (development)
flutter run

# Run in release mode (optimized)
flutter run --release

# Run tests
flutter test

# Build for Android
flutter build apk
flutter build appbundle

# Build for iOS
flutter build ios

# Build for Web
flutter build web

# Build for desktop
flutter build windows
flutter build macos
flutter build linux

# Clean build artifacts
flutter clean

# Get project structure info
flutter doctor

# Check all available devices
flutter devices
```

---

## 🌐 API Configuration

### **Local Development**
```dart
static const String apiBaseUrl = 'http://localhost:8000/api';
```

### **Android Emulator**
```dart
static const String apiBaseUrl = 'http://10.0.2.2:8000/api';
```

### **iOS Simulator**
```dart
// Replace with your machine's IP address
static const String apiBaseUrl = 'http://192.168.1.100:8000/api';
```

### **Production**
```dart
static const String apiBaseUrl = 'https://your-domain.com/api';
```

---

## 🎯 Features Checklist

### Home Screen
- [ ] Load and display jobs
- [ ] Pull to refresh
- [ ] Auto-refresh every 3 seconds
- [ ] Tap job to view details
- [ ] Delete job with confirmation
- [ ] Create new job button

### Create Job Screen
- [ ] Select image from gallery
- [ ] Enter prompt text
- [ ] Select thumbnail count (1-3)
- [ ] Choose style
- [ ] Upload and create job

### Job Details Screen
- [ ] View job information
- [ ] See reference image
- [ ] Watch generated thumbnails
- [ ] View thumbnail status
- [ ] Retry failed jobs
- [ ] Delete job

---

## 💡 Pro Tips

1. **Auto-Refresh**: Leave job details open to see thumbnails appear in real-time

2. **Retry Failed Jobs**: If a job fails, tap the "Retry" button instead of recreating

3. **Style Selection**: Try different styles to see what works best for your needs

4. **Image Caching**: The app caches images automatically for faster loading

5. **Error Messages**: Pay attention to error notifications - they help diagnose issues

6. **Pull to Refresh**: Always refresh if job status seems outdated

---

## 🐛 Debugging Tips

### Enable Debug Logging
The app will print API calls and state changes to the console:
```
flutter run
```

### Check Backend Connection
```bash
# Test backend from terminal
curl http://localhost:8000/api/jobs
```

### Clear App Data
```bash
# Android
flutter run --release

# Or clear in device settings
```

### Hot Reload During Development
```bash
# Press 'r' in terminal to hot reload
# Press 'R' to hot restart (full restart)
```

---

## 📞 Getting Help

### **App won't connect to backend**
1. Verify backend is running: `http://localhost:8000`
2. Check `AppConfig.apiBaseUrl` is correct
3. Check your network connection
4. Try `flutter run --release`

### **Images not loading**
1. Check internet connection
2. Verify image URLs are valid
3. Try closing and reopening the app

### **Job not updating**
1. Pull down to manually refresh
2. Tap the job to see latest status
3. Check backend logs for errors

### **App crashes**
1. Check console output: `flutter run`
2. Look for red error messages
3. Try `flutter clean && flutter pub get`

---

## 🚀 Deployment

### Android
```bash
# Generate release APK
flutter build apk --release

# Generate App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build for iOS
flutter build ios --release

# Archive in Xcode (for App Store)
```

### Web
```bash
# Build for web
flutter build web

# Deploy the 'build/web' folder to your server
```

---

## 📊 Project Statistics

- **Lines of Code**: ~2000
- **Files Created**: 17
- **Packages Used**: 7
- **Screens**: 3
- **Reusable Components**: 5
- **API Endpoints**: 7

---

## ✨ What's Next?

After getting the app running:

1. ✅ **Create a test job** - Verify everything works
2. ✅ **Try different styles** - See the variety
3. ✅ **Explore the code** - Read [`SETUP_AND_ARCHITECTURE.md`](./SETUP_AND_ARCHITECTURE.md)
4. ✅ **Customize** - Change colors in `app_theme.dart`
5. ✅ **Deploy** - Build for your target platform

---

## 📖 Full Documentation Index

| Document | Purpose |
|----------|---------|
| [BUILD_SUMMARY.md](./BUILD_SUMMARY.md) | Overview of all features built |
| [FLUTTER_APP_README.md](./FLUTTER_APP_README.md) | User guide and features |
| [SETUP_AND_ARCHITECTURE.md](./SETUP_AND_ARCHITECTURE.md) | Technical deep dive |
| [ARCHITECTURE_DIAGRAMS.md](./ARCHITECTURE_DIAGRAMS.md) | Visual architecture |
| [QUICK_START.md](./QUICK_START.md) | This file |

---

## 🎉 You're All Set!

Everything is ready to go. Just run:

```bash
flutter pub get && flutter run
```

And start creating thumbnails! 🚀

---

**Questions?** Check the documentation files above or review the source code in `lib/`.

**Happy coding!** ✨
