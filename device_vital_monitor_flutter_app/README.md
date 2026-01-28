# Device Vital Monitor – Flutter App

A Flutter application that monitors device vitals (thermal state, battery, memory, disk) in real time, logs snapshots to a backend API, and displays history and analytics. It uses **MethodChannels** for native Android/iOS sensor access (no third‑party sensor plugins) and follows **Clean Architecture** with **Bloc** for state and **get_it + injectable** for dependency injection.

---

## App functionality overview

### What the app does

- **Dashboard**: Shows live thermal state, battery level/health/charger/status, memory usage, and disk space. Pull-to-refresh updates readings. A “Log Status Snapshot” button sends the current vitals to the backend.
- **History**: Loads the latest vital logs from the API and shows analytics (rolling averages, total logs). Supports pull-to-refresh.
- **Settings**: App language (Bangla / English), theme (Light / Dark / System), and app version/build.

All sensor data is read via a single **MethodChannel** (`device_vital_monitor/sensors`) from native Android or iOS code. The app talks to a .NET backend (default `http://10.0.2.2:5265` on Android, `http://localhost:5265` on iOS/macOS).

---

## Screens and user flows

### 1. Dashboard (home)

- **Entry**: App starts on the dashboard. Sensor data is fetched once on load; thermal updates can also arrive via an **EventChannel** (`device_vital_monitor/thermal_events`) on Android.
- **Navigation**: Drawer for Dashboard / History / Settings. App bar: theme cycle (light ↔ dark ↔ system), overflow menu.
- **Content**:
  - **Thermal state**  
    Numeric 0–3 and label (NONE / LIGHT / MODERATE / SEVERE). Optional thermal headroom (Android). Shimmer while loading.
  - **Battery**  
    Level %, health (Good, Overheat, etc.), charger (AC/USB/Wireless/None), status (Charging/Discharging/Full/Not charging). Shimmer while loading.
  - **Memory usage**  
    Percentage and qualitative label (Optimized / Normal / Moderate / High / Critical). Shimmer while loading.
  - **Disk space**  
    Used / available (formatted), usage %. Shimmer while loading.
- **Actions**:
  - Pull-to-refresh: re-fetches all sensor data.
  - “Log Status Snapshot”: builds a `VitalLogRequest` (device_id, timestamp, thermal_value, battery_level, memory_usage), POSTs to `/api/vitals`, shows Snackbar on success or error. Button shows loading state while submitting.
- **Feedback**: Success/error Snackbars for log action; loading/shimmer for sensor cards.

### 2. History

- **Entry**: From drawer → “History”. Pushing the route creates a `HistoryBloc` and dispatches `HistoryRequested`.
- **Data**: Fetches in parallel:
  - `GET /api/vitals` → list of `VitalLog` (latest 100),
  - `GET /api/vitals/analytics` → `AnalyticsResult` (rolling-window averages, total logs).
- **UI**:
  - **Analytics card** (if available): average thermal, average battery %, average memory %, total logs, “logs in window”.
  - **List**: One tile per log with formatted time and “Thermal · Battery · Memory”.
- **States**: Loading spinner; empty state message when no logs; error Snackbar and message when the backend is unreachable or request fails. Pull-to-refresh re-dispatches `HistoryRequested`.

### 3. Settings

- **Entry**: From drawer → “Settings”.
- **Sections**:
  - **Branding**: App title, short subtitle, icon.
  - **Language**: Bangla / English. Choice is stored and applied via `LocaleBloc` and `supportedLocales` / `locale` in `MaterialApp`.
  - **Theme**: Light / Dark / System. Choice is stored and applied via `ThemeBloc` and `themeMode` in `MaterialApp`.
  - **Footer**: “DEVICE VITAL MONITOR”, version and build (e.g. “Version 1.0.0 (Build 1)”).

Theme and locale are persisted (e.g. `SharedPreferences`) and restored on next launch.

---

## Architecture and layers

The app uses **Clean Architecture**: **domain** (entities, repository interfaces, use cases), **data** (datasources, models, mappers, repository implementations), and **presentation** (Bloc, screens, widgets). Dependency direction: presentation → domain ← data.

### State management (Bloc)

