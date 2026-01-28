using System;
using System.ComponentModel.DataAnnotations;

namespace device_vital_monitor_backend.Models
{
    public class DeviceVital
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string DeviceId { get; set; } = string.Empty;

        [Required]
        public DateTime Timestamp { get; set; }

        [Required]
        public int ThermalValue { get; set; }

        [Required]
        public double BatteryLevel { get; set; }

        [Required]
        public double MemoryUsage { get; set; }
    }
}
