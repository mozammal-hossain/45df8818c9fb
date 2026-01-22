# Device Vital Monitor

A comprehensive Flutter mobile application that monitors and tracks device vitals in real-time, including thermal state, battery level, and memory usage. The app seamlessly integrates with native platform APIs (Android/iOS) and communicates with a backend service for data persistence, analytics, and historical tracking.

## Overview

Device Vital Monitor is a full-stack mobile monitoring solution that demonstrates:
- **Cross-platform mobile development** with Flutter
- **Native platform integration** using MethodChannels for Android and iOS
- **Backend API integration** for data logging and analytics
- **Real-time monitoring** of critical device metrics
- **Data persistence** and historical analysis

This project showcases modern mobile development practices, including proper error handling, data validation, and a clean architecture pattern.

## Features

- **Real-time Sensor Monitoring**: Displays current thermal state, battery level, and memory usage
- **Native Platform Integration**: Uses Flutter MethodChannels to communicate with native Android/iOS code
- **Backend API**: RESTful API for logging and retrieving device vitals with analytics
- **Data Persistence**: Backend stores data persistently and survives restarts
- **Error Handling**: Graceful handling of network errors, platform exceptions, and invalid data
- **History & Analytics**: View historical logs and analytics including rolling averages

## Project Structure

```
device_vital_monitor/
├── lib/                    # Flutter application code
├── android/                # Android native implementation
├── ios/                    # iOS native implementation
├── backend/                # Backend API server (Node.js or .NET)
├── test/                   # Unit tests
├── README.md              # This file
├── DECISIONS.md           # Design decisions and ambiguity handling
└── ai_log.md              # AI collaboration log
```

## Prerequisites

### For Flutter App

