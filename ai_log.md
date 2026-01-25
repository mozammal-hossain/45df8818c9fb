# AI Collaboration Log

This document tracks my use of AI tools (Claude, ChatGPT, Copilot) during the development of the Device Vital Monitor application.

---

## The Prompts

### Prompt 1: MethodChannel Implementation for Android Battery Sensors

**Prompt (verbatim):**
```
Generate a Flutter MethodChannel implementation to retrieve battery level from Android using Kotlin. The channel should be named 'device_vital_monitor/sensors' and the method should be 'getBatteryLevel'. Handle both modern API (BatteryManager.BATTERY_PROPERTY_CAPACITY) and legacy API (Intent.ACTION_BATTERY_CHANGED) for backward compatibility. Include proper error handling.
```

**Result:**
The AI generated a complete MainActivity.kt implementation with MethodChannel setup, including:
- MethodChannel configuration in `configureFlutterEngine`
- `getBatteryLevel()` method with API level checks
- Fallback to Intent-based approach for older Android versions
- Basic error handling structure

**My Changes:**
- Added additional battery methods (`getBatteryHealth`, `getChargerConnection`, `getBatteryStatus`) beyond the initial prompt
- Enhanced error handling with specific error codes and messages
- Added logging for debugging battery state transitions
- Improved null safety checks for the battery intent

**Why it works:**
The MethodChannel uses Flutter's binary messaging system to bridge Dart and native Kotlin code. The `setMethodCallHandler` receives method calls from Flutter, routes them based on `call.method`, and returns results via `result.success()` or `result.error()`. The battery level retrieval uses Android's BatteryManager API which provides real-time battery information through the system service.

---

### Prompt 2: Flutter Service Layer for Device Sensors

**Prompt (verbatim):**
```
Create a Flutter service class for DeviceSensorService that uses MethodChannel to call native Android methods. It should have a method getBatteryLevel() that returns Future<int?> and handles PlatformException and MissingPluginException gracefully by returning null.
```

**Result:**
The AI generated a clean service class with:
- Singleton pattern using private constructor
- Static MethodChannel instance
- `getBatteryLevel()` method with try-catch for exceptions
- Proper null handling

**My Changes:**
- Extended the service to include additional methods (battery health, charger connection, battery status)
- Added debug logging for PlatformException details
- Improved type safety by handling Object? return types and converting to String where needed
- Added comprehensive documentation comments

