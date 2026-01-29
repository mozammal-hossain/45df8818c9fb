# Device Vital Monitor Backend

A .NET Core Web API backend for the Device Vital Monitor application. This backend receives device sensor data (thermal state, battery level, memory usage) and provides analytics including rolling averages.

## Quick Start

### Prerequisites

- **.NET SDK 10.0** or higher ([Download](https://dotnet.microsoft.com/download))
- SQLite (included with .NET, no separate installation needed)

### Installation

1. **Restore dependencies:**

   ```bash
   dotnet restore
   ```

2. **Build the project:**

   ```bash
   dotnet build
   ```

3. **Run the backend:**

   ```bash
   dotnet run
   ```

   The backend will start and listen on:
   - HTTP: `http://localhost:5265` (or the port specified in `Properties/launchSettings.json`)
   - HTTPS: `https://localhost:5266` (if configured)

### Database Setup

The backend uses **SQLite** for persistent storage. The database file (`app.db`) is automatically created in the backend directory when you first run the application.

- **Database Location**: `device_vital_monitor_backend/app.db`
- **Connection String**: Configured in `appsettings.json` as `Data Source=app.db`
- **Auto-creation**: The database and tables are automatically created on first run via `context.Database.EnsureCreated()` in `Program.cs`

## Architecture

The backend follows a clean architecture pattern with clear separation of concerns:

```
Controllers/
  └── VitalsController.cs      # API endpoints, request validation
Services/
  └── VitalService.cs            # Business logic (analytics, rolling averages)
Repositories/
  └── DeviceVitalRepository.cs  # Data access layer
Models/
  └── DeviceVital.cs            # Domain entity
DTOs/
  ├── VitalLogRequest.cs        # Request DTO
  ├── PagedResponse.cs          # Pagination response wrapper
  ├── AnalyticsResult.cs        # Analytics response DTO
  └── ErrorResponse.cs          # Standardized error response
Data/
  └── VitalContext.cs            # Entity Framework DbContext
```

### Key Components

- **VitalsController**: Handles HTTP requests, validates input, returns responses
- **VitalService**: Implements business logic including rolling average calculations
- **DeviceVitalRepository**: Provides data access abstraction using Entity Framework Core
- **VitalContext**: Manages database connections and entity mappings

## API Endpoints

### POST /api/vitals

Log device vital data.

**Request Body:**

```json
{
  "device_id": "string",
  "timestamp": "2024-01-15T10:30:00Z",
  "thermal_value": 1,
  "battery_level": 75.5,
  "memory_usage": 60.0
}
```

**Validation Rules:**

- `device_id`: Required, non-empty string
- `timestamp`: Required, ISO8601 **UTC** (e.g. `...Z`); cannot be more than 5 minutes in the future. All API timestamps are in UTC.
- `thermal_value`: Required, integer between 0 and 3 (inclusive)
- `battery_level`: Required, number between 0 and 100 (inclusive)
- `memory_usage`: Required, number between 0 and 100 (inclusive)

**Success Response (201 Created):**

```json
{
  "id": 1,
  "deviceId": "device-1",
  "timestamp": "2024-01-15T10:30:00Z",
  "thermalValue": 1,
  "batteryLevel": 75.5,
  "memoryUsage": 60.0
}
```

**Error Response (400 Bad Request):**

```json
{
  "error": "Thermal value must be between 0 and 3.",
  "field": "thermal_value",
  "code": "INVALID_RANGE"
}
```

### GET /api/vitals

Get historical logs with pagination.

**Query Parameters:**

- `page` (optional): Page number, default: 1
- `pageSize` (optional): Items per page, default: 20, maximum: 100

**Example Request:**

```
GET /api/vitals?page=1&pageSize=20
```

**Success Response (200 OK):**

```json
{
  "data": [
    {
      "id": 1,
      "deviceId": "device-1",
      "timestamp": "2024-01-15T10:30:00Z",
      "thermalValue": 1,
      "batteryLevel": 75.5,
      "memoryUsage": 60.0
    }
  ],
  "page": 1,
  "page_size": 20,
  "total_count": 45,
  "total_pages": 3,
  "has_next_page": true,
  "has_previous_page": false
}
```

**Error Response (400 Bad Request):**

```json
{
  "error": "Page size must be between 1 and 100.",
  "field": "pageSize",
  "code": "INVALID_RANGE"
}
```

### GET /api/vitals/analytics

Get analytics data including rolling averages.

**Success Response (200 OK):**

```json
{
  "rolling_window_logs": 100,
  "average_thermal": 1.5,
  "average_battery": 65.2,
  "average_memory": 55.8,
  "min_thermal": 0,
  "max_thermal": 3,
  "min_battery": 20.0,
  "max_battery": 100.0,
  "min_memory": 30.0,
  "max_memory": 85.0,
  "trend_thermal": "increasing",
  "trend_battery": "decreasing",
  "trend_memory": "stable",
  "total_logs": 250
}
```

**Analytics Details:**

- **Rolling Window**: Last 100 logs (most recent first)
- **Trends**: Calculated by comparing recent half vs older half of rolling window
  - `increasing`: Recent average > older average
  - `decreasing`: Recent average < older average
  - `stable`: Recent average ≈ older average
  - `insufficient_data`: Less than 2 logs available

## Error Response Format

All error responses follow a standardized format:

```json
{
  "error": "Human-readable error message",
  "field": "field_name",
  "code": "ERROR_CODE"
}
```

**Error Codes:**

- `INVALID_REQUEST`: Request body is null or malformed
- `MISSING_FIELD`: Required field is missing or empty
- `INVALID_RANGE`: Value is outside allowed range
- `INVALID_TIMESTAMP`: Timestamp is invalid or in the future
- `RATE_LIMIT_EXCEEDED`: Too many requests (429 Too Many Requests)

### Rate Limiting (429 Too Many Requests)

The API is rate-limited per client IP using a fixed window. When the limit is exceeded, the server returns **429 Too Many Requests** with the same JSON shape:

```json
{
  "error": "Too many requests. Please try again later.",
  "field": null,
  "code": "RATE_LIMIT_EXCEEDED"
}
```

Defaults: 100 requests per 60 seconds per IP. Configurable via `appsettings.json` (see Configuration).

## Database Schema

### DeviceVital Table

| Column       | Type     | Constraints                 |
| ------------ | -------- | --------------------------- |
| Id           | int      | Primary Key, Auto-increment |
| DeviceId     | string   | Required                    |
| Timestamp    | DateTime | Required                    |
| ThermalValue | int      | Required, 0-3               |
| BatteryLevel | double   | Required, 0-100             |
| MemoryUsage  | double   | Required, 0-100             |

**Indexes:**

- Index on `Timestamp` (descending) for efficient pagination queries

## Testing

### Run Unit Tests

```bash
cd device_vital_monitor_backend.Tests
dotnet test
```

### Test Coverage

The test suite covers:

- ✅ Data validation (all required fields, ranges, boundaries)
- ✅ Rolling average calculation logic
- ✅ Pagination logic and defaults
- ✅ Analytics calculations (min, max, averages, trends)
- ✅ Error response format
- ✅ Boundary value testing (0, 3 for thermal; 0, 100 for battery/memory)
- ✅ Timestamp validation (5-minute clock skew tolerance)

### Test Files

- `VitalsControllerTests.cs`: Tests API endpoints, validation, error handling
- `VitalServiceTests.cs`: Tests business logic, rolling averages, pagination

## Configuration

### appsettings.json

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=app.db"
  },
  "RateLimiting": {
    "PermitLimit": 100,
    "WindowSeconds": 60
  }
}
```

- **RateLimiting:PermitLimit**: Maximum requests allowed per client IP per window (default: 100).
- **RateLimiting:WindowSeconds**: Window duration in seconds (default: 60).

### Development Settings

`appsettings.Development.json` contains development-specific logging configurations.

## CORS Configuration

CORS is configured to allow requests from the Flutter app:

- **Android Emulator**: Use `http://10.0.2.2:5265` as the base URL
- **iOS Simulator**: Use `http://localhost:5265` as the base URL
- **Physical Devices**: Use your machine's IP address (e.g., `http://192.168.1.100:5265`)