- **DashboardBloc**: Sealed states — `DashboardInitial`, `DashboardLoading`, `DashboardLoaded(sensorData, logStatus, logStatusMessage)`, `DashboardError(message, lastKnownData)`. Uses `GetSensorDataUsecase` (returns `Result<SensorData>`), `LogVitalSnapshotUsecase`, and `DeviceRepository.thermalStatusChangeStream`. Handles `DashboardSensorDataRequested`, `DashboardLogStatusRequested`, `DashboardThermalStatusChanged`.
- **HistoryBloc**: Log list, analytics, loading/failure. Handles `HistoryRequested`; uses `GetHistoryUsecase` and `GetAnalyticsUsecase`.
- **ThemeBloc**: `ThemeMode` (light/dark/system), persisted via `PreferencesRepository`.
- **LocaleBloc**: `Locale?` (e.g. `bn`, `en`), persisted via `PreferencesRepository`.

Blocs are provided at app or screen level. Dependency injection uses **get_it** + **injectable** (`configureDependencies()` in `main.dart`).

### Domain and data

- **Repositories** (interfaces in `domain/repositories/`, implementations in `data/repositories/`):
  - **VitalsRepository**: `logVital(...)`, `getHistoryPage(...)` → `PagedResult<VitalLog>`, `getAnalytics()` → `AnalyticsResult`. Implemented with `VitalsRemoteDatasource` (Dio, base URL from `ApiConfig`).
  - **DeviceRepository**: `getDeviceInfo()`, `getSensorData()` → `SensorData`, `thermalStatusChangeStream`. Implemented with `DeviceIdLocalDatasource` and `SensorPlatformDatasource`.
  - **PreferencesRepository**: theme/locale persistence (e.g. SharedPreferences).
- **Use cases** (`domain/usecases/`): `GetSensorDataUsecase` (returns `Result<SensorData>`), `LogVitalSnapshotUsecase`, `GetHistoryUsecase`, `GetAnalyticsUsecase`.
- **Mappers** (`data/mappers/`): e.g. `VitalLogResponse.toDomain()`, `AnalyticsResponse.toDomain()`; repositories use these to map API models to domain entities.
- **Error/result**: `core/error/result.dart` defines sealed `Result<T>` (`Success<T>`, `Error<T>`); failures include `PlatformFailure`, `UnexpectedFailure`, `ServerFailure`, `NetworkFailure`.

### Native integration (MethodChannel)

- **Channels** (`core/platform/method_channels.dart`): `MethodChannels.sensors` = `device_vital_monitor/sensors`; `MethodChannels.thermalEvents` = `device_vital_monitor/thermal_events`.
- **Method names** (`SensorMethods`): `getThermalState`, `getThermalHeadroom`, `getBatteryLevel`, `getBatteryHealth`, `getChargerConnection`, `getBatteryStatus`, `getMemoryUsage`, `getStorageInfo`. Platform returns values or null when unsupported.
- **EventChannel**: `device_vital_monitor/thermal_events` (Android) streams thermal changes; `DashboardBloc` subscribes via `DeviceRepository.thermalStatusChangeStream`.

Device id for log requests comes from `DeviceIdLocalDatasource` (e.g. persistent store or UUID).

### Domain entities and data models

- **Entities** (`domain/entities/`): `VitalLog`, `AnalyticsResult`, `SensorData`, `StorageInfo`, `DeviceInfo`.
- **Request/response** (`data/models/`): `VitalLogRequest`, `VitalLogResponse`, `AnalyticsResponse`, local `StorageInfo`; mappers convert to/from domain.

### Configuration

- **ApiConfig**: `baseUrl` (defaults: Android `http://10.0.2.2:5265`, else `http://localhost:5265`), `vitalsPath` → `/api/vitals`, `vitalsAnalyticsPath` → `/api/vitals/analytics`.

---

## Localization (l10n)

- **Mechanism**: Flutter `gen-l10n` from ARB files (`app_en.arb`, `app_bn.arb`, etc.).
- **Scope**: All user-visible strings (dashboard labels, thermal/battery/memory/disk copy, history, settings, theme/language options, errors, etc.).
- **Locales**: English (en), Bangla (bn), and any others defined in ARB + `supportedLocales`.

---

## Theming

- **AppTheme**: Light and dark themes (e.g. `ColorScheme.fromSeed`), set via `MaterialApp.theme` / `darkTheme` / `themeMode`.
- **ThemeBloc** drives `themeMode` and persistence; Settings and app bar allow switching.

---

## Error handling

