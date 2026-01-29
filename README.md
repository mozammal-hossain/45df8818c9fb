# Device Vital Monitor

A **Flutter** app that monitors device sensor data (thermal state, battery level, memory usage), logs it to a **.NET backend API**, and displays history plus analytics. Built as a full-stack take-home: Flutter UI, **native platform integration via MethodChannels** (no third‑party sensor plugins), and a persistent backend with validation and rolling averages.

---

## Overview

- **Mobile app**: Dashboard (live sensor readings, “Log Status” button), History (vital logs + analytics), Settings (theme, language). Sensor data is read through **Flutter MethodChannels** from **native Android (Kotlin)** and **iOS (Swift)** code only.
- **Backend**: REST API that accepts vital logs, validates them, stores persistently in **SQLite**, and exposes history plus **rolling-average analytics** over the latest 100 logs.
- **Tests**: Backend unit tests (rolling average, validation, paging) and Flutter tests (repository/platform layer, dashboard, widget smoke).

---

## Tech Stack

| Layer       | Choices                                                                        |
| ----------- | ------------------------------------------------------------------------------ |
| **Backend** | .NET 10, ASP.NET Core, Entity Framework Core, SQLite                           |
| **Mobile**  | Flutter 3.10+, Dart 3.10+, Bloc, get_it + injectable, Clean Architecture       |
| **Native**  | Android: Kotlin; iOS: Swift. MethodChannels only—no `battery_plus` or similar. |

---

## Platform Support

| Platform    | Status                                                                                                                                       |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **Android** | ✅ Implemented. MethodChannel `device_vital_monitor/sensors`; thermal (API 29+), battery, memory. Optional EventChannel for thermal updates. |
| **iOS**     | ✅ Implemented. Same MethodChannel; `ProcessInfo.thermalState`, `UIDevice.batteryLevel`, `mach_task_basic_info` for memory.                  |

---

## Prerequisites

