using device_vital_monitor_backend.Models;

namespace device_vital_monitor_backend.Repositories
{
    public interface IDeviceVitalRepository
    {
        Task<DeviceVital> AddAsync(DeviceVital vital, CancellationToken ct = default);
        Task<int> CountAsync(CancellationToken ct = default);
        Task<List<DeviceVital>> GetLatestAsync(int count, CancellationToken ct = default);
    }
}

