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
                return BadRequest("Invalid request.");
            }

            // Validate required fields
            if (string.IsNullOrWhiteSpace(request.DeviceId))
            {
                return BadRequest("Device ID is required.");
            }

            if (!request.Timestamp.HasValue)
            {
                return BadRequest("Timestamp is required.");
            }

            if (!request.ThermalValue.HasValue)
            {
                return BadRequest("Thermal value is required.");
            }

            if (!request.BatteryLevel.HasValue)
            {
                return BadRequest("Battery level is required.");
            }

            if (!request.MemoryUsage.HasValue)
            {
                return BadRequest("Memory usage is required.");
            }

            // Validate value ranges
            if (request.ThermalValue.Value < 0 || request.ThermalValue.Value > 3)
            {
                return BadRequest("Thermal value must be between 0 and 3.");
            }

            if (request.BatteryLevel.Value < 0 || request.BatteryLevel.Value > 100)
            {
                return BadRequest("Battery level must be between 0 and 100.");
            }

            if (request.MemoryUsage.Value < 0 || request.MemoryUsage.Value > 100)
            {
                return BadRequest("Memory usage must be between 0 and 100.");
            }

            if (request.Timestamp.Value > DateTime.UtcNow.AddMinutes(5)) // Allow 5 mins clock skew
            {
                return BadRequest("Timestamp cannot be in the future.");
            }

            // Convert DTO to model
            var vital = new DeviceVital
            {
                DeviceId = request.DeviceId,
                Timestamp = request.Timestamp.Value,
                ThermalValue = request.ThermalValue.Value,
                BatteryLevel = request.BatteryLevel.Value,
                MemoryUsage = request.MemoryUsage.Value
            };

            await _vitalService.LogVitalAsync(vital);

            return Ok(new { message = "Vital logged successfully.", timestamp = DateTime.UtcNow });
        }

        [HttpGet]
        public async Task<IActionResult> GetHistory()
        {
            var history = await _vitalService.GetHistoryAsync();
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
