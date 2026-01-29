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

- Adapted the solution to use Bloc (ThemeBloc) instead of Provider/Riverpod for consistency with the rest of the app
- Theme and locale controls live on a dedicated Settings screen (ThemeSelector, LanguageSelector), with persistence via PreferencesRepository / SharedPreferences
- Added theme and locale persistence that loads on app startup
- Customized color schemes (e.g. seed color) in core theme

**Implementation note (later evolution):** The app now uses clean architecture (core/data/domain/presentation), Bloc for all UI state (theme, locale, dashboard, history), and get_it + injectable for dependency injection. Theme and locale are persisted via PreferencesRepository; the Settings screen hosts both theme and language pickers (en, es, bn). No additional AI prompts were used for this refactor.

---

### Prompt 4: Localization (Internationalization)

**Context:** Implemented app-wide localization so the UI can be shown in
multiple languages (English and Spanish initially).

**Approach:**

- Added `flutter_localizations` (SDK) and `intl` to `pubspec.yaml`, and
  `flutter.generate: true` for `gen-l10n`
- Created `lib/l10n/app_en.arb` (template) and `lib/l10n/app_es.arb` with all
  user-facing strings (app title, thermal/battery/memory labels, status text,
  units, etc.)
- Ran `flutter gen-l10n` to generate `AppLocalizations` and per-locale classes
  in `lib/l10n/`
- Wired `MaterialApp` with `localizationsDelegates` and `supportedLocales`
- Replaced hardcoded strings in `main.dart` and `DashboardScreen` with
  `AppLocalizations.of(context)!` and passed `l10n` into helpers
  (`_formatBatteryHealth`, `_getThermalStateLabel`, `_formatBytes`, etc.)
- Added `l10n.yaml` with `arb-dir: lib/l10n` and `template-arb-file: app_en.arb`
- Updated tests: `widget_test` now pumps `MyApp(initialThemeMode: ThemeMode.system)`
  with a mocked sensor channel and asserts on "Device Vital Monitor";
  `dashboard_screen_memory_test` uses a `_localizedMaterialApp()` helper that
  wraps `MaterialApp` with `localizationsDelegates`, `supportedLocales`,
  `ThemeProviderScope`/`ThemeProvider`, and `locale: Locale('en')` so
  `AppLocalizations` and theme toggle work in tests

**Why it works:**
Flutter’s `gen-l10n` tool generates type-safe `AppLocalizations` from ARB
files. `localizationsDelegates` (including `AppLocalizations.delegate`) provide
translations to the widget tree; `supportedLocales` defines available locales.
The app uses the device locale when supported, otherwise falls back to English.

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

---

## Android ADPF Thermal API – Alignment and Gaps

