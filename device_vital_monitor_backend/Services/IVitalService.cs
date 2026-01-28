using device_vital_monitor_backend.DTOs;
using device_vital_monitor_backend.Models;

namespace device_vital_monitor_backend.Services
{
    public interface IVitalService
    {
        Task<DeviceVital> LogVitalAsync(DeviceVital vital);
        Task<PagedResponse<DeviceVital>> GetHistoryAsync(int page, int pageSize);
        Task<AnalyticsResult> GetAnalyticsAsync();
    }
}