**Why it works:**
The service acts as an abstraction layer between the UI and native platform code. By catching `PlatformException` (when native code throws an error) and `MissingPluginException` (when the MethodChannel isn't registered), the service gracefully degrades and returns null, allowing the UI to handle the error state appropriately.

---

### Prompt 3: Theme Configuration with Dark Mode Support

**Prompt (verbatim):**
```
How do I implement dark and light theme support in Flutter using Material 3? I want to use ColorScheme.fromSeed() and allow users to toggle between light, dark, and system theme modes. Include state management approach.
```

**Result:**
The AI provided a comprehensive solution including:
- Light and dark ThemeData definitions using `ColorScheme.fromSeed()`
- ThemeMode state management using Provider
- SharedPreferences for persistence
- Theme toggle widget example

**My Changes:**
- Adapted the solution to use Riverpod instead of Provider (personal preference)
- Integrated theme toggle into the app bar instead of a separate settings screen
- Added theme persistence that loads on app startup
- Customized color schemes to use blue as seed color for brand consistency

**Why it works:**
Material 3's `ColorScheme.fromSeed()` generates a harmonious color palette from a single seed color, automatically adjusting for light and dark modes. The `ThemeMode` enum (light, dark, system) allows the MaterialApp to switch themes dynamically. State management ensures the theme preference persists across app restarts, and the system mode respects the device's theme setting.

---

## The Wins

### Win 1: MethodChannel Setup Accelerated Development

**Before:** I was manually researching Android BatteryManager API documentation, Flutter MethodChannel setup, and Kotlin syntax. This would have taken 2-3 hours of reading documentation and trial-and-error.

**After:** AI generated a working MethodChannel skeleton in minutes. I then spent 30 minutes refining it with additional methods and error handling.

**Time Saved:** ~2 hours

**Context:** The MethodChannel implementation is the core requirement of this assignment. Getting a working foundation quickly allowed me to focus on the business logic (sensor data aggregation, API integration) rather than platform-specific plumbing.

---

### Win 2: Theme Configuration Best Practices

**Before:** I would have implemented a basic light theme only, or spent significant time researching Material 3 theming patterns.

**After:** AI provided a complete solution following Material Design 3 best practices, including proper use of `ColorScheme.fromSeed()`, theme persistence, and state management integration.

**Time Saved:** ~1.5 hours

**Context:** While theme configuration wasn't explicitly required, it's a common user expectation. The AI solution included modern Flutter patterns I might not have known about, resulting in a more polished app.

---

## The Failures

### Failure: Incorrect Return Type in MethodChannel

**What happened:**
The AI initially generated the Flutter service method with this signature:
```dart
static Future<int> getBatteryLevel() async {
  final level = await _channel.invokeMethod<int>('getBatteryLevel');
  return level ?? 0;  // AI suggested defaulting to 0
}
```

**The Problem:**
When the native method failed or wasn't available, it would return 0, which is a valid battery level. This made it impossible to distinguish between "battery is actually at 0%" and "sensor reading failed."

**How I debugged it:**
1. Tested on an emulator where battery APIs might behave differently
2. Added logging and discovered that `PlatformException` was being thrown but caught silently
3. Realized that returning a sentinel value (0) was masking errors
4. Checked the Android native code and confirmed it could return -1 on error

**The Fix:**
Changed the return type to `Future<int?>` and return `null` on exceptions:
```dart
static Future<int?> getBatteryLevel() async {
  try {
    final level = await _channel.invokeMethod<int>('getBatteryLevel');
    return level;
  } on PlatformException catch (_) {
    return null;  // Explicitly null for error state
  } on MissingPluginException {
    return null;
  }
}
```

**Lesson Learned:**
AI sometimes suggests "safe defaults" that actually hide errors. For sensor data, it's better to use nullable types and let the UI handle the error state explicitly, rather than returning a value that could be mistaken for valid data.

---

## The Understanding

### Code Block: MethodChannel Handler in MainActivity.kt

Here's the AI-generated MethodChannel handler, explained line-by-line:

```kotlin
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
```

**Line 1:** Creates a MethodChannel instance. `flutterEngine.dartExecutor.binaryMessenger` is the communication bridge between Flutter and native code. `CHANNEL` is the string identifier ("device_vital_monitor/sensors") that must match on both Flutter and native sides. `setMethodCallHandler` registers a callback that will be invoked whenever Flutter calls a method on this channel.

```kotlin
    when (call.method) {
```

**Line 2:** `call.method` is a String containing the method name that Flutter invoked (e.g., "getBatteryLevel"). The `when` expression is Kotlin's switch statement, routing to different handlers based on the method name.

```kotlin
        "getBatteryLevel" -> {
            try {
                val batteryLevel = getBatteryLevel()
                result.success(batteryLevel)
```

**Lines 3-5:** If the method is "getBatteryLevel", we call our native `getBatteryLevel()` function (which uses Android's BatteryManager). `result.success()` sends the value back to Flutter as a successful response. The value is automatically serialized across the platform boundary.

```kotlin
            } catch (e: Exception) {
                result.error("BATTERY_ERROR", "Failed to get battery level: ${e.message}", null)
            }
```

**Lines 6-7:** If an exception occurs (e.g., BatteryManager service unavailable), we call `result.error()` with an error code, message, and optional details. This causes Flutter to throw a `PlatformException` that can be caught in the Dart code.

```kotlin
        else -> {
            result.notImplemented()
        }
```

**Lines 8-10:** If the method name doesn't match any handler, we call `result.notImplemented()`, which tells Flutter that this method isn't supported. This is important for graceful degradation when adding new methods incrementally.

**Overall Flow:**
1. Flutter calls `_channel.invokeMethod('getBatteryLevel')`
2. The binary messenger serializes the call and sends it to native code
3. This handler receives the call, executes the native method
4. The result (success or error) is serialized back to Flutter
5. Flutter's Future completes with the value or throws PlatformException

This pattern allows Flutter apps to access platform-specific APIs that aren't available through standard Flutter packages, which was a core requirement of this assignment.