## Troubleshooting

### Port Already in Use

Change the port in `Properties/launchSettings.json` or use:

```bash
dotnet run --urls "http://localhost:5000"
```

### Database Issues

- Delete `app.db` and restart the application to recreate the database
- Ensure write permissions in the backend directory
- Check that SQLite is properly installed (included with .NET)

### CORS Errors

- Verify CORS is enabled in `Program.cs`
- Check that the Flutter app is using the correct base URL for the platform
- Ensure the backend is running and accessible

## Design Decisions

Key design decisions are documented in the root `DECISIONS.md` file. Notable decisions:

- **Pagination**: Default `pageSize` is 20 (not 100) for better UX with scroll-to-load-more
- **Rolling Average**: Uses last 100 logs (most recent first)
- **Timestamp Validation**: Allows 5-minute clock skew tolerance
- **Error Format**: Standardized error responses with field and code for better client handling
- **Rate Limiting**: Per-IP fixed window (default 100 requests per 60 seconds); 429 uses same error format as other API errors

## Project Structure

```
device_vital_monitor_backend/
├── Controllers/
│   └── VitalsController.cs
├── Services/
│   ├── IVitalService.cs
│   └── VitalService.cs
├── Repositories/
│   ├── IDeviceVitalRepository.cs
│   └── DeviceVitalRepository.cs
├── Models/
│   └── DeviceVital.cs
├── DTOs/
│   ├── VitalLogRequest.cs
│   ├── PagedResponse.cs
│   ├── AnalyticsResult.cs
│   └── ErrorResponse.cs
├── Data/
│   └── VitalContext.cs
├── Middleware/
│   └── RequestLoggingMiddleware.cs
├── Program.cs
├── appsettings.json
└── README.md
```

## Dependencies

- **Microsoft.AspNetCore.OpenApi**: OpenAPI/Swagger support
- **Microsoft.EntityFrameworkCore.Sqlite**: SQLite database provider
- **Microsoft.EntityFrameworkCore.Design**: EF Core design-time tools

## License

This project is part of a take-home assignment.
