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

        public async Task<PagedResponse<DeviceVital>> GetHistoryAsync(int page, int pageSize)
        {
            var (items, totalCount) = await _repo.GetPagedAsync(page, pageSize);

            var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);

            return new PagedResponse<DeviceVital>
            {
                Data = items,
                Page = page,
                PageSize = pageSize,
                TotalCount = totalCount,
                TotalPages = totalPages,
                HasNextPage = page < totalPages,
                HasPreviousPage = page > 1
            };
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
                    MinThermal = 0,
                    MaxThermal = 0,
                    MinBattery = 0,
                    MaxBattery = 0,
                    MinMemory = 0,
                    MaxMemory = 0,
                    TrendThermal = "insufficient_data",
                    TrendBattery = "insufficient_data",
                    TrendMemory = "insufficient_data",
                    TotalLogs = 0
                };
            }

            var thermalValues = rollingVitals.Select(v => v.ThermalValue).ToList();
            var batteryValues = rollingVitals.Select(v => v.BatteryLevel).ToList();
            var memoryValues = rollingVitals.Select(v => v.MemoryUsage).ToList();

            (string trendThermal, string trendBattery, string trendMemory) = ComputeTrends(rollingVitals);

            return new AnalyticsResult
            {
                RollingWindowLogs = rollingVitals.Count,
                AverageThermal = rollingVitals.Average(v => v.ThermalValue),
                AverageBattery = rollingVitals.Average(v => v.BatteryLevel),
                AverageMemory = rollingVitals.Average(v => v.MemoryUsage),
                MinThermal = thermalValues.Min(),
                MaxThermal = thermalValues.Max(),
                MinBattery = batteryValues.Min(),
                MaxBattery = batteryValues.Max(),
                MinMemory = memoryValues.Min(),
                MaxMemory = memoryValues.Max(),
                TrendThermal = trendThermal,
                TrendBattery = trendBattery,
                TrendMemory = trendMemory,
                TotalLogs = totalCount
            };
        }

        /// <summary>
        /// Computes trend by comparing recent half (newest) vs older half of the rolling window.
        /// List is ordered newest first (index 0 = most recent).
        /// </summary>
        private static (string thermal, string battery, string memory) ComputeTrends(List<DeviceVital> vitals)
        {
            if (vitals.Count < 2)
            {
                return ("insufficient_data", "insufficient_data", "insufficient_data");
            }

            int half = vitals.Count / 2;
            var recent = vitals.Take(half).ToList();
            var older = vitals.Skip(half).ToList();

            string Trend(double recentAvg, double olderAvg)
            {
                const double epsilon = 0.0001;
                var diff = recentAvg - olderAvg;
                if (Math.Abs(diff) < epsilon) return "stable";
                return diff > 0 ? "increasing" : "decreasing";
            }

            var trendThermal = Trend(recent.Average(v => v.ThermalValue), older.Average(v => v.ThermalValue));
            var trendBattery = Trend(recent.Average(v => v.BatteryLevel), older.Average(v => v.BatteryLevel));
            var trendMemory = Trend(recent.Average(v => v.MemoryUsage), older.Average(v => v.MemoryUsage));

            return (trendThermal, trendBattery, trendMemory);
        }
    }
}
