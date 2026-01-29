using System;
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
            // Timestamps are stored in UTC; SQLite does not persist Kind, so materialize as UTC.
            modelBuilder.Entity<DeviceVital>()
                .Property(e => e.Timestamp)
                .HasConversion(
                    v => v,
                    v => DateTime.SpecifyKind(v, DateTimeKind.Utc));
        }
    }
}
