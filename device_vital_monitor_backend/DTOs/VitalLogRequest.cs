using System.Text.Json.Serialization;

namespace device_vital_monitor_backend.DTOs
{
    public class VitalLogRequest
    {
        [JsonPropertyName("device_id")]
        public string? DeviceId { get; set; }

        [JsonPropertyName("timestamp")]
        public DateTime? Timestamp { get; set; }

        [JsonPropertyName("thermal_value")]
        public int? ThermalValue { get; set; }

        [JsonPropertyName("battery_level")]
        public double? BatteryLevel { get; set; }

        [JsonPropertyName("memory_usage")]
        public double? MemoryUsage { get; set; }
    }
}