**Context:** The [Android ADPF Thermal API](https://developer.android.com/games/optimize/adpf/thermal) doc describes how to monitor device thermal state so apps (e.g. games) can avoid throttling by reducing workload in time. The question is whether this behavior is **maintained** in the Device Vital Monitor Flutter app.

### What the app does today

- **Android (MainActivity.kt):** Uses `PowerManager.getCurrentThermalStatus()` on API 30+ and maps `THERMAL_STATUS_*` to 0–3. There is an explicit comment referencing the thermal doc. On API &lt; 30 the app returns `0` (NONE) and does not call any other thermal API.
- **Flutter:** `DeviceSensorService.getThermalState()` calls the `getThermalState` method channel; the dashboard requests it when the user refreshes or when sensor data is first loaded. There is no special throttling or caching for thermal reads.

### What the ADPF thermal doc recommends

| Capability                       | Doc                                                                                                                                                                                                                         | In this app                                                 |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| **getCurrentThermalStatus()**    | Use for a simple status (NONE / LIGHT / MODERATE / SEVERE / …).                                                                                                                                                             | ✅ Used on API 30+ and mapped to 0–3.                       |
| **getThermalHeadroom(seconds)**  | Forecast thermal headroom in X seconds (0.0–1.0). Do **not** call more than once per 10 seconds; otherwise returns NaN.                                                                                                     | ❌ Not used.                                                |
| **ThermalStatusChangedListener** | Register for status changes instead of polling.                                                                                                                                                                             | ❌ Not used.                                                |
| **Device-limitation heuristics** | If `getThermalHeadroom()` is NaN/0 on first call, treat API as unsupported. If status is always NONE but headroom is high, use headroom-based heuristics (e.g. &gt; 1.0 → severe, &gt; 0.95 → moderate, &gt; 0.85 → light). | ❌ Not implemented.                                         |
| **Fallback for “older” APIs**    | Brief asks for `getCurrentThermalStatus()` (API 29+) or `getThermalHeadroom()` for older versions; ADPF describes headroom as the main forecasting tool on supported devices.                                               | ❌ No headroom path; below API 30 the app always returns 0. |

### Conclusion

- **Thermal _status_ is maintained** in the sense that the app uses the same API and mapping as the ADPF thermal doc: `getCurrentThermalStatus()` and the 0–3 scale (NONE/LIGHT/MODERATE/SEVERE).
- **The full “thermal testing” behavior from the doc is not maintained:** there is no use of `getThermalHeadroom()`, no thermal status listener, no 10‑second headroom polling discipline, and no device-limitation heuristics. The app also does not implement the brief’s “or getThermalHeadroom() for older versions” path.

### Recommendations (if aligning further with ADPF)

1. **Optional headroom path (API 30+):** Add a method channel method that calls `PowerManager.getThermalHeadroom(10)` (or similar). In Dart, throttle calls to at most once every 10 seconds and handle NaN as “unsupported.” This supports “forecast in X seconds” and devices where status lags.
2. **Heuristics when status is always NONE:** Where headroom is supported, if `getCurrentThermalStatus()` stays NONE but `getThermalHeadroom()` is high (e.g. &gt; 0.85), use the doc’s heuristics to derive a synthetic severity for display or logging.
3. **Leave listener as future work:** `OnThermalStatusChangedListener` is useful to avoid polling; it could be added later if the app needs to react immediately to thermal changes without waiting for a refresh.

For the current assignment scope (display thermal state 0–3 and log it to the backend), the existing use of `getCurrentThermalStatus()` is sufficient and matches the doc’s status semantics. The gaps above matter if the product goal shifts toward “thermal testing” or proactive thermal-aware behavior as described in the full ADPF thermal page.

### Implementation of “Missing from the app” (per candidate brief)

The following were implemented so the app aligns with the ADPF thermal doc and the candidate_project_brief.md (“Use `getCurrentThermalStatus()` (API 29+) or `getThermalHeadroom()` for older versions”, “Handle devices that don't support these APIs”):

1. **getThermalHeadroom(forecastSeconds)**
   - **Android:** New method-channel call `getThermalHeadroom` invokes `PowerManager.getThermalHeadroom(forecastSeconds)` on API 30+. A 10‑second throttle is enforced (ADPF: calling more than once per 10s returns NaN). NaN and invalid values are treated as “unsupported” and not surfaced as valid headroom.
   - **Flutter:** `DeviceSensorService.getThermalHeadroom({int forecastSeconds = 10})` returns `Future<double?>`. Used for heuristics and optional UI/telemetry.

2. **Device-limitation heuristics in getThermalState()**
   - On API 29+, `getCurrentThermalStatus()` is used first.
   - When status is `THERMAL_STATUS_NONE` and API ≥ 30, `getThermalHeadroom(10)` is used (subject to the 10s throttle). If headroom &gt; 1.0 → 3, &gt; 0.95 → 2, &gt; 0.85 → 1; otherwise 0.
   - Covers devices that keep reporting NONE even when headroom indicates throttling.

3. **ThermalStatusChangedListener + EventChannel**
   - **Android:** `PowerManager.addThermalStatusListener(mainExecutor, listener)` is registered when the Flutter side listens to the thermal event stream. The listener maps status to 0–3 and sends it over `EventChannel("device_vital_monitor/thermal_events")`. The listener is removed in `onCancel`.
   - **Flutter:** `DeviceSensorService.thermalStatusChangeStream` returns a broadcast stream of `int?` (0–3). Errors (e.g. no native handler on iOS/tests) are handled so the stream does not break the app.

4. **Dashboard reaction to thermal changes**
   - `DashboardBloc` subscribes to `thermalStatusChangeStream` and handles `DashboardThermalStatusChanged(thermalState)`, updating `state.thermalState` so the UI reflects thermal changes without a manual refresh. The subscription is cancelled in `close()`.

5. **API level behavior**
   - **API 29 (Q):** `getCurrentThermalStatus()` only (no headroom; headroom is API 30+).
   - **API 30+ (R):** Status + headroom heuristics when status is NONE, plus optional `getThermalHeadroom` and thermal event stream.
   - **API &lt; 29:** Thermal state remains 0 (NONE); no thermal APIs on stock Android.

Tests were updated so `DashboardBloc` is constructed with the three required dependencies (`DeviceSensorService`, `VitalsRepository`, `DeviceIdService`), including `SharedPreferences.setMockInitialValues` and a shared `DashboardBloc` in `setUpAll` for the dashboard screen memory tests.

---

## Backend Rate Limiter

**Context:** Introduced rate limiting on the device_vital_monitor_backend API to protect against abuse and ensure fair usage across clients.

**Approach:**

- Used ASP.NET Core’s built-in rate limiting (no extra package). In `Program.cs`: `AddRateLimiter` with a custom policy that partitions by client IP via `RateLimitPartition.GetFixedWindowLimiter(clientIp, ...)`.
- Default: 100 requests per 60 seconds per IP. Values are configurable in `appsettings.json` under `RateLimiting:PermitLimit` and `RateLimiting:WindowSeconds`.
- All API routes use the policy via `RequireRateLimiting("api")`. When the limit is exceeded, the middleware returns **429 Too Many Requests** with a JSON body matching the existing `ErrorResponse` shape (`error`, `field`, `code`), with `code: "RATE_LIMIT_EXCEEDED"`.
- Pipeline order: `UseRateLimiter()` is registered after CORS and before `UseAuthorization()` so rate limiting runs after logging and CORS.

**Why it works:** Each client IP gets its own fixed window; when the window resets, the counter replenishes. The Flutter app can treat 429 like other API errors and show a user-friendly “too many requests” message. Design and assumptions are recorded in **DECISIONS.md** (Ambiguity 6: Rate Limiting).
