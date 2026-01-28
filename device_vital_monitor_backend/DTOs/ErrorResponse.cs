using System.Text.Json.Serialization;

namespace device_vital_monitor_backend.DTOs
{
    public class ErrorResponse
    {
        [JsonPropertyName("error")]
        public string Error { get; set; } = string.Empty;

        [JsonPropertyName("field")]
        public string? Field { get; set; }

        [JsonPropertyName("code")]
        public string? Code { get; set; }

        public ErrorResponse(string error, string? field = null, string? code = null)
        {
            Error = error;
            Field = field;
            Code = code;
        }
    }
}
