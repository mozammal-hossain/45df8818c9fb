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

        [JsonPropertyName("min_thermal")]
        public int MinThermal { get; set; }

        [JsonPropertyName("max_thermal")]
        public int MaxThermal { get; set; }

        [JsonPropertyName("min_battery")]
        public double MinBattery { get; set; }

        [JsonPropertyName("max_battery")]
        public double MaxBattery { get; set; }

        [JsonPropertyName("min_memory")]
        public double MinMemory { get; set; }

        [JsonPropertyName("max_memory")]
        public double MaxMemory { get; set; }

        [JsonPropertyName("trend_thermal")]
        public string TrendThermal { get; set; } = "insufficient_data";

        [JsonPropertyName("trend_battery")]
        public string TrendBattery { get; set; } = "insufficient_data";

        [JsonPropertyName("trend_memory")]
        public string TrendMemory { get; set; } = "insufficient_data";

        [JsonPropertyName("total_logs")]
        public int TotalLogs { get; set; }
    }
}
