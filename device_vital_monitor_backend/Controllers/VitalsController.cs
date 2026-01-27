using device_vital_monitor_backend.DTOs;
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

            var (success, errorMessage) = await _vitalService.LogVitalAsync(request);

            if (!success)
            {
                return BadRequest(errorMessage);
            }

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
