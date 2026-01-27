using device_vital_monitor_backend.Models;
using Microsoft.EntityFrameworkCore;

namespace device_vital_monitor_backend.Data
{
    public class VitalContext : DbContext
    {
        public VitalContext(DbContextOptions<VitalContext> options) : base(options)
        {
        }

        public DbSet<DeviceVital> DeviceVitals { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            // Additional configuration if needed
        }
    }
}
