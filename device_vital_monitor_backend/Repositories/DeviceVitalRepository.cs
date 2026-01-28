using device_vital_monitor_backend.Data;
using device_vital_monitor_backend.Models;
using Microsoft.EntityFrameworkCore;

namespace device_vital_monitor_backend.Repositories
{
    public class DeviceVitalRepository : IDeviceVitalRepository
    {
        private readonly VitalContext _context;

        public DeviceVitalRepository(VitalContext context)
        {
            _context = context;
        }

        public async Task<DeviceVital> AddAsync(DeviceVital vital, CancellationToken ct = default)
        {
            _context.DeviceVitals.Add(vital);
            await _context.SaveChangesAsync(ct);
            return vital;
        }

        public Task<int> CountAsync(CancellationToken ct = default)
        {
            return _context.DeviceVitals.CountAsync(ct);
        }

        public Task<List<DeviceVital>> GetLatestAsync(int count, CancellationToken ct = default)
        {
            return _context.DeviceVitals
                .AsNoTracking()
                .OrderByDescending(v => v.Timestamp)
                .Take(count)
                .ToListAsync(ct);
        }

        public async Task<(List<DeviceVital> items, int totalCount)> GetPagedAsync(int page, int pageSize, CancellationToken ct = default)
        {
            var query = _context.DeviceVitals
                .AsNoTracking()
                .OrderByDescending(v => v.Timestamp);

            var totalCount = await query.CountAsync(ct);
            var items = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync(ct);

            return (items, totalCount);
        }
    }
}

