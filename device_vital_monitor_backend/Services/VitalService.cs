using device_vital_monitor_backend.Data;
using device_vital_monitor_backend.DTOs;
using device_vital_monitor_backend.Models;
using Microsoft.EntityFrameworkCore;

namespace device_vital_monitor_backend.Services
{
    public class VitalService : IVitalService
    {
        private readonly VitalContext _context;

        public VitalService(VitalContext context)
        {
            _context = context;
        }

        public async Task<(bool, string?)> LogVitalAsync(VitalLogRequest request)
        {
            if (request == null)
                return (false, "Request body is required.");

            // Treat null as missing required field
            if (string.IsNullOrWhiteSpace(request.DeviceId))
                return (false, "Device ID is required.");

            if (!request.Timestamp.HasValue)
                return (false, "Timestamp is required.");

            if (!request.ThermalValue.HasValue)
                return (false, "Thermal value is required.");

            if (!request.BatteryLevel.HasValue)
                return (false, "Battery level is required.");

            if (!request.MemoryUsage.HasValue)
                return (false, "Memory usage is required.");

            // When value is present, validate range
            if (request.ThermalValue.Value < 0 || request.ThermalValue.Value > 3)
                return (false, "Thermal value must be between 0 and 3.");

            if (request.BatteryLevel.Value < 0 || request.BatteryLevel.Value > 100)
                return (false, "Battery level must be between 0 and 100.");

            if (request.MemoryUsage.Value < 0 || request.MemoryUsage.Value > 100)
                return (false, "Memory usage must be between 0 and 100.");

            if (request.Timestamp.Value > DateTime.UtcNow.AddMinutes(5)) // Allow 5 mins clock skew
                return (false, "Timestamp cannot be in the future.");

            var vital = new DeviceVital
            {
                DeviceId = request.DeviceId,
                Timestamp = request.Timestamp.Value,
                ThermalValue = request.ThermalValue.Value,
                BatteryLevel = request.BatteryLevel.Value,
                MemoryUsage = request.MemoryUsage.Value
            };

            _context.DeviceVitals.Add(vital);
            await _context.SaveChangesAsync();

            return (true, null);
        }

        public async Task<IEnumerable<DeviceVital>> GetHistoryAsync()
        {
            return await _context.DeviceVitals
                .OrderByDescending(v => v.Timestamp)
                .Take(100)
                .ToListAsync();
        }

        public const int RollingWindowSize = 100;

        public async Task<AnalyticsResult> GetAnalyticsAsync()
        {
            var totalCount = await _context.DeviceVitals.CountAsync();
            var rollingVitals = await _context.DeviceVitals
                .OrderByDescending(v => v.Timestamp)
                .Take(RollingWindowSize)
                .ToListAsync();

            if (rollingVitals.Count == 0)
            {
                return new AnalyticsResult
                {
                    RollingWindowLogs = RollingWindowSize,
                    AverageThermal = 0,
                    AverageBattery = 0,
                    AverageMemory = 0,
                    TotalLogs = 0
                };
            }

            return new AnalyticsResult
            {
                RollingWindowLogs = rollingVitals.Count,
                AverageThermal = rollingVitals.Average(v => v.ThermalValue),
                AverageBattery = rollingVitals.Average(v => v.BatteryLevel),
                AverageMemory = rollingVitals.Average(v => v.MemoryUsage),
                TotalLogs = totalCount
            };
        }
    }
}
