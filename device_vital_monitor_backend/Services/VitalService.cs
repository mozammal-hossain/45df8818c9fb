using device_vital_monitor_backend.DTOs;
using device_vital_monitor_backend.Models;
using device_vital_monitor_backend.Repositories;

namespace device_vital_monitor_backend.Services
{
    public class VitalService : IVitalService
    {
        private readonly IDeviceVitalRepository _repo;

        public VitalService(IDeviceVitalRepository repo)
        {
            _repo = repo;
        }

        public async Task<DeviceVital> LogVitalAsync(DeviceVital vital)
        {
            return await _repo.AddAsync(vital);
        }

        public async Task<IEnumerable<DeviceVital>> GetHistoryAsync()
        {
            return await _repo.GetLatestAsync(100);
        }

        public const int RollingWindowSize = 100;

        public async Task<AnalyticsResult> GetAnalyticsAsync()
        {
            var totalCount = await _repo.CountAsync();
            var rollingVitals = await _repo.GetLatestAsync(RollingWindowSize);

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