- **Sensor load failures**: `GetSensorDataUsecase` returns `Result<SensorData>`; on `PlatformException` or other errors it returns `Error(PlatformFailure(...))` or `Error(UnexpectedFailure(...))`. `DashboardBloc` emits `DashboardError(message)` and shows an error Snackbar.
- **Backend unreachable / timeouts**: `VitalsRepository` throws `VitalsRepositoryException` on log or history/analytics calls; Dashboard shows log-failure Snackbar; History shows Snackbar and optional full-screen message.
- **Platform sensor errors**: `SensorPlatformDatasource` catches `PlatformException` / `MissingPluginException` and returns `null` per method; `DeviceRepository` still returns a `SensorData` with nullable fields, so UI can show “—” or equivalent without crashing.
- **Validation/HTTP errors from API**: Message from server is shown in Snackbar when logging fails.

---

## Project structure

```
lib/
├── main.dart                     # Bloc setup, MultiBlocProvider, MaterialApp
├── core/
│   ├── config/                   # ApiConfig, AppConfig, logger
│   ├── di/                       # get_it + injectable (injection.dart, injection.config.dart)
│   ├── error/                    # exceptions, failures, Result<T>
│   ├── platform/                 # MethodChannels, SensorMethods, platform_dispatcher
│   ├── theme/                    # AppTheme, app_colors, text_styles
│   └── utils/                    # constants, extensions, logger
│       └── formatters/           # battery, memory, storage formatters, status_colors
├── data/
│   ├── datasources/
│   │   ├── local/                # device_id, preferences
│   │   ├── platform/             # sensor_platform_datasource (MethodChannel)
│   │   └── remote/               # vitals_remote_datasource (Dio)
│   ├── mappers/                  # vital_log_mapper, analytics_mapper
│   ├── models/                   # request/, response/, local/ (VitalLogRequest, etc.)
│   └── repositories/             # vitals, device, preferences implementations
├── domain/
│   ├── entities/                 # VitalLog, SensorData, AnalyticsResult, StorageInfo, DeviceInfo
│   ├── repositories/             # VitalsRepository, DeviceRepository, PreferencesRepository
│   └── usecases/                 # get_sensor_data, log_vital_snapshot, get_history, get_analytics
├── l10n/                         # ARB files + generated AppLocalizations
└── presentation/
    ├── bloc/
    │   ├── common/               # AppBlocObserver
    │   ├── dashboard/            # DashboardBloc, events, sealed state
    │   ├── history/              # HistoryBloc, events, state
    │   └── settings/
    │       ├── locale/           # LocaleBloc
    │       └── theme/            # ThemeBloc
    ├── screens/
    │   ├── dashboard/            # DashboardScreen + widgets (thermal, battery, memory, disk, log button)
    │   ├── history/              # HistoryScreen + widgets (analytics_card, vital_log_item)
    │   └── settings/             # SettingsScreen + language_selector, theme_selector
    └── widgets/
        ├── cards/                # VitalCard
        └── common/               # AppDrawer, LoadingShimmer, ErrorView, EmptyState
```

---

## Setup and run

### Prerequisites

- Flutter SDK (e.g. 3.10+), Android SDK (API 29+ for thermal APIs), Xcode/CocoaPods for iOS.
- Backend: .NET backend in repo root (e.g. `device_vital_monitor_backend`) listening on port **5265**.

### Steps

1. **Backend**  
   From repo root, run the .NET backend so it serves `http://localhost:5265` (and is reachable as `http://10.0.2.2:5265` from Android emulator).

2. **Flutter app**  
   From `device_vital_monitor_flutter_app/`:
   - `flutter pub get`
   - `dart run build_runner build` (if you change injectable registrations)
   - `flutter run` (or run on a chosen device/emulator)

3. **API base URL**  
   To point at another host/port, provide a custom `baseUrl` where `ApiConfig` is constructed (or inject a config that overrides the default).

---

## Tests

- **Flutter**: Tests under `test/` include `widget_test.dart` (app smoke), `screens/dashboard_screen_memory_test.dart` (dashboard/memory display, using `ensureDashboardLoaded` to wait for sealed dashboard state), and `services/device_sensor_service_test.dart` (platform datasource). Run with `flutter test`.
- **Backend**: See the backend project for validation and rolling-average tests.

---

## Platform support

- **Android**: Implemented via MethodChannel (and thermal EventChannel) in the Android project.
- **iOS**: Implemented via MethodChannel in the iOS project where applicable; thermal events may be no-op.

For detailed design choices, ambiguities, and trade-offs, see the repository’s **DECISIONS.md**.
