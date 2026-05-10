# 🏗️ App Architecture & Data Flow

## Application Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Flutter App                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    UI Layer (Screens)                    │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  HomeScreen  │  CreateJobScreen  │  JobDetailsScreen   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ▲                                     │
│                           │ rebuilds                            │
│                           ▼                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │            Widget Layer (Components)                    │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  StatusBadge  │  LoadingShimmer  │  JobCard            │  │
│  │  EmptyState   │  ErrorWidget     │  ThumbnailCard      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ▲                                     │
│                           │ listens                             │
│                           ▼                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │          State Management Layer (Provider)              │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │                     JobProvider                         │  │
│  │  - jobs: List<JobResponse>                             │  │
│  │  - isLoading: bool                                     │  │
│  │  - error: String?                                      │  │
│  │  - _refreshTimer: Timer?                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ▲                                     │
│                           │ calls                               │
│                           ▼                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Service Layer (API)                         │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │                    ApiService                           │  │
│  │  - uploadImage()                                       │  │
│  │  - createJob()                                         │  │
│  │  - listJobs()                                          │  │
│  │  - getJob()                                            │  │
│  │  - deleteJob()                                         │  │
│  │  - retryJob()                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           ▲                                     │
│                           │ HTTP                                │
│                           ▼                                     │
├─────────────────────────────────────────────────────────────────┤
│                   Backend (FastAPI)                            │
├─────────────────────────────────────────────────────────────────┤
│  POST   /api/upload-image      - Upload reference image       │
│  POST   /api/jobs              - Create new job               │
│  GET    /api/jobs              - List all jobs                │
│  GET    /api/jobs/{id}         - Get job details              │
│  DELETE /api/jobs/{id}         - Delete job                   │
│  POST   /api/jobs/{id}/retry   - Retry job                    │
│  GET    /api/jobs/{id}/stream  - Stream progress (TODO)       │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Diagrams

### **Create Job Flow**

```
User Taps "+"
     │
     ▼
Navigate to CreateJobScreen
     │
     ├─► Select Image (ImagePicker)
     │
     ├─► Enter Prompt
     │
     ├─► Select Count (1-3)
     │
     ├─► Choose Style (Optional)
     │
     ▼
User Taps "Create Job"
     │
     ▼
Validate Form
     │
     ├─► Error? Show SnackBar ──────┐
     │                              │
     ▼                              │
Upload Image via ApiService        │
     │                              │
     ├─► Success ──────┐            │
     │                 │            │
     │                 ▼            │
     │          Create Job Request  │
     │                 │            │
     │                 ▼            │
     │          Send to Backend     │
     │                 │            │
     │                 ├─► Success  │
     │                 │     │      │
     │                 │     ▼      │
     │                 │  Update    │
     │                 │  JobProvider
     │                 │     │      │
     │                 │     ▼      │
     │                 │  Show Toast
     │                 │     │      │
     │                 │     ▼      │
     │                 │  Navigate ◄┼────┐
     │                 │  to Home   │    │
     │                 │            │    │
     │                 ├─► Error ───┼────┘
     │                 │
     ▼
Home Screen Auto-Refresh
```

### **View Job Details Flow**

```
User Taps Job Card
     │
     ▼
Navigate to JobDetailsScreen
     │
     ▼
Load Job Details
     │
     ├─► Show Reference Image
     │
     ├─► Display Job Info
     │   - Status Badge
     │   - Prompt
     │   - Count Info
     │
     ▼
Fetch Thumbnails
     │
     ├─► Show in Grid
     │   - Cached images
     │   - Status indicators
     │   - Error messages
     │
     ▼
Pull-to-Refresh
     │
     ├─► Reload Job Data
     │   │
     │   └─► Update UI
     │
     └─► Or Auto-Refresh (3s interval)
         │
         └─► Update Thumbnail Status
```

### **State Management Flow**

```
┌─────────────────────┐
│  JobProvider State  │
│                     │
│  jobs: []          │
│  isLoading: false  │
│  error: null       │
└────────┬────────────┘
         │
         │ notifyListeners()
         │
         ▼
┌─────────────────────────────────────┐
│  Listeners (Consumer/Selectors)    │
├─────────────────────────────────────┤
│  HomeScreen        ListenersConsumer │
│  ├─ Rebuilds when jobs change      │
│  └─ Rebuilds when loading changes  │
│                                     │
│  JobDetailsScreen Consumer          │
│  └─ Rebuilds when job details update
└─────────────────────────────────────┘
```

---

## Class Diagram