- **.NET SDK 10** – [Download](https://dotnet.microsoft.com/download)
- **Flutter SDK** (3.10+) – [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Android**: SDK with API 29+ (for thermal APIs)
- **iOS**: Xcode + CocoaPods (for simulator/device)

---

## Setup and Run

### 1. Backend

From the **repository root**:

```bash
cd device_vital_monitor_backend
dotnet restore
dotnet build
dotnet run
```

- Listens on **http://localhost:5265** (HTTP profile in `launchSettings.json`).
- SQLite DB: `device_vital_monitor_backend/app.db` (created on first run).
- Data **persists across restarts**.

### 2. Flutter app

```bash
cd device_vital_monitor_flutter_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # if you change injectable DI
flutter run
```

- **Android emulator**: app uses `http://10.0.2.2:5265` as the API base URL.
- **iOS simulator / macOS**: app uses `http://localhost:5265`.
- Use a device or emulator; sensor data comes from the native side.

### 3. Run tests

**Backend:**

```bash
cd device_vital_monitor_backend.Tests
dotnet test
```

**Flutter:**

```bash
cd device_vital_monitor_flutter_app
flutter test
```

---

## API Endpoints

| Method | Path                    | Description                                                                                                                             |
| ------ | ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `POST` | `/api/vitals`           | Log a vital snapshot. Body: `device_id`, `timestamp` (ISO8601), `thermal_value` (0–3), `battery_level` (0–100), `memory_usage` (0–100). |
| `GET`  | `/api/vitals`           | Paginated history. Query: `page` (default 1), `pageSize` (default 20, max 100).                                                         |
| `GET`  | `/api/vitals/analytics` | Analytics: rolling averages (last 100 logs), min/max, trends, total log count.                                                          |

**Validation (all enforced):**

- `thermal_value` ∈ [0, 3]
- `battery_level` ∈ [0, 100]
- `memory_usage` ∈ [0, 100]
- `timestamp` not in the future (up to 5 min clock skew allowed)
- Required fields present; invalid requests return `400` with `ErrorResponse` body.

---

## Project Structure

```
├── device_vital_monitor_backend/        # .NET API
│   ├── Controllers/                     # VitalsController
│   ├── Data/                            # VitalContext, SQLite
│   ├── DTOs/                            # VitalLogRequest, AnalyticsResult, etc.
│   ├── Models/                          # DeviceVital
│   ├── Repositories/                    # DeviceVitalRepository
│   ├── Services/                        # VitalService (rolling average, etc.)
│   └── Program.cs
│
├── device_vital_monitor_backend.Tests/  # xUnit
│   ├── VitalServiceTests.cs             # Rolling average, paging, persistence
│   └── VitalsControllerTests.cs         # Validation (thermal, battery, memory, timestamp)
│
├── device_vital_monitor_flutter_app/    # Flutter app
│   ├── lib/
│   │   ├── core/                        # config, di, error, platform, theme
│   │   ├── data/                        # datasources (remote, platform, local), mappers, repositories
│   │   ├── domain/                      # entities, repositories, use cases
│   │   ├── l10n/                        # ARB + generated localizations
│   │   └── presentation/                # Bloc, dashboard, history, settings, shell
│   ├── android/.../MainActivity.kt      # MethodChannel handlers (thermal, battery, memory)
│   ├── ios/Runner/AppDelegate.swift     # MethodChannel handlers
│   └── test/                            # widget, service, dashboard tests
│
├── DECISIONS.md                         # Ambiguities, design decisions, assumptions
├── ai_log.md                            # AI collaboration (prompts, wins, failures)
└── README.md                            # This file
```

---

## Native Implementation (MethodChannels)

- **Channel**: `device_vital_monitor/sensors`
- **Methods**: `getThermalState`, `getBatteryLevel`, `getMemoryUsage` (plus optional `getThermalHeadroom`, battery health/status on Android).
- **Android**: `PowerManager.getCurrentThermalStatus()` (API 29+), `BatteryManager.BATTERY_PROPERTY_CAPACITY`, `ActivityManager.MemoryInfo`.
- **iOS**: `ProcessInfo.processInfo.thermalState`, `UIDevice.current.batteryLevel`, `mach_task_basic_info` for memory.

No third‑party packages are used for sensor data.

---

## Error Handling

- **Backend unreachable / timeouts**: Snackbar in app; History shows an error state.
- **PlatformException / MissingPluginException**: Caught in platform datasource; UI shows “—” or similar for unavailable sensors.
- **Validation / 4xx from API**: Error message from server shown in Snackbar when logging fails.

---

## Documentation

- **[DECISIONS.md](./DECISIONS.md)** – Ambiguities, options considered, decisions, trade-offs, assumptions.
- **[ai_log.md](./ai_log.md)** – AI usage (prompts, wins, failures, line‑by‑line explanation of chosen code).

---

## Quick Reference

| Task            | Command                                                |
| --------------- | ------------------------------------------------------ |
| Run backend     | `cd device_vital_monitor_backend && dotnet run`        |
| Run Flutter app | `cd device_vital_monitor_flutter_app && flutter run`   |
| Backend tests   | `cd device_vital_monitor_backend.Tests && dotnet test` |
| Flutter tests   | `cd device_vital_monitor_flutter_app && flutter test`  |

Ensure the backend is running on **http://localhost:5265** before using the app’s “Log Status” or History screen.

---

## Troubleshooting

- **Port 5265 in use:** Run with `dotnet run --urls "http://localhost:5000"` and set the app's API base URL accordingly (or change the port in `Properties/launchSettings.json`).
- **Android emulator:** Use `http://10.0.2.2:5265` (default). **iOS simulator:** Use `http://localhost:5265`.
- **Database:** SQLite file is `device_vital_monitor_backend/app.db`. Delete it and restart the backend to reset data.