- **Flutter SDK**: Version 3.10.4 or higher
  - Install from [flutter.dev](https://flutter.dev/docs/get-started/install)
  - Verify installation: `flutter doctor`
- **Dart SDK**: Included with Flutter
- **Android Studio** (for Android development)
  - Android SDK (API level 29+ recommended)
  - Android SDK Platform-Tools
- **Xcode** (for iOS development, macOS only)
  - Xcode 14.0 or higher
  - CocoaPods: `sudo gem install cocoapods`

### For Backend

**If using Node.js:**
- **Node.js**: Version 18.0 or higher
- **npm**: Included with Node.js

**If using .NET:**
- **.NET SDK**: Version 6.0 or higher
- Install from [dotnet.microsoft.com](https://dotnet.microsoft.com/download)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd device_vital_monitor
```

### 2. Backend Setup

#### Option A: Node.js Backend

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Configure the backend (if needed):
   - Update `backend/.env` or `backend/config.js` with your preferred port (default: 3000)
   - Database/storage location will be configured automatically

4. Start the backend server:
   ```bash
   npm start
   # Or for development with auto-reload:
   npm run dev
   ```

   The backend will start on `http://localhost:3000` (or your configured port).

#### Option B: .NET Backend

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Restore dependencies:
   ```bash
   dotnet restore
   ```

3. Build the project:
   ```bash
   dotnet build
   ```

4. Run the backend:
   ```bash
   dotnet run
   ```

   The backend will start on `http://localhost:5000` (or your configured port).

**Verify Backend is Running:**
- Open your browser and navigate to `http://localhost:3000/api/vitals` (Node.js) or `http://localhost:5000/api/vitals` (.NET)
- You should see an empty array `[]` or a JSON response

### 3. Flutter App Setup

1. Navigate back to the project root:
   ```bash
   cd ..
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Backend URL (if needed):
   - Open `lib/config/api_config.dart` (or similar config file)
   - Update the `baseUrl` to match your backend URL:
     ```dart
     static const String baseUrl = 'http://localhost:3000'; // Node.js
     // or
     static const String baseUrl = 'http://localhost:5000'; // .NET
     ```
   - **For Android Emulator**: Use `http://10.0.2.2:3000` instead of `localhost`
   - **For iOS Simulator**: Use `http://localhost:3000`
   - **For Physical Device**: Use your computer's local IP address (e.g., `http://192.168.1.100:3000`)

4. Verify Flutter setup:
   ```bash
   flutter doctor
   ```

### 4. Platform-Specific Setup

#### Android

1. Ensure Android SDK is properly configured
2. Create an Android Virtual Device (AVD) or connect a physical device:
   ```bash
   flutter emulators --launch <emulator_name>
   # Or list available emulators:
   flutter emulators
   ```

3. For physical devices, enable USB debugging:
   - Settings → About Phone → Tap "Build Number" 7 times
   - Settings → Developer Options → Enable "USB Debugging"

#### iOS (macOS only)

1. Install CocoaPods dependencies:
   ```bash
   cd ios
   pod install
   cd ..
   ```

2. Open the project in Xcode to configure signing:
   ```bash
   open ios/Runner.xcworkspace
   ```
   - Select your development team in Signing & Capabilities
   - Close Xcode

## Running the Application

### Start the Backend First

**Important**: Always start the backend server before running the Flutter app.

```bash
# In backend directory
npm start  # Node.js
# or
dotnet run  # .NET
```

Keep this terminal window open.

### Run the Flutter App

1. **List available devices:**
   ```bash
   flutter devices
   ```

2. **Run on a specific device:**
   ```bash
   # Android
   flutter run -d <device-id>
   
   # iOS
   flutter run -d <device-id>
   
   # Or let Flutter choose
   flutter run
   ```

3. **For hot reload**: Press `r` in the terminal where Flutter is running
4. **For hot restart**: Press `R` in the terminal

### Alternative: Using IDE

- **VS Code**: Press `F5` or use the Run/Debug panel
- **Android Studio**: Click the green "Run" button or press `Shift+F10`

## Platform Support

- ✅ **Android**: Fully implemented with MethodChannels
- ✅ **iOS**: Fully implemented with MethodChannels (or specify if only one is done)

*Note: Update this section based on which platform(s) you've implemented.*

## API Endpoints

The backend provides the following endpoints:

### POST /api/vitals
Log device vital data to the backend.

**Request Body:**
```json
{
  "device_id": "string",
  "timestamp": "2024-01-15T10:30:00Z",
  "thermal_value": 1,
  "battery_level": 85,
  "memory_usage": 45
}
```

**Response:** `201 Created` with the saved vital record

### GET /api/vitals
Retrieve the latest 100 historical logs.

**Response:**
```json
[
  {
    "id": 1,
    "device_id": "string",
    "timestamp": "2024-01-15T10:30:00Z",
    "thermal_value": 1,
    "battery_level": 85,
    "memory_usage": 45
  }
]
```

### GET /api/vitals/analytics
Get analytics data including rolling averages.

**Response:**
```json
{
  "rolling_average": {
    "thermal_value": 1.2,
    "battery_level": 78.5,
    "memory_usage": 52.3
  },
  "total_logs": 150,
  "time_range": {
    "from": "2024-01-15T08:00:00Z",
    "to": "2024-01-15T10:30:00Z"
  }
}
```

## Testing

### Run Unit Tests

```bash
# Flutter tests
flutter test

# Backend tests (Node.js)
cd backend
npm test

# Backend tests (.NET)
cd backend
dotnet test
```

### Test Coverage

- Backend: Rolling average calculation, data validation
- Flutter: Repository/Service layer logic

## Troubleshooting

### Backend Issues

**Problem**: Backend won't start
- **Solution**: Check if the port is already in use. Change the port in your backend configuration.

**Problem**: "Cannot connect to backend" error in Flutter app
- **Solution**: 
  - Ensure backend is running
  - Check the API URL in Flutter config matches your backend URL
  - For Android emulator, use `10.0.2.2` instead of `localhost`
  - For physical devices, ensure device and computer are on the same network

**Problem**: Data not persisting after restart
- **Solution**: Check that your database/storage file is being created in the correct location and not in a temporary directory.

### Flutter App Issues

**Problem**: "PlatformException" when reading sensors
- **Solution**: 
  - Ensure you're running on a physical device or emulator (not web)
  - Check that MethodChannels are properly implemented in native code
  - Verify platform permissions are set (battery access, etc.)

**Problem**: Build errors on Android
- **Solution**: 
  ```bash
  cd android
  ./gradlew clean
  cd ..
  flutter clean
  flutter pub get
  ```

**Problem**: Build errors on iOS
- **Solution**: 
  ```bash
  cd ios
  pod deintegrate
  pod install
  cd ..
  flutter clean
  flutter pub get
  ```

**Problem**: "No devices found"
- **Solution**: 
  - For Android: Start an emulator or connect a device with USB debugging enabled
  - For iOS: Start the iOS Simulator from Xcode or connect a physical device

### Network Issues

**Problem**: CORS errors (if testing backend in browser)
- **Solution**: Ensure CORS is properly configured in your backend to allow requests from your Flutter app origin.

## Architecture

### Flutter App
- **State Management**: [Provider/Riverpod/Bloc - specify which]
- **Architecture Pattern**: Repository pattern for data layer separation
- **Native Communication**: MethodChannels for platform-specific sensor access

### Backend
- **Tech Stack**: [Node.js/.NET - specify which]
- **Storage**: [SQLite/JSON file/LiteDB - specify which]
- **Architecture**: RESTful API with validation and persistence layer

## Data Validation

The backend validates all incoming data:

- **thermal_value**: Must be between 0-3 (inclusive)
- **battery_level**: Must be between 0-100 (inclusive)
- **memory_usage**: Must be between 0-100 (inclusive)
- **timestamp**: Must be a valid ISO8601 datetime and not in the future
- **device_id**: Required string field

Invalid data will be rejected with appropriate error messages.

## Error Handling

The application handles various error scenarios:

- **Network Errors**: Shows user-friendly error messages when backend is unreachable
- **Platform Exceptions**: Handles cases where native sensors are unavailable
- **Validation Errors**: Displays specific error messages for invalid data
- **Timeout Errors**: Gracefully handles network timeouts

## Additional Documentation

- **[DECISIONS.md](DECISIONS.md)**: Design decisions and how ambiguities were handled
- **[ai_log.md](ai_log.md)**: AI collaboration log and workflow

## Development Notes

### MethodChannel Implementation

The app uses Flutter MethodChannels to communicate with native code:

- **Channel Name**: `device_vital_monitor/sensors`
- **Methods**:
  - `getThermalState()`: Returns thermal state (0-3)
  - `getBatteryLevel()`: Returns battery percentage (0-100)
  - `getMemoryUsage()`: Returns memory usage percentage (0-100)

### Native Implementation Details

**Android (Kotlin)**:
- Uses `PowerManager.getCurrentThermalStatus()` for thermal state
- Uses `BatteryManager.BATTERY_PROPERTY_CAPACITY` for battery level
- Uses `ActivityManager.MemoryInfo` for memory usage

**iOS (Swift)**:
- Uses `ProcessInfo.processInfo.thermalState` for thermal state
- Uses `UIDevice.current.batteryLevel` for battery level
- Uses `mach_task_basic_info` for memory usage

## License

[Specify your license or "Private project for assessment purposes"]

## Contact

[Your contact information or repository maintainer]

---

**Note**: This project was created as a take-home assignment. For questions about implementation decisions, please refer to `DECISIONS.md`.