```
┌──────────────────────────┐
│     JobProvider         │
│  (ChangeNotifier)       │
├──────────────────────────┤
│ - _jobs: List<JobResp>  │
│ - _isLoading: bool      │
│ - _error: String?       │
│ - _refreshTimer: Timer? │
├──────────────────────────┤
│ + loadJobs()            │
│ + getJobDetails()       │
│ + createJob()           │
│ + deleteJob()           │
│ + retryJob()            │
│ + startAutoRefresh()    │
│ + stopAutoRefresh()     │
└──────────────────────────┘
         △
         │ uses
         │
┌──────────────────────────┐
│     ApiService          │
│   (static methods)      │
├──────────────────────────┤
│ + uploadImage()         │
│ + createJob()           │
│ + listJobs()            │
│ + getJob()              │
│ + deleteJob()           │
│ + retryJob()            │
│ + streamJob()           │
└──────────────────────────┘


┌──────────────────────────┐
│   JobResponse            │
├──────────────────────────┤
│ - id: String            │
│ - prompt: String        │
│ - numThumbnails: int    │
│ - imageUrl: String      │
│ - status: String        │
│ - thumbnails: List<T>   │
├──────────────────────────┤
│ + fromJson()            │
│ + toJson()              │
│ + isProcessing          │
│ + isCompleted           │
│ + isFailed              │
└──────────────────────────┘
         △
         │ contains
         │
┌──────────────────────────┐
│  ThumbnailResponse       │
├──────────────────────────┤
│ - id: String            │
│ - styleName: String     │
│ - status: String        │
│ - imageUrl: String?     │
│ - errorMessage: String? │
│ - createdAt: DateTime?  │
│ - variants: Map?        │
├──────────────────────────┤
│ + fromJson()            │
│ + toJson()              │
└──────────────────────────┘
```

---

## Navigation Flow

```
┌──────────────────────────────────────────────────────┐
│                   Navigator Stack                    │
├──────────────────────────────────────────────────────┤
│                                                      │
│  Route Hierarchy:                                   │
│                                                      │
│  / (Home)                                          │
│  ├─► /create-job                                   │
│  │   └─► Back to HomeScreen                        │
│  │                                                  │
│  └─► /job-details/:jobId                           │
│      ├─► Back to HomeScreen                        │
│      └─► Delete Job                                │
│                                                      │
└──────────────────────────────────────────────────────┘
```

---

## HTTP Request/Response Flow

### **Create Job Request**
```json
POST /api/jobs
Content-Type: application/json

{
  "prompt": "Beautiful landscape with mountains",
  "num_thumbnails": 2,
  "original_image_url": "https://imagekit.io/...",
  "style": "bold_dramatic"
}

Response (200 OK):
{
  "job_id": "uuid-123-456",
  "style": "High-contrast chiaroscuro lighting..."
}
```

### **Get Jobs Response**
```json
GET /api/jobs

Response (200 OK):
[
  {
    "id": "uuid-123",
    "prompt": "...",
    "num_thumbnails": 2,
    "image_url": "...",
    "status": "completed",
    "thumbnails": [
      {
        "id": "thumb-1",
        "style_name": "bold_dramatic",
        "status": "processed",
        "image_url": "...",
        "created_at": "2024-01-01T10:00:00Z",
        "error_message": null
      }
    ]
  }
]
```

---

## Configuration Flow

```
┌────────────────────────────┐
│   app_config.dart          │
├────────────────────────────┤
│ • apiBaseUrl               │
│ • timeout                  │
│ • refreshInterval          │
│ • imageQuality             │
└────────────┬───────────────┘
             │
             ▼
┌────────────────────────────┐
│   ApiService               │
│   (uses AppConfig)         │
├────────────────────────────┤
│ Applies configuration to   │
│ all HTTP requests          │
└────────────────────────────┘
```

---

## Error Handling Flow

```
Try HTTP Request
     │
     ├─► Success (200)
     │   └─► Parse JSON
     │       └─► Return Model
     │
     └─► Failure
         │
         ├─► Network Error
         │   └─► "Connection error: ..."
         │
         ├─► HTTP Error (4xx/5xx)
         │   └─► "Failed to [action]: [code]"
         │
         ├─► Parse Error
         │   └─► "Error parsing response"
         │
         └─► Timeout
             └─► "Request timeout"
                 │
                 ▼
         Update Provider Error
         │
         ▼
         Show ErrorWidget
         │
         └─► User Can Retry
```

---

## Auto-Refresh Mechanism

```
HomeScreen Initialization
     │
     ├─► loadJobs() [initial fetch]
     │
     └─► startAutoRefresh()
         │
         ├─► Create Timer (3 second interval)
         │
         └─► Timer Callback Repeats:
             │
             ├─► Check JobProvider.isLoading
             │
             ├─► Call loadJobs()
             │
             └─► Notify Listeners
                 │
                 ▼
             Screens Rebuild
                 │
                 ├─► New data shown
                 ├─► Status updated
                 └─► Thumbnails refreshed

HomeScreen Dispose
     │
     └─► stopAutoRefresh()
         │
         └─► Cancel Timer
```

---

## Image Caching Strategy

```
Request Image URL
     │
     ├─► Check Local Cache
     │   │
     │   ├─► Found? ───► Display (Fast)
     │   │
     │   └─► Not Found?
     │       │
     │       ▼
     │   Download from Network
     │       │
     │       ├─► Success
     │       │   └─► Cache + Display
     │       │
     │       └─► Error
     │           └─► Show Error Icon
     │
     └─► CachedNetworkImage Widget
         Manages all of this automatically
```

---

## Theme System

```
AppTheme (Single Source of Truth)
     │
     ├─► Colors
     │   ├─ primary
     │   ├─ secondary
     │   ├─ error
     │   └─ background
     │
     ├─► Typography
     │   ├─ body text styles
     │   ├─ headline styles
     │   └─ label styles
     │
     ├─► Components
     │   ├─ button styles
     │   ├─ input decoration
     │   ├─ card styling
     │   └─ app bar theme
     │
     └─► Applied to MaterialApp
         │
         └─► All Screens/Widgets
             Get consistent styling
```

---

**These diagrams provide a complete visual representation of the app's architecture, data flow, and component relationships.**
