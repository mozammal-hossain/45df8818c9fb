using device_vital_monitor_backend.DTOs;
using device_vital_monitor_backend.Models;
using device_vital_monitor_backend.Services;
using Microsoft.AspNetCore.Mvc;

namespace device_vital_monitor_backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class VitalsController : ControllerBase
    {
        private readonly IVitalService _vitalService;

        public VitalsController(IVitalService vitalService)
        {
            _vitalService = vitalService;
        }

        [HttpPost]
        public async Task<IActionResult> LogVital([FromBody] VitalLogRequest request)
        {
            if (request == null)
            {
                return BadRequest(new ErrorResponse("Invalid request.", null, "INVALID_REQUEST"));
            }

            // Validate required fields
            if (string.IsNullOrWhiteSpace(request.DeviceId))
            {
                return BadRequest(new ErrorResponse("Device ID is required.", "device_id", "MISSING_FIELD"));
            }

            if (!request.Timestamp.HasValue)
            {
                return BadRequest(new ErrorResponse("Timestamp is required.", "timestamp", "MISSING_FIELD"));
            }

            if (!request.ThermalValue.HasValue)
            {
                return BadRequest(new ErrorResponse("Thermal value is required.", "thermal_value", "MISSING_FIELD"));
            }

            if (!request.BatteryLevel.HasValue)
            {
                return BadRequest(new ErrorResponse("Battery level is required.", "battery_level", "MISSING_FIELD"));
            }

            if (!request.MemoryUsage.HasValue)
            {
                return BadRequest(new ErrorResponse("Memory usage is required.", "memory_usage", "MISSING_FIELD"));
            }

            // Validate value ranges
            if (request.ThermalValue.Value < 0 || request.ThermalValue.Value > 3)
            {
                return BadRequest(new ErrorResponse("Thermal value must be between 0 and 3.", "thermal_value", "INVALID_RANGE"));
            }

            if (request.BatteryLevel.Value < 0 || request.BatteryLevel.Value > 100)
            {
                return BadRequest(new ErrorResponse("Battery level must be between 0 and 100.", "battery_level", "INVALID_RANGE"));
            }

            if (request.MemoryUsage.Value < 0 || request.MemoryUsage.Value > 100)
            {
                return BadRequest(new ErrorResponse("Memory usage must be between 0 and 100.", "memory_usage", "INVALID_RANGE"));
            }

            if (request.Timestamp.Value > DateTime.UtcNow.AddMinutes(5)) // Allow 5 mins clock skew
            {
                return BadRequest(new ErrorResponse("Timestamp cannot be in the future.", "timestamp", "INVALID_TIMESTAMP"));
            }

            // API contract: timestamps are UTC. Normalize to UTC for storage.
            var utcTimestamp = request.Timestamp.Value.Kind == DateTimeKind.Utc
                ? request.Timestamp.Value
                : DateTime.SpecifyKind(request.Timestamp.Value, DateTimeKind.Utc);

            // Convert DTO to model
            var vital = new DeviceVital
            {
                DeviceId = request.DeviceId,
                Timestamp = utcTimestamp,
                ThermalValue = request.ThermalValue.Value,
                BatteryLevel = request.BatteryLevel.Value,
                MemoryUsage = request.MemoryUsage.Value
            };

            var createdVital = await _vitalService.LogVitalAsync(vital);

            return Created($"/api/vitals/{createdVital.Id}", createdVital);
        }

        [HttpGet]
        public async Task<IActionResult> GetHistory([FromQuery] int page = 1, [FromQuery] int? pageSize = null)
        {
            // Default to 20 entries per DECISIONS.md for scroll-to-load-more UX
            var effectivePageSize = pageSize ?? 20;

            if (page < 1)
            {
                return BadRequest(new ErrorResponse("Page must be greater than or equal to 1.", "page", "INVALID_RANGE"));
            }

            if (effectivePageSize < 1 || effectivePageSize > 100)
            {
                return BadRequest(new ErrorResponse("Page size must be between 1 and 100.", "pageSize", "INVALID_RANGE"));
            }

            var history = await _vitalService.GetHistoryAsync(page, effectivePageSize);
            return Ok(history);
        }

        [HttpGet("analytics")]
        public async Task<IActionResult> GetAnalytics()
        {
            var analytics = await _vitalService.GetAnalyticsAsync();
            return Ok(analytics);
        }
    }
}
