using System.Text.Json.Serialization;

namespace device_vital_monitor_backend.DTOs
{
    public class AnalyticsResult
    {
        [JsonPropertyName("rolling_window_logs")]
        public int RollingWindowLogs { get; set; }

        [JsonPropertyName("average_thermal")]
        public double AverageThermal { get; set; }

        [JsonPropertyName("average_battery")]
        public double AverageBattery { get; set; }

        [JsonPropertyName("average_memory")]
        public double AverageMemory { get; set; }

        [JsonPropertyName("total_logs")]
        public int TotalLogs { get; set; }
    }
}
