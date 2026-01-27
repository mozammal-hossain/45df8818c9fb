using device_vital_monitor_backend.DTOs;
using device_vital_monitor_backend.Models;

namespace device_vital_monitor_backend.Services
{
    public interface IVitalService
    {
        Task<(bool, string?)> LogVitalAsync(VitalLogRequest request);
        Task<IEnumerable<DeviceVital>> GetHistoryAsync();
        Task<AnalyticsResult> GetAnalyticsAsync();
    }
}
